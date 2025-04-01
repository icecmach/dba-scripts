SELECT ' alter index '
       || owner
       || '.'
       || index_name
       || ' rebuild tablespace SOE_INDEX;' CMD
FROM   dba_indexes
WHERE  index_type <> 'LOB' AND
       owner      = 'SOE';