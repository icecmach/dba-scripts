set serveroutput on size 100000
REM --------------------------------------------------------------------------------------------------
REM Author: Riyaj Shamsudeen @OraInternals, LLC
REM         www.orainternals.com
REM
REM Functionality: This script is to print Change in Segment statistics
REM **************
REM
REM Source  : gv$segment_statistics, gv$segstat_name
REM
REM Note : 1. Keep window 160 columns for better visibility.
REM
REM Exectution type: Execute from sqlplus or any other tool.  Modify sleep as needed. Default is 60 seconds
REM
REM Parameters:
REM No implied or explicit warranty
REM
REM Please send me an email to rshamsud@orainternals.com for any question..
REM  NOTE   1. Querying gv$ tables when there is a GC performance issue is not exactly nice. So, don't run this too often.
REM         2. Until 11g, gv statistics did not include PQ traffic.
REM         3. Of course, this does not tell any thing about root cause :-)
REM @copyright : OraInternals, LLC. www.orainternals.com
REM Version     Change
REM ----------  --------------------
REM 1.01        Initial version
REM --------------------------------------------------------------------------------------------------
PROMPT
PROMPT
PROMPT  segment_stats_delta.sql v1.01 by Riyaj Shamsudeen @orainternals.com
PROMPT
PROMPT  ...Prints Change in segment statistics in the past N seconds.
PROMPT  ...Default collection period is 60 seconds.... Please wait for at least 60 seconds...
PROMPT
PROMPT  !!! NOTICE !!! This scripts drops and recreates two types: segment_stats_tbl_type and segment_stats_type. 
PROMPT
PROMPT Following are the avaliable statistics: 
PROMPT   Pay close attention to sampled column below. Statistics which are sampled are not exact and so, it might not reflect immediately.
PROMPT
select name, sampled from v$segstat_name;
PROMPT
pause 'Press any key to continue' 
undef sleep
set lines 170 pages 100
set verify off
set lines 140 pages 100 
col owner format A12
col object_name format A30
col statistic_name format A30 
col object_type format A10
col value format 99999999999
col perc format 99.99
set pause off
drop type segment_stats_tbl_type;
drop type segment_stats_type;
create type segment_stats_type  is object
  ( inst_id number,
    owner  varchar2(32),
    object_name varchar2(32),
    subobject_name varchar2(30),
    object_type varchar2(32),
    statistic_name varchar2(64), 
    value number
  )
/
create type segment_stats_tbl_type as table of segment_stats_type
/
undef statistic_name
undef sleep_duration
set serveroutput on size 1000000
declare
  beg_segment_stats_tbl  segment_stats_tbl_type := segment_stats_tbl_type();
  end_segment_stats_tbl  segment_stats_tbl_type := segment_stats_tbl_type ();
  srt_segment_stats_tbl  segment_stats_tbl_type := segment_stats_tbl_type ();
begin
   select  segment_stats_type(inst_id, owner, object_name,subobject_name, object_type, statistic_name, value )
     bulk collect into beg_segment_stats_tbl
   from gv$segment_statistics
   where  statistic_name='&&statistic_name' and value >0;
   dbms_lock.sleep (&sleep_duration);
   select  segment_stats_type(inst_id, owner, object_name,subobject_name, object_type, statistic_name, value)
    bulk collect  into end_segment_stats_tbl
   from gv$segment_statistics
   where  statistic_name='&&statistic_name' and value >0;
   select cast ( multiset(
                 select    inst_id, owner, object_name, object_type,' ' subobject_name, statistic_name, diff
                  from  (
                  select  b.inst_id, b.owner, b.object_name, b.object_type, b.statistic_name,sum(e.value-b.value) diff
                    from table ( beg_segment_stats_tbl) b, table ( end_segment_stats_tbl) e
                   where b.owner=e.owner and b.object_name=e.object_name and
                          b.object_type=e.object_type and b.inst_id=e.inst_id
                           and b.statistic_name=e.statistic_name
                           and b.subobject_name = e.subobject_name
                    group by  b.inst_id, b.owner, b.object_name, b.object_type, b.statistic_name
                    having sum(e.value-b.value) > 0
                   order by  6 desc
                  ) where rownum <50
                 ) as  segment_stats_tbl_type )
	   into srt_segment_stats_tbl
   from dual;
   if srt_segment_stats_tbl.count >0 then
   for idx in srt_segment_stats_tbl.first .. srt_segment_stats_tbl.last
     loop
       dbms_output.put_line ( rpad ( srt_segment_stats_tbl(idx).owner, 30, ' ') || ' | ' || rpad(srt_segment_stats_tbl(idx).object_name,30,' ') || ' | ' || srt_segment_stats_tbl(idx).value) ;
     end loop;
   else
     dbms_output.put_line (' ');
     dbms_output.put_line (' No increase in statistics!. Try a bigger time window.' );
     dbms_output.put_line (' ');
   end if;
end;
/
