select l.group#,
       f.member,
       l.archived,
       l.bytes/1078576 bytes,
       l.status,
       f.type
from   v$log l, v$logfile f
where  l.group# = f.group#
order by 1;