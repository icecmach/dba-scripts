--3605 – Sends the output to errorlog
--3213 – Provides information about backup or restore throughput and other configurations
DBCC TRACEON (3605, -1);
DBCC TRACEON (3213, -1);

DBCC TRACEOFF (3605, -1);
DBCC TRACEOFF (3213, -1);
