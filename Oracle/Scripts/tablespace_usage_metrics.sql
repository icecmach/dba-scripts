set echo off lin 132
set verify off

col tablespace_name head "Tablespace" for a15
col tablespace_mb head "Maxbytes| (Mbytes)" for 9,999,999,999
col used_mb head "Used Mb" for 9,999,999,999
col free_mb head "Free bytes| (Mbytes)" for 9,999,999,999
col free_percent head "% Free" for 999

SELECT tablespace_name,
     ROUND ((tablespace_size * 8192) / 1048576, 2)                tablespace_mb,
     ROUND ((used_space * 8192) / 1048576, 2)                     used_mb,
     ROUND (((tablespace_size - used_space) * 8192) / 1048576, 2) free_mb,
     ROUND (100 - used_percent, 2)                                free_percent
FROM dba_tablespace_usage_metrics
WHERE used_percent > ${Free}
and (((tablespace_size - used_space) * 8192) / 1048576) < ${FreeB}
ORDER BY used_percent DESC;