/* STEP 01 */
DECLARE
  my_task_name VARCHAR2(30);
  my_sqltext   CLOB;
BEGIN
  my_sqltext := 'select BAH.CUSTOMER_ID , '
||'  TO_CHAR(BAH.VALID_FROM,'YYYY-MM-DD-HH24.MI.SS') , '
||'  BGM.BILLCYCLE_GROUP_ID  from BILLCYCLE_ASSIGNMENT_HISTORY BAH , '
||'  BILLCYCLE_GROUP_MEMBER BGM where BAH.BILLCYCLE=BGM.BILLCYCLE '
||'  order by BAH.CUSTOMER_ID,BAH.VALID_FROM asc ';

  my_task_name := DBMS_SQLTUNE.CREATE_TUNING_TASK (
          sql_text    => my_sqltext
,         user_name   => 'SYSTEM'
,         scope       => 'COMPREHENSIVE'
,         task_name   => 'task01'
,         description => null
);
END;
/

/* STEP 02*/
begin
DBMS_SQLTUNE.EXECUTE_TUNING_TASK(task_name => 'task01');
end;
/

/* STEP 03: EXECUTE TILL THIS APPEAR: "task01	COMPLETED"  */
SELECT TASK_NAME, STATUS FROM DBA_ADVISOR_LOG WHERE TASK_NAME = 'task01';

/* STEP 04: EXECUTE THIS QUERY IN THE TOAD OR DEVELOPER, THE RESULT WILL COME IN ONE LINE.
-DOUBLE-CLICK IN THIS LINE TO SHOW THE CONTENT, COPY THE RESULT AND SEND ME */
SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK('task01') AS recommendations FROM dual;
