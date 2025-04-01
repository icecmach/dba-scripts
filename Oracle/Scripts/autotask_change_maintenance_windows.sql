select * from DBA_AUTOTASK_WINDOW_CLIENTS;
select * from DBA_AUTOTASK_CLIENT;
select * from DBA_AUTO_STAT_EXECUTIONS;
select * from DBA_AUTOTASK_OPERATION;
select * from DBA_AUTOTASK_WINDOW_HISTORY;

BEGIN
  SYS.DBMS_SCHEDULER.CREATE_WINDOW
    (
       window_name     => 'MORNING_WINDOW'
      ,start_date      => NULL
      ,repeat_interval => 'freq=daily;byhour=05;byminute=0; bysecond=0'
      ,end_date        => NULL
      ,resource_plan   => 'DEFAULT_MAINTENANCE_PLAN'
      ,duration        => to_dsInterval('+000 03:00:00')
      ,window_priority => 'LOW'
      ,comments        => 'Morning window for maintenance tasks'
    );
  SYS.DBMS_SCHEDULER.ENABLE
    (name => 'SYS.MORNING_WINDOW');
  --
  SYS.DBMS_SCHEDULER.CREATE_WINDOW
    (
       window_name     => 'NIGHT_WINDOW'
      ,start_date      => NULL
      ,repeat_interval => 'freq=daily;byhour=21;byminute=0; bysecond=0'
      ,end_date        => NULL
      ,resource_plan   => 'DEFAULT_MAINTENANCE_PLAN'
      ,duration        => to_dsInterval('+000 04:00:00')
      ,window_priority => 'LOW'
      ,comments        => 'Night window for maintenance tasks'
    );
  SYS.DBMS_SCHEDULER.ENABLE
    (name => 'SYS.NIGHT_WINDOW');
  --
  DBMS_SCHEDULER.REMOVE_WINDOW_GROUP_MEMBER
    (group_name  => 'SYS.ORA$AT_WGRP_OS',
     window_list => 'MONDAY_WINDOW,TUESDAY_WINDOW,WEDNESDAY_WINDOW,THURSDAY_WINDOW,FRIDAY_WINDOW,SATURDAY_WINDOW,SUNDAY_WINDOW');
  --
  DBMS_SCHEDULER.ADD_WINDOW_GROUP_MEMBER
    (group_name  => 'SYS.ORA$AT_WGRP_OS',
     window_list => 'MORNING_WINDOW,NIGHT_WINDOW');
  --
  DBMS_SCHEDULER.ADD_WINDOW_GROUP_MEMBER
    (group_name  => 'SYS.MAINTENANCE_WINDOW_GROUP',
     window_list => 'MORNING_WINDOW,NIGHT_WINDOW');
  --
  DBMS_AUTO_TASK_ADMIN.DISABLE ('auto optimizer stats collection', NULL, 'MONDAY_WINDOW');
  DBMS_AUTO_TASK_ADMIN.DISABLE ('auto optimizer stats collection', NULL, 'TUESDAY_WINDOW');
  DBMS_AUTO_TASK_ADMIN.DISABLE ('auto optimizer stats collection', NULL, 'WEDNESDAY_WINDOW');
  DBMS_AUTO_TASK_ADMIN.DISABLE ('auto optimizer stats collection', NULL, 'THURSDAY_WINDOW');
  DBMS_AUTO_TASK_ADMIN.DISABLE ('auto optimizer stats collection', NULL, 'FRIDAY_WINDOW');
  DBMS_AUTO_TASK_ADMIN.DISABLE ('auto optimizer stats collection', NULL, 'SATURDAY_WINDOW');
  DBMS_AUTO_TASK_ADMIN.DISABLE ('auto optimizer stats collection', NULL, 'SUNDAY_WINDOW');
  --
  DBMS_AUTO_TASK_ADMIN.ENABLE (
   client_name => 'auto optimizer stats collection',
   operation   => NULL,
   window_name => 'MORNING_WINDOW');
  --
  DBMS_AUTO_TASK_ADMIN.ENABLE (
   client_name => 'auto optimizer stats collection',
   operation   => NULL,
   window_name => 'NIGHT_WINDOW');
END;
/

-- Fix timezone from scheduler window
EXECUTE DBMS_SCHEDULER.SET_ATTRIBUTE('SYS.MONDAY_WINDOW',   'START_DATE',TO_TIMESTAMP_TZ('2024/01/01 00:00:00.000000 -05:00','yyyy/mm/dd hh24:mi:ss.ff tzr tzd'));
EXECUTE DBMS_SCHEDULER.SET_ATTRIBUTE('SYS.TUESDAY_WINDOW',  'START_DATE',TO_TIMESTAMP_TZ('2024/01/01 00:00:00.000000 -05:00','yyyy/mm/dd hh24:mi:ss.ff tzr tzd'));
EXECUTE DBMS_SCHEDULER.SET_ATTRIBUTE('SYS.WEDNESDAY_WINDOW','START_DATE',TO_TIMESTAMP_TZ('2024/01/01 00:00:00.000000 -05:00','yyyy/mm/dd hh24:mi:ss.ff tzr tzd'));
EXECUTE DBMS_SCHEDULER.SET_ATTRIBUTE('SYS.THURSDAY_WINDOW', 'START_DATE',TO_TIMESTAMP_TZ('2024/01/01 00:00:00.000000 -05:00','yyyy/mm/dd hh24:mi:ss.ff tzr tzd'));
EXECUTE DBMS_SCHEDULER.SET_ATTRIBUTE('SYS.FRIDAY_WINDOW',   'START_DATE',TO_TIMESTAMP_TZ('2024/01/01 00:00:00.000000 -05:00','yyyy/mm/dd hh24:mi:ss.ff tzr tzd'));
EXECUTE DBMS_SCHEDULER.SET_ATTRIBUTE('SYS.SATURDAY_WINDOW', 'START_DATE',TO_TIMESTAMP_TZ('2024/01/01 00:00:00.000000 -05:00','yyyy/mm/dd hh24:mi:ss.ff tzr tzd'));
EXECUTE DBMS_SCHEDULER.SET_ATTRIBUTE('SYS.SUNDAY_WINDOW',   'START_DATE',TO_TIMESTAMP_TZ('2024/01/01 00:00:00.000000 -05:00','yyyy/mm/dd hh24:mi:ss.ff tzr tzd'));