WITH Table_Size as (
	SELECT obj.schema_id,
		   obj.name table_name,
		   prt.rows
	FROM sys.objects obj
	JOIN sys.indexes idx    on idx.object_id = obj.object_id
	JOIN sys.partitions prt on prt.object_id = obj.object_id
	JOIN sys.allocation_units alloc on alloc.container_id = prt.partition_id
	WHERE obj.type = 'U'
	AND idx.index_id IN (0, 1)
	and prt.rows > 1000000
	GROUP BY obj.schema_id,
			 obj.name,
			 prt.rows)
SELECT 'UPDATE STATISTICS [' + SCHEMA_NAME(D.schema_id) + '].[' + D.table_name + '] ' + A.name + ' WITH FULLSCAN',
       C.rowmodctr,
	   D.rows
FROM sys.stats A
join sys.sysobjects B on A.object_id = B.id
join sys.sysindexes C on C.id = B.id and A.name= C.Name
JOIN Table_Size D on B.name = D.table_name
WHERE C.rowmodctr > 100000
and C.rowmodctr > D.rows * .005
and substring(B.name, 1, 3) not in ('sys', 'dtp')
ORDER BY D.rows, C.rowmodctr


SELECT A.*, b.*, c.*
FROM sys.stats A
join sys.sysobjects B on A.object_id = B.id
join sys.sysindexes C on C.id = B.id and A.name= C.Name
WHERE C.rowmodctr > 100000
and substring(B.name, 1, 3) not in ('sys', 'dtp')
ORDER BY C.rows, C.rowmodctr


SELECT OBJECT_NAME(A.[OBJECT_ID]) AS [OBJECT NAME], 
       I.[NAME] AS [INDEX NAME], 
       A.LEAF_INSERT_COUNT, 
       A.LEAF_UPDATE_COUNT, 
       A.LEAF_DELETE_COUNT 
FROM   SYS.DM_DB_INDEX_OPERATIONAL_STATS (NULL,NULL,NULL,NULL ) A 
       INNER JOIN SYS.INDEXES AS I 
         ON I.[OBJECT_ID] = A.[OBJECT_ID] 
            AND I.INDEX_ID = A.INDEX_ID 
WHERE  OBJECTPROPERTY(A.[OBJECT_ID],'IsUserTable') = 1


SELECT   OBJECT_NAME(S.[OBJECT_ID]) AS [OBJECT NAME], 
         I.[NAME] AS [INDEX NAME], 
         USER_SEEKS, 
         USER_SCANS, 
         USER_LOOKUPS, 
         USER_UPDATES 
FROM     SYS.DM_DB_INDEX_USAGE_STATS AS S 
         INNER JOIN SYS.INDEXES AS I 
           ON I.[OBJECT_ID] = S.[OBJECT_ID] 
              AND I.INDEX_ID = S.INDEX_ID 
WHERE    OBJECTPROPERTY(S.[OBJECT_ID],'IsUserTable') = 1 


DBCC SHOW_STATISTICS(tbl_name, [IX_name])