USE [MoH]
GO

/****** Object:  Table [dbo].[AHCIBlocks]    Script Date: 2018-07-07 13:45:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE lookups.[AHCIBlock](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Num] [int] NOT NULL,
	[Description] [varchar](200) NOT NULL,
	[chapterId] [int] NOT NULL,
	SeverityTinChiu INT NULL,
	SeverityDougCampbell INT NULL,
	SeverityTimShort INT NULL,
	SeverityDecider INT NULL,
	SeverityFinal INT NULL,
 CONSTRAINT [PK_AHCIBlocks] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

INSERT INTO	lookups.AHCIBlock
SELECT		DISTINCT Block_code, Block_Description, c.id, NULL, NULL, NULL, NULL, NULL FROM [MoH].[stage].[ACHICodes8th] bl INNER JOIN [MoH].[lookups].AHCIChapter c on c.Num = bl.ChapterNum
GO

--UPDATE		[MoH].[stage].[AHCISeverity]
--SET			DougDecider = Null
--WHERE		DougDecider = 'NA'
--SELECT * FROM [MoH].[stage].[AHCISeverity]
--WHERE		ISNUMERIC(DougDecider) = 0
--AND			NOT DougDecider IS NULL


UPDATE		lookups.AHCIBlock
SET			SeverityTinChiu = sev.TinChiu
			, SeverityDougCampbell = sev.DougCampbell
			, SeverityTimShort = sev.TimShort
			, SeverityDecider = sev.DougDecider
			, SeverityFinal = sev.Final
FROM		stage.AHCISeverity sev
			INNER JOIN lookups.AHCIBlock bl ON bl.Num = sev.BlockNum
GO