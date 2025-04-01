-- Possiveis campos de tabelas AF_ (ou outro filtro) que estejam sem FK
select cl.table_name,
       cl.column_name,
       cl.ordinal_position
from   information_schema.columns cl
where  table_schema = 'public'  and
       table_name   like 'af_%' and
       column_name  like 'id%'  and
       -- Desconsiderar colunas que possivelmente sao Primary Key
       -- e possuem Foreign Key
       not exists (select 1
                   from   information_schema.key_column_usage kc
                   where  kc.table_name  = cl.table_name  and
                          kc.column_name = cl.column_name and
                          kc.constraint_name like 'pk%') and
       not exists (select 1
                   from   information_schema.key_column_usage kc
                   where  kc.table_name  = cl.table_name  and
                          kc.column_name = cl.column_name and
                          kc.constraint_name like 'fk%')
order  by 1, 3;
