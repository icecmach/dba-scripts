SELECT TABLE_NAME,
  NUM_ROWS,
  BLOCKS,
  AVG_ROW_LEN,
  TO_CHAR(LAST_ANALYZED, 'MM/DD/YYYY HH24:MI:SS') LAST_ANALYZED
FROM DBA_TABLES
WHERE owner = '';

SELECT INDEX_NAME "NAME", NUM_ROWS, DISTINCT_KEYS "DISTINCT",
LEAF_BLOCKS, CLUSTERING_FACTOR "CF", BLEVEL "LEVEL",
AVG_LEAF_BLOCKS_PER_KEY "ALFBPKEY", TO_CHAR(LAST_ANALYZED, 'MM/DD/YYYY HH24:MI:SS') LAST_ANALYZED
FROM DBA_INDEXES
WHERE OWNER = ''
ORDER BY INDEX_NAME;

--Number of rows in the index (cardinality).
--Number of distinct keys. These define the selectivity of the index.
--Level or height of the index. This indicates how deeply the data probe must search in order to find the data.
--Number of leaf blocks in the index. This is the number of I/Os needed to find the desired rows of data.
--Clustering factor (CF). This is the collocation amount of the index block relative to data blocks. The higher the CF, the less likely the optimizer is to select this index.
--Average leaf blocks for each key (ALFBKEY). Average number of leaf blocks in which each distinct value in the index appears, rounded to the nearest integer. For indexes that enforce UNIQUE and PRIMARY KEY constraints, this value is always one.


SELECT table_name, COLUMN_NAME, NUM_DISTINCT, NUM_NULLS, NUM_BUCKETS, DENSITY
FROM DBA_TAB_COL_STATISTICS
WHERE OWNER = ''
ORDER BY table_name, COLUMN_NAME;

SELECT table_name, COLUMN_NAME, ENDPOINT_NUMBER, ENDPOINT_VALUE 
FROM DBA_HISTOGRAMS 
WHERE OWNER = ''
ORDER BY table_name, COLUMN_NAME, ENDPOINT_NUMBER; 