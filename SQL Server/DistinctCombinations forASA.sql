SELECT		ASA
			, gender, ethnicGroup, domicileCode, DHB, eventType, endType, facility, opCode, opCount, opSeverity, diagnosis, DiagnosisCount, ecode, ecodeCount, OpAgeYears, eventDuration, EventYear, EventMonth, EventDay, IsEmergency
			, COUNT(*) AS NumEach

FROM		ASAPredAllHosp

WHERE		1=1
			AND ASA = 3

GROUP BY	ASA, gender, ethnicGroup, domicileCode, DHB, eventType, endType, facility, opCode, opCount, opSeverity, diagnosis, DiagnosisCount, ecode, ecodeCount, OpAgeYears, eventDuration, EventYear, EventMonth, EventDay, IsEmergency
ORDER BY	NumEach DESC