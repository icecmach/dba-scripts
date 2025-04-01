-- To discover the SID and SERIAL# of a session, use the following SQL query:
SELECT a.sid,
       a.serial#,
       b.spid,
       b.pid,
       a.username,
       a.osuser,
       a.machine
FROM  v$session a, v$process b
WHERE a.username IS NOT NULL
AND   a.paddr=b.addr;

-- Find OS PID
SELECT P.SPID, P.TRACEFILE
FROM V$SESSION S, V$PROCESS P
WHERE S.PADDR = P.ADDR AND S.USERNAME = 'SCOTT';

-- Activate Event 10046 (must be sysdba)
oradebug setospid 9999;
oradebug tracefile_name;
oradebug unlimit;
oradebug event 10046 trace name context forever, level 12;

-- Event 10046
ALTER SESSION SET EVENTS '10046 TRACE NAME CONTEXT FOREVER, LEVEL 12';
ALTER SESSION SET EVENTS '10046 TRACE NAME CONTEXT OFF';

-- Event 10053
ALTER SESSION SET EVENTS '10053 TRACE NAME CONTEXT FOREVER, LEVEL 1';
ALTER SESSION SET EVENTS '10053 TRACE NAME CONTEXT OFF';

-- tkprof (event 10046)
tkprof /oracle/oracode/admin/diag/rdbms/b3p/b3p/trace/b3p_ora_44186.trc output = TKPROF_OUT_01

(Event 10046): Níveis
0 - Trace OFF
2 - Regular SQL Trace
4 - Nível 2, + Bind Variable
8 - Nível 2 + Wait Events
12 - Nível 2, + Bind Variable + Wait Events

-- Explain plan
SELECT /*+ GATHER_PLAN_STATISTICS */ COUNT(OBJECT_NAME) FROM T91 WHERE OBJECT_TYPE = 'SYNONYM';
SELECT SQL_ID, CHILD_NUMBER, SQL_TEXT FROM V$SQL WHERE SQL_TEXT LIKE '%T91%';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('fnjnr3c42v3fr', NULL, 'ALLSTATS LAST'));
