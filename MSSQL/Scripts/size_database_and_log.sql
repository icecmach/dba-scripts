EXEC sp_databases;

select total_log_size_in_bytes/1024/1024 total_log_size_in_mbytes,
       used_log_space_in_bytes/1024/1024 used_log_space_in_mbytes,
       used_log_space_in_percent,
       log_space_in_bytes_since_last_backup/1024/1024 log_space_in_mbytes_since_last_backup
from sys.dm_db_log_space_usage