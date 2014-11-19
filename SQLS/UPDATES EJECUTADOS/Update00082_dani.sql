USE vs_martinez
GO 

ALTER TABLE TMP_APUNTES_TRASPASO ADD asiento dm_asiento default 1
go 

update tmp_apuntes_traspaso set asiento = 1

alter table emp_orden_pago_c add codigo_concepto dm_codigos_c
GO 