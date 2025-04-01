-- Sql plus
sql> SHOW SGA;

-- SGA size
SELECT name,value/1024/1024 "SGA (MB)" FROM v$sga;

-- Total SGA size
SELECT sum(value)/1024/1024 "TOTAL SGA (MB)" FROM v$sga;

-- displays information about the dynamic SGA components. This view summarizes information based on all completed SGA resize operations since instance startup
select component,
     current_size/1048576 as "current_size (MB)",
     min_size/1048576 as "min_size (MB)",
     max_size/1048576 as "max_size (MB)",
     user_specified_size/1048576 as "user_specified_size (MB)",
     oper_count,
     last_oper_type,
     last_oper_mode,
     last_oper_time,
     granule_size/1048576 as "granule_size (MB)",
     con_id
from V$SGA_DYNAMIC_COMPONENTS;

select component,
     current_size/1048576 as "current_size (MB)",
     min_size/1048576 as "min_size (MB)",
     max_size/1048576 as "max_size (MB)",
     oper_count,
     last_oper_type,
     last_oper_mode,
     last_oper_time,
     granule_size/1048576 as "granule_size (MB)"
from V$SGA_DYNAMIC_COMPONENTS;

-- displays information about the amount of SGA memory available for future dynamic SGA resize operations.
select current_size/1048576 as "current_size (MB)", con_id
from V$SGA_DYNAMIC_FREE_MEMORY;

-- displays information about the last 800 completed SGA resize operations. This does not include in-progress operations
select * from V$SGA_RESIZE_OPS order by start_time desc;


select * from V$SHARED_POOL_ADVICE;


select * from V$SHARED_POOL_RESERVED;

