/**************************************************************************************************************************
Subset 02

This data is a subset of the HospitalisationPlus Table. It is only uses records from 2013 onwards because we only have pharmacy records from then.

Only a subset of the columns are used (18) to test the ability (speed/accuracy) to do imputations on smaller datasets

**************************************************************************************************************************/

SELECT		TOP 100000 
			[gender]
			, [ethnicGroup]
			, [endType]
			, [diag01Chapter]
			, [eventDuration]
			, [EventYear]
			, [EventAgeYearsFractional]
			, [eventMonth]
			, [AdmissionType]
			, [IsCancer]
			, [IsSmoker]
			, [WasSmoker]
			, [HasDiabetesT1]
			, [HasDiabetesT2]
			, [Drugs6m]
			, [Labs6m]
			, [OPVisits6m]
			, [IPVisits6m]


INTO		sc.HospitalisationPlusSubset02

FROM		[MoH].[sc].[HospitalisationsPlus]

WHERE		EventYear >= 2013

ORDER BY	NEWID()