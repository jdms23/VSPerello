use vs_martinez
go 

alter table eje_apuntes add numero_factura_iva dm_char_corto
go 

alter table tmp_apuntes_traspaso add numero_factura_iva dm_char_corto
go 

UPDATE eje_apuntes set numero_factura_iva = RTRIM(serie_documento) + ' ' + RTRIM(numero_documento) 
where modelo_iva = 1
  and LEFT(subcuenta, 3) = '477'

update eje_apuntes set numero_factura_iva = eje_factura_compra_c.su_factura
  from eje_apuntes
	INNER JOIN eje_factura_compra_c ON eje_apuntes.ejercicio = eje_factura_compra_c.ejercicio
		and eje_apuntes.serie_documento = eje_factura_compra_c.serie
		and eje_apuntes.numero_documento = eje_factura_compra_c.numero
where modelo_iva = 1
  and LEFT(subcuenta, 3) = '472'

update eje_apuntes set numero_factura_iva = LTRIM(descripcion), modelo_347 = 1, modelo_iva = 1
 where LEFT(subcuenta,3) = '472' and numero_factura_iva is null
 
