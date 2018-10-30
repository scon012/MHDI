USE		MoH
GO

-- -------------------------------------------------------------------------------
--
-- Create the MoH tables on SQL Server
--
-- -------------------------------------------------------------------------------

--------------------------------------------------------
--  File created - Thursday 2018-06-14
--------------------------------------------------------

/*
	All DROP statements (useful if you want to drop after adding FK constraints)

	DROP TABLE IF EXISTS Labs;								-- Labs
	DROP TABLE IF EXISTS PHOEnrolments;						-- PHO
	DROP TABLE IF EXISTS Pharmacy;							-- PHH
	DROP TABLE IF EXISTS Hospitalisations;					-- PUS
	DROP TABLE IF EXISTS Mortality;							-- mos3679
	DROP TABLE IF EXISTS NNPAC;								-- NAP

----*/

------------------------------------------------------------
------  DDL for Table Labs
------------------------------------------------------------
/*
DROP TABLE IF EXISTS Labs;
CREATE TABLE Labs
(
  new_enc_nhi VARCHAR(15) NOT NULL,
  AGE_AT_VISIT INT,
  GENDER VARCHAR(5),
  ETHNICGP VARCHAR(20),
  DOMICILE_CODE VARCHAR(20),
  DHB_DOM VARCHAR(20),
  LAB_TEST VARCHAR(20),
  TEST_GRP VARCHAR(20),
  VISIT_DATE VARCHAR(20),
  BULK_FUNDING_FLAG VARCHAR(20),
  FUNDING_DHB_CODE VARCHAR(20),
  NUMBER_OF_TESTS INT,
  AMOUNT_PAID_EXCL FLOAT,
  ESTIMATED_AMOUNT_EXCL FLOAT
) ;

------------------------------------------------------------
------  DDL for Table OutPatient
------------------------------------------------------------

DROP TABLE IF EXISTS OutPatient;
CREATE TABLE OutPatient
(
  new_enc_nhi VARCHAR(15) NOT NULL,
  ATTENDANCE_CODE VARCHAR(10),
  SERVICE_TYPE VARCHAR(25),
  EVENT_TYPE VARCHAR(25),
  PURCHASE_UNIT_CODE VARCHAR(25),
  UNIT_OF_MEASURE VARCHAR(100),
  VOLUME FLOAT,
  AGE_AT_VISIT VARCHAR(5),
  AGENCY VARCHAR(25),
  DATE_OF_BIRTH VARCHAR(10),
  SERVICE_DATE VARCHAR(10),
  DOMICILE_CODE VARCHAR(25),
  EVENT_END_TYPE_CODE VARCHAR(25),
  FACILITY VARCHAR(25),
  SEX VARCHAR(5),
  HEALTH_SPECIALTY_CODE VARCHAR(25),
  PURCHASER_CODE VARCHAR(25),
  ethnicgp INT,
  dhb_dom VARCHAR(25)
) ;

------------------------------------------------------------
------  DDL for Table Mortality
------------------------------------------------------------

DROP TABLE IF EXISTS Mortality;
CREATE TABLE Mortality
(
  new_enc_nhi VARCHAR(15) NOT NULL,
  REG_YEAR VARCHAR(4),
  BTHDATE VARCHAR(10),
  DEATH_TYPE VARCHAR(10),
  AGE_AT_DEATH_YRS INT,
  SEX VARCHAR(10),
  PRIORITY_ETHNIC_CODE VARCHAR(10),
  DOM VARCHAR(10),
  YRS_IN_NZ INT,
  DOD VARCHAR(25),
  DEATH_CERTIFIER_CODE VARCHAR(10),
  POST_MORTEM_CODE VARCHAR(10),
  DEATH_FACILITY_CODE VARCHAR(10), 
  DEATH_INFO_SRC_CODE VARCHAR(10), 
  icdd VARCHAR(10), 
  icdf1 VARCHAR(10), 
  icdf2 VARCHAR(10), 
  icdf3 VARCHAR(10), 
  icdf4 VARCHAR(25), 
  icdf5 VARCHAR(10), 
  icdf6 VARCHAR(10), 
  icdf7 VARCHAR(10), 
  icdf8 VARCHAR(10), 
  icdf9 VARCHAR(10), 
  icdf10 VARCHAR(10), 
  icdf11 VARCHAR(10), 
  icdf12 VARCHAR(10), 
  icdf13 VARCHAR(25),
  icdf14 VARCHAR(10), 
  icdf15 VARCHAR(10), 
  icdf16 VARCHAR(10), 
  icdf17 VARCHAR(10), 
  icdg1 VARCHAR(10), 
  icdg2 VARCHAR(10), 
  icdg3 VARCHAR(10), 
  icdg4 VARCHAR(10), 
  icdg5 VARCHAR(25), 
  icdg6 VARCHAR(10), 
  icdg7 VARCHAR(10), 
  icdg8 VARCHAR(10), 
  icdc1 VARCHAR(10), 
  icdc2 VARCHAR(10), 
  icdc3 VARCHAR(10), 
  icdc4 VARCHAR(10), 
  icdc5 VARCHAR(10), 
  icdc6  VARCHAR(25)
) ;

GO
DROP VIEW IF EXISTS vwMortality;
GO

-- This view is created because the two files have different columns. This view contains the columns for the 2016 onwards file.
CREATE VIEW vwMortality
AS
	SELECT
			  new_enc_nhi,
			  REG_YEAR,
			  BTHDATE,
			  DEATH_TYPE,
			  AGE_AT_DEATH_YRS,
			  SEX,
			  PRIORITY_ETHNIC_CODE,
			  DOM,
			  YRS_IN_NZ,
			  DOD
	FROM
				Mortality
;
GO


------------------------------------------------------------
------  DDL for Table Hospitalisations
------------------------------------------------------------

DROP TABLE IF EXISTS Hospitalisations;
CREATE TABLE Hospitalisations
(
  new_enc_nhi VARCHAR(15) NOT NULL,
  ADM_SRC VARCHAR(10),
  ADM_TYPE VARCHAR(10),
  DOB VARCHAR(10),
  GENDER VARCHAR(5),
  ETHNICGP INT,
  DOM_CD VARCHAR(10),
  DHBDOM VARCHAR(10), 
  EVENT_TYPE VARCHAR(10), 
  END_TYPE VARCHAR(10), 
  EVSTDATE VARCHAR(10), 
  EVENDATE VARCHAR(10), 
  LOCAL_ID VARCHAR(10), 
  EVNTLVD VARCHAR(10), 
  AGENCY VARCHAR(10), 
  AGENCY_TYPE VARCHAR(10), 
  FACILITY VARCHAR(10), 
  FAC_TYPE VARCHAR(10), 
  HLTHSPEC VARCHAR(10), 
  PURCHASER VARCHAR(10), 
  LOS VARCHAR(10), 
  DRG_CURRENT VARCHAR(10), 
  DRG_GROUPER_TYPE VARCHAR(10), 
  PCCL VARCHAR(10), 
  PUR_UNIT VARCHAR(10), 
  COST_WEIGHT VARCHAR(10), 
  COST_WEIGHT_CODE VARCHAR(10), 
  diag01 VARCHAR(25), 
  diag02 VARCHAR(25),
  diag03 VARCHAR(25), 
  diag04 VARCHAR(25), 
  diag05 VARCHAR(25), 
  diag06 VARCHAR(25), 
  diag07 VARCHAR(25), 
  diag08 VARCHAR(25), 
  diag09 VARCHAR(25), 
  diag10 VARCHAR(25), 
  diag11 VARCHAR(25), 
  diag12 VARCHAR(25), 
  diag13 VARCHAR(25), 
  diag14 VARCHAR(25), 
  diag15 VARCHAR(25), 
  diag16 VARCHAR(25), 
  diag17 VARCHAR(25), 
  diag18 VARCHAR(25), 
  diag19 VARCHAR(25), 
  diag20 VARCHAR(25), 
  diag21 VARCHAR(25), 
  diag22 VARCHAR(25), 
  diag23 VARCHAR(25), 
  diag24 VARCHAR(25), 
  diag25 VARCHAR(25), 
  diag26 VARCHAR(25), 
  diag27 VARCHAR(25), 
  diag28 VARCHAR(25), 
  diag29 VARCHAR(25), 
  diag30 VARCHAR(25), 
  op01 VARCHAR(25), 
  op02 VARCHAR(25), 
  op03 VARCHAR(25), 
  op04 VARCHAR(25), 
  op05 VARCHAR(25), 
  op06 VARCHAR(25), 
  op07 VARCHAR(25), 
  op08 VARCHAR(25), 
  op09 VARCHAR(25), 
  op10 VARCHAR(25), 
  op11 VARCHAR(25), 
  op12 VARCHAR(25), 
  op13 VARCHAR(25), 
  op14 VARCHAR(25), 
  op15 VARCHAR(25), 
  op16 VARCHAR(25), 
  op17 VARCHAR(25), 
  op18 VARCHAR(25), 
  op19 VARCHAR(25), 
  op20 VARCHAR(25), 
  op21 VARCHAR(25), 
  op22 VARCHAR(25), 
  op23 VARCHAR(25), 
  op24 VARCHAR(25), 
  op25 VARCHAR(25), 
  op26 VARCHAR(25), 
  op27 VARCHAR(25), 
  op28 VARCHAR(25), 
  op29 VARCHAR(25), 
  op30 VARCHAR(25), 
  opdate01 VARCHAR(10),
  opdate02 VARCHAR(10), 
  opdate03 VARCHAR(10), 
  opdate04 VARCHAR(10), 
  opdate05 VARCHAR(10), 
  opdate06 VARCHAR(10), 
  opdate07 VARCHAR(10), 
  opdate08 VARCHAR(10), 
  opdate09 VARCHAR(10), 
  opdate10 VARCHAR(10), 
  opdate11 VARCHAR(10), 
  opdate12 VARCHAR(10), 
  opdate13 VARCHAR(10), 
  opdate14 VARCHAR(10), 
  opdate15 VARCHAR(10), 
  opdate16 VARCHAR(10), 
  opdate17 VARCHAR(10), 
  opdate18 VARCHAR(10), 
  opdate19 VARCHAR(10), 
  opdate20 VARCHAR(10), 
  opdate21 VARCHAR(10), 
  opdate22 VARCHAR(10), 
  opdate23 VARCHAR(10), 
  opdate24 VARCHAR(10), 
  opdate25 VARCHAR(10), 
  opdate26 VARCHAR(10), 
  opdate27 VARCHAR(10), 
  opdate28 VARCHAR(10), 
  opdate29 VARCHAR(10), 
  opdate30 VARCHAR(10), 
  ecode01 VARCHAR(25), 
  ecode02 VARCHAR(25), 
  ecode03 VARCHAR(25), 
  ecode04 VARCHAR(25), 
  ecode05 VARCHAR(25), 
  ecode06 VARCHAR(25), 
  ecode07 VARCHAR(25), 
  ecode08 VARCHAR(25), 
  ecode09 VARCHAR(25), 
  ecode10 VARCHAR(25), 
  ecode11 VARCHAR(25), 
  ecode12 VARCHAR(25), 
  ecode13 VARCHAR(25), 
  ecode14 VARCHAR(25), 
  ecode15 VARCHAR(25), 
  ecode16 VARCHAR(25), 
  ecode17 VARCHAR(25), 
  ecode18 VARCHAR(25), 
  ecode19 VARCHAR(25), 
  ecode20 VARCHAR(25), 
  accdate01 VARCHAR(10), 
  accdate02 VARCHAR(10), 
  accdate03 VARCHAR(10), 
  accdate04 VARCHAR(10), 
  accdate05 VARCHAR(10), 
  accdate06 VARCHAR(10), 
  accdate07 VARCHAR(10), 
  accdate08 VARCHAR(10), 
  accdate09 VARCHAR(10), 
  accdate10 VARCHAR(10), 
  accdate11 VARCHAR(10), 
  accdate12 VARCHAR(10), 
  accdate13 VARCHAR(10), 
  accdate14 VARCHAR(10), 
  accdate15 VARCHAR(10), 
  accdate16 VARCHAR(10), 
  accdate17 VARCHAR(10), 
  accdate18 VARCHAR(10), 
  accdate19 VARCHAR(10), 
  accdate20 VARCHAR(25)
) ;


------------------------------------------------------------
------  DDL for Table PHOEnrolment
------------------------------------------------------------

DROP TABLE IF EXISTS PHOEnrolment;
CREATE TABLE PHOEnrolment
(
  new_enc_nhi VARCHAR(15) NOT NULL,
  YEAR_QUARTER VARCHAR(10),
  DOB VARCHAR(10),
  DOMICILE_CODE VARCHAR(10),
  DHB_DOM VARCHAR(25),
  GENDER VARCHAR(5),
  PHO_ID VARCHAR(10),
  PHO_NAME VARCHAR(100),
  PRACTICE_ID VARCHAR(25),
  PRACTICE_NAME VARCHAR(100),
  LAST_CONSULTATION_DATE VARCHAR(10),
  ENROLMENT_DATE VARCHAR(10),
  ethnicgp INT
) ;

------------------------------------------------------------
------  DDL for Table Pharmacy
------------------------------------------------------------

DROP TABLE IF EXISTS Pharmacy;
CREATE TABLE Pharmacy
(
  new_enc_nhi VARCHAR(15) NOT NULL,
  DIM_FORM_PACK_SUBSIDY_KEY VARCHAR(10),
  AGE_AT_DISPENSING INT,
  GENDER VARCHAR(5),
  ETHNICGP INT,
  DOMICILE_CODE VARCHAR(10),
  DHBDOM VARCHAR(10),
  REPEAT_SEQUENCE_NUMBER INT,
  BASE_UNITS VARCHAR(10),
  QUANTITY_DISPENSED FLOAT,
  QUANTITY_PRESCRIBED FLOAT,
  DISPENSINGS_PRESCRIBED FLOAT,
  DOSE FLOAT,
  FREQUENCY FLOAT,
  DAILY_DOSE FLOAT,
  DAYS_SUPPLY FLOAT,
  ORDER_TYPE VARCHAR(10),
  DATE_DISPENSED VARCHAR(10),
  dispensing_id VARCHAR(50),
  patient_category VARCHAR(10),
  patient_catgry_age_mismatch_flag INT,
  disp_b4_birth_after_death_flag VARCHAR(10)
) ;


*/
/*
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TO DO
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 * BACKUP THE DATABASES!!!! - Compressed
 * Backup the scripts
 * Compress the databases
 * Change dates to date type
 * Add constraints
 * Add indexes
 * Create dimension tables
 * Flatten factors
 * Check that same nhi across tables has same birth/death, gender, ethnic group etc.
 * Create views of the original data
*/