-- Option 1
BEGIN
DBMS_SCHEDULER.create_job (
    job_name => 'PURGE_UNIFIED_AUDIT_JOB',
    job_type => 'PLSQL_BLOCK',
    job_action => 'BEGIN
DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED, ADD_MONTHS(systimestamp, -12));
DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL(audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
use_last_arch_timestamp  =>  TRUE);
END;',
    start_date => TO_TIMESTAMP_TZ('2023/11/17 05:00:00.000000 -05:00','yyyy/mm/dd hh24:mi:ss.ff tzr'),
    repeat_interval => 'freq=daily; byhour=5; byminute=00; bysecond=0;',
    end_date => NULL,
    enabled  => TRUE,
    comments => 'Purge unified audit trail older than 1 year. Doc ID 1582627.1');
END;
/

-- Option 2
BEGIN
  DBMS_AUDIT_MGMT.INIT_CLEANUP(
    AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
    DEFAULT_CLEANUP_INTERVAL => 24 /*hours*/
  );
END;
/
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name   => 'DAILY_AUDIT_ARCHIVE_TIMESTAMP',
    job_type   => 'PLSQL_BLOCK',
    job_action => 'BEGIN DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(AUDIT_TRAIL_TYPE =>
                   DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,LAST_ARCHIVE_TIME => sysdate-365); END;',
    start_date => sysdate,
    repeat_interval => 'FREQ=HOURLY;INTERVAL=24',
    enabled    =>  TRUE,
    comments   => 'Create an archive timestamp'
  );
END;
/
BEGIN
  DBMS_AUDIT_MGMT.CREATE_PURGE_JOB(
    AUDIT_TRAIL_TYPE           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD,
    AUDIT_TRAIL_PURGE_INTERVAL => 24 /* hours */,
    AUDIT_TRAIL_PURGE_NAME     => 'Daily_Audit_Purge_Job',
    USE_LAST_ARCH_TIMESTAMP    => TRUE
  );
END;
/

--Views
DBA_AUDIT_MGMT_CLEAN_EVENTS  	Displays the cleanup event history
DBA_AUDIT_MGMT_CLEANUP_JOBS  	Displays the currently configured trail purge jobs
DBA_AUDIT_MGMT_CONFIG_PARAMS 	Displays the currently configured audit trail properties
DBA_AUDIT_MGMT_LAST_ARCH_TS  	Displays the last archive timestamps set for the audit trails


