USE MoH
GO

-- ----------------------------------------------------------------
--
-- This is a script to add the MoH data indexes for SQL Server.
--
-- ----------------------------------------------------------------

/*
Add the IDENTITY column to each table and make it the clustered PRIMARY Key
*/

ALTER TABLE dbo.Hospitalisations ADD id INT IDENTITY(1,1)
ALTER TABLE dbo.Hospitalisations ADD CONSTRAINT PK_Hospitalisations PRIMARY KEY CLUSTERED (id)
GO

ALTER TABLE dbo.Labs ADD id INT IDENTITY(1,1)
ALTER TABLE dbo.Labs ADD CONSTRAINT PK_Labs PRIMARY KEY CLUSTERED (id)
GO

ALTER TABLE dbo.Mortality ADD id INT IDENTITY(1,1)
ALTER TABLE dbo.Mortality ADD CONSTRAINT PK_Mortality PRIMARY KEY CLUSTERED (id)
GO

ALTER TABLE dbo.Outpatient ADD id INT IDENTITY(1,1)
ALTER TABLE dbo.Outpatient ADD CONSTRAINT PK_Outpatient PRIMARY KEY CLUSTERED (id)
GO

ALTER TABLE dbo.PHOEnrolment ADD id INT IDENTITY(1,1)
ALTER TABLE dbo.PHOEnrolment ADD CONSTRAINT PK_PHOEnrolment PRIMARY KEY CLUSTERED (id)
GO

ALTER TABLE dbo.Pharmacy ADD id INT IDENTITY(1,1)
ALTER TABLE dbo.Pharmacy ADD CONSTRAINT PK_Pharmacy PRIMARY KEY CLUSTERED (id)
--GO

/* 
----------------------------------------------------------------
-- Add Page level compression to each table
----------------------------------------------------------------
*/

ALTER TABLE [dbo].[Hospitalisations] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);
GO
ALTER TABLE [dbo].[Labs] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);
GO
ALTER TABLE [dbo].[Mortality] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);
GO
ALTER TABLE [dbo].[OutPatient] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);
GO
ALTER TABLE [dbo].[Pharmacy] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);
GO
ALTER TABLE [dbo].[PHOEnrolment] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);
GO

----------------------------------------------------------------
-- Add non-clustered index on the new_enc_nhi of each table
----------------------------------------------------------------

CREATE	INDEX IX_Mortality_nhi ON MORTALITY (new_enc_nhi)
CREATE	INDEX IX_Hospitalisations_nhi ON [dbo].[Hospitalisations] (new_enc_nhi)
CREATE	INDEX IX_Labs_nhi ON [dbo].[Labs] (new_enc_nhi)
CREATE	INDEX IX_OutPatient_nhi ON [dbo].[OutPatient] (new_enc_nhi)
CREATE	INDEX IX_Pharmacy_nhi ON [dbo].[Pharmacy] (new_enc_nhi)
CREATE	INDEX IX_PHOEnrolment_nhi ON [dbo].[PHOEnrolment] (new_enc_nhi)