SELECT OBJECT_NAME(i.object_id) as table_name,
	i.*
FROM SYS.INDEXES AS I
WHERE i.is_disabled = 1