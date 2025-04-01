set serveroutput on
begin
    for x in (
    select owner,
           synonym_name
    from   dba_synonyms
    where  table_name in ('SBR_PROCESS_CONTR', 'SBR_PROCESS_BILL_CYCLES', 'SBR_PROCESS_BILLCYCLE_INSTANCE',
    					  'BI_CRED_ACCOUNTS', 'BI_ACCOUNTS', 'BI_ACCOUNTS_VIEW',
    					  'TOPUP_REQUEST', 'TOPUP_ACTION_HISTORY', 'TOPUP_REQUEST_ACTION_VIEW',
    					  'RTX_BCH', 'BCH_LT_APPEND',
    					  'BCH_UDR_LT_ST', 'UDR_LT', 'UDR_ST')
    and    db_link is not null
    and    owner = 'PUBLIC'
    )
    loop
        begin
            execute immediate 'drop public synonym ' || x.synonym_name;
            dbms_output.put_line ( 'synonym dropped '||x.owner||'.'||x.synonym_name);
            --
            execute immediate 'create public synonym ' || '"'||x.synonym_name||'" for "'||x.synonym_name||'"';
            dbms_output.put_line ( 'synonym created '||x.owner||'.'||x.synonym_name);
        exception when others then 
            dbms_output.put_line ( 'unable to recreate '||x.owner||'.'||x.synonym_name||' '||' -ERROR- '||SQLERRM);
        end;
    end loop;
end;
/