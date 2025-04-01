select * from V$SGA; --Displays summary information about the system global area (SGA).
select * from V$SGAINFO; --Displays size information about the SGA, including the sizes of different SGA components, the granule size, and free memory.
select * from V$SGASTAT; --Displays detailed information about how memory is allocated within the shared pool, large pool, Java pool, and Streams pool.
select * from V$PGASTAT; --Displays PGA memory usage statistics as well as statistics about the automatic PGA memory manager when it is enabled (that is, when PGA_AGGREGATE_TARGET is set). Cumulative values in V$PGASTAT are accumulated since instance startup.
select * from V$MEMORY_DYNAMIC_COMPONENTS; --Displays information on the current size of all automatically tuned and static memory components, with the last operation (for example, grow or shrink) that occurred on each.
select * from V$SGA_DYNAMIC_COMPONENTS; --Displays the current sizes of all SGA components, and the last operation for each component.
select * from V$SGA_DYNAMIC_FREE_MEMORY; --Displays information about the amount of SGA memory available for future dynamic SGA resize operations.
select * from V$MEMORY_CURRENT_RESIZE_OPS; --Displays information about resize operations that are currently in progress. A resize operation is an enlargement or reduction of the SGA, the instance PGA, or a dynamic SGA component.
select * from V$SGA_CURRENT_RESIZE_OPS; --Displays information about dynamic SGA component resize operations that are currently in progress.
select * from V$MEMORY_RESIZE_OPS; --Displays information about the last 800 completed memory component resize operations, including automatic grow and shrink operations for SGA_TARGET and PGA_AGGREGATE_TARGET.
select * from V$SGA_RESIZE_OPS; -- Displays information about the last 800 completed SGA component resize operations.
select * from V$MEMORY_TARGET_ADVICE; --Displays information that helps you tune MEMORY_TARGET if you enabled automatic memory management.
select * from V$SGA_TARGET_ADVICE; --Displays information that helps you tune SGA_TARGET.
select * from V$PGA_TARGET_ADVICE; --Displays information that helps you tune PGA_AGGREGATE_TARGET.
select * from V$IM_SEGMENTS; --Displays information about the storage allocated for all segments in the IM column store.