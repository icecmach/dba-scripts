BEGIN
  SYS.DBMS_SCHEDULER.DROP_JOB
    (job_name  => 'PERFSTAT.SP_PURGE_INITIAL');
END;
/

BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'PERFSTAT.SP_PURGE_INITIAL'
      ,start_date      => TO_TIMESTAMP_TZ('2023/07/10 13:56:00.000000 -04:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => NULL
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'PLSQL_BLOCK'
      ,job_action      => 'declare
    vnSnapDtBegin PERFSTAT.STATS$SNAPSHOT.SNAP_TIME%TYPE;
    vnSnapDtEnd   PERFSTAT.STATS$SNAPSHOT.SNAP_TIME%TYPE;
begin
    select trunc(min(SNAP_TIME)), trunc(max(SNAP_TIME))
    into vnSnapDtBegin, vnSnapDtEnd
    from PERFSTAT.STATS$SNAPSHOT
    where snap_time < trunc(sysdate) -90;

    LOOP
        STATSPACK.PURGE(
          i_begin_date => vnSnapDtBegin,
          i_end_date   => vnSnapDtBegin + 1);

        COMMIT;

        vnSnapDtBegin := vnSnapDtBegin + 2;
        EXIT WHEN vnSnapDtBegin >= vnSnapDtEnd;
    END LOOP;

    COMMIT;
exception
    when others then
        rollback;
        raise;
end;'
      ,comments        => NULL
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'PERFSTAT.SP_PURGE_INITIAL'
     ,attribute => 'RESTARTABLE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'PERFSTAT.SP_PURGE_INITIAL'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_OFF);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'PERFSTAT.SP_PURGE_INITIAL'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'PERFSTAT.SP_PURGE_INITIAL'
     ,attribute => 'MAX_RUNS');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'PERFSTAT.SP_PURGE_INITIAL'
     ,attribute => 'STOP_ON_WINDOW_CLOSE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'PERFSTAT.SP_PURGE_INITIAL'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'PERFSTAT.SP_PURGE_INITIAL'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'PERFSTAT.SP_PURGE_INITIAL'
     ,attribute => 'AUTO_DROP'
     ,value     => FALSE);
END;
/
