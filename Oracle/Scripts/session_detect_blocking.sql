create table t1 (id number);
insert into t1 values(1);
insert into t1 values(2);
commit;
--update t1 set id=10 where id=1;
--update t1 set id=20 where id=2;

select * from v$mystat;

select sid,
       serial#,
       status,
       username,
       osuser,
       program,
       blocking_session blocking,
       event,
       seconds_in_wait
from   v$session
where  blocking_session is not null;

select waiting_session,
       holding_session
from   dba_waiters;

select * from dba_blockers;

set linesize 200
@$ORACLE_HOME/rdbms/admin/utllockt.sql

select c.owner,
       c.object_name,
       c.object_type,
       b.sid,
       b.serial#,
       b.status,
       b.osuser,
       b.machine
from   v$locked_object a ,
       v$session b,
       dba_objects c
where  b.sid = a.session_id
and    a.object_id = c.object_id;
