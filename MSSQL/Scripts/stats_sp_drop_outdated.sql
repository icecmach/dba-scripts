CREATE PROCEDURE [dbo].[sp_Statistics_Drop_Outdated]
As
BEGIN

SET NOCOUNT ON
-- Leave the procedure when maintenance window finishes > 8:00 PM
IF GETDATE()> dateadd(mi,+00,dateadd(hh,+20,cast(floor(cast(getdate()as float))as datetime)))
BEGIN
  RETURN
END

Create table #tmp_drop_statistics(
  ds_command varchar(4000),
  nr_line int IDENTITY(1,1)
);

--statistics that haven’t been updated in over 7 days
--statistics that have a row_modfications value above a specific threshold
insert into #tmp_drop_statistics
  SELECT 'DROP STATISTICS ' + QUOTENAME(SCHEMA_NAME(so.Schema_id)) + '.' + QUOTENAME(OBJECT_NAME(ss.object_id)) + '.' + QUOTENAME(ss.name) DropStatisticsStatement
  FROM sys.stats ss
  JOIN sys.objects so ON ss.object_id = so.object_id
  OUTER APPLY sys.dm_db_stats_properties(so.object_id, ss.stats_id) AS sp
  WHERE so.TYPE = 'U'
  AND sp.last_updated < getdate() - 7 
  AND sp.modification_counter > 50000
  AND ss.auto_created = 1
  ORDER BY so.name;

declare @Loop int, @command nvarchar(4000)
set @Loop = 1

while exists(select top 1 null from #tmp_drop_statistics)
begin
  -- Leave the loop if maintenance window finishes > 8:00 PM
  IF GETDATE()> dateadd(mi,+00,dateadd(hh,+20,cast(floor(cast(getdate()as float))as datetime)))
  BEGIN
    BREAK
  END

  select @command = ds_command
  from #tmp_drop_statistics
  where nr_line = @Loop

  EXECUTE sp_executesql @command

  delete from #tmp_drop_statistics
  where nr_line = @Loop

  set @Loop= @Loop + 1
end

END