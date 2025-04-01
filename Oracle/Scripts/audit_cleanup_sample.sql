-- start sample code
connect / as sysdba

drop index i_aud_support;

create or replace procedure purge_audit_data

-- Comments for procedure purge_audit_data to cleanup audit data
-- this was written for extrmely large AUD$ table (order of several Gbytes)
-- therefore since it can take some time progress can be monitored using
-- v$session_longops :
--
-- select sid, serial#, opname, to_char(start_time,'HH24:MI:SS') start_time,
--  (sofar/(totalwork+1))*100 percent_complete from v$session_longops;
--
-- Also to avoid stress on the undo space, each day of audit data
-- that is deleted is commited separately.
--
-- Temporary index is created to avoid full table scans on the audit table.

   (retention in number,
    temporary_tablespace in varchar2 default 'USERS') as
  oldest date;
  numdays integer;
  slot binary_integer;
  dummy binary_integer;
  stmt varchar2(200);
  aud_owner varchar2(6);
  now date := sysdate;
begin
  -- In case OLS is installed AUD$ is in the SYSTEM schema
  select owner into aud_owner from dba_objects
  where object_name = 'AUD$' and object_type = 'TABLE'
  and owner in ('SYS','SYSTEM');
  -- create temporary indexe on aud$.ntimestamp#
execute immediate
 'create index i_aud_support on '||
  aud_owner||'.aud$(ntimestamp#) tablespace '||
  temporary_tablespace||' online nologging';
  dbms_stats.gather_table_stats
       (ownname => aud_owner,tabname => 'AUD$',cascade => true);
  select trunc(min(ntimestamp#)) into oldest from aud$;
  -- if oldest is null there are no audit records
  if oldest is not null then
     numdays := now-oldest-retention;
     stmt := 'delete from '||aud_owner||
             '.AUD$ where ntimestamp# < :b0 - :b1 - :b2 + :b3';
     select dbms_application_info.set_session_longops_nohint
     into slot from dual;
     dbms_application_info.set_session_longops
            (rindex => slot,
             slno => dummy,
             op_name => 'DELETE_AUDIT_WORK',
             sofar => 0,
             totalwork => numdays);
     for i in 1..numdays loop
        execute immediate stmt using now, retention, numdays, i;
        commit;
        dbms_application_info.set_session_longops
               (rindex => slot,
                slno => dummy,
                sofar => i,
                totalwork => numdays);
     end loop;
     dbms_application_info.set_session_longops
            (rindex => slot,
             slno => dummy,
             sofar => numdays,
             totalwork => numdays);
  end  if;
  execute immediate 'drop index i_aud_support';
end;
/
show err

-- sample way of calling the procedure:
--
-- begin
-- --  retention: keep 1 month
--    purge_audit_data(32);
-- end;
-- /

-- stop sample code