/* As ORA-01775: looping chain of synonyms is the standard Oracle error for an
   attempt to reference a public synonym after dropping the underlying object
   (and the object and synonym had the same name, so now the only object left
    with that name is the synonym itself).
*/
select s.table_owner, s.synonym_name
from   all_synonyms s
       join dba_objects o
            on  o.owner= s.owner
            and o.object_name = s.synonym_name
where  s.owner = 'PUBLIC'
and    s.table_owner <> 'SYS'
and    s.table_name = s.synonym_name
and    s.synonym_name not like '%/%'
and    o.object_type = 'SYNONYM'
and    o.sharing = 'NONE'
minus
select o.owner, o.object_name
from   dba_objects o
where  o.subobject_name is null;