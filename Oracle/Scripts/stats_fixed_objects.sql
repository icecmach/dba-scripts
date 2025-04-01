-- Create a table capable of holding statistics
EXEC DBMS_STATS.CREATE_STAT_TABLE (ownname => 'DSDBA', stattab => 'FIXED_OBJ_STATS_TABLE');

-- Export current fixed object statistics
EXEC DBMS_STATS.EXPORT_FIXED_OBJECTS_STATS(statown => 'DSDBA', stattab => 'FIXED_OBJ_STATS_TABLE');

-- Create job to run fixed statistics collection
BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'SYSTEM.GATHER_FIXED_OBJ_STATS'
      ,start_date      => TO_TIMESTAMP_TZ('2024/06/02 00:00:00.000000 -05:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => NULL
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'PLSQL_BLOCK'
      ,job_action      => 'BEGIN
    DBMS_STATS.GATHER_FIXED_OBJECTS_STATS;
END;'
      ,comments        => 'Gathers statistics for all fixed objects (dynamic performance tables)'
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYSTEM.GATHER_FIXED_OBJ_STATS'
     ,attribute => 'RESTARTABLE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYSTEM.GATHER_FIXED_OBJ_STATS'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_OFF);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'SYSTEM.GATHER_FIXED_OBJ_STATS'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'SYSTEM.GATHER_FIXED_OBJ_STATS'
     ,attribute => 'MAX_RUNS');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYSTEM.GATHER_FIXED_OBJ_STATS'
     ,attribute => 'STOP_ON_WINDOW_CLOSE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYSTEM.GATHER_FIXED_OBJ_STATS'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'SYSTEM.GATHER_FIXED_OBJ_STATS'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYSTEM.GATHER_FIXED_OBJ_STATS'
     ,attribute => 'AUTO_DROP'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYSTEM.GATHER_FIXED_OBJ_STATS'
     ,attribute => 'RESTART_ON_RECOVERY'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYSTEM.GATHER_FIXED_OBJ_STATS'
     ,attribute => 'RESTART_ON_FAILURE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYSTEM.GATHER_FIXED_OBJ_STATS'
     ,attribute => 'STORE_OUTPUT'
     ,value     => TRUE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'SYSTEM.GATHER_FIXED_OBJ_STATS'
     ,attribute => 'MAX_RUN_DURATION'
     ,value     => TO_DSINTERVAL('+000 01:00:00'));

  SYS.DBMS_SCHEDULER.ENABLE
    (name       => 'SYSTEM.GATHER_FIXED_OBJ_STATS');
END;
/

-- In case of problems
-- Try to lock the table stats if it gets stuck and continue
EXEC DBMS_STATS.LOCK_TABLE_STATS (ownname    VARCHAR2, tabname    VARCHAR2);


-- Rollback procedure
EXEC dbms_stats.delete_fixed_objects_stats();

-- Import old statistics back
EXEC DBMS_STATS.IMPORT_FIXED_OBJECTS_STATS (statown => 'DSDBA', stattab => 'FIXED_OBJ_STATS_TABLE');



/*
References:
https://support.oracle.com/epmos/faces/DocContentDisplay?id=798257.1 - Fixed Objects Statistics (GATHER_FIXED_OBJECTS_STATS) Considerations (Doc ID 798257.1)
https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_STATS.html
https://blogs.oracle.com/optimizer/post/fixed-objects-statistics-and-why-they-are-important

https://support.oracle.com/epmos/faces/DocContentDisplay?id=357765.1 - Rman uses a lot Of Temporary Segments ORA-1652: Unable To Extend Temp Segment (Doc ID 357765.1)
*/

