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

DROP TABLE IF EXISTS Labs;
CREATE TABLE Labs
(
  ROW_ID INT IDENTITY(1,1),
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
  CONSTRAINT pk PRIMARY KEY (ROW_ID)
) ;
