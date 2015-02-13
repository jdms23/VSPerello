USE [vs_perello]
GO

/****** Object:  View [dbo].[vv_produccion_trazabilidad_hasta_proveedor_completa]    Script Date: 28/01/2015 10:58:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vv_produccion_trazabilidad_hasta_cliente_completa] AS 

		with produccion as (
			select distinct CONVERT(CHAR(10), 'PRODUCCION') as proceso, tr.numero, tr.fecha,
				tr.empresa, tr.codigo_articulo_producido, tr.lote_producido, tr.sscc_producido, 
				ep.sys_oid as sys_oid_linea_entrada, epl.codigo_articulo as codigo_articulo_entrado, epl.lote as lote_entrado, epl.sscc as sscc_entrado, 
				epl.numero_cajas as cajas_entradas, epl.peso as peso_entrado, e.sys_oid as sys_oid_albaran_entrada,
				convert(int, 1) as nivel, convert(char(1000), 'EV-' + rtrim(e.numero)) as traza 
			  from vv_produccion_trazabilidad as tr 
				inner join eje_entradas_pesadas_lotes as epl ON epl.empresa = tr.empresa
					and epl.codigo_articulo = tr.codigo_articulo_utilizado
					and epl.lote = tr.lote_utilizado
					and epl.sscc = tr.sscc_utilizado
				inner join eje_entradas_pesadas AS ep ON ep.empresa = epl.empresa 
					and ep.ejercicio = epl.ejercicio
					and ep.codigo_tipo_documento = epl.codigo_tipo_documento
					and ep.serie = epl.serie
					and ep.numero = epl.numero
					and ep.linea = epl.linea
				inner join eje_entradas AS e ON e.empresa = ep.empresa
					and e.ejercicio = ep.ejercicio
					and e.codigo_tipo_documento = ep.codigo_tipo_documento
					and e.serie = ep.serie
					and e.numero = ep.numero

			UNION ALL 

			select convert(CHAR(10), 'PRODUCCION'), tr.numero, tr.fecha, 
				tr.empresa, tr.codigo_articulo_producido, tr.lote_producido, tr.sscc_producido, 
				pr.sys_oid_linea_entrada, pr.codigo_articulo_entrado, pr.lote_entrado, pr.sscc_entrado, 
				pr.cajas_entradas, pr.peso_entrado, pr.sys_oid_albaran_entrada,
				pr.nivel + 1, convert(char(1000), rtrim(pr.traza) + ' | PP-' + rtrim(tr.numero))
			  from vv_produccion_trazabilidad as tr 
				inner join produccion as pr ON pr.empresa = tr.empresa
					and pr.codigo_articulo_producido = tr.codigo_articulo_utilizado
					and pr.lote_producido = tr.lote_utilizado
					and pr.sscc_producido = tr.sscc_utilizado
					),
											
		expediciones as (

			select proceso, numero, fecha, 
				empresa, codigo_articulo_producido, lote_producido, sscc_producido, 
				sys_oid_linea_entrada, codigo_articulo_entrado, lote_entrado, sscc_entrado, 
				cajas_entradas, peso_entrado, sys_oid_albaran_entrada, 
				convert(int, null) as sys_oid_albaran_venta,
				nivel, traza 
			  from produccion

			UNION ALL 

			select convert(CHAR(10), 'EXPEDICION'), cav.numero, cav.fecha, 
				cav.empresa, null, null, null, 
			    prod.sys_oid_linea_entrada, prod.codigo_articulo_producido, prod.lote_producido, prod.sscc_producido, 
				prod.cajas_entradas, prod.peso_entrado, prod.sys_oid_albaran_entrada, cav.sys_oid,
				prod.nivel + 1, convert(char(1000), rtrim(prod.traza) + ' | AV-' + rtrim(cav.numero))
			   from vv_venta_c_alba as cav
					inner join vv_venta_l_alba as lav ON lav.empresa = cav.empresa
						and lav.ejercicio = cav.ejercicio
						and lav.codigo_tipo_documento = cav.codigo_tipo_documento
						and lav.serie = cav.serie
						and lav.numero = cav.numero
					inner join vf_eje_montaje_pedidos_lotes AS m ON m.sys_oid_linea_pedido = lav.sys_oid_origen
						inner join produccion as prod ON prod.empresa  = m.empresa
							and prod.codigo_articulo_producido = m.codigo_articulo
							and prod.lote_producido = m.lote
							and prod.sscc_producido = m.sscc

			UNION ALL 

			select convert(CHAR(10), 'EXPEDICION'), e.numero, e.fecha,
				e.empresa, null, null, null, 
			    mont.sys_oid_linea_pedido, mont.codigo_articulo, mont.lote, mont.sscc, 
				mont.numero_cajas, mont.peso, cav.sys_oid, e.sys_oid, 
				convert(int, 1), convert(char(1000), 'EV-' + rtrim(e.numero))
			   from eje_entradas as e
				left outer join emp_articulos as a on a.empresa = e.empresa
					and a.codigo = e.codigo_articulo
				left outer join vf_emp_proveedores as prov on prov.empresa = e.empresa
					and prov.codigo = e.codigo_proveedor
				inner join eje_entradas_pesadas_lotes as epl ON epl.empresa = e.empresa
					and epl.ejercicio = e.ejercicio
					and epl.codigo_tipo_documento = e.codigo_tipo_documento
					and epl.serie = e.serie
					and epl.numero = e.numero
				inner join vf_eje_montaje_pedidos_lotes as mont ON mont.empresa  = epl.empresa
					and mont.lote = epl.lote
					and mont.sscc = epl.sscc
				inner join vv_venta_l_alba AS lav ON lav.sys_oid_origen = mont.sys_oid_linea_pedido
				inner join vv_venta_c_alba AS cav ON cav.empresa = lav.empresa
					and cav.ejercicio = lav.ejercicio
					and cav.serie = lav.serie
					and cav.numero = lav.numero
					)

select e.proceso, e.numero, e.fecha, 
		e.empresa, e.codigo_articulo_utilizado, e.lote_utilizado, e.sscc_utilizado,
		e.sys_oid_linea_pedido, e.codigo_articulo_cargado, e.lote_cargado, e.sscc_cargado, 
		e.cajas_cargadas, e.peso_cargado, e.sys_oid_albaran_venta, e.sys_oid_albaran_entrada,
		e.nivel, e.traza, 
		cav.numero as numero_albaran, cav.fecha as fecha_albaran, cav.codigo_cliente, cav.nombre_cliente, cav.nombre_dir_envio, a.descripcion as descripcion_articulo_utilizado, 
		cac.numero as numero_albaran_entrada, cac.fecha as fecha_albaran_entrada, cac.codigo_proveedor, prov.nombre as nombre_proveedor, 
		cac.codigo_parcela, cac.codigo_subparcela, cac.linea_cultivo, ac.descripcion as descripcion_articulo_cargado
  from entradas as e 
	left outer join vv_venta_c_alba as cav on cav.sys_oid = e.sys_oid_albaran_venta
	left outer join eje_entradas as cac on cac.sys_oid = e.sys_oid_albaran_entrada				
	left outer join emp_articulos as a on a.empresa = e.empresa
		and a.codigo = e.codigo_articulo_utilizado
	left outer join emp_articulos as ac on ac.empresa = e.empresa
		and ac.codigo = e.codigo_articulo_cargado
	left outer join vf_emp_proveedores as prov on prov.empresa = cac.empresa
		and prov.codigo = cac.codigo_proveedor

GO


