SELECT 
    SUM(CASE WHEN UPPER(type_name(user_type_id)) IN ('INT', 'BIT', 'TINYINT') THEN 4 ELSE 0 END) AS Fixed_Length_Column_Sizes,
    SUM(CASE WHEN UPPER(type_name(user_type_id)) IN ('VARCHAR', 'NVARCHAR', 'NUMERIC', 'UNIQUEIDENTIFIER', 'DATETIME2') THEN DATALENGTH(max_length)
		    ELSE 0 END) AS Variable_Length_Column_Sizes
FROM
    sys.columns c
WHERE 
    object_id = OBJECT_ID('[dbo].[LOG]');
