select sql_id from v$sql where sql_text like '%bch_cust_history%';

declare
  ret_val VARCHAR2(4000);
BEGIN
    RET_VAL := DBMS_SQLTUNE.CREATE_TUNING_TASK(SQL_ID => '1t0g9qtatbq8w',
    SCOPE => DBMS_SQLTUNE.SCOPE_COMPREHENSIVE,
    TIME_LIMIT => 60,
    TASK_NAME => 'Tuning Task',
    DESCRIPTION => 'Tuning Task');
END;
/

EXEC DBMS_SQLTUNE.EXECUTE_TUNING_TASK('Portilho Tuning Task');
SET LONG 9000
SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK('Portilho Tuning Task') FROM DUAL;
SELECT DBMS_SQLTUNE.SCRIPT_TUNING_TASK('Portilho Tuning Task') FROM DUAL;

-- Remova o SQL_TUNE executado, após executar a correção.
EXEC DBMS_SQLTUNE.DROP_TUNING_TASK('Portilho Tuning Task');
