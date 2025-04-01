SELECT db_name(database_id) + '.' + SCHEMA_NAME(objects.schema_id) + '.' + objects.name AS Table_name,
    indexes.name AS Index_name,
    us.last_user_seek,
    us.last_user_scan,
    us.last_user_lookup
FROM sys.dm_db_index_usage_stats us
INNER JOIN sys.objects ON us.OBJECT_ID = objects.OBJECT_ID
INNER JOIN sys.indexes ON indexes.index_id = us.index_id AND us.OBJECT_ID = indexes.OBJECT_ID
WHERE indexes.is_primary_key = 0 -- This condition excludes primary key constarint
AND indexes. is_unique = 0 -- This condition excludes unique key constarint
AND us.user_updates <> 0 -- This line excludes indexes SQL Server hasn’t done any work with
AND us.user_lookups = 0
AND us.user_seeks = 0
AND us.user_scans = 0
AND us.database_id > 4
AND indexes.name IS NOT NULL
ORDER BY 1, us.user_updates DESC