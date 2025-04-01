USE [msdb]
GO

/****** Object:  Job [DBA_Perf_Collect_Performance_Data]    Script Date: 6/14/2024 2:24:34 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

DECLARE @jobId BINARY(16)
EXEC @ReturnCode = msdb.dbo.sp_add_job @job_name=N'DBA_Perf_Collect_Performance_Data',
		@enabled=0,
		@notify_level_eventlog=0,
		@notify_level_email=0,
		@notify_level_netsend=0,
		@notify_level_page=0,
		@delete_level=0,
		@description=N'Description: Executes sp_BlitzFirst to collect performance data
Start Date: 14/Jun/2024
General Schedule: Every 15min
Dependencies: sp_BlitzFirst',
		@category_name=N'Database Maintenance',
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Collect Stats]    Script Date: 6/14/2024 2:24:34 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Collect Stats',
		@step_id=1,
		@cmdexec_success_code=0,
		@on_success_action=1,
		@on_success_step_id=0,
		@on_fail_action=2,
		@on_fail_step_id=0,
		@retry_attempts=0,
		@retry_interval=0,
		@os_run_priority=0, @subsystem=N'TSQL',
		@command=N'EXEC sp_BlitzFirst
  @OutputDatabaseName = ''DBAtools'',
  @OutputSchemaName = ''dbo'',
  @OutputTableName = ''BlitzFirst'',
  @OutputTableNameWaitStats = ''BlitzFirst_WaitStats'',
  @OutputTableNameBlitzCache = ''BlitzCache'',
  @OutputResultSets = N''WaitStats|BlitzCache'',
  @OutputType = ''none'',
  @CheckServerInfo = 0',
		@database_name=N'master',
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
