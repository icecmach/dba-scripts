select * from v$sga;

select name, decode(unit,'bytes',decode(value,0,0,(value/1024/1024/1024)),value) value, unit
from v$pgastat;

select * from v$sga_target_advice;

select * from v$pga_target_advice;

SELECT
   ROUND(pga_target_for_estimate /(1024*1024)) c1,
   estd_pga_cache_hit_percentage         c2,
   estd_overalloc_count                  c3
FROM
   v$pga_target_advice;
   
SELECT
   low_optimal_size/1024 "Low(K)",
   (high_optimal_size+1)/1024 "High(K)",
   estd_optimal_executions "Optimal",
   estd_onepass_executions "One Pass",
   estd_multipasses_executions "Multi-Pass"
FROM
   v$pga_target_advice_histogram
WHERE
   pga_target_factor = 2
AND
   estd_total_executions != 0
ORDER BY
   1;

select * from v$memory_target_advice;

select resource_name, current_utilization, max_utilization, limit_value
from v$resource_limit
where resource_name in ('sessions', 'processes');

SELECT 202*(2048576+P1.VALUE+P2.VALUE)/(1024*1024) YOU_NEED_PGA_MB
FROM V$PARAMETER P1, V$PARAMETER P2
WHERE P1.NAME = 'sort_area_size'
AND P2.NAME = 'hash_area_size';

-- check for all session
select name, value
from v$statname n, v$sesstat t
where n.statistic# = t.statistic#
and t.sid = ( select sid from v$mystat where rownum = 1 )
and n.name in ( 'session pga memory', 'session pga memory max','session uga memory', 'session uga memory max');


select s.osuser osuser,s.serial# serial,se.sid,n.name,
max(se.value) maxmem
from v$sesstat se,
v$statname n
,v$session s
where n.statistic# = se.statistic#
and n.name in ('session pga memory','session pga memory max',
'session uga memory','session uga memory max')
and s.sid=se.sid
group by n.name,se.sid,s.osuser,s.serial#
order by 2
;


SELECT ROUND(SUM(pga_used_mem)/(1024*1024),2) PGA_USED_MB FROM v$process;

select ROUND(SUM(pga_max_mem)/(1024*1024),2) PGA_USED_MB FROM v$process;

-- For memory allocation total by process
SELECT ROUND(SUM(pga_used_mem)/(1024*1024),2) max,
ROUND(SUM(pga_alloc_mem)/(1024*1024),2) alloc,
ROUND(SUM(pga_used_mem)/(1024*1024),2) used,
ROUND(SUM(pga_freeable_mem)/(1024*1024),2) free,
ROUND(SUM(PGA_MAX_MEM)/(1024*1024),2) maxmem
FROM V$PROCESS;

-- Check PGA Allocation for each process
SELECT spid, program,
pga_max_mem max,
pga_alloc_mem alloc,
pga_used_mem used,
pga_freeable_mem free
FROM V$PROCESS;