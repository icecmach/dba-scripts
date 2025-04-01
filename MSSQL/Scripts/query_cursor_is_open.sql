SELECT c.session_id, c.properties, c.creation_time, c.is_open, t.text
FROM sys.dm_exec_cursors (0) c --0 for all cursors running
CROSS APPLY sys.dm_exec_sql_text (c.sql_handle) t
