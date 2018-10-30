USE MoH
GO

--------------------------------------------------------------------------------------------------------------------------
--	Convert the date columns from varchar type to date type
--------------------------------------------------------------------------------------------------------------------------


--------------------------------
-- Mortality
--------------------------------

ALTER TABLE Mortality ADD new_DOD DATE NULL, new_BTHDATE DATE NULL;

SET DATEFORMAT dmy
UPDATE		Mortality
SET			new_DOD = LEFT(DOD, 10)
			, new_BTHDATE = LEFT(BTHDATE, 10)


-- This test should return NO results
SET DATEFORMAT dmy
SELECT		*
FROM		Mortality
WHERE		BTHDate != new_Bthdate OR LEFT(DOD, 10) != new_DOD

ALTER TABLE	Mortality DROP COLUMN BTHDATE, DOD

EXEC sp_rename 'Mortality.new_DOD', 'DOD', 'COLUMN';
EXEC sp_rename 'Mortality.new_BTHDATE', 'BTHDATE', 'COLUMN';


--------------------------------
-- Hospitalisations (NMDS)
--------------------------------

ALTER TABLE Hospitalisations ADD new_DOB DATE NULL, new_EVSTDATE DATE NULL, new_EVENDATE DATE NULL;

SET DATEFORMAT dmy
UPDATE		Hospitalisations
SET			new_DOB = DOB
			, new_EVSTDATE = EVSTDATE
			, new_EVENDATE = EVENDATE


-- This test should return NO results
SET DATEFORMAT dmy
SELECT		*
FROM		Hospitalisations
WHERE		DOB != new_DOB OR new_EVSTDATE != EVSTDATE OR new_EVENDATE != EVENDATE

ALTER TABLE	Hospitalisations DROP COLUMN DOB, EVSTDATE, EVENDATE

EXEC sp_rename 'Hospitalisations.new_DOB', 'DOB', 'COLUMN';
EXEC sp_rename 'Hospitalisations.new_EVSTDATE', 'EVSTDATE', 'COLUMN';
EXEC sp_rename 'Hospitalisations.new_EVENDATE', 'EVENDATE', 'COLUMN';


--------------------------------
-- Pharmacy
--------------------------------

ALTER TABLE Pharmacy ADD new_DATE_DISPENSED DATE NULL;

SET DATEFORMAT dmy
UPDATE		Pharmacy
SET			new_DATE_DISPENSED = DATE_DISPENSED
			

-- This test should return NO results
SET DATEFORMAT dmy
SELECT		*
FROM		Pharmacy
WHERE		DATE_DISPENSED != new_DATE_DISPENSED

ALTER TABLE	Pharmacy DROP COLUMN DATE_DISPENSED

EXEC sp_rename 'Pharmacy.new_DATE_DISPENSED', 'DATE_DISPENSED', 'COLUMN';


--------------------------------
-- Outpatient (NNPAC)
--------------------------------

ALTER TABLE Outpatient ADD new_DATE_OF_BIRTH DATE NULL, new_SERVICE_DATE DATE NULL

SET DATEFORMAT dmy
UPDATE		Outpatient
SET			new_DATE_OF_BIRTH = DATE_OF_BIRTH
			, new_SERVICE_DATE = SERVICE_DATE
			
-- This test should return NO results
SET DATEFORMAT dmy
SELECT		*
FROM		Outpatient
WHERE		DATE_OF_BIRTH != new_DATE_OF_BIRTH OR new_SERVICE_DATE != SERVICE_DATE

ALTER TABLE	Outpatient DROP COLUMN DATE_OF_BIRTH, SERVICE_DATE

EXEC sp_rename 'Outpatient.new_DATE_OF_BIRTH', 'DATE_OF_BIRTH', 'COLUMN';
EXEC sp_rename 'Outpatient.new_SERVICE_DATE', 'SERVICE_DATE', 'COLUMN';


--------------------------------
-- Labs
--------------------------------

ALTER TABLE Labs ADD new_VISIT_DATE DATE NULL

SET DATEFORMAT dmy
UPDATE		Labs
SET			new_VISIT_DATE = VISIT_DATE
			
-- This test should return NO results
SET DATEFORMAT dmy
SELECT		*
FROM		Labs
WHERE		VISIT_DATE != new_VISIT_DATE

ALTER TABLE	Labs DROP COLUMN VISIT_DATE

EXEC sp_rename 'Labs.new_VISIT_DATE', 'VISIT_DATE', 'COLUMN';


--------------------------------
-- PHOEnrolment
--------------------------------

ALTER TABLE PHOEnrolment ADD new_DOB DATE NULL, new_LAST_CONSULTATION_DATE DATE NULL, new_ENROLMENT_DATE DATE NULL;

SET DATEFORMAT dmy
UPDATE		PHOEnrolment
SET			new_DOB = DOB
			, new_LAST_CONSULTATION_DATE = LAST_CONSULTATION_DATE
			, new_ENROLMENT_DATE = ENROLMENT_DATE


-- This test should return NO results
SET DATEFORMAT dmy
SELECT		*
FROM		PHOEnrolment
WHERE		DOB != new_DOB OR new_LAST_CONSULTATION_DATE != LAST_CONSULTATION_DATE OR new_ENROLMENT_DATE != ENROLMENT_DATE

ALTER TABLE	PHOEnrolment DROP COLUMN DOB, LAST_CONSULTATION_DATE, ENROLMENT_DATE

EXEC sp_rename 'PHOEnrolment.new_DOB', 'DOB', 'COLUMN';
EXEC sp_rename 'PHOEnrolment.new_LAST_CONSULTATION_DATE', 'LAST_CONSULTATION_DATE', 'COLUMN';
EXEC sp_rename 'PHOEnrolment.new_ENROLMENT_DATE', 'ENROLMENT_DATE', 'COLUMN';
