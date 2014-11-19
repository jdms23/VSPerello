CLEAR ALL 
CLOSE TABLES ALL 

PUBLIC CRLF, oApp

LOCAL oInit 
LOCAL loTabla, lcTabla

CRLF = CHR(13) + CHR(10)

SET DELETED ON
SET DEFAULT TO (CURDIR())
SET PATH TO PROGS, FORMS, CLASES
SET CLASSLIB TO gestion, gestcs, syscs, acceso_bd, permisos, controles_app, controles

oApp = CREATEOBJECT("Aplicacion")

****
OPEN DATABASE ? SHARED

USE ? ALIAS Tmp IN 0 

loTabla = oApp.SBD.add_cursor("terceros","gen_actividades")
loTabla.actualizable = .T.
loTabla.Rellenar_cursor()

SELECT Tmp
scan
	*WAIT WINDOW "Tercero " + ALLTRIM(STR(codigo)) nowait
	SELECT(loTabla.Alias)
	APPEND BLANK
	*replace empresa WITH "A"
	replace codigo WITH tmp.codigo
	replace descripcion WITH tmp.descripcion
	
	
	loTabla.actualizar()
ENDSCAN 

USE IN Tmp

oApp.SBD.del_cursor("terceros")


****
CLEAR ALL 
CLOSE TABLES ALL	
CLOSE DATABASES ALL 