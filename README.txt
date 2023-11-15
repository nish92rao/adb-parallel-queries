Step 1:
Create a Linux compute instance. For example, Standard.E3.Flex - 1 OCPU, 16 GB RAM

Step 2:
Install Oracle Instant Client on this compute instance. Execute the following:
	sudo dnf install oracle-instantclient-release-el8 -y
	sudo dnf install oracle-instantclient-sqlplus -y

Step 3:
Copy the ADB Wallet file (e.g. Wallet_test.zip) to the compute instance. Then, unzip this wallet in a separate directory (e.g. /home/opc/adbwallet)
	mkdir ~/adbwallet
	mv Wallet_test.zip ~/adbwallet/
	cd ~/adbwallet
	unzip Wallet_test.zip
	rm Wallet_test.zip

Step 4:
Set the TNS_ADMIN value (adbwallet directory path) in sqlnet.ora and TNS_ADMIN environment variable

Edit the sqlnet.ora file:
	vim sqlnet.ora
Contents of the file as follows:
	WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY="/home/opc/adbwallet")))
	SSL_SERVER_DN_MATCH=yes

Edit the .bashrc file, and add the "export" line after the "# User specific aliases..." line:
	vim ~/.bashrc
		# User specific aliases and functions
		export TNS_ADMIN=/home/opc/adwwallet
	source ~/.bashrc

Step 5:
Create a SQL script for the query you want to run
	vim query.sql
Set the contents as follows, plugging in your query where shown (remove the comments characters --):
	define myval = '&1'
	spool /home/opc/&myval
	select systimestamp from dual;
	--Put your query here - START
	--
	--Put your query here - END
	select systimestamp from dual;
	spool off
	exit;
	
Step 6:
Assuming you want to run the same query multiple times (e.g. 10 times), create a Shell script file as follows:
	vim loop.sh
Contents of the file as follows:
	#!/bin/bash
	for i in {1..10}
	do
	   sqlplus admin/password@test_high @/home/opc/query.sql $i &
	done

=> admin is ADB admin user. Replace with your user accordingly.
=> password is ADB admin user password. Replace with your user password accordingly.
=> test_high is the ADB service name found in tnsnames.ora. Replace with your desired service name accordingly.
=> 1..10 loops 10 times. Replace with your desired count accordingly.
=> This will start all iterations of the queries parallely in separate sqlplus sessions (because the command ends in '&', so it sets it as a background process)

Step 7:
Make the shell script file executable and run it:
	chmod +x loop.sh
	./loop.sh

Step 8: View the start & end timestamps for each execution in the output files:
	cat 1.lst
	cat 2.lst
	...
	etc..


=> If you want to execute multiple different queries parallely, create multiple script files as shown in Step 5.
=> Then, in Step 6, you can simply list the sqlplus commands instead of running it in a loop:
	sqlplus admin/password@test_high @/home/opc/query1.sql query1 &
	sqlplus admin/password@test_high @/home/opc/query2.sql query2 &
	sqlplus admin/password@test_high @/home/opc/query3.sql query3 &
	...
	etc..