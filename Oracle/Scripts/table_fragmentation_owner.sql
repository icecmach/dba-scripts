SET linesize 200 pages 1000
SET serveroutput ON SIZE 999999
SET verify off
SET feedback off
DECLARE
  bytes_dba_segments NUMBER;
  vtablespace_name dba_tables.tablespace_name%TYPE;
  vavg_row_len dba_tables.avg_row_len%TYPE;
  vnum_rows dba_tables.num_rows%TYPE;
  vpct_free dba_tables.pct_free%TYPE;
  used_bytes NUMBER;
  alloc_bytes NUMBER;
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
    FOR t in (SELECT table_name, tablespace_name, avg_row_len, num_rows, pct_free 
              FROM dba_tables
              WHERE owner = ''
              AND num_rows > 0
              AND avg_row_len > 0)
    LOOP
        vtablespace_name := t.tablespace_name;
        vavg_row_len := t.avg_row_len;
        vnum_rows := t.num_rows;
        vpct_free := t.pct_free;
    
        dbms_output.put_line('----------------------------------------------------------------');
        dbms_output.put_line('Analyzing table ' || t.table_name);

        SELECT bytes
        INTO bytes_dba_segments
        FROM dba_segments
        WHERE owner = ''
        AND segment_name = t.table_name;

        dbms_output.put_line('Size of the segment: ' || format_size(bytes_dba_segments));

        dbms_space.create_table_cost(vtablespace_name, vavg_row_len, vnum_rows, vpct_free, used_bytes, alloc_bytes);

        dbms_output.put_line('Used: ' || format_size(used_bytes));
        dbms_output.put_line('Allocated: ' || format_size(alloc_bytes));
        dbms_output.put_line('Potential percentage gain (DBA_SEGMENTS): ' || ROUND(100 * (bytes_dba_segments - alloc_bytes) / bytes_dba_segments) || '%');
    END LOOP;
END;
/