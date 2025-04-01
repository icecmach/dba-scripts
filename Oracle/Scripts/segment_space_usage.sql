create table seg_space_usage
(segment_owner varchar2(128),
 segment_name  varchar2(128),
 segment_type  varchar2(18),
 unformatted_bytes number,
 fs1_bytes         number,
 fs2_bytes         number,
 fs3_bytes         number,
 fs4_bytes         number,
 full_bytes        number);

DECLARE
  unf   number; 
  unfb  number; 
  fs1   number; 
  fs1b  number; 
  fs2   number; 
  fs2b  number; 
  fs3   number; 
  fs3b  number; 
  fs4   number; 
  fs4b  number; 
  full  number; 
  fullb number;
  v_owner VARCHAR2(30) := 'MEC861';
BEGIN
  for x in (select segment_name,
                   segment_type
            from dba_segments
            where owner = v_owner
            and segment_type in ('TABLE', 'INDEX'))
  loop
    dbms_space.space_usage(v_owner, x.segment_name, x.segment_type,
                           unf, unfb, 
                           fs1, fs1b, 
                           fs2, fs2b, 
                           fs3, fs3b, 
                           fs4, fs4b, 
                           full,fullb);
    insert into seg_space_usage values(v_owner, x.segment_name, x.segment_type, unfb, fs1b, fs2b, fs3b, fs4b, fullb);
  end loop;
  commit; 
END;
/


select sg.segment_name,
       round(free_bytes / 1048576, 2) as free_mbytes,
       round(sg.BYTES / 1048576, 2)   as alloc_mbytes,
       round((free_bytes / sg.bytes) * 100, 2) as free_pct
from (select segment_owner, segment_name,
       (unformatted_bytes
       + fs1_bytes
       + fs2_bytes * 0.25
       + fs3_bytes * 0.5
       + fs4_bytes * 0.75) as free_bytes
      from seg_space_usage) su
inner join dba_segments sg on sg.owner = su.SEGMENT_OWNER and sg.SEGMENT_NAME = su.segment_name
order by 2 desc