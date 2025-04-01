select sql_id,sql_text, child_number, plan_hash_value, first_load_time, last_load_time,
outline_category, sql_profile, executions,
trunc(decode(executions, 0, 0, rows_processed/executions)) rows_avg,
trunc(decode(executions, 0, 0, fetches/executions)) fetches_avg,
trunc(decode(executions, 0, 0, disk_reads/executions)) disk_reads_avg,
trunc(decode(executions, 0, 0, buffer_gets/executions)) buffer_gets_avg,
trunc(decode(executions, 0, 0, cpu_time/executions)) cpu_time_avg,
trunc(decode(executions, 0, 0, elapsed_time/executions)) elapsed_time_avg,
trunc(decode(executions, 0, 0, application_wait_time/executions)) apwait_time_avg,
trunc(decode(executions, 0, 0, concurrency_wait_time/executions)) cwait_time_avg,
trunc(decode(executions, 0, 0, cluster_wait_time/executions)) clwait_time_avg,
trunc(decode(executions, 0, 0, user_io_wait_time/executions)) iowait_time_avg,
trunc(decode(executions, 0, 0, plsql_exec_time/executions)) plsexec_time_avg,
trunc(decode(executions, 0, 0, java_exec_time/executions)) javexec_time_avg
from v$sql
where sql_id = 'b8x5n8c6rax34'
order by sql_id, child_number;


select *
from v$sql
where sql_id = '66j8h6us7qmms'
order by sql_id, child_number;

-- Oracle 9i
select HASH_VALUE,sql_text, child_number, plan_hash_value, first_load_time, last_load_time,
outline_category, executions,
trunc(decode(executions, 0, 0, rows_processed/executions)) rows_avg,
trunc(decode(executions, 0, 0, fetches/executions)) fetches_avg,
trunc(decode(executions, 0, 0, disk_reads/executions)) disk_reads_avg,
trunc(decode(executions, 0, 0, buffer_gets/executions)) buffer_gets_avg,
trunc(decode(executions, 0, 0, (cpu_time/executions)/1000000)) cpu_time_avg,
trunc(decode(executions, 0, 0, (elapsed_time/executions)/1000000)) elapsed_time_avg
from v$sql
where HASH_VALUE = '2814456072'
order by HASH_VALUE, child_number;