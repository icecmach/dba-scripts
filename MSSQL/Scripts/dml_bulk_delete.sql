SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Description: Purge table
-- 1- Create a new table with 7 days old records (retention is 1 week)
-- 2- Rename Table_name to Table_name_old
-- 3- Rename new table to correct name
-- 4- After validation the _old can be dropped
-- The idea is to avoid log generation since most of the table will be purged
-- =============================================
CREATE PROCEDURE Purge_Table_Logs_1_time_execution
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRAN
	BEGIN TRY
		-- Step 1
		SELECT * INTO Table_Logs_New FROM Table_Logs Where DATEDIFF(day,EventTimeStamp,SYSDATETIME()) < 7;
		-- Step 2
		EXEC sp_rename 'dbo.Table_Logs', 'Table_Logs_old';
		-- Step 3
		EXEC sp_rename 'dbo.Table_Logs_New', 'Table_Logs';
		COMMIT TRAN
	END TRY
	BEGIN CATCH
      ROLLBACK TRAN
	END CATCH
END
GO

-- =============================================
-- Description: Purge table using delete
-- change the batch size accordingly
-- =============================================
DECLARE @batchSize INT = 3000;
DECLARE @rowCount INT = 1;

WHILE @rowCount > 0
BEGIN
	BEGIN TRANSACTION
    DELETE TOP (@batchSize) FROM [iq].[dbo].[syslog_event] WHERE [created] < 1733011200000;
    SET @rowCount = @@ROWCOUNT;
	COMMIT TRANSACTION;
	WAITFOR DELAY '00:00:01';
END

