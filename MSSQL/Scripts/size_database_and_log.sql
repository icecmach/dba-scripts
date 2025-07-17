EXEC sp_databases;

select total_log_size_in_bytes/1024/1024 total_log_size_in_mbytes,
       used_log_space_in_bytes/1024/1024 used_log_space_in_mbytes,
       used_log_space_in_percent,
       log_space_in_bytes_since_last_backup/1024/1024 log_space_in_mbytes_since_last_backup
from sys.dm_db_log_space_usage

WITH fs AS (
    SELECT database_id, type, size * 8.0 / 1024 AS size
    FROM sys.master_files
)
SELECT
    name,
    (SELECT SUM(size) FROM fs WHERE type = 0 AND fs.database_id = db.database_id) AS DataFileSizeMB,
    (SELECT SUM(size) FROM fs WHERE type = 1 AND fs.database_id = db.database_id) AS LogFileSizeMB
FROM sys.databases db;