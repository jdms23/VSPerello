USE [vsolution]
GO

/****** Object:  View [dbo].[vf_estad_ventas_lineas]    Script Date: 03/01/2012 12:26:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [dbo].[vf_estad_ventas_lineas]
AS
SELECT     dbo.eje_venta_c.empresa, dbo.eje_venta_c.ejercicio, dbo.eje_venta_c.codigo_tipo_documento, dbo.eje_venta_c.serie, dbo.eje_venta_c.numero, 
                      dbo.eje_venta_c.fecha, dbo.eje_venta_c.codigo_cliente, dbo.eje_venta_c.nombre_cliente, dbo.eje_venta_c.razon_social_cliente, dbo.eje_venta_c.domicilio_cliente, 
                      dbo.eje_venta_c.nif_cliente, dbo.eje_venta_c.poblacion_cliente, dbo.eje_venta_c.codigo_postal_cliente, dbo.eje_venta_c.provincia_cliente, 
                      dbo.emp_formas_pago.descripcion AS descripcion_forma_pago, UPPER(dbo.eje_venta_l.codigo_Articulo) AS codigo_articulo, dbo.emp_articulos.descripcion, dbo.eje_venta_l.unidades, 
                      dbo.eje_venta_l.precio, dbo.eje_venta_l.dto1, dbo.eje_venta_l.dto2, dbo.eje_venta_l.total_linea, dbo.eje_venta_l.iva, dbo.eje_venta_l.re, 
                      dbo.eje_venta_t.cuota_dto_comercial, dbo.eje_venta_t.cuota_dto_financiero,dbo.eje_venta_t.base_imponible, 
                      dbo.eje_venta_t.cuota_iva,dbo.eje_venta_t.cuota_re, dbo.eje_venta_t.neto_lineas, dbo.eje_venta_t.total, 
                      dbo.eje_venta_t.cuota_cargo_financiero, dbo.eje_venta_c.dto_comercial, dbo.eje_venta_c.dto_financiero, dbo.eje_venta_c.nombre_dir_envio, 
                      dbo.eje_venta_c.domicilio_dir_envio, dbo.eje_venta_c.codigo_postal_dir_envio, dbo.eje_venta_c.poblacion_dir_envio, dbo.eje_venta_c.provincia_dir_envio, 
                      dbo.eje_venta_c.telefono_dir_envio, dbo.eje_venta_c.movil_dir_envio, dbo.eje_venta_c.importe_portes, dbo.eje_venta_c.cargo_financiero, 
                      dbo.emp_agencias.descripcion AS descripcion_agencia, dbo.emp_portes.descripcion AS descripcion_portes, dbo.eje_venta_c.sys_oid, 
                      dbo.eje_venta_c.observaciones, dbo.eje_venta_c.observaciones_internas, dbo.eje_venta_c.referencia, dbo.eje_venta_c.email_dir_envio, 
                      dbo.eje_venta_c.fax_dir_envio, dbo.vf_emp_representantes.nombre AS nombre_representante, dbo.sys_usuarios.alias AS nombre_empleado, 
                      dbo.gen_empresas.nif AS nif_empresa, dbo.gen_tipos_documentos.descripcion_report AS tipo_documento, dbo.eje_venta_l.codigo_ubicacion, 
                      dbo.eje_venta_c.situacion, dbo.emp_articulos.codigo_familia, dbo.emp_formas_pago.codigo AS codigo_forma_pago, 
                      dbo.vf_emp_representantes.codigo AS codigo_representante, dbo.emp_familias.descripcion AS descripcion_familia, dbo.gen_empresas.logo_empresa, 
                      dbo.eje_venta_t.entrega_a_cuenta, dbo.eje_venta_t.fecha_entrega, dbo.eje_venta_c.pdf_generado, dbo.emp_centros.descripcion AS centro_venta, 
                      dbo.eje_venta_l.subcuenta_ventas, dbo.eje_venta_c.compensar_abono, dbo.eje_venta_t.importe_compensado, dbo.eje_venta_t.abonos_compensados, 
                      dbo.eje_venta_t.pendiente_compensar, dbo.gen_empresas.nombre AS nombre_empresa, dbo.gen_empresas.domicilio AS domicilio_empresa, 
                      dbo.gen_empresas.codigo_postal AS codigo_postal_empresa, dbo.gen_empresas.poblacion AS poblacion_empresa, 
                      dbo.gen_empresas.provincia AS provincia_empresa, dbo.gen_empresas.telefono AS telefono_empresa, dbo.gen_empresas.fax AS fax_empresa, 
                      dbo.gen_empresas.email AS email_empresa, dbo.gen_empresas.razon_social AS razon_social_empresa, dbo.eje_venta_c.piramidal, 
                      dbo.eje_venta_l.codigo_almacen, dbo.gen_tipos_documentos.pantalla_asociada, dbo.eje_venta_c.codigo_tercero, dbo.eje_venta_c.criterio_conjuntacion, 
                      dbo.emp_articulos.pvp, dbo.eje_venta_c.identificador_dir_envio, dbo.eje_venta_c.alias_dir_envio,vf_emp_representantes.es_de_calle,gen_empresas.nombre as empresa_contabilizar
FROM         dbo.emp_centros LEFT OUTER JOIN
                      dbo.gen_empresas INNER JOIN
                      dbo.eje_venta_c LEFT OUTER JOIN
                      dbo.eje_venta_l ON dbo.eje_venta_c.empresa = dbo.eje_venta_l.empresa AND dbo.eje_venta_c.ejercicio = dbo.eje_venta_l.ejercicio AND 
                      dbo.eje_venta_c.codigo_tipo_documento = dbo.eje_venta_l.codigo_tipo_documento AND dbo.eje_venta_c.serie = dbo.eje_venta_l.serie AND 
                      dbo.eje_venta_c.numero = dbo.eje_venta_l.numero LEFT OUTER JOIN
                      dbo.eje_venta_t ON dbo.eje_venta_c.empresa = dbo.eje_venta_t.empresa AND dbo.eje_venta_c.ejercicio = dbo.eje_venta_t.ejercicio AND 
                      dbo.eje_venta_c.codigo_tipo_documento = dbo.eje_venta_t.codigo_tipo_documento AND dbo.eje_venta_c.serie = dbo.eje_venta_t.serie AND 
                      dbo.eje_venta_c.numero = dbo.eje_venta_t.numero LEFT OUTER JOIN
                      dbo.gen_tipos_documentos ON dbo.eje_venta_c.codigo_tipo_documento = dbo.gen_tipos_documentos.codigo LEFT OUTER JOIN
                      dbo.emp_series ON dbo.eje_venta_c.empresa = dbo.emp_series.empresa AND dbo.eje_venta_c.ejercicio = dbo.emp_series.ejercicio AND 
                      dbo.eje_venta_c.serie = dbo.emp_series.codigo AND dbo.eje_venta_c.codigo_tipo_documento = dbo.emp_series.codigo_tipo_documento ON 
                      dbo.gen_empresas.codigo = dbo.emp_series.empresa_contabilizar LEFT OUTER JOIN
                      dbo.emp_familias RIGHT OUTER JOIN
                      dbo.emp_articulos ON dbo.emp_familias.codigo = dbo.emp_articulos.codigo_familia AND dbo.emp_familias.empresa = dbo.emp_articulos.empresa ON 
                      dbo.eje_venta_c.empresa = dbo.emp_articulos.empresa AND dbo.eje_venta_l.codigo_Articulo = dbo.emp_articulos.codigo LEFT OUTER JOIN
                      dbo.emp_formas_pago ON dbo.eje_venta_c.empresa = dbo.emp_formas_pago.empresa AND 
                      dbo.eje_venta_c.codigo_forma_pago = dbo.emp_formas_pago.codigo LEFT OUTER JOIN
                      dbo.sys_usuarios ON dbo.eje_venta_c.realizado_por = dbo.sys_usuarios.usuario LEFT OUTER JOIN
                      dbo.emp_agencias ON dbo.eje_venta_c.empresa = dbo.emp_agencias.empresa AND dbo.eje_venta_c.codigo_agencia = dbo.emp_agencias.codigo LEFT OUTER JOIN
                      dbo.vf_emp_representantes ON dbo.eje_venta_c.empresa = dbo.vf_emp_representantes.empresa AND 
                      dbo.eje_venta_c.codigo_representante = dbo.vf_emp_representantes.codigo LEFT OUTER JOIN
                      dbo.emp_portes ON dbo.eje_venta_c.empresa = dbo.emp_portes.empresa AND dbo.eje_venta_c.codigo_portes = dbo.emp_portes.codigo ON 
                      dbo.emp_centros.codigo = dbo.eje_venta_c.codigo_centro_venta AND dbo.emp_centros.empresa = dbo.eje_venta_c.empresa




GO


