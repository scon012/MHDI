USE [MoH]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE lookups.[ACHIProcedure](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[code] [varchar](25) NOT NULL,
	[description] [varchar](200) NOT NULL,
	[blockId] [int] NOT NULL,
	[IsCardiac] [bit] NULL,
	[IsOperation] [bit] NULL,
	[ASA] TINYINT NULL,
	[IsEmergency] bit NULL
 CONSTRAINT [PK_ACHIProcedure] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

INSERT INTO	lookups.ACHIProcedure
SELECT		DISTINCT Procedure_Code, Procedure_Description, b.id, NULL, NULL, NULL, NULL FROM [MoH].[stage].[ACHICodes8th] pro INNER JOIN [MoH].[lookups].ACHIBlock b on b.Num = pro.Block_Code
GO

UPDATE	lookups.ACHIProcedure
SET		IsCardiac = 1
WHERE	code IN (SELECT Procedure_code FROM stage.[ACHI6IsOpIsCardiac] WHERE CARDIAC = 'CARDIAC')
GO

UPDATE	lookups.ACHIProcedure
SET		IsCardiac = 1
WHERE	code IN (SELECT Procedure_code FROM stage.[ACHI8IsOpIsCardiac] WHERE CARDIAC = 'CARDIAC')
GO

UPDATE	lookups.ACHIProcedure
SET		IsCardiac = 0
WHERE	IsCardiac IS NULL
GO

UPDATE	lookups.ACHIProcedure
SET		IsOperation = 1
WHERE	code IN (SELECT Procedure_code FROM stage.[ACHI6IsOpIsCardiac] WHERE NOT_AN_OP IS NULL)
GO

UPDATE	lookups.ACHIProcedure
SET		IsOperation = 1
WHERE	code IN (SELECT Procedure_code FROM stage.[ACHI8IsOpIsCardiac] WHERE NOT_AN_OP IS NULL)
GO

UPDATE	lookups.ACHIProcedure
SET		IsOperation = 0
WHERE	IsOperation IS NULL
GO

UPDATE			[MoH].[lookups].[ACHIProcedure]

SET				ASA = t.ASA
				, IsEmergency = t.IsEmergency

FROM			(
					SELECT			OpCode, c.ASA, CASE c.IsEmergency WHEN 9 THEN 1 ELSE 0 END AS IsEmergency
      
					FROM			[MoH].[stage].[ASACodes] c
									INNER JOIN [MoH].[lookups].[ACHIProcedure] p ON p.code = c.OpCode
				) t
				INNER JOIN [MoH].[lookups].[ACHIProcedure] q ON q.code = t.OpCode
GO
