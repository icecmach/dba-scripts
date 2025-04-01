-- To determine the trace file for each Oracle Database process
SELECT PID, PROGRAM, TRACEFILE FROM V$PROCESS;

-- To find all trace files for the current instance
SELECT VALUE FROM V$DIAG_INFO WHERE NAME = 'Diag Trace';

-- To find the trace file for your current session
SELECT VALUE FROM V$DIAG_INFO WHERE NAME = 'Default Trace File';