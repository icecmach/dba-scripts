select 'VACUUM ANALYZE ' || tablename || ';'
from   pg_tables
where  schemaname='public'
