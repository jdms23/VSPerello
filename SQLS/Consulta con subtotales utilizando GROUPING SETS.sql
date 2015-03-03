USE vs_perello
go 

select codigo_pais, nombre_pais, codigo_cliente, razon_social, sum(unidades) as kilos, sum(total_linea_e) as importe
  from vf_gen_estadisticas_ventas
 group by codigo_pais, nombre_pais, codigo_cliente, razon_social 

select codigo_pais, nombre_pais, codigo_cliente, razon_social, codigo_articulo, descripcion_articulo, sum(unidades) as kilos, sum(total_linea_e) as importe,	
	grouping_id(codigo_pais, codigo_cliente, codigo_articulo) AS grupo
  from vf_gen_estadisticas_ventas
 group by GROUPING SETS((codigo_pais, nombre_pais, codigo_cliente, razon_social, codigo_articulo, descripcion_articulo), 
		(codigo_pais, nombre_pais, codigo_cliente, razon_social),
		(codigo_pais, nombre_pais),
		())