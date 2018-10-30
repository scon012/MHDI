/****** Script for SelectTopNRows command from SSMS  ******/
SELECT		*
FROM		[MoH].[sc].[HospitalisationsPlus] hp
			INNER JOIN lookups.ACHIProcedure p ON p.code = opCode

WHERE		1=1
			AND opcode > 0
			AND FLOOR(opAgeYearsFractional) >= 18
			AND hp.ASA IS NOT NULL
			AND p.IsOperation = 1