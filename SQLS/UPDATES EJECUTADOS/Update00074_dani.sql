USE [vs_martinez]
GO

/****** Object:  View [dbo].[vr_venta_factura]    Script Date: 02/08/2012 18:32:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vr_venta_factura]
WITH ENCRYPTION AS
SELECT     dbo.eje_venta_c.empresa, dbo.eje_venta_c.ejercicio, dbo.eje_venta_c.codigo_tipo_documento, dbo.eje_venta_c.serie, dbo.eje_venta_c.numero, 
                      dbo.eje_venta_c.fecha, dbo.eje_venta_c.codigo_cliente, dbo.eje_venta_c.nombre_cliente, dbo.eje_venta_c.razon_social_cliente, dbo.eje_venta_c.domicilio_cliente, 
                      dbo.eje_venta_c.nif_cliente, dbo.eje_venta_c.poblacion_cliente, dbo.eje_venta_c.codigo_postal_cliente, dbo.eje_venta_c.provincia_cliente, 
                      dbo.emp_formas_pago.descripcion AS descripcion_forma_pago, dbo.eje_venta_l.codigo_Articulo, dbo.eje_venta_l.descripcion, dbo.eje_venta_l.unidades, 
                      dbo.eje_venta_l.precio, dbo.eje_venta_l.dto1, dbo.eje_venta_l.dto2, dbo.eje_venta_l.total_linea, dbo.eje_venta_l.iva, dbo.eje_venta_l.re, 
                      dbo.eje_venta_t.cuota_dto_comercial, dbo.eje_venta_t.cuota_dto_financiero, dbo.eje_venta_t.base_imponible1, dbo.eje_venta_t.base_imponible2, 
                      dbo.eje_venta_t.base_imponible3, dbo.eje_venta_t.base_imponible4, dbo.eje_venta_t.base_imponible5, dbo.eje_venta_t.iva1, dbo.eje_venta_t.base_imponible, 
                      dbo.eje_venta_t.iva2, dbo.eje_venta_t.iva3, dbo.eje_venta_t.iva4, dbo.eje_venta_t.iva5, dbo.eje_venta_t.cuota_iva1, dbo.eje_venta_t.cuota_iva2, 
                      dbo.eje_venta_t.cuota_iva3, dbo.eje_venta_t.cuota_iva4, dbo.eje_venta_t.cuota_iva5, dbo.eje_venta_t.re1, dbo.eje_venta_t.cuota_iva, dbo.eje_venta_t.re2, 
                      dbo.eje_venta_t.re3, dbo.eje_venta_t.re4, dbo.eje_venta_t.re5, dbo.eje_venta_t.cuota_re1, dbo.eje_venta_t.cuota_re2, dbo.eje_venta_t.cuota_re3, 
                      dbo.eje_venta_t.cuota_re4, dbo.eje_venta_t.cuota_re5, dbo.eje_venta_t.cuota_re, dbo.eje_venta_t.neto_lineas, dbo.eje_venta_t.total, 
                      dbo.eje_venta_t.cuota_cargo_financiero, dbo.eje_venta_c.dto_comercial, dbo.eje_venta_c.dto_financiero, dbo.eje_venta_c.nombre_dir_envio, 
                      dbo.eje_venta_c.domicilio_dir_envio, dbo.eje_venta_c.codigo_postal_dir_envio, dbo.eje_venta_c.poblacion_dir_envio, dbo.eje_venta_c.provincia_dir_envio, 
                      dbo.eje_venta_c.telefono_dir_envio, dbo.eje_venta_c.movil_dir_envio, dbo.eje_venta_c.importe_portes, dbo.eje_venta_c.cargo_financiero, dbo.eje_venta_c.sys_oid, 
                      dbo.eje_venta_c.observaciones, dbo.eje_venta_c.observaciones_internas, dbo.eje_venta_c.referencia, dbo.eje_venta_c.email_dir_envio, 
                      dbo.eje_venta_c.fax_dir_envio, dbo.vf_emp_representantes.nombre AS nombre_representante, dbo.sys_usuarios.alias AS nombre_empleado, 
                      dbo.gen_empresas.nif AS nif_empresa, dbo.gen_tipos_documentos.descripcion_report AS tipo_documento, dbo.eje_venta_l.codigo_ubicacion, 
                      dbo.gen_empresas.logo_empresa, dbo.eje_venta_t.entrega_a_cuenta, dbo.eje_venta_t.fecha_entrega, dbo.eje_venta_c.pdf_generado, dbo.eje_venta_t.fecha_vto1, 
                      dbo.eje_venta_t.importe1, dbo.eje_venta_t.fecha_vto2, dbo.eje_venta_t.importe2, dbo.eje_venta_t.fecha_vto3, dbo.eje_venta_t.importe3, dbo.eje_venta_t.fecha_vto4, 
                      dbo.eje_venta_t.importe4, dbo.eje_venta_t.fecha_vto5, dbo.eje_venta_t.importe5, dbo.eje_venta_t.fecha_vto6, dbo.eje_venta_t.importe6, dbo.eje_venta_t.fecha_vto7, 
                      dbo.eje_venta_t.importe7, dbo.eje_venta_t.fecha_vto8, dbo.eje_venta_t.importe8, dbo.eje_venta_t.fecha_vto9, dbo.eje_venta_t.importe9, 
                      dbo.eje_venta_t.fecha_vto10, dbo.eje_venta_t.importe10, dbo.eje_venta_t.importe11, dbo.eje_venta_t.fecha_vto11, dbo.eje_venta_t.fecha_vto12, 
                      dbo.eje_venta_t.importe12, dbo.eje_venta_l.subcuenta_ventas, dbo.eje_venta_c.compensar_abono, dbo.eje_venta_t.importe_compensado, 
                      dbo.eje_venta_t.pendiente_compensar, dbo.eje_venta_t.abonos_compensados, dbo.eje_factura_c.nombre_dir_pago, dbo.eje_factura_c.domicilio_dir_pago, 
                      dbo.eje_factura_c.codigo_postal_dir_pago, dbo.eje_factura_c.poblacion_dir_pago, dbo.eje_factura_c.provincia_dir_pago, dbo.eje_factura_c.codigo_pais_dir_pago, 
                      dbo.eje_factura_c.telefono_dir_pago, dbo.eje_factura_c.movil_dir_pago, dbo.eje_factura_c.email_dir_pago, dbo.eje_factura_c.fax_dir_pago, 
                      dbo.eje_venta_c.identificador_dir_envio, calba.serie AS serie_albaran, calba.numero AS numero_alba, calba.fecha AS fecha_albaran, 
                      dbo.eje_venta_c.clave_entidad_banco, dbo.eje_venta_c.clave_sucursal_banco, dbo.eje_venta_c.digito_control_banco, dbo.eje_venta_c.cuenta_corriente_banco, 
                      dbo.eje_venta_c.criterio_conjuntacion, dbo.emp_clientes.criterio_facturacion1, dbo.emp_clientes.criterio_facturacion2, dbo.emp_clientes.criterio_facturacion3, 
                      dbo.gen_empresas.nombre AS nombre_empresa, dbo.gen_empresas.razon_social AS razon_social_empresa, dbo.gen_empresas.domicilio AS domicilio_empresa, 
                      dbo.gen_empresas.codigo_postal AS codigo_postal_empresa, dbo.gen_empresas.poblacion AS poblacion_empresa, 
                      dbo.gen_empresas.provincia AS provincia_empresa, dbo.gen_empresas.telefono AS telefono_empresa, dbo.gen_empresas.fax AS fax_empresa, 
                      dbo.gen_empresas.registro_mercantil AS registro_mercantil_empresa, dbo.eje_venta_c.situacion
FROM         dbo.eje_venta_c LEFT OUTER JOIN
                      dbo.eje_venta_l ON dbo.eje_venta_c.empresa = dbo.eje_venta_l.empresa AND dbo.eje_venta_c.ejercicio = dbo.eje_venta_l.ejercicio AND 
                      dbo.eje_venta_c.codigo_tipo_documento = dbo.eje_venta_l.codigo_tipo_documento AND dbo.eje_venta_c.serie = dbo.eje_venta_l.serie AND 
                      dbo.eje_venta_c.numero = dbo.eje_venta_l.numero INNER JOIN
                      dbo.eje_venta_t ON dbo.eje_venta_c.empresa = dbo.eje_venta_t.empresa AND dbo.eje_venta_c.ejercicio = dbo.eje_venta_t.ejercicio AND 
                      dbo.eje_venta_c.codigo_tipo_documento = dbo.eje_venta_t.codigo_tipo_documento AND dbo.eje_venta_c.serie = dbo.eje_venta_t.serie AND 
                      dbo.eje_venta_c.numero = dbo.eje_venta_t.numero INNER JOIN
                      dbo.eje_factura_l ON dbo.eje_venta_l.empresa = dbo.eje_factura_l.empresa AND dbo.eje_venta_l.ejercicio = dbo.eje_factura_l.ejercicio AND 
                      dbo.eje_venta_l.codigo_tipo_documento = dbo.eje_factura_l.codigo_tipo_documento AND dbo.eje_venta_l.serie = dbo.eje_factura_l.serie AND 
                      dbo.eje_venta_l.numero = dbo.eje_factura_l.numero AND dbo.eje_venta_l.linea = dbo.eje_factura_l.linea LEFT OUTER JOIN
                      dbo.eje_venta_c AS calba ON dbo.eje_factura_l.sys_oid_albaran = calba.sys_oid INNER JOIN
                      dbo.emp_series ON dbo.eje_venta_c.empresa = dbo.emp_series.empresa AND dbo.eje_venta_c.ejercicio = dbo.emp_series.ejercicio AND 
                      dbo.eje_venta_c.serie = dbo.emp_series.codigo AND dbo.eje_venta_c.codigo_tipo_documento = dbo.emp_series.codigo_tipo_documento INNER JOIN
                      dbo.gen_tipos_documentos ON dbo.eje_venta_c.codigo_tipo_documento = dbo.gen_tipos_documentos.codigo INNER JOIN
                      dbo.eje_factura_c ON dbo.eje_venta_c.empresa = dbo.eje_factura_c.empresa AND dbo.eje_venta_c.ejercicio = dbo.eje_factura_c.ejercicio AND 
                      dbo.eje_venta_c.codigo_tipo_documento = dbo.eje_factura_c.codigo_tipo_documento AND dbo.eje_venta_c.serie = dbo.eje_factura_c.serie AND 
                      dbo.eje_venta_c.numero = dbo.eje_factura_c.numero LEFT OUTER JOIN
                      dbo.gen_empresas ON dbo.emp_series.empresa_contabilizar = dbo.gen_empresas.codigo LEFT OUTER JOIN
                      dbo.emp_formas_pago ON dbo.eje_venta_c.empresa = dbo.emp_formas_pago.empresa AND 
                      dbo.eje_venta_c.codigo_forma_pago = dbo.emp_formas_pago.codigo LEFT OUTER JOIN
                      dbo.sys_usuarios ON dbo.eje_venta_c.realizado_por = dbo.sys_usuarios.usuario LEFT OUTER JOIN
                      dbo.vf_emp_representantes ON dbo.eje_venta_c.empresa = dbo.vf_emp_representantes.empresa AND 
                      dbo.eje_venta_c.codigo_representante = dbo.vf_emp_representantes.codigo LEFT OUTER JOIN
                      dbo.emp_clientes ON dbo.emp_clientes.empresa = dbo.eje_venta_c.empresa AND dbo.emp_clientes.codigo = dbo.eje_venta_c.codigo_cliente
WHERE     (dbo.eje_venta_c.codigo_tipo_documento = 'FV')

GO


