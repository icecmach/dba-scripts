select tc.table_name,
       tc.constraint_name,
       tr.table_name,
       rc.constraint_name
from   information_schema.referential_constraints rc
inner  join information_schema.table_constraints tc on tc.constraint_name = rc.unique_constraint_name
inner  join information_schema.table_constraints tr on tr.constraint_name = rc.constraint_name
where  rc.constraint_schema = 'public'      and
       tc.constraint_type   = 'PRIMARY KEY' and
       tr.constraint_type   = 'FOREIGN KEY';