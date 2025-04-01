select 'ALTER SYSTEM KILL SESSION '''||SID||','||SERIAL#||''' IMMEDIATE;' FROM V$SESSION WHERE MACHINE='';
select 'ALTER SYSTEM KILL SESSION '''||SID||','||SERIAL#||''' IMMEDIATE;' FROM V$SESSION WHERE USERNAME!='SYS';

ALTER SYSTEM KILL SESSION '15,11839' IMMEDIATE;
ALTER SYSTEM KILL SESSION '16,65345' IMMEDIATE;
ALTER SYSTEM KILL SESSION '136,13597' IMMEDIATE;

SELECT s.username,
    s.osuser,
    s.sid,
    s.serial#,
    p.spid,
    s.status,
    s.machine,
    s.program,
    TO_CHAR(s.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time,
    'alter system kill session '''||s.sid||','||s.serial#||',@'||s.inst_id||''';'
FROM gv$session s
inner join gv$process p on s.paddr = p.addr
WHERE s.username='W360'
--s.status = 'ACTIVE'
and s.type <> 'BACKGROUND';

SELECT s.username,s.osuser,s.sid,s.serial#,s.status,s.machine,s.program FROM v$session s WHERE s.type <> 'BACKGROUND';
