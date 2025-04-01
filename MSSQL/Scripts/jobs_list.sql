USE [msdb]
GO
SELECT j.Name
    , j.owner_sid
    , j.[Description]
    , js.Step_ID
    , js.Step_Name
    , js.Database_Name
    , js.Command
    --, j.*, js.*
FROM dbo.sysjobs j
INNER JOIN dbo.sysjobsteps js ON js.job_id = j.job_id
ORDER BY j.name, js.Step_ID
