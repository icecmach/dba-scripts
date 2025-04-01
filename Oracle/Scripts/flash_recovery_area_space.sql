SELECT name, ceil( space_limit / 1024 / 1024) SIZE_M,
       ceil( space_used  / 1024 / 1024) USED_M,
       decode( nvl( space_used, 2), 0, 0, ceil ( ( space_used / space_limit) * 100) ) PCT_USED
FROM   v$recovery_file_dest
ORDER  BY name