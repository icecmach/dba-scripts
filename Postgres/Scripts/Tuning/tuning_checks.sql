--------------------------------
-- Verificacao do uso de memoria
--------------------------------

--
-- Verificacao de uso de cache pela pg_stat_database
--
--- Valores muito baixo podem indicar pouca memoria para shared buffers
---

SELECT sum ( blks_hit ) /
	   sum (( blks_read + blks_hit ) :: numeric ) as cache_ratio
FROM   pg_stat_database
WHERE  blks_read + blks_hit <> 0;

select datname, 
       (blks_hit::numeric / (blks_hit + blks_read)::numeric)*100 as read_hit_percentage,* 
from   pg_stat_database
where  blks_hit + blks_read > 0;

-----------------------------------------
-- Verificacao do processo de CHECKPOINTs
-----------------------------------------

--
-- Verificando escrita de buffers pelo processo checkpointer VS backends pg_stat_bgwriter:
--
--- Buscamos um valor mais alto (sendo 1.0 a taxa ideal), valores proximos a 0.0 podem
--- indicar a necessidade de forcar mais CHECKPOINTs ou aumentar a shared buffers
---

SELECT buffers_checkpoint /
       ( buffers_checkpoint + buffers_backend )
       :: numeric AS checkpointer_ratio
FROM   pg_stat_bgwriter ;

--
-- Verificacao das requisicoes de CHECKPOINT pela pg_stat_bgwriter:
--
--- Tambem buscamos taxas proximas a 1.0, sendo que valores muito baixos podem indicar
--- necessidade de aumento do parametro checkpoint segments ou reducao do checkpoint timeout
---

SELECT checkpoints_timed /
       ( checkpoints_timed + checkpoints_req )
       :: numeric AS timed_ratio
FROM   pg_stat_bgwriter ;

-------------------------------------
-- Utilizacao de Arquivos Temporarios
-------------------------------------

--
-- Tambem utilizando a pg_stat_database, podemos ver o tamanho de arquivos temporarios gerados:
--
--- Utilizacao de arquivos temporarios degenera a performance, pode ser preciso aumentar o work mem
---

SELECT pg_size_pretty ( sum ( temp_bytes ) ) AS size
FROM   pg_stat_database ;

-----------------------------------------------
-- Verificacao de Tabelas com Muito “Seq-Scans”
-----------------------------------------------

--
-- Usando a visao pg_stat_user_tables:
--
--- Que tal olhar com carinho as consultas dessas tabelas? Mas lembre-se, para tabelas pequenas ou
--- consultas que trazem grandes porcoes da tabela “seq-scan” nao e ruim
---

SELECT relname , seq_scan , idx_scan
FROM   pg_stat_user_tables
ORDER BY seq_scan DESC LIMIT 10;

----------------------------------------
-- Verificacao de Indices Nao Utilizados
----------------------------------------

--
-- Para informacoes de ındices especıficos usamos a pg_stat_user_indexes:
--
--- Indices nao utilizados, muitas vezes podem ser removidos. Mas nem sempre!
---

SELECT relname , indexrelname
FROM   pg_stat_user_indexes
WHERE  idx_scan = 0;



select now() - query_start AS elapsed, 
current_query AS sql_text, 
datname AS database, 
usename AS username
from    pg_stat_activity
where now() - query_start > '00:01:00'   /* we only want queries lasting more than one minute */
order by 1 desc;

select now() - query_start AS elapsed, 
query AS sql_text, 
datname AS database, 
usename AS username
from    pg_stat_activity
where now() - query_start > '00:01:00'   /* we only want queries lasting more than one minute */
and state = 'active'
order by 1 desc;



https://www.vertabelo.com/blog/technical-articles/using-sql-to-monitor-a-postgresql-database
https://www.enterprisedb.com/blog/tuning-sharedbuffers-and-walbuffers
https://gist.github.com/rgreenjr
https://www.cybertec-postgresql.com/en/3-ways-to-detect-slow-queries-in-postgresql/#


-- show running queries (pre 9.2)
SELECT procpid, age(clock_timestamp(), query_start), usename, current_query 
FROM pg_stat_activity 
WHERE current_query != '<IDLE>' AND current_query NOT ILIKE '%pg_stat_activity%' 
ORDER BY query_start desc;

-- show running queries (9.2)
SELECT pid, age(clock_timestamp(), query_start), usename, query 
FROM pg_stat_activity 
WHERE query != '<IDLE>' AND query NOT ILIKE '%pg_stat_activity%' 
ORDER BY query_start desc;

-- kill running query
SELECT pg_cancel_backend(procpid);

-- kill idle query
SELECT pg_terminate_backend(procpid);

-- vacuum command
VACUUM (VERBOSE, ANALYZE);

-- all database users
select * from pg_stat_activity where current_query not like '<%';

-- all databases and their sizes
select * from pg_user;

-- all tables and their size, with/without indexes
select datname, pg_size_pretty(pg_database_size(datname))
from pg_database
order by pg_database_size(datname) desc;

-- cache hit rates (should not be less than 0.99)
SELECT sum(heap_blks_read) as heap_read, sum(heap_blks_hit)  as heap_hit, (sum(heap_blks_hit) - sum(heap_blks_read)) / sum(heap_blks_hit) as ratio
FROM pg_statio_user_tables;

-- table index usage rates (should not be less than 0.99)
SELECT relname, 100 * idx_scan / (seq_scan + idx_scan) percent_of_times_index_used, n_live_tup rows_in_table
FROM pg_stat_user_tables 
ORDER BY n_live_tup DESC;

-- how many indexes are in cache
SELECT sum(idx_blks_read) as idx_read, sum(idx_blks_hit)  as idx_hit, (sum(idx_blks_hit) - sum(idx_blks_read)) / sum(idx_blks_hit) as ratio
FROM pg_statio_user_indexes;