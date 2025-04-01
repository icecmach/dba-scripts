use tempdb
select * from sys.dm_db_task_space_usage;
select * from sys.dm_db_session_space_usage;
select * from sys.dm_db_file_space_usage;

SELECT
  es.session_id AS [SESSION ID]
  ,DB_NAME(su.database_id) AS [DATABASE Name]
  ,HOST_NAME AS [System Name]
  ,program_name AS [Program Name]
  ,login_name AS [USER Name]
  ,status
  ,cpu_time AS [CPU TIME (in milisec)]
  ,total_scheduled_time AS [Total Scheduled TIME (in milisec)]
  ,total_elapsed_time AS    [Elapsed TIME (in milisec)]
  ,(memory_usage * 8)      AS [Memory USAGE (in KB)]
  ,(user_objects_alloc_page_count * 8) AS [SPACE Allocated FOR USER Objects (in KB)]
  ,(user_objects_dealloc_page_count * 8) AS [SPACE Deallocated FOR USER Objects (in KB)]
  ,(internal_objects_alloc_page_count * 8) AS [SPACE Allocated FOR Internal Objects (in KB)]
  ,(internal_objects_dealloc_page_count * 8) AS [SPACE Deallocated FOR Internal Objects (in KB)]
  ,CASE is_user_process
    WHEN 1 THEN 'user session'
    WHEN 0 THEN 'system session'
  END AS [SESSION Type], row_count AS [ROW COUNT]
FROM sys.dm_db_session_space_usage su
INNER join sys.dm_exec_sessions es ON su.session_id = es.session_id

SELECT  SS.session_id , SS.database_id ,
        CAST(SS.user_objects_alloc_page_count / 128 AS DECIMAL(15, 2)) [Total Allocation User Objects MB] ,
        CAST(( SS.user_objects_alloc_page_count - SS.user_objects_dealloc_page_count ) / 128 AS DECIMAL(15, 2)) [Net Allocation User Objects MB] ,
        CAST(SS.internal_objects_alloc_page_count / 128 AS DECIMAL(15, 2)) [Total Allocation Internal Objects MB] ,
        CAST(( SS.internal_objects_alloc_page_count - SS.internal_objects_dealloc_page_count ) / 128 AS DECIMAL(15, 2)) [Net Allocation Internal Objects MB] ,
        CAST(( SS.user_objects_alloc_page_count + internal_objects_alloc_page_count ) / 128 AS DECIMAL(15, 2)) [Total Allocation MB] ,
        CAST(( SS.user_objects_alloc_page_count
               + SS.internal_objects_alloc_page_count
               - SS.internal_objects_dealloc_page_count
               - SS.user_objects_dealloc_page_count ) / 128 AS DECIMAL(15, 2)) [Net Allocation MB] ,
        T.text [Query Text]
FROM    sys.dm_db_session_space_usage SS
LEFT JOIN sys.dm_exec_connections CN ON CN.session_id = SS.session_id
OUTER APPLY sys.dm_exec_sql_text(CN.most_recent_sql_handle) T

SELECT TOP 5 --Change number accordingly
  su.Session_ID,
  ss.Login_Name,
  rq.Command,
  su.Task_Alloc,
  su.Task_Dealloc,
  --Find Offending Query Text:
  (SELECT SUBSTRING(text, rq.statement_start_offset/2 + 1,
   (CASE WHEN statement_end_offset = -1 
         THEN LEN(CONVERT(nvarchar(max),text)) * 2 
         ELSE statement_end_offset 
   END - rq.statement_start_offset)/2)
  FROM sys.dm_exec_sql_text(sql_handle))
FROM 
  (SELECT su.session_id, su.request_id,
   SUM(su.internal_objects_alloc_page_count + su.user_objects_alloc_page_count) AS Task_Alloc,
   SUM(su.internal_objects_dealloc_page_count + su.user_objects_dealloc_page_count) AS Task_Dealloc
  FROM sys.dm_db_task_space_usage AS su
  GROUP BY session_id, request_id) AS su, 
   sys.dm_exec_sessions AS ss, 
   sys.dm_exec_requests AS rq
  WHERE su.session_id = rq.session_id 
   AND(su.request_id = rq.request_id) 
   AND (ss.session_id = su.session_id)
   AND su.session_id > 50  --sessions 50 and below are system sessions and should not be killed
   AND su.session_id <> (SELECT @@SPID) --Eliminates current user session from results
  ORDER BY su.task_alloc DESC  --The largest "Task Allocation/Deallocation" is probably the query that is causing the db growth

  -- Determining the amount of free space in tempdb
