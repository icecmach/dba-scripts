SELECT resource_name
     , current_utilization current_used
     , max_utilization max_used
     , limit_value limit
     , CASE WHEN TRIM( limit_value ) = 'UNLIMITED' THEN 0
            WHEN TRIM( limit_value ) = '0' THEN 0
            ELSE max_utilization * 100 / TO_NUMBER( limit_value )
       END pctmax
FROM v$resource_limit
ORDER BY 1;
