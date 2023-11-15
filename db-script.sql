define myval = '&1'
spool /home/opc/&myval
select systimestamp from dual;
declare
l_mins_to_exit number := 0.1;
l_start   date;
l_minutes number;
begin
    l_start := sysdate;
    loop
        insert into test (datum) values (sysdate);
        l_minutes := (sysdate - l_start) * 24 * 60;
        exit when l_minutes > l_mins_to_exit;
    end loop;
    rollback;
end;
/
select systimestamp from dual;
spool off
exit;