SELECT SUM(unallocated_extent_page_count) AS [free pages],
  (SUM(unallocated_extent_page_count)*1.0/128) AS [free space in MB]
FROM tempdb.sys.dm_db_file_space_usage;

-- Determining the amount of space used by the version store
SELECT SUM(version_store_reserved_page_count) AS [version store pages used],
  (SUM(version_store_reserved_page_count)*1.0/128) AS [version store space in MB]
FROM tempdb.sys.dm_db_file_space_usage;

-- Determining the amount of space used by internal objects
SELECT SUM(internal_object_reserved_page_count) AS [internal object pages used],
  (SUM(internal_object_reserved_page_count)*1.0/128) AS [internal object space in MB]
FROM tempdb.sys.dm_db_file_space_usage;

-- Determining the amount of space used by user objects
SELECT SUM(user_object_reserved_page_count) AS [user object pages used],
  (SUM(user_object_reserved_page_count)*1.0/128) AS [user object space in MB]
FROM tempdb.sys.dm_db_file_space_usage;

SELECT
SUM (user_object_reserved_page_count)*8/1024.0/1024.0 as user_obj_GB,
SUM (internal_object_reserved_page_count)*8/1024.0/1024.0 as internal_obj_GB,
SUM (version_store_reserved_page_count)*8/1024.0/1024.0  as version_store_GB,
SUM (unallocated_extent_page_count)*8/1024.0/1024.0 as freespace_GB,
SUM (mixed_extent_page_count)*8/1024.0/1024.0 as mixedextent_GB
FROM sys.dm_db_file_space_usage;

-- Obtaining the space consumed by internal objects in all currently running tasks in each session
SELECT session_id,
  SUM(internal_objects_alloc_page_count) AS task_internal_objects_alloc_page_count,
  SUM(internal_objects_dealloc_page_count) AS task_internal_objects_dealloc_page_count
FROM sys.dm_db_task_space_usage
GROUP BY session_id;

-- Obtaining the space consumed by internal objects in the current session for both running and completed tasks
SELECT R2.session_id,
  R1.internal_objects_alloc_page_count
  + SUM(R2.internal_objects_alloc_page_count) AS session_internal_objects_alloc_page_count,
  R1.internal_objects_dealloc_page_count
  + SUM(R2.internal_objects_dealloc_page_count) AS session_internal_objects_dealloc_page_count
FROM sys.dm_db_session_space_usage AS R1
INNER JOIN sys.dm_db_task_space_usage AS R2 ON R1.session_id = R2.session_id
GROUP BY R2.session_id, R1.internal_objects_alloc_page_count,
  R1.internal_objects_dealloc_page_count;

-- Transactions that are using the version store
-- When using RCSI as sometime active transactions will not show up with the usual tools such as DBCC opentran
-- If Implicit_Transactions is being set to ON and connections to the database are not being closed this will
-- cause the version store to grow which causes TempDB to grow which will either fill the disk or cause
-- performance issue being that the version store is so large.
SELECT ast.transaction_id,
	     ast.session_id,
	     db_name(spu.database_id) as database_name,
       at.transaction_begin_time as begin_time,
	     at.transaction_type,
	     at.name,
       case 
         when at.transaction_state in (0,1) then 'init'
         when at.transaction_state = 2 then 'active'
         when at.transaction_state = 3 then 'ended'
         when at.transaction_state = 4 then 'committing'
         when at.transaction_state = 6 then 'comitted'
         when at.transaction_state = 7 then 'rolling back'
         when at.transaction_state = 6 then 'rolled back'
         else 'other'
       end as transaction_state,
       ast.elapsed_time_seconds as elapsed_seconds,
  	   ast.elapsed_time_seconds/60/60.0 as hours_tran_has_been_open,
       ses.program_name,
	     p.status,
  	   p.cmd,
       ses.row_count,
       (spu.user_objects_alloc_page_count * 8) AS user_objects_kb,
       (spu.user_objects_dealloc_page_count * 8) AS user_objects_deallocated_kb,
       (spu.internal_objects_alloc_page_count * 8) AS internal_objects_kb,
       (spu.internal_objects_dealloc_page_count * 8) AS internal_objects_deallocated_kb
FROM sys.dm_tran_active_snapshot_database_transactions ast
JOIN sys.dm_tran_active_transactions at on at.transaction_id = ast.transaction_id
JOIN sys.dm_exec_sessions ses ON ses.session_id = ast.session_id
JOIN sys.dm_db_session_space_usage spu ON spu.session_id = ses.session_id
join sys.sysprocesses p on p.spid = ast.session_id
ORDER BY elapsed_time_seconds DESC;
