SELECT name,
    s.used / 128.0 AS SpaceUsedInMB,
    size / 128.0 - s.used / 128.0 AS AvailableSpaceInMB
FROM sys.database_files
CROSS APPLY (SELECT CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)) s(used)
WHERE FILEPROPERTY(name, 'SpaceUsed') IS NOT NULL;
