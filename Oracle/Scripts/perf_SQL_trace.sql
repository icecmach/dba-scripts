select p.PID,p.SPID,s.SID, s.program
from v$process p, v$session s
where s.paddr = p.addr
and s.username='';
 
-- With SQL*Plus
connect / as sysdba
oradebug setospid 9834
oradebug unlimit
oradebug event 10046 trace name context forever, level 12
oradebug event 10053 trace name context forever, level 1;
 
-- Turn off trace
oradebug event 10046 trace name context off
oradebug event 10053 trace name context off