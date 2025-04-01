-- Check free space
select tablespace_name,sum(bytes),trunc(sum(bytes)/(1024*1024) ) MBytes
from   dba_free_space
group  by tablespace_name;

-- Check free temp space
select tablespace_name, (free_space)/ (1024*1024)  "Free_Alloc_And_NotAlloc"
from   dba_temp_free_space;

-- Check datafiles size
select substr(tablespace_name,1,10) TSP,
       substr(file_name,1,50) Name,
       round(bytes/(1024*1024)) FileSizeMB,
       round(maxbytes/(1024*1024)) MaxFileSizeMB
from   dba_data_files
order  by 1,2;

-- Check tempfiles size
select substr(tablespace_name,1,10) TSP,
       substr(file_name,1,50) Name,
       round(bytes/(1024*1024)) FileSizeMB,
       round(maxbytes/(1024*1024)) MaxFileSizeMB
from   dba_temp_files
order  by 1,2;

-- Add datafile
alter tablespace
   fred
add datafile
   '/u01/oracle/oradata/booktst_users_02.dbf'
size 150M
autoextend on;

ALTER TABLESPACE YOUR_TABLESPACE_NAME ADD DATAFILE 'LOCATION_OF_CURRENT_DATAFILES/NEW_DATAFILE.dbf' SIZE 50M AUTOEXTEND ON NEXT 512K MAXSIZE 500M;

alter tablespace DATA add datafile '/home/oradata/c1tb/data/data_3.dbf' size 1024M AUTOEXTEND ON NEXT 1024M MAXSIZE 8192M;
alter tablespace DATA add datafile '/home/oradata/c1tb/data/data_4.dbf' size 1024M AUTOEXTEND ON NEXT 1024M MAXSIZE 8192M;
alter tablespace DATA add datafile '/home/oradata/c1tb/data/data_5.dbf' size 1024M AUTOEXTEND ON NEXT 1024M MAXSIZE 8192M;

-- Add tempfile
alter tablespace TEMP add tempfile '/home/oradata/c1tb/temp/temp_2.dbf' size 1024M AUTOEXTEND ON NEXT 1024M MAXSIZE 4096M;
