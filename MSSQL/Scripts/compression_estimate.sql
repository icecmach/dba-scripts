DECLARE @tabname VARCHAR(50)
DECLARE @schema  VARCHAR(50)
DECLARE db_cursor CURSOR FOR 
	SELECT SchemaName, TableName
	FROM (SELECT TOP 10
		s.Name AS SchemaName,
		t.Name AS TableName,
		p.rows AS RowCounts,
		CAST(ROUND((SUM(a.used_pages) / 128.00), 2) AS NUMERIC(36, 2)) AS Used_MB,
		CAST(ROUND((SUM(a.total_pages) - SUM(a.used_pages)) / 128.00, 2) AS NUMERIC(36, 2)) AS Unused_MB,
		CAST(ROUND((SUM(a.total_pages) / 128.00), 2) AS NUMERIC(36, 2)) AS Total_MB
	FROM sys.tables t
	INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
	INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
	INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
	INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
	GROUP BY t.Name, s.Name, p.Rows
	ORDER BY s.Name, t.Name) A;

CREATE TABLE #tempEstimate (
    object_name sysname,
    schema_name sysname,
    index_id int,
    partition_number int,
    size_with_current_compression_setting bigint,
    size_with_requested_compression_setting bigint,
    sample_size_with_current_compression_setting bigint,
    sample_size_with_requested_compression_setting bigint
);

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @schema, @tabname  
WHILE @@FETCH_STATUS = 0 
BEGIN
	INSERT INTO #tempEstimate
	EXEC sp_estimate_data_compression_savings 
		@schema_name = @schema,
		@object_name = @tabname,
		@index_id = NULL, 
		@partition_number = NULL, 
		@data_compression = 'PAGE'
	FETCH NEXT FROM db_cursor INTO @schema, @tabname 
END 
CLOSE db_cursor  
DEALLOCATE db_cursor

SELECT object_name, schema_name,
	CASE WHEN index_id = 0 THEN 'Heap'
		WHEN index_id = 1 THEN 'Clustered index'
		ELSE 'Nonclustered index'
	END AS index_type,
	CASE WHEN partition_number = 1 THEN 'Nonpartitioned'
		ELSE CAST(partition_number as VARCHAR) 
	END AS partition_number,
	size_with_current_compression_setting,-- / 1024 as size_with_current_compression_setting_MB,
	size_with_requested_compression_setting,-- / 1024 as size_with_requested_compression_setting_MB,
	100 - ((CAST(size_with_requested_compression_setting as float) / CAST(size_with_current_compression_setting as float)) * 100) as estimated_savings
FROM #tempEstimate
WHERE size_with_current_compression_setting > 0
AND size_with_requested_compression_setting > 0
