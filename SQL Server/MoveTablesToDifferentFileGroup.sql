-------------------------------------------------------------------------------------------------------------
-- Before
-------------------------------------------------------------------------------------------------------------

SELECT    tbl.name AS [Table Name], 
          CASE WHEN dsidx.type='FG' THEN dsidx.name ELSE '(Partitioned)' END AS [File Group] 
FROM      sys.tables AS tbl 
JOIN      sys.indexes AS idx 
ON        idx.object_id = tbl.object_id 
AND       idx.index_id <= 1 
LEFT JOIN sys.data_spaces AS dsidx 
ON        dsidx.data_space_id = idx.data_space_id 
ORDER BY  [File Group], [Table Name] 
GO
-------------------------------------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------------------------------------

CREATE CLUSTERED INDEX [CX_HospitalisationsPlus_id] ON [dbo].[HospitalisationsPlus]
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Indexes]
GO

-------------------------------------------------------------------------------------------------------------
-- After 
-------------------------------------------------------------------------------------------------------------

SELECT    tbl.name AS [Table Name], 
          CASE WHEN dsidx.type='FG' THEN dsidx.name ELSE '(Partitioned)' END AS [File Group] 
FROM      sys.tables AS tbl 
JOIN      sys.indexes AS idx 
ON        idx.object_id = tbl.object_id 
AND       idx.index_id <= 1 
LEFT JOIN sys.data_spaces AS dsidx 
ON        dsidx.data_space_id = idx.data_space_id 
ORDER BY  [File Group], [Table Name] 

GO

-- sp_spaceused HospitalisationsPlus