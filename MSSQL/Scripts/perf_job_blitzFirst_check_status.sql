USE [msdb]
GO

/****** Object:  Job [DBA_Maint_Check_Job_Status]    Script Date: 6/14/2024 2:29:47 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

DECLARE @jobId BINARY(16)
EXEC @ReturnCode = msdb.dbo.sp_add_job @job_name=N'DBA_Maint_Check_Job_Status',
		@enabled=0,
		@notify_level_eventlog=0,
		@notify_level_email=0,
		@notify_level_netsend=0,
		@notify_level_page=0,
		@delete_level=0,
		@description=N'Description: Checks if performance collection job is running for more than 1 min
Start Date: 14/Jun/2024
General Schedule: Same as perf collection + 1min',
		@category_name=N'Database Maintenance',
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check job status]    Script Date: 6/14/2024 2:29:47 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check job status',
		@step_id=1,
		@cmdexec_success_code=0,
		@on_success_action=1,
		@on_success_step_id=0,
		@on_fail_action=2,
		@on_fail_step_id=0,
		@retry_attempts=0,
		@retry_interval=0,
		@os_run_priority=0, @subsystem=N'TSQL',
		@command=N'DECLARE @RunTime INTEGER
WITH cte AS(
  SELECT sj.name, sja.start_execution_date, ROW_NUMBER() OVER (ORDER BY sja.start_execution_date DESC) AS rn
  FROM msdb.dbo.sysjobactivity AS sja
  INNER JOIN msdb.dbo.sysjobs AS sj ON sja.job_id = sj.job_id
  WHERE sja.start_execution_date IS NOT NULL
  AND sja.stop_execution_date IS NULL
  AND sj.name LIKE ''%DBA_Perf_Collect_Performance_Data%''
)
SELECT @RunTime=DATEDIFF(SECOND, start_execution_date, GETDATE())/60
  FROM cte
 WHERE rn = 1

IF @RunTime >= 1
  EXEC msdb..sp_stop_job @job_name = ''DBA_Perf_Collect_Performance_Data''',
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
