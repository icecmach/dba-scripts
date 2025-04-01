SELECT t.owner,
       t.table_name,
       t.num_rows,
       t.stale_stats stale,
       NVL (p.preference_value, 10) STALE_PERCENT,
       ROUND (((m.inserts + m.updates + m.deletes) / DECODE(t.num_rows, 0, 1, t.num_rows) * 100), 2) pct_changes,
       inserts,
       updates,
       deletes,
       truncated,
       t.last_analyzed mods_since,
       m.timestamp     last_flushed
FROM dba_tab_modifications m,
     dba_tab_statistics t,
     dba_tab_stat_prefs p
WHERE t.owner = m.table_owner
AND t.table_name = m.table_name
AND p.table_name(+) = t.table_name
AND p.owner(+) = t.owner
AND p.preference_name(+) = 'STALE_PERCENT'
and t.num_rows > 0