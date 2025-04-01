DECLARE @view_name SYSNAME
DECLARE view_cursor CURSOR FOR
SELECT name
FROM sys.views
WHERE schema_id = SCHEMA_ID('dbo')

OPEN view_cursor
FETCH NEXT FROM view_cursor INTO @view_name

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC('DROP VIEW dbo.' + @view_name)
    FETCH NEXT FROM view_cursor INTO @view_name
END

CLOSE view_cursor
DEALLOCATE view_cursor
