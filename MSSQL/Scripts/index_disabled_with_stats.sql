SELECT ss.name AS "Statistic",
	si.name AS "Index Name",
	CASE
		WHEN ss.auto_Created = 0 AND ss.user_created = 0 THEN 'Index Statistic'
		WHEN ss.auto_created = 0 AND ss.user_created = 1 THEN 'User Created'
		WHEN ss.auto_created = 1 AND ss.user_created = 0 THEN 'Auto Created'
		WHEN ss.AUTO_created = 1 AND ss.user_created = 1 THEN 'Not Possible?'
	END AS "Statistic Type",
	sp.last_updated AS "Stats Last Updated",
	sp.rows AS "Rows",
	sp.rows_sampled AS "Rows Sampled",
	sp.unfiltered_rows AS "Unfiltered Rows",
	sp.modification_counter AS "Row Modifications",
	sp.steps AS "Histogram Steps"
FROM sys.indexes AS si
JOIN sys.stats AS ss ON ss.object_id = si.object_id AND ss.stats_id = si.index_id
OUTER APPLY sys.dm_db_stats_properties(ss.object_id, ss.stats_id) AS sp
WHERE si.is_disabled = 1