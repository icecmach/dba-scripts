select sum(bytes)/1024/1024 index_size
from   dba_extents 
where  SEGMENT_TYPE = 'INDEX' and
       OWNER        = 'SOE';