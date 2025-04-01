column stat format a30
col value format 9999999
select inst_id, statistic_name stat,  value 
from  gv$segment_statistics where object_name=upper('&tabname')
and statistic_name like '%&stat%'
order by inst_id,2;
