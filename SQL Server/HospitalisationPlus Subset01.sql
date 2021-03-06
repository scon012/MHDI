/**************************************************************************************************************************
Subset 01

This data is a subset of the HospitalisationPlus Table. It is only uses records from 2013 onwards because we only have pharmacy records from then.

**************************************************************************************************************************/

SELECT		TOP 100000 

			[gender]
			,[ethnicGroup]
			,[domicileCode]
			,[DHB]
			,[eventType]
			,[endType]
			,[facility]
			,[diag01Chapter]
			,[diag02Chapter]
			,[diag03Chapter]
			,[eventDuration]
			,[EventYear]
			,[eventMonth]
			,[EventDayOfWeek]
			,[EventAgeYearsFractional]
			,[AdmissionType]
			,[IsCancer]
			,[IsSmoker]
			,[WasSmoker]
			,[HasDiabetesT1]
			,[HasDiabetesT2]
			,[IsNeuroTrauma]
			,[DiedDuringThisEvent]
			,[Drugs1m]
			,[Drugs6m]
			,[Drugs9m]
			,[Drugs12m]
			,[Drugs18m]
			,[Drugs24m]
			,[Drugs36m]
			,[Drugs60m]
			,[DrugsTotal]
			,[Labs1m]
			,[Labs6m]
			,[Labs9m]
			,[Labs12m]
			,[Labs18m]
			,[Labs24m]
			,[Labs36m]
			,[Labs60m]
			,[LabsTotal]
			,[OPVisits1m]
			,[OPVisits6m]
			,[OPVisits9m]
			,[OPVisits12m]
			,[OPVisits18m]
			,[OPVisits24m]
			,[OPVisits36m]
			,[OPVisits60m]
			,[OPVisitsTotal]
			,[IPVisits1m]
			,[IPVisits6m]
			,[IPVisits9m]
			,[IPVisits12m]
			,[IPVisits18m]
			,[IPVisits24m]
			,[IPVisits36m]
			,[IPVisits60m]
			,[IPVisitsTotal]

INTO		sc.HospitalisationPlusSubsetLarge

FROM		[MoH].[sc].[HospitalisationsPlus]

WHERE		EventYear >= 2013

ORDER BY	NEWID()