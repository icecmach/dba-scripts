create table t11 as select * from all_objects;
select count(*) from t11;
insert into t11 select * from t11;

select * from t11;

select object_type, count(*) from t11 group by object_type;

create index idx_01 on t11(object_id);
create index idx_02 on t11(object_type);

set autotrace on
set timing on
declare
    type tbl_object_id is table of number index by pls_integer;
    vtObjectId tbl_object_id;
    --vnCountSqlRows number := 0;
    
    cursor cur_delete(p_object varchar2) is
        select object_id
        from   t11
        where  object_type = p_object;
begin
    open cur_delete('SYNONYM');
    loop
        fetch cur_delete
        bulk collect into vtObjectId limit 2000;
        
        forall i IN vtObjectId.FIRST..vtObjectId.LAST
        delete from t11
        where object_id = vtObjectId(i);
        commit;
        exit when cur_delete%NOTFOUND;
    end loop;
    commit;
    close cur_delete;
exception
    when others then
        if (cur_delete%ISOPEN) then
            close cur_delete;
        end if;
        rollback;
end;
/