SELECT segment_name,
       segment_type,
       bytes / 1024 / 1024 as megabytes
FROM dba_segments s
where s.owner=''
order by 3 desc
