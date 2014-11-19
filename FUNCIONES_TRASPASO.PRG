FUNCTION AccionAntesImportar
PARAMETERS pAliasOrigen, pAliasDestino, pCon

LOCAL lcSQL 

TEXT TO lcSQL TEXTMERGE NOSHOW 
	DELETE FROM sys_usuarios 
	 WHERE usuario <> 'SA'
ENDTEXT 

oApp.SBD.ExecSelect(lcSQL)


ENDFUNC
