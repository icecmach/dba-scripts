SELECT indexes.name, us.*
FROM sys.dm_db_index_usage_stats us
INNER JOIN sys.objects ON us.OBJECT_ID = objects.OBJECT_ID
INNER JOIN sys.indexes ON indexes.index_id = us.index_id AND us.OBJECT_ID = indexes.OBJECT_ID
WHERE indexes.name in ('')
ORDER BY 1, us.user_updates DESC

SELECT I.[NAME] AS [INDEX NAME], 
       A.*
FROM SYS.INDEXES AS I  
INNER JOIN SYS.DM_DB_INDEX_OPERATIONAL_STATS (NULL,NULL,NULL,NULL ) A ON I.[OBJECT_ID] = A.[OBJECT_ID]  AND I.INDEX_ID = A.INDEX_ID
WHERE i.object_id=598293191