use vs_martinez
go 
alter table emp_orden_pago_c drop column codigo_concepto
go
alter table emp_orden_pago_c add codigo_patron dm_codigos_c
go
