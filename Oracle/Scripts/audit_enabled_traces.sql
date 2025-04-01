select username,
  os_username,
  userhost,
  client_id,
  trunc(timestamp),
  count(*) failed_logins
from dba_audit_trail
where returncode=1017
and timestamp > sysdate -7
group by username,os_username,userhost, client_id,trunc(timestamp);

SELECT
  TO_CHAR(TIMESTAMP,'MM/DD HH24:MI') TIMESTAMP,
  SUBSTR(OS_USERNAME,1,20) OS_USERNAME,
  SUBSTR(USERNAME,1,20) USERNAME,
  SUBSTR(TERMINAL,1,20) TERMINAL,
  ACTION_NAME,
  RETURNCODE,
   OS_USERNAME,
   USERNAME,
   USERHOST
FROM SYS.DBA_AUDIT_SESSION
WHERE USERNAME = 'SYSTEM'
AND TIMESTAMP BETWEEN SYSDATE-1 AND SYSDATE and RETURNCODE in (1017,20008)
ORDER BY TIMESTAMP DESC;

select username, owner, obj_name, action_name
from dba_audit_trail
where obj_name like '%MONITOR%';

select event_timestamp,
       action_name,
       object_schema,
       object_name
from   unified_audit_trail
where  object_schema='SYS'
and object_name='DBMS_MONITOR'
order by event_timestamp;

select * from dba_enabled_traces;

SQL> audit execute on DBMS_MONITOR by session;

Audit reussi.

SQL> exec dbms_monitor.serv_mod_act_trace_disable('starnova','SOE:emag P74 SPEC','1752');

