set serveroutput on
begin
    for x in (
    select owner,
           object_name
    from   dba_objects
    where  status = 'INVALID'
    and    object_type = 'SYNONYM'
    )
    loop
        begin
            execute immediate 'alter public synonym ' || x.object_name || ' compile';
            dbms_output.put_line ( 'synonym compiled '||x.owner||'.'||x.object_name);
        exception when others then 
            dbms_output.put_line ( 'unable to recompile '||x.owner||'.'||x.object_name||' '||' -ERROR- '||SQLERRM);
        end;
    end loop;
end;
/