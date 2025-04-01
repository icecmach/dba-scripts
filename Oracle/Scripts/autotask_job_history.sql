select *
from dba_autotask_job_history
where client_name = 'auto optimizer stats collection'
order by job_start_time desc