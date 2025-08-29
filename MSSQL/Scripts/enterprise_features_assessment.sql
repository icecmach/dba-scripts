-- https://docs.aws.amazon.com/prescriptive-guidance/latest/evaluate-downgrading-sql-server-edition/assess-environment.html
-- To assess your SQL Server environment and find out whether your Enterprise SQL Server instance is using Enterprise feature

IF (SELECT SERVERPROPERTY('EngineEdition')) = 2
    SELECT 'This is already a Standard SQL Server Edition instance!' AS Status
ELSE
    BEGIN
        --Checking Enterprise features
        CREATE TABLE ##EntFeatures ( dbid int, db_name SYSNAME, feature_name VARCHAR(100))
        EXEC sp_msforeachdb
        N' USE [?]
        IF (SELECT COUNT(*) FROM sys.dm_db_persisted_sku_features) >0
        BEGIN
           INSERT INTO ##EntFeatures
            SELECT db_id(),dbname=DB_NAME(),feature_name FROM sys.dm_db_persisted_sku_features
        END '
        IF (SELECT COUNT(1) FROM ##EntFeatures WHERE dbid>4) >0
            SELECT db_name,feature_name FROM   ##EntFeatures;
        ELSE
            SELECT CONCAT('Ready to move! You are running a(n) ', CONVERT(VARCHAR,SERVERPROPERTY('Edition')),' and are not using any Enterprise features') AS Status
    END

IF OBJECT_ID('tempdb.dbo.##EntFeatures') IS NOT NULL
DROP TABLE ##EntFeatures