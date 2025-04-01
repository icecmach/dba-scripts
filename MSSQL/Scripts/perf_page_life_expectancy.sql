SELECT *
FROM sys.dm_os_performance_counters
WHERE [counter_name] = 'Page life expectancy';

SELECT object_name, (cntr_value/1024/1024) as 'Total Server Memory (GB)'
  FROM sys.dm_os_performance_counters
  WHERE counter_name = 'Total Server Memory (KB)';

SELECT DB_NAME(database_id) AS [Database]
		,(COUNT(*) * 8)/1024 AS [MB_Per_DB] 
		, COUNT(*) AS [Number_Of_Pages]
		, page_type
FROM sys.dm_os_buffer_descriptors 
WHERE database_id <> 32767 --Resource_DB
AND (page_type = 'INDEX_PAGE'
OR page_type = 'DATA_PAGE')
GROUP BY database_id, page_type
ORDER BY database_id, page_type;

SELECT [object_name], [counter_name], [cntr_value] AS Page_Life_Expectency
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Manager%' AND [counter_name] = 'Page life expectancy';



--(DataCacheSizeInGB/4GB*300)
SELECT (COUNT(*) * 8.0) / 1024 / 1024 / 4 * 300 AS SuggestedThreshold
FROM sys.dm_os_buffer_descriptors;

--The Data Cache is the largest portion of SQL Server Buffer Pool, the main memory consumer in SQL Server.
--Data Cache is the place where every 8 KB page is put into before reading and is the place where the page is written to before being put on disk.
SELECT count(*)*8/1024/1024 AS 'Data Cache Size(GB)'
,CASE database_id
WHEN 32767 THEN 'RESOURCEDB'
ELSE db_name(database_id)
END AS 'DatabaseName'
FROM sys.dm_os_buffer_descriptors
GROUP BY db_name(database_id) ,database_id
ORDER BY 'Data Cache Size(GB)' DESC;