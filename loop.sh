#!/bin/bash
for i in {1..10}
do
   sqlplus admin/PaSsword123#_@test_high @/home/opc/db-script.sql $i &
done
