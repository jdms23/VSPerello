PARAMETERS pClaseOrigen, pLibreriaOrigen, pClaseDestino, pLibreriaDestino

LOCAL lcTemp

IF PCOUNT() < 3 THEN 
	MESSAGEBOX("Nº de parametros incorrecto")
	RETURN 
ENDIF 

IF EMPTY(pLibreriaDestino) THEN 
	pLibreriaDestino = pLibreriaOrigen
ENDIF 

IF UPPER(pLibreriaOrigen) == UPPER(pLibreriaDestino) THEN 
	lcTemp = "CLASES\TEMP.VCX"
ELSE 
	lcTemp = pLibreriaDestino
ENDIF 

ADD CLASS (pClaseOrigen) OF (FORCEEXT(pLibreriaOrigen,"vcx")) TO (FORCEEXT(lcTemp,"vcx"))
RENAME CLASS (pClaseOrigen) OF (FORCEEXT(lcTemp,"vcx")) TO (pClaseDestino)
IF UPPER(pLibreriaOrigen) == UPPER(pLibreriaDestino) THEN 
	ADD CLASS (pClaseDestino) OF (FORCEEXT(lcTemp,"vcx")) TO (FORCEEXT(pLibreriaOrigen,"vcx"))
	REMOVE CLASS (pClaseDestino) OF (FORCEEXT(lcTemp,"vcx")) 
ENDIF 

CLEAR ALL 
