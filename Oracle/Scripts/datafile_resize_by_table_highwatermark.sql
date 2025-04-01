/* Formatted on 6/11/2024 2:04:48 PM (QP5 v5.404) */
REM Script is meant for Oracle version 9 and higher
REM -----------------------------------------------

SET SERVEROUTPUT ON
EXEC dbms_output.enable(1000000);

DECLARE
  CURSOR c_dbfile IS
      SELECT f.tablespace_name,
             f.file_name,
             f.file_id,
             f.blocks,
             t.block_size,
             DECODE (t.allocation_type,
                     'UNIFORM', t.initial_extent / t.block_size,
                     0)    uni_extent,
             DECODE (t.allocation_type,
                     'UNIFORM', (128 + (t.initial_extent / t.block_size)),
                     128)  file_min_size
        FROM dba_data_files f, dba_tablespaces t
       WHERE     f.tablespace_name = t.tablespace_name
             AND t.status = 'ONLINE'
             AND t.tablespace_name = 'SYSAUX'
    ORDER BY f.tablespace_name, f.file_id;

  CURSOR c_freespace (v_file_id IN NUMBER)
  IS
      SELECT block_id, block_id + blocks max_block
        FROM dba_free_space
       WHERE file_id = v_file_id
    ORDER BY block_id DESC;

  /* variables to check settings/values */
  dummy                   NUMBER;
  checkval                VARCHAR2 (10);
  block_correction1       NUMBER;
  block_correction2       NUMBER;

  /* running variable to show (possible) end-of-file */
  file_min_block          NUMBER;

  /* variables to check if recycle_bin is on and if extent as checked is in ... */
  recycle_bin             BOOLEAN := FALSE;
  extent_in_recycle_bin   BOOLEAN;

  /* exception handler needed for non-existing tables note:344940.1 */
  sqlstr                  VARCHAR2 (100);
  table_does_not_exist    EXCEPTION;
  PRAGMA EXCEPTION_INIT (table_does_not_exist, -942);

  /* variable to spot space wastage in datafile of uniform tablespace */
  space_wastage           NUMBER;
BEGIN
  /* recyclebin is present in Oracle 10.2 and higher and might contain extent as checked */
  BEGIN
    SELECT VALUE
      INTO checkval
      FROM v$parameter
     WHERE name = 'recyclebin';

    IF checkval = 'on'
    THEN
      recycle_bin := TRUE;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      recycle_bin := FALSE;
  END;

  /* main loop */
  FOR c_file IN c_dbfile
  LOOP
    /* initialization of loop variables */
    dummy := 0;
    extent_in_recycle_bin := FALSE;
    file_min_block := c_file.blocks;

    BEGIN
      space_wastage := 0;                     /* reset for every file check */

     <<check_free>>
      FOR c_free IN c_freespace (c_file.file_id)
      LOOP
        /* if blocks is an uneven value there is a need to correct
        with -1 to compare with end-of-file which is even */
        block_correction1 := (0 - MOD (c_free.max_block, 2));
        block_correction2 := (0 - MOD (c_file.blocks, 2));

        IF file_min_block + block_correction2 =
           c_free.max_block + block_correction1
        THEN
          /* free extent is at end so file can be resized */
          file_min_block := c_free.block_id;
        /* Uniform sized tablespace check if space at end of file
        is less then uniform extent size */
        ELSIF     (c_file.uni_extent != 0)
              AND ((c_file.blocks - c_free.max_block) < c_file.uni_extent)
        THEN
          /* uniform tablespace which has a wastage of space in datafile
          due to fact that space at end of file is smaller than uniform extent size */

          space_wastage := c_file.blocks - c_free.max_block;
          file_min_block := c_free.block_id;
        ELSE
          /* no more free extent at end of file, file cannot be further resized */
          EXIT check_free;
        END IF;
      END LOOP;
    END;

    /* check if file can be resized, minimal size of file 128 {+ initial_extent} blocks */
    IF    (file_min_block = c_file.blocks)
       OR (c_file.blocks <= c_file.file_min_size)
    THEN
      DBMS_OUTPUT.put_line (
           'Tablespace: '
        || c_file.tablespace_name
        || ' Datafile: '
        || c_file.file_name);
      DBMS_OUTPUT.put_line ('cannot be resized no free extents found');
      DBMS_OUTPUT.put_line (
        'Note: for some cases, dba_free_spaces data is not accurate, and this script does not work for such cases. You may want to manually check if the datafile is feasible to be resized');
      DBMS_OUTPUT.put_line ('.');
    ELSE
      /* file needs minimal no of blocks which does vary over versions,
      using safe value of 128 {+ initial_extent} */
      IF file_min_block < c_file.file_min_size
      THEN
        file_min_block := c_file.file_min_size;
      END IF;


      DBMS_OUTPUT.put_line (
           'Tablespace: '
        || c_file.tablespace_name
        || ' Datafile: '
        || c_file.file_name);
      DBMS_OUTPUT.put_line (
           'current size: '
        || (c_file.blocks * c_file.block_size) / 1024
        || 'K'
        || ' can be resized to: '
        || ROUND ((file_min_block * c_file.block_size) / 1024)
        || 'K (reduction of: '
        || ROUND (((c_file.blocks - file_min_block) / c_file.blocks) * 100,
                  2)
        || ' %)');


      /* below is only true if recyclebin is on */
      IF recycle_bin
      THEN
        BEGIN
          sqlstr :=
               'select distinct 1 from recyclebin$ where file#='
            || c_file.file_id;

          EXECUTE IMMEDIATE sqlstr
            INTO dummy;

          IF dummy > 0
          THEN
            DBMS_OUTPUT.put_line (
              'Extents found in recyclebin for above file/tablespace');
            DBMS_OUTPUT.put_line (
              'Implying that purge of recyclebin might be needed in order to resize');
            DBMS_OUTPUT.put_line (
              'SQL> purge tablespace ' || c_file.tablespace_name || ';');
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
            NULL;
          WHEN table_does_not_exist
          THEN
            NULL;
        END;
      END IF;

      DBMS_OUTPUT.put_line (
           'SQL> alter database datafile '''
        || c_file.file_name
        || ''' resize '
        || ROUND ((file_min_block * c_file.block_size) / 1024)
        || 'K;');

      IF space_wastage != 0
      THEN
        DBMS_OUTPUT.put_line (
          'Datafile belongs to uniform sized tablespace and is not optimally sized.');
        DBMS_OUTPUT.put_line (
          'Size of datafile is not a multiple of NN*uniform_extent_size + overhead');
        DBMS_OUTPUT.put_line (
             'Space that cannot be used (space wastage): '
          || ROUND ((space_wastage * c_file.block_size) / 1024)
          || 'K');
        DBMS_OUTPUT.put_line (
             'For optimal usage of space in file either resize OR increase to: '
          || ROUND (
                 (  (c_file.blocks + (c_file.uni_extent - space_wastage))
                  * c_file.block_size)
               / 1024)
          || 'K');
      END IF;

      DBMS_OUTPUT.put_line ('.');
    END IF;
  END LOOP;
END;
/
