/*
      -----------------------------------------------------------------
      Cost Threshold For Parallelism
      -----------------------------------------------------------------
   
      For more SQL resources, check out SQLServer365.blogspot.com
      -----------------------------------------------------------------
      You may alter this code for your own purposes.
      You may republish altered code as long as you give due credit.
      You must obtain prior permission before blogging this code.
      THIS CODE AND INFORMATION ARE PROVIDED "AS IS"
    
      -----------------------------------------------------------------
*/
-- Set Database Context
USE DBA;
GO
-- Create table
IF NOT EXISTS ( SELECT  1
                FROM    sys.objects
                WHERE   [object_id] = OBJECT_ID('dbo.PlanCacheForMaxDop')
                        AND [type] = 'U' )
    CREATE TABLE DBA.dbo.PlanCacheForMaxDop
        (
          CompleteQueryPlan XML ,
          StatementText VARCHAR(4000) ,
          StatementOptimizationLevel VARCHAR(25) ,
          StatementSubTreeCost FLOAT ,
          ParallelSubTreeXML XML ,
          UseCounts INT,
          PlanSizeInBytes INT
        );
ELSE
      -- If table exists truncate it before population
    TRUNCATE TABLE  DBA.dbo.PlanCacheForMaxDop;     
GO

-- Collect parallel plan information
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
WITH XMLNAMESPACES(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
INSERT INTO DBA.dbo.PlanCacheForMaxDop
SELECT 
     query_plan ASCompleteQueryPlan,
     n.value('(@StatementText)[1]', 'VARCHAR(4000)') AS StatementText,
     n.value('(@StatementOptmLevel)[1]', 'VARCHAR(25)') ASStatementOptimizationLevel,
     n.value('(@StatementSubTreeCost)[1]', 'VARCHAR(128)') ASStatementSubTreeCost,
     n.query('.') ASParallelSubTreeXML, 
     ecp.usecounts,
     ecp.size_in_bytes 
FROM sys.dm_exec_cached_plans AS ecp
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS eqp
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS qn(n)
WHERE n.query('.').exist('//RelOp[@PhysicalOp="Parallelism"]') = 1;
GO
-- Return parallel plan information
SELECT  CompleteQueryPlan ,
        StatementText ,
        StatementOptimizationLevel ,
        StatementSubTreeCost ,
        ParallelSubTreeXML ,
        UseCounts ,
        PlanSizeInBytes
FROM    DBA.dbo.PlanCacheForMaxDop;
GO
-- Return grouped parallel plan information
SELECT  MAX(CASE WHEN StatementSubTreeCost BETWEEN 1 AND 5 THEN '1-5'
                 WHEN StatementSubTreeCost BETWEEN 5 AND 6 THEN '5-6'
                 WHEN StatementSubTreeCost BETWEEN 6 AND 7 THEN '6-7'
                 WHEN StatementSubTreeCost BETWEEN 7 AND 8 THEN '7-8'
                 WHEN StatementSubTreeCost BETWEEN 8 AND 9 THEN '8-9'
                 WHEN StatementSubTreeCost BETWEEN 9 AND 10 THEN '9-10'
                 WHEN StatementSubTreeCost BETWEEN 10 AND 11 THEN '10-11'
                 WHEN StatementSubTreeCost BETWEEN 11 AND 12 THEN '11-12'
                 WHEN StatementSubTreeCost BETWEEN 12 AND 13 THEN '12-13'
                 WHEN StatementSubTreeCost BETWEEN 13 AND 14 THEN '13-14'
                 WHEN StatementSubTreeCost BETWEEN 14 AND 15 THEN '14-15'
                 WHEN StatementSubTreeCost BETWEEN 15 AND 16 THEN '15-16'
                 WHEN StatementSubTreeCost BETWEEN 16 AND 17 THEN '16-17'
                 WHEN StatementSubTreeCost BETWEEN 17 AND 18 THEN '17-18'
                 WHEN StatementSubTreeCost BETWEEN 18 AND 19 THEN '18-19'
                 WHEN StatementSubTreeCost BETWEEN 19 AND 20 THEN '19-20'
                 WHEN StatementSubTreeCost BETWEEN 20 AND 25 THEN '20-25'
                 WHEN StatementSubTreeCost BETWEEN 25 AND 30 THEN '25-30'
                 WHEN StatementSubTreeCost BETWEEN 30 AND 35 THEN '30-35'
                 WHEN StatementSubTreeCost BETWEEN 35 AND 40 THEN '35-40'
                 WHEN StatementSubTreeCost BETWEEN 40 AND 45 THEN '40-45'
                 WHEN StatementSubTreeCost BETWEEN 45 AND 50 THEN '45-50'
                 WHEN StatementSubTreeCost > 50 THEN '>50'
                 ELSE CAST(StatementSubTreeCost AS VARCHAR(100))
            END) ASStatementSubTreeCost ,
        COUNT(*) AS countInstance
FROM    DBA.dbo.PlanCacheForMaxDop
GROUP BY CASE WHEN StatementSubTreeCost BETWEEN 1 AND 5 THEN 2.5
              WHEN StatementSubTreeCost BETWEEN 5 AND 6 THEN 5.5
              WHEN StatementSubTreeCost BETWEEN 6 AND 7 THEN 6.5
              WHEN StatementSubTreeCost BETWEEN 7 AND 8 THEN 7.5
              WHEN StatementSubTreeCost BETWEEN 8 AND 9 THEN 8.5
              WHEN StatementSubTreeCost BETWEEN 9 AND 10 THEN 9.5
              WHEN StatementSubTreeCost BETWEEN 10 AND 11 THEN 10.5
              WHEN StatementSubTreeCost BETWEEN 11 AND 12 THEN 11.5
              WHEN StatementSubTreeCost BETWEEN 12 AND 13 THEN 12.5
              WHEN StatementSubTreeCost BETWEEN 13 AND 14 THEN 13.5
              WHEN StatementSubTreeCost BETWEEN 14 AND 15 THEN 14.5
              WHEN StatementSubTreeCost BETWEEN 15 AND 16 THEN 15.5
              WHEN StatementSubTreeCost BETWEEN 16 AND 17 THEN 16.5
              WHEN StatementSubTreeCost BETWEEN 17 AND 18 THEN 17.5
              WHEN StatementSubTreeCost BETWEEN 18 AND 19 THEN 18.5
              WHEN StatementSubTreeCost BETWEEN 19 AND 20 THEN 19.5
              WHEN StatementSubTreeCost BETWEEN 10 AND 15 THEN 12.5
              WHEN StatementSubTreeCost BETWEEN 15 AND 20 THEN 17.5
              WHEN StatementSubTreeCost BETWEEN 20 AND 25 THEN 22.5
              WHEN StatementSubTreeCost BETWEEN 25 AND 30 THEN 27.5
              WHEN StatementSubTreeCost BETWEEN 30 AND 35 THEN 32.5
              WHEN StatementSubTreeCost BETWEEN 35 AND 40 THEN 37.5
              WHEN StatementSubTreeCost BETWEEN 40 AND 45 THEN 42.5
              WHEN StatementSubTreeCost BETWEEN 45 AND 50 THEN 47.5
              WHEN StatementSubTreeCost > 50 THEN 100
              ELSE StatementSubTreeCost
         END;
GO