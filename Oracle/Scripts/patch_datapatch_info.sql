set markup html on;
spool datapatch-info.html
select patch_id,action,status,action_time,description,patch_uid,flags,logfile from registry$sqlpatch;
select comp_id,comp_name,status,version from dba_registry;
select owner, object_name, object_type from dba_objects where owner IN ('SYS', 'SYSTEM') and status = 'INVALID';
select owner,object_name,object_type from dba_objects where status='INVALID' order by owner;
select dbms_qopatch.get_pending_activity() from dual;
select a.ksppinm name, b.ksppstvl value from x$ksppi a, x$ksppcv b where a.indx = b.indx and a.ksppinm like '%xt_preproc_timeout%';
select owner,directory_name,directory_path from dba_directories where directory_name like '%OPATCH%';
select xmltransform(dbms_qopatch.get_opatch_install_info() , dbms_qopatch.get_opatch_xslt()) from dual;
select xmltransform (dbms_qopatch.get_opatch_lsinventory(), dbms_qopatch.GET_OPATCH_XSLT()) from dual;
select dbms_qopatch.get_opatch_lsinventory() from dual;
select dbms_sqlpatch.verify_queryable_inventory from dual;
exec dbms_qopatch.get_sqlpatch_status;
set heading off long 50000
select dbms_metadata.get_ddl('TABLE','OPATCH_XML_INV','SYS') from dual;
select * from OPATCH_XML_INV ;
select OWNER, OBJECT_NAME, OBJECT_TYPE, STATUS from dba_objects where STATUS = 'INVALID';
select * from PDB_PLUG_IN_VIOLATIONS where STATUS != 'RESOLVED';
set markup html off;
spool off

--

set markup html on spool on
spool sqlpatch.html
set pagesize 50000;
set echo on;
set feedback on;
SELECT SYSTIMESTAMP FROM DUAL;
ALTER SESSION SET CONTAINER = CDB$ROOT;
show con_name;
select INSTANCE_NUMBER,INSTANCE_NAME,STATUS,CON_ID from v$instance;
show pdbs;
SELECT NAME, CON_ID FROM V$CONTAINERS ORDER BY CON_ID;
select * from V$PDBS;
select * from pdb_alert$;
select * from PDB_PLUG_IN_VIOLATIONS ;
select * from registry$sqlpatch;
select comp_name, version, status from dba_registry;
select owner, object_name, object_type from dba_objects where owner IN ('SYS', 'SYSTEM') and status = 'INVALID';
select owner,object_name,object_type from dba_objects where status='INVALID' order by owner;
ALTER SESSION SET CONTAINER = PDB$SEED;
show con_name;
select * from registry$sqlpatch;
select comp_name, version, status from dba_registry;
select owner, object_name, object_type from dba_objects where owner IN ('SYS', 'SYSTEM') and status = 'INVALID';
select owner,object_name,object_type from dba_objects where status='INVALID' order by owner;
ALTER SESSION SET CONTAINER = CON_NAME;
show con_name;
select * from registry$sqlpatch;
select comp_name, version, status from dba_registry;
select owner, object_name, object_type from dba_objects where owner IN ('SYS', 'SYSTEM') and status = 'INVALID';
select owner,object_name,object_type from dba_objects where status='INVALID' order by owner;
spool off
set markup html off preformat off