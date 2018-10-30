USE [MoH]
GO

/****** Object:  Table [dbo].[AHCIChapter]    Script Date: 2018-07-07 13:40:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE lookups.[AHCIChapter](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Num] [int] NOT NULL,
	[Description] [varchar](200) NOT NULL,
	[Roman] [varchar](5) NULL,
	[BlockRange] [varchar](10) NULL,
 CONSTRAINT [PK_AHCIChapter] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


INSERT INTO	lookups.AHCIChapter
SELECT		DISTINCT ChapterNum, Chapter, NULL, NULL FROM [MoH].[stage].[ACHICodes8th]
GO

UPDATE		lookups.AHCIChapter
SET			Roman = sev.ChapterRoman
			, BlockRange = sev.BlockRange
FROM		stage.AHCISeverity sev
			INNER JOIN lookups.AHCIChapter c ON c.Num = sev.ChapterNum
GO