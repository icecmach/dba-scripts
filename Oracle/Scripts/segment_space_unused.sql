create table seg_space_unused
(segment_owner varchar2(128),
 segment_name  varchar2(128),
 segment_type  varchar2(18),
 total_bytes   number,
 unused_bytes  number);

DECLARE
  TOTAL_BLOCKS                NUMBER;
  TOTAL_BYTES                 NUMBER;
  UNUSED_BLOCKS               NUMBER;
  UNUSED_BYTES                NUMBER;
  LAST_USED_EXTENT_FILE_ID    NUMBER;
  LAST_USED_EXTENT_BLOCK_ID   NUMBER;
  LAST_USED_BLOCK             NUMBER;
  v_owner VARCHAR2(30) := 'SOE';
BEGIN
  for x in (select segment_name,
                   segment_type
            from dba_segments
            where owner = v_owner
            and segment_type in ('TABLE', 'INDEX'))
  loop
    DBMS_SPACE.unused_space (v_owner,
                             x.segment_name,
                             x.segment_type,
                             TOTAL_BLOCKS,
                             TOTAL_BYTES,
                             UNUSED_BLOCKS,
                             UNUSED_BYTES,
                             LAST_USED_EXTENT_FILE_ID,
                             LAST_USED_EXTENT_BLOCK_ID,
                             LAST_USED_BLOCK);
    insert into seg_space_unused values(v_owner,x.segment_name, x.segment_type,total_Bytes,unused_bytes);
  end loop;
  commit; 
END;
/

select sum(total_bytes)  / 1048576,
       sum(unused_bytes) / 1048576
from seg_space_unused;

select segment_name, segment_type,
total_bytes/1048576 total_mbytes,
unused_bytes/1048576 unused_mbytes,
(total_bytes - unused_bytes)/1048576 real_size_mbytes
from seg_space_unused
order by unused_bytes desc
;


--------------------------------------------------------------------------------------------------
SELECT 'Task Name : '      || f.task_name || CHR(10) ||
       'Start Run Time : ' || TO_CHAR(execution_start, 'dd-mon-yy hh24:mi') || chr (10) ||
       'Segment Name : '   || o.attr2 || CHR(10) ||
       'Segment Type : '   || o.type || CHR(10) ||
       'Partition Name : ' || o.attr3 || CHR(10) ||
       'Message : '        || f.message || CHR(10) ||
       'More Info : '      || f.more_info || CHR(10) ||
'------------------------------------------------------' Advice
FROM   dba_advisor_findings f,
       dba_advisor_objects o,
       dba_advisor_executions e
WHERE  o.task_id          = f.task_id   AND
       o.object_id        = f.object_id AND
       f.task_id          = e.task_id   AND
       e. execution_start > sysdate - 1 AND
       e.advisor_name     = 'Segment Advisor'
ORDER  BY f.task_name;

--
select segment_name, segment_type, bytes, bytes / 1024 / 1024 SIZE_MB
from   dba_segments
where  owner = 'SOE'
--and segment_name = 'ORD_CUSTOMER_IX'
;