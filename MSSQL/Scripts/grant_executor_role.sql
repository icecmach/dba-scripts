USE [db1-prd]
CREATE ROLE db_executor;
GRANT EXECUTE TO db_executor;

ALTER ROLE [db_executor] ADD MEMBER [sqlusr_prd];
