SELECT ss.name,
       ss.stats_id,
       shr.steps,
       shr.rows,
       shr.rows_sampled, 
       shr.modification_counter,
       shr.last_updated,
       sh.range_rows,
       sh.equal_rows
FROM sys.stats ss
INNER JOIN sys.stats_columns sc ON ss.stats_id = sc.stats_id AND ss.object_id = sc.object_id
INNER JOIN sys.all_columns ac   ON ac.column_id = sc.column_id AND ac.object_id = sc.object_id
CROSS APPLY sys.dm_db_stats_properties(ss.object_id, ss.stats_id) shr
CROSS APPLY sys.dm_db_stats_histogram(ss.object_id, ss.stats_id) sh
WHERE ss.[object_id] = OBJECT_ID('OBJ_NAME') 
AND ac.name = 'INV_ID'
order by range_rows