alter session set container=PDB$SEED;
alter session set "_oracle_script"=TRUE;
alter pluggable database pdb$seed close immediate instances=all;
alter pluggable database pdb$seed OPEN READ WRITE;

@?/rdbms/admin/utlrp.sql; --run couple of times to resolve dependencies

alter pluggable database pdb$seed close immediate instances=all;
alter pluggable database pdb$seed OPEN READ ONLY;

set lines 180 pages 200
column owner format a10
column object_name format A30
col COMP_NAME for a50
col name for a35
col type for a30
col text for a100
select COMP_ID, comp_name,version,status from dba_registry order by 4, 2;
select owner, object_name,object_type,status,created,last_ddl_time from dba_objects where status='INVALID' order by 1,2;
select owner, name,type,LINE, text from dba_errors order by owner, name,type,line;