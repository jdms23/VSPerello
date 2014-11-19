use vs_martinez
go 
alter table emp_series add serie_web dm_logico default 0
go 
update emp_series set serie_web = 0
go 

insert into emp_series (empresa,ejercicio,codigo_tipo_documento,codigo,descripcion,prefijo,separador,numero_delante,inicializar,proximo_numero,digitos,gestion_huecos,
	empresa_contabilizar, predeterminada,codigo_almacen_defecto,codigo_centro_defecto, serie_web)
select empresa,ejercicio,codigo_tipo_documento,'W'+rtrim(codigo),'W'+rtrim(descripcion),prefijo,separador,numero_delante,inicializar,0,digitos,gestion_huecos,
	empresa_contabilizar, predeterminada, codigo_almacen_defecto, codigo_centro_defecto, 1 
from emp_series 
where ejercicio = '2012' and codigo_tipo_documento = 'PRE' and not codigo_almacen_defecto is null