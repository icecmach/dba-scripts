Enable auditing on database
The auditing is enabled by setting the AUDIT_TRAIL parameter to a value different than NONE followed by a restart of the database.
When you set this parameter to DB, audit data is written to the SYS.AUD$ table in the SYSTEM tablespace by default.

SQL> connect / as sysdba
SQL> alter system set audit_trail=DB scope=spfile;
SQL> shutdown immediate
SQL> startup


Validation in which tablespace the AUD$ table is:

SELECT table_name, tablespace_name FROM dba_tables WHERE table_name IN ('AUD$') ORDER BY table_name;


Create a new tablespace:
When there is already data into AUD$ table, you have to create the new datafile big enough to hold the actual data.
So, you will have to modify the initial size.
The maxsize is intentionnaly set to 10Gig, this will give us time to react before this table to becomes too big.

CREATE TABLESPACE AUDIT_DATA
DATAFILE '/datafile_location/datafile_name'
SIZE 500M AUTOEXTEND ON NEXT 500M MAXSIZE 10G;


Move the standard audit trail table to the new tablespace.

BEGIN
  DBMS_AUDIT_MGMT.set_audit_trail_location (audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD, audit_trail_location_value => 'AUDIT_DATA');
END;
/


Auditing connects (login) attempts

SQL> AUDIT SESSION;

This will audit connections to Oracle Database regardless of success or failure.

SELECT * FROM DBA_STMT_AUDIT_OPTS;


Report of Audit session

SQL> SELECT os_username,
       username,
       terminal,
       returncode,
       TO_CHAR(timestamp, 'DD-MON-YYYY HH24:MI:SS') LOGON_TIME,
       TO_CHAR(logoff_time, 'DD-MON-YYYY HH24:MI:SS') LOGOFF_TIME
     FROM dba_audit_trail
     order by TIMESTAMP desc;

Disable auditing on database

SQL> connect / as sysdba
SQL> NOAUDIT SESSION;


Delete the AUD$ table content.

SQL > truncate table sys.aud$ drop storage;

Archive data if necessary


Deactivate auditing that is not needed

NOAUDIT <statement>;


Retrieve information about standard auditing parameters

SELECT PARAMETER_NAME, PARAMETER_VALUE, AUDIT_TRAIL
FROM DBA_AUDIT_MGMT_CONFIG_PARAMS
WHERE audit_trail = 'STANDARD AUDIT TRAIL';


Retrieve information about what user login for the last year broken by month.

SELECT to_char(extended_timestamp,'YYYY')|| to_char(extended_timestamp,'MM') "Period",
       username "Username",
       count(*)
from  DBA_AUDIT_SESSION
where extended_timestamp > sysdate-365 and action_name='LOGON'
group by to_char(extended_timestamp,'YYYY')|| to_char(extended_timestamp,'MM'), username
order by to_char(extended_timestamp,'YYYY')|| to_char(extended_timestamp,'MM'), username desc;


References:
Master Note for Oracle Database Auditing (Doc ID 1299033.1)
How to Truncate, Delete, or Purge Rows from the Audit Trail Table AUD$ (Doc ID 73408.1)
SCRIPT: Basic example to manage AUD$ table in 11.2 with dbms_audit_mgmt (Doc ID 1362997.1)

