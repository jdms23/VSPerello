FUNCTION AccionAntesImportar
PARAMETERS pAliasOrigen, pAliasDestino, pCon

LOCAL lcSQL 

TEXT TO lcSQL TEXTMERGE NOSHOW 
	DELETE vf_emp_proveedores_completo 
	 WHERE empresa = ?oApp.empresa 
	   AND acreedor = 1
	
	ALTER TABLE emp_terceros NOCHECK CONSTRAINT FK_emp_terceros_gen_paises	   
	ALTER TABLE eje_proveedores_cond_compra_cuentas NOCHECK CONSTRAINT FK_eje_proveedores_cond_compra_cuentas_eje_cuentas
	ALTER TABLE eje_proveedores_cond_compra_cuentas NOCHECK CONSTRAINT FK_eje_proveedores_cond_compra_cuentas_eje_cuentas_efectos	
	ALTER TABLE eje_proveedores_cond_compra_cuentas NOCHECK CONSTRAINT FK_eje_proveedores_cond_compra_cuentas_eje_cuentas_compras

ENDTEXT 

oApp.SBD.ExecSelect(lcSQL)
ENDFUNC
FUNCTION AccionDespuesImportar
PARAMETERS pAliasOrigen, pAliasDestino, pCon

LOCAL lcSQL 

TEXT TO lcSQL TEXTMERGE NOSHOW 
	ALTER TABLE emp_terceros CHECK CONSTRAINT FK_emp_terceros_gen_paises	  
	ALTER TABLE eje_proveedores_cond_compra_cuentas CHECK CONSTRAINT FK_eje_proveedores_cond_compra_cuentas_eje_cuentas
	ALTER TABLE eje_proveedores_cond_compra_cuentas CHECK CONSTRAINT FK_eje_proveedores_cond_compra_cuentas_eje_cuentas_efectos
	ALTER TABLE eje_proveedores_cond_compra_cuentas CHECK CONSTRAINT FK_eje_proveedores_cond_compra_cuentas_eje_cuentas_compras
ENDTEXT 

oApp.SBD.ExecSelect(lcSQL)

ENDFUNC
FUNCTION AccionAntesGrupoCODIGO
PARAMETERS pAliasOrigen, pAliasDestino, pCon

ENDFUNC
FUNCTION AccionDespuesGrupoCODIGO
PARAMETERS pAliasOrigen, pAliasDestino, pCon

ENDFUNC
