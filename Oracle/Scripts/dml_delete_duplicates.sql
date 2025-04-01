declare
  --
  cursor cur_com_audit_info is
    select a.rowid, a.command_audit_info_id
    from   command_audit_info a
    where  exists (select b.rowid
                   from   command_audit_info b
                   where  a.rowid > b.rowid);
  --
  type t_com_aud_info is table of cur_com_audit_info%ROWTYPE
    index by pls_integer;
  --
  l_com_aud_info t_com_aud_info;
begin
  open cur_com_audit_info;
  loop
    fetch cur_com_audit_info bulk collect into l_com_aud_info
    limit 2000;
    exit when l_com_aud_info.count = 0;
    --
    for indx in 1..l_com_aud_info.count
    loop
      delete from command_audit_info a
      where  a.COMMAND_AUDIT_INFO_ID = l_com_aud_info(indx).command_audit_info_id
      and    a.rowid != l_com_aud_info(indx).rowid;
    end loop;
    --
    commit;
    --
  end loop;
  --
  close cur_com_audit_info;
  commit;
end;
/

---

DELETE FROM your_table
WHERE rowid not in
(SELECT MIN(rowid)
FROM your_table
GROUP BY column1, column2, column3);