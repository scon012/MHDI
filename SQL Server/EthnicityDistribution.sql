
--BEGIN TRANSACTION
--SET QUOTED_IDENTIFIER ON
--SET ARITHABORT ON
--SET NUMERIC_ROUNDABORT OFF
--SET CONCAT_NULL_YIELDS_NULL ON
--SET ANSI_NULLS ON
--SET ANSI_PADDING ON
--SET ANSI_WARNINGS ON
--COMMIT
--BEGIN TRANSACTION
--GO
--CREATE NONCLUSTERED INDEX IX_Hospitalisations_ethnicity ON dbo.Hospitalisations
--	(
--	ETHNICGP
--	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
--GO
--ALTER TABLE dbo.Hospitalisations SET (LOCK_ESCALATION = TABLE)
--GO
--COMMIT
--GO

--BEGIN TRANSACTION
--GO
--CREATE NONCLUSTERED INDEX IX_Labs_ethnicity ON dbo.Labs
--	(
--	ETHNICGP
--	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
--GO
--ALTER TABLE dbo.Labs SET (LOCK_ESCALATION = TABLE)
--GO
--COMMIT
--GO

--BEGIN TRANSACTION
--GO
--CREATE NONCLUSTERED INDEX IX_Mortality_ethnicity ON dbo.Mortality
--	(
--	[PRIORITY_ETHNIC_CODE]
--	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
--GO
--ALTER TABLE dbo.Mortality SET (LOCK_ESCALATION = TABLE)
--GO
--COMMIT
--GO

--BEGIN TRANSACTION
--GO
--CREATE NONCLUSTERED INDEX IX_OutPatient_ethnicity ON dbo.OutPatient
--	(
--	Ethnicgp
--	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
--GO
--ALTER TABLE dbo.OutPatient SET (LOCK_ESCALATION = TABLE)
--GO
--COMMIT
--GO

--BEGIN TRANSACTION
--GO
--CREATE NONCLUSTERED INDEX IX_Pharmacy_ethnicity ON dbo.Pharmacy
--	(
--	Ethnicgp
--	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
--GO
--ALTER TABLE dbo.Pharmacy SET (LOCK_ESCALATION = TABLE)
--GO
--COMMIT
--GO

--BEGIN TRANSACTION
--GO
--CREATE NONCLUSTERED INDEX IX_PHO_ethnicity ON dbo.PHOEnrolment
--	(
--	Ethnicgp
--	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
--GO
--ALTER TABLE dbo.PHOEnrolment SET (LOCK_ESCALATION = TABLE)
--GO
--COMMIT
--GO


SELECT ETHNICGP, COUNT(*) HospitalizationEthnicities
  FROM [MoH].[dbo].[Hospitalisations]
  GROUP BY ETHNICGP
GO

  
SELECT ETHNICGP, COUNT(*) LabsEthnicities
  FROM [MoH].[dbo].Labs
  GROUP BY ETHNICGP
GO

  
SELECT [PRIORITY_ETHNIC_CODE] ETHNICGP, COUNT(*) MortalityEthnicities
  FROM [MoH].[dbo].Mortality
  GROUP BY [PRIORITY_ETHNIC_CODE]
GO

SELECT ETHNICGP, COUNT(*) OutPatientEthnicities
  FROM [MoH].[dbo].OutPatient
  GROUP BY ETHNICGP
GO
 
SELECT ETHNICGP, COUNT(*) PharmacyEthnicities
  FROM [MoH].[dbo].Pharmacy
  GROUP BY ETHNICGP
GO

  
SELECT ETHNICGP, COUNT(*) PHOEthnicities
  FROM [MoH].[dbo].PHOEnrolment
  GROUP BY ETHNICGP
GO