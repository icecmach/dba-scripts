select 'ALTER SYSTEM KILL SESSION '''||SID||','||SERIAL#||''' IMMEDIATE;' killcmd
from   v$session
where  SID = userenv('SID');

SELECT * FROM V$session;

select userenv('SID') from dual;