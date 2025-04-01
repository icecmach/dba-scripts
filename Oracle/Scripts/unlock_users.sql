set serveroutput on
declare
  --
  v_user dba_users.username%TYPE;
  v_pass clob;
  --
  cursor cur_locked_users is
    select username
    from   dba_users du
    where  username not in ('AUDSYS', 'DBSNMP', 'DIP', 'OUTLN', 'SYSBACKUP', 'SYSDG', 'SYSKM', 'WMSYS', 'XDB', 'XS$NULL')
    and    account_status != 'OPEN';
  --
  cursor cur_expired_users is
    select username,
           REGEXP_SUBSTR(DBMS_METADATA.get_ddl ('USER',username), '''[^'']+''') passwd
    from   dba_users
    where  account_status = 'EXPIRED';
  --
begin
  --
  open cur_locked_users;
  loop
    fetch cur_locked_users into v_user;
    exit when cur_locked_users%NOTFOUND;
    execute immediate 'alter user ' || v_user || ' account unlock';
    DBMS_OUTPUT.PUT_LINE('User account ' || v_user || ' unlocked!');
  end loop;
  close cur_locked_users;
  --
  open cur_expired_users;
  loop
    fetch cur_expired_users into v_user, v_pass;
    exit when cur_expired_users%NOTFOUND;
    execute immediate 'alter user ' || v_user || ' identified by values ' || v_pass;
    dbms_output.put_line('User account ' || v_user || ' password altered!');
  end loop;
  close cur_expired_users;
  --
end;
/