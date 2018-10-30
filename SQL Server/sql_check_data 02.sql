
/* --------------------------------------------------------------------------------------------------------------------------
--	Check the ethnic groups
*/ --------------------------------------------------------------------------------------------------------------------------
/*
SELECT		DISTINCT 'Hospitalisations' AS SOURCE, Ethnicgp, COUNT(EthnicGP) NumOfEthnicity
FROM		Hospitalisations
GROUP BY	Ethnicgp
UNION
--SELECT		DISTINCT 'Labs' AS SOURCE, Ethnicgp, COUNT(EthnicGP) NumOfEthnicity
--FROM		Labs
--GROUP BY	Ethnicgp
--UNION
SELECT		DISTINCT 'Mortality' AS SOURCE, [PRIORITY_ETHNIC_CODE], COUNT([PRIORITY_ETHNIC_CODE]) NumOfEthnicity
FROM		Mortality
GROUP BY	[PRIORITY_ETHNIC_CODE]
UNION
SELECT		DISTINCT 'OutPatient' AS SOURCE, Ethnicgp, COUNT(EthnicGP) NumOfEthnicity
FROM		OutPatient
GROUP BY	Ethnicgp
--UNION
--SELECT		DISTINCT 'Pharmacy' AS SOURCE, Ethnicgp, COUNT(EthnicGP) NumOfEthnicity
--FROM		Pharmacy
--GROUP BY	Ethnicgp
UNION
SELECT		DISTINCT 'PHOEnrolment' AS SOURCE, Ethnicgp, COUNT(EthnicGP) NumOfEthnicity
FROM		PHOEnrolment
GROUP BY	Ethnicgp
ORDER BY	Ethnicgp
*/

/* --------------------------------------------------------------------------------------------------------------------------
--	Check that there are matching NHIs
*/ --------------------------------------------------------------------------------------------------------------------------

SET DATEFORMAT dmy

-- Gender check
SELECT		DISTINCT m.new_enc_nhi, m.SEX, h.GENDER
FROM		[dbo].[Hospitalisations] h
			INNER JOIN [dbo].[Mortality] m on m.[new_enc_nhi] = h.[new_enc_nhi]
WHERE		m.SEX != h.GENDER
GO

-- Ethnicity Check
SELECT		DISTINCT m.new_enc_nhi, m.Priority_ethnic_code, h.ETHNICGP
FROM		[dbo].[Hospitalisations] h
			INNER JOIN [dbo].[Mortality] m on m.[new_enc_nhi] = h.[new_enc_nhi]
WHERE		m.Priority_ethnic_code != h.ETHNICGP
GO

-- DOB Check
SELECT		DISTINCT m.new_enc_nhi, m.BTHDATE, h.DOB
FROM		[dbo].[Hospitalisations] h
			INNER JOIN [dbo].[Mortality] m on m.[new_enc_nhi] = h.[new_enc_nhi]
WHERE		m.BTHDATE != h.DOB
GO