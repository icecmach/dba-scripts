SET linesize 200 pages 1000
SET serveroutput ON SIZE 999999
SET verify off
SET feedback off
DECLARE
  unformatted_blocks NUMBER;
  unformatted_bytes NUMBER;
  fs1_blocks NUMBER;
  fs1_bytes NUMBER;
  fs2_blocks NUMBER;
  fs2_bytes NUMBER;
  fs3_blocks NUMBER;
  fs3_bytes NUMBER;
  fs4_blocks NUMBER;
  fs4_bytes NUMBER;
  full_blocks NUMBER;
  full_bytes NUMBER;
  dbms_space_bytes NUMBER;
  bytes_dba_segments NUMBER;
  vtablespace_name dba_tables.tablespace_name%TYPE;
  vavg_row_len dba_tables.avg_row_len%TYPE;
  vnum_rows dba_tables.num_rows%TYPE;
  vpct_free dba_tables.pct_free%TYPE;
  used_bytes NUMBER;
  alloc_bytes NUMBER;
  vs_table VARCHAR2(50) := '';
  vs_owner VARCHAR2(50) := '';
  FUNCTION format_size(value1 IN NUMBER)
  RETURN VARCHAR2 AS
  BEGIN
    CASE
      WHEN (value1>1024*1024*1024) THEN RETURN LTRIM(TO_CHAR(value1/(1024*1024*1024),'999,999.999') || 'GB');
      WHEN (value1>1024*1024) THEN RETURN LTRIM(TO_CHAR(value1/(1024*1024),'999,999.999') || 'MB');
      WHEN (value1>1024) THEN RETURN LTRIM(TO_CHAR(value1/(1024),'999,999.999') || 'KB');
      ELSE RETURN LTRIM(TO_CHAR(value1,'999,999.999') || 'B');
    END CASE;
  END format_size;
BEGIN
  SELECT tablespace_name, avg_row_len, num_rows, pct_free 
  INTO vtablespace_name, vavg_row_len, vnum_rows, vpct_free 
  FROM dba_tables
  WHERE owner = vs_owner
  AND table_name = vs_table;
  dbms_output.put_line('----------------------------------------------------------------');
  dbms_output.put_line('Analyzing table ');
  dbms_output.put_line('----------------------------------------------------------------');
  dbms_output.put_line('-------------------- DBMS_SPACE.SPACE_USAGE --------------------');
  dbms_output.put_line('----------------------------------------------------------------');
  dbms_space.space_usage(vs_owner, vs_table, 'TABLE', unformatted_blocks, unformatted_bytes, fs1_blocks, fs1_bytes, fs2_blocks, fs2_bytes, fs3_blocks, fs3_bytes, fs4_blocks, fs4_bytes, full_blocks, full_bytes);
  dbms_output.put_line('Total number of blocks unformatted :' || unformatted_blocks);
  --dbms_output.put_line('Total number of bytes unformatted: ' || unformatted_bytes);
  dbms_output.put_line('Number of blocks having at least 0 to 25% free space: ' || fs1_blocks);
  --dbms_output.put_line('Number of bytes having at least 0 to 25% free space: ' || fs1_bytes);
  dbms_output.put_line('Number of blocks having at least 25 to 50% free space: ' || fs2_blocks);
  --dbms_output.put_line('Number of bytes having at least 25 to 50% free space: ' || fs2_bytes);
  dbms_output.put_line('Number of blocks having at least 50 to 75% free space: ' || fs3_blocks);
  --dbms_output.put_line('Number of bytes having at least 50 to 75% free space: ' || fs3_bytes);
  dbms_output.put_line('Number of blocks having at least 75 to 100% free space: ' || fs4_blocks);
  --dbms_output.put_line('Number of bytes having at least 75 to 100% free space: ' || fs4_bytes);
  dbms_output.put_line('The number of blocks full in the segment: ' || full_blocks);
  --dbms_output.put_line('Total number of bytes full in the segment: ' || format_size(full_bytes));
  dbms_space_bytes:=unformatted_bytes+fs1_bytes+fs2_bytes+fs3_bytes+fs4_bytes+full_bytes;
  dbms_output.put_line('----------------------------------------------------------------');
  dbms_output.put_line('------------------------- DBA_SEGMENTS -------------------------');
  dbms_output.put_line('----------------------------------------------------------------');
  SELECT bytes INTO bytes_dba_segments FROM dba_segments WHERE owner=vs_owner AND segment_name=vs_table;
  dbms_output.put_line('Size of the segment: ' || format_size(bytes_dba_segments));
  dbms_output.put_line('----------------------------------------------------------------');
  dbms_output.put_line('----------------- DBMS_SPACE.CREATE_TABLE_COST -----------------');
  dbms_output.put_line('----------------------------------------------------------------');
  dbms_space.create_table_cost(vtablespace_name, vavg_row_len, vnum_rows, vpct_free, used_bytes, alloc_bytes);
  dbms_output.put_line('Used: ' || format_size(used_bytes));
  dbms_output.put_line('Allocated: ' || format_size(alloc_bytes));
  dbms_output.put_line('----------------------------------------------------------------');
  dbms_output.put_line('---------------------------- Results ---------------------------'); 
  dbms_output.put_line('----------------------------------------------------------------');
  dbms_output.put_line('Potential percentage gain (DBMS_SPACE): ' || ROUND(100 * (dbms_space_bytes - alloc_bytes) / dbms_space_bytes) || '%');
  dbms_output.put_line('Potential percentage gain (DBA_SEGMENTS): ' || ROUND(100 * (bytes_dba_segments - alloc_bytes) / bytes_dba_segments) || '%');
END;
/