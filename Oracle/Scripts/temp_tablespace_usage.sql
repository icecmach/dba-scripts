-- Usage by session
  SELECT b.tablespace,
         ROUND (((b.blocks * p.VALUE) / 1024 / 1024), 2) || 'M'  AS temp_size,
         a.inst_id                                               AS Instance,
         a.sid || ',' || a.serial#                               AS sid_serial,
         NVL (a.username, '(oracle)')                            AS username,
         a.program,
         a.status,
         a.sql_id
    FROM gv$session a, gv$sort_usage b, gv$parameter p
   WHERE p.name = 'db_block_size'
         AND a.saddr = b.session_addr
         AND a.inst_id = b.inst_id
         AND a.inst_id = p.inst_id
ORDER BY temp_size DESC;

-- Tablespace usage
  SELECT a.tablespace_name                                                   tablespace,
         d.TEMP_TOTAL_MB,
         SUM (a.used_blocks * d.block_size) / 1024 / 1024                    TEMP_USED_MB,
         d.TEMP_TOTAL_MB - SUM (a.used_blocks * d.block_size) / 1024 / 1024  TEMP_FREE_MB
    FROM v$sort_segment a,
         (  SELECT b.name,
                   c.block_size,
                   SUM (c.bytes) / 1024 / 1024   TEMP_TOTAL_MB
              FROM v$tablespace b, v$tempfile c
             WHERE b.ts# = c.ts#
          GROUP BY b.name, c.block_size) d
   WHERE a.tablespace_name = d.name
GROUP BY a.tablespace_name, d.TEMP_TOTAL_MB;

-- Size and free space
SELECT * FROM dba_temp_free_space;