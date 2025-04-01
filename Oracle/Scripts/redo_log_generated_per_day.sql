select trunc(completion_time) rundate,
       count(*)
       logswitch,
       round((sum(blocks*block_size)/1024/1024)) "REDO PER DAY (MB)"
from v$archived_log
group by trunc(completion_time)
order by 1 desc;