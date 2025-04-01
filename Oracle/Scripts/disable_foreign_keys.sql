declare
    vsql VARCHAR2(4000);
begin
    for x in (
    SELECT 'ALTER TABLE '||OWNER||'.'||
           TABLE_NAME||' DISABLE CONSTRAINT '||CONSTRAINT_NAME AS sql_string,
           CONSTRAINT_NAME
    FROM   ALL_CONSTRAINTS
    WHERE  CONSTRAINT_TYPE='R'
    AND    OWNER='SYSADM'
    ) loop
        vsql := x.sql_string;
        execute immediate vsql;
    end loop;
end;
/