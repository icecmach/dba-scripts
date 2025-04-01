select table_name
from   dba_tables
where  owner='SYSADM'
minus
select distinct table_name
from   dba_tab_privs
where  grantor='SYSADM';

grant select, insert, delete, update on MPDPLTAB to BSCS_ROLE;