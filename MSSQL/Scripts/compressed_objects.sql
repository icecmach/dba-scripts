SELECT t.name AS Table_Name,
    p.partition_number,
    p.data_compression_desc AS Compression
FROM sys.partitions p
INNER JOIN sys.tables t ON p.object_id = t.object_id
WHERE p.index_id IN (0, 1)  -- heap or clustered index
AND p.data_compression <> 0

SELECT 
    t.name AS Table_Name,
    i.name AS Index_Name,
    i.type AS Index_Type,
    p.data_compression_desc AS Compression_Desc
FROM sys.partitions p
INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
INNER JOIN sys.tables t ON p.object_id = t.object_id
WHERE i.type IN (1, 2)  -- 1 for clustered, 2 for non-clustered
AND p.data_compression_desc <> 'NONE'
order by t.name,i.name


EXEC sp_estimate_data_compression_savings 
    @schema_name = 'dbo', 
    @object_name = 'syslog_event', 
    @index_id = NULL, 
    @partition_number = NULL, 
    @data_compression = 'ROW'
 
EXEC sp_estimate_data_compression_savings 
    @schema_name = 'dbo', 
    @object_name = 'syslog_event', 
    @index_id = NULL, 
    @partition_number = NULL, 
    @data_compression = 'PAGE'
