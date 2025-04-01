SELECT cp.objtype
	,cp.cacheobjtype
	,cp.usecounts
	,st.TEXT
	,qp.query_plan
FROM sys.dm_exec_cached_plans cp
OUTER APPLY sys.dm_exec_sql_text(cp.plan_handle) st
OUTER APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
WHERE st.dbid = db_id('dbname')
and st.TEXT LIKE '%CustomLog%'