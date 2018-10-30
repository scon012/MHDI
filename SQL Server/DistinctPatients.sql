/*

Get the list of distinct patients across all data tables

*/

INSERT		INTO	DistinctPatients
SELECT		new_enc_nhi, NULL, NULL, NULL, NULL, NULL, NULL		FROM		Labs
UNION
SELECT		new_enc_nhi, NULL, NULL, NULL, NULL, NULL, NULL		FROM		Pharmacy
UNION
SELECT		new_enc_nhi, NULL, NULL, NULL, NULL, NULL, NULL		FROM		Mortality
UNION
SELECT		new_enc_nhi, NULL, NULL, NULL, NULL, NULL, NULL		FROM		OutPatient
UNION
SELECT		new_enc_nhi, NULL, NULL, NULL, NULL, NULL, NULL		FROM		PHOEnrolment
UNION
SELECT		new_enc_nhi, NULL, NULL, NULL, NULL, NULL, NULL		FROM		Hospitalisations

/*

Add each of the counts

*/

UPDATE		DistinctPatients
SET			[labs] = (SELECT COUNT(*) FROM Labs l WHERE l.new_enc_nhi = dp.nhi)
FROM		DistinctPatients dp

UPDATE		DistinctPatients
SET			[prescriptionItems] = (SELECT COUNT(*) FROM Pharmacy p WHERE p.new_enc_nhi = dp.nhi)
FROM		DistinctPatients dp

UPDATE		DistinctPatients
SET			[outPatientEvents] = (SELECT COUNT(*) FROM OutPatient o WHERE o.new_enc_nhi = dp.nhi)
FROM		DistinctPatients dp

UPDATE		DistinctPatients
SET			PHORegistrations = (SELECT COUNT(*) FROM PHOEnrolment p WHERE p.new_enc_nhi = dp.nhi)
FROM		DistinctPatients dp

UPDATE		DistinctPatients
SET			Hospitalisations = (SELECT COUNT(*) FROM Hospitalisations h WHERE h.new_enc_nhi = dp.nhi)
FROM		DistinctPatients dp

UPDATE		DistinctPatients
SET			dateOfDeath = (SELECT TOP 1 m.DOD FROM Mortality m WHERE m.new_enc_nhi = dp.nhi)
FROM		DistinctPatients dp

UPDATE		DistinctPatients
SET			ageAtDeath = (SELECT TOP 1 m.AGE_AT_DEATH_YRS FROM Mortality m WHERE m.new_enc_nhi = dp.nhi)
FROM		DistinctPatients dp