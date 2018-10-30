USE MoH
GO

/********************************************************************************************************************************************************
Create additional Indexes
********************************************************************************************************************************************************/
--CREATE		INDEX IX_PHOEnrolment_EnrolmentDate ON [dbo].[PHOEnrolment] ([ENROLMENT_DATE])
--CREATE		INDEX IX_Hospitalisations_EVSTDATE ON [dbo].[Hospitalisations] ([EVSTDATE])
--CREATE		INDEX IX_Hospitalisations_EVENDATE ON [dbo].[Hospitalisations] ([EVENDATE])
--CREATE		INDEX IX_Labs_VisitDate ON [dbo].[Labs] (VISIT_DATE)
--CREATE		INDEX IX_OutPatient_ServiceDate ON [dbo].[OutPatient] (SERVICE_DATE)
--CREATE		INDEX IX_Mortality_DOD ON [dbo].[Mortality] (DOD)
--CREATE		INDEX IX_Pharmacy_DateDispensed ON [dbo].Pharmacy (DATE_DISPENSED)

/********************************************************************************************************************************************************/

SELECT
			(	SELECT		COUNT(*) 
				FROM		[dbo].[Hospitalisations]
			) AS HospitalizationRows
			, 
			(	SELECT		COUNT(DISTINCT new_enc_nhi) 
				FROM		[dbo].[Hospitalisations]
			) AS HospitalizationDistinctPatients
			,
			(	SELECT		MIN([EVSTDATE])
				FROM		[dbo].[Hospitalisations]
			) AS HospitalisationsFirstEvent
			,
			(	SELECT		MAX([EVENDATE])
				FROM		[dbo].[Hospitalisations]
			) AS HospitalisationsLastEvent
			,
			(	SELECT		COUNT(*) 
				FROM		[dbo].Labs
			) AS LabsRows
			, 
			(	SELECT		COUNT(DISTINCT new_enc_nhi) 
				FROM		[dbo].Labs
			) AS LabsDistinctPatients
			,
			(	SELECT		MIN([VISIT_DATE])
				FROM		[dbo].Labs
			) AS LabsFirstEvent
			,
			(	SELECT		MAX([VISIT_DATE])
				FROM		[dbo].Labs
			) AS LabsLastEvent
			,
			(	SELECT		COUNT(*) 
				FROM		[dbo].Mortality
			) AS MortalityRows
			, 
			(	SELECT		COUNT(DISTINCT new_enc_nhi) 
				FROM		[dbo].Mortality
			) AS MortalityDistinctPatients
			,
			(	SELECT		MIN(DOD)
				FROM		[dbo].Mortality
			) AS MortalityFirstEvent
			,
			(	SELECT		MAX(DoD)
				FROM		[dbo].Mortality
			) AS MortalityLastEvent
			,
			(	SELECT		COUNT(*) 
				FROM		[dbo].OutPatient
			) AS OutPatientRows
			, 
			(	SELECT		COUNT(DISTINCT new_enc_nhi) 
				FROM		[dbo].OutPatient
			) AS OutPatientDistinctPatients
			,
			(	SELECT		MIN(SERVICE_DATE)
				FROM		[dbo].OutPatient
			) AS OutPatientFirstEvent
			,
			(	SELECT		MAX(SERVICE_DATE)
				FROM		[dbo].OutPatient
			) AS OutPatientLastEvent
			,
			(	SELECT		COUNT(*) 
				FROM		[dbo].Pharmacy
			) AS PharmacyRows
			, 
			(	SELECT		COUNT(DISTINCT new_enc_nhi) 
				FROM		[dbo].Pharmacy
			) AS PharmacyDistinctPatients
			,
			(	SELECT		MIN(DATE_DISPENSED)
				FROM		[dbo].Pharmacy
			) AS PharmacyFirstEvent
			,
			(	SELECT		MAX(DATE_DISPENSED)
				FROM		[dbo].Pharmacy
			) AS PharmacyLastEvent
			,
			(	SELECT		COUNT(*) 
				FROM		[dbo].PHOEnrolment
			) AS PHOEnrolmentRows
			, 
			(	SELECT		COUNT(DISTINCT new_enc_nhi) 
				FROM		[dbo].PHOEnrolment
			) AS PHOEnrolmentDistinctPatients
			,
			(	SELECT		MIN(ENROLMENT_DATE)
				FROM		[dbo].PHOEnrolment
			) AS PHOEnrolmentFirstEvent
			,
			(	SELECT		MAX(ENROLMENT_DATE)
				FROM		[dbo].PHOEnrolment
			) AS PHOEnrolmentLastEvent