col USED_CHANGE_TRACKING format a25
col CONTROLFILE_TYPE format a25
col USED_OPTIMIZATION format a25
col PLUGGED_READONLY format a25
col UNDO_OPTIMIZED format a25
col BACKED_BY_PDB format a25
col SPARSE_BACKUP format a25
set lines 32000 pages 100000 trimspool on numw 20
alter session set nls_date_format='DD-Mon-YYYY HH24:MI:SS';
spool bct_change_rate_raw.csv
select * from v$backup_datafile where checkpoint_time > to_date('01-Oct-2021','dd-Mon-YYYY') order by checkpoint_change#;
spool off
