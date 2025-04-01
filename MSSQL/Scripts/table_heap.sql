WITH heap as (
	SELECT o.object_id
		  ,schemaname = OBJECT_SCHEMA_NAME(o.object_id)
		  ,tablename = o.NAME
	FROM sys.objects o
	INNER JOIN sys.indexes i ON i.OBJECT_ID = o.OBJECT_ID
	-- tables that are heaps without any nonclustered indexes
	WHERE o.type = 'U'
	AND o.OBJECT_ID NOT IN (SELECT OBJECT_ID
							FROM sys.indexes
							WHERE index_id > 0)
)
SELECT
    OBJECT_NAME(ps.object_id) as TableName,
    i.name as IndexName,
    ps.index_type_desc,
    ps.page_count,
    ps.avg_fragmentation_in_percent,
    ps.forwarded_record_count
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, 'LIMITED') AS ps
INNER JOIN sys.indexes AS i
    ON ps.OBJECT_ID = i.OBJECT_ID  
    AND ps.index_id = i.index_id
WHERE type = 0