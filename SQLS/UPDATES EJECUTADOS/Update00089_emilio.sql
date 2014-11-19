USE vs_martinez
GO

/****** Object:  View [dbo].[vv_venta_c_alba]    Script Date: 02/17/2012 11:54:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vv_venta_c_alba] with encryption
AS
SELECT     dbo.eje_venta_c.empresa, dbo.eje_venta_c.ejercicio, dbo.eje_venta_c.periodo, dbo.eje_venta_c.codigo_tipo_documento, dbo.eje_venta_c.serie, 
                      dbo.eje_venta_c.codigo_tipo_cond_venta, dbo.eje_venta_c.numero, dbo.eje_venta_c.fecha, dbo.eje_venta_c.situacion, dbo.eje_venta_c.codigo_tercero, 
                      dbo.eje_venta_c.codigo_cliente, dbo.eje_venta_c.nombre_cliente, dbo.eje_venta_c.razon_social_cliente, dbo.eje_venta_c.nif_cliente, 
                      dbo.eje_venta_c.domicilio_cliente, dbo.eje_venta_c.codigo_postal_cliente, dbo.eje_venta_c.poblacion_cliente, dbo.eje_venta_c.provincia_cliente, 
                      dbo.eje_venta_c.codigo_forma_pago, dbo.eje_venta_c.codigo_tabla_iva, dbo.eje_venta_c.codigo_representante, dbo.eje_venta_c.dto_comercial, 
                      dbo.eje_venta_c.dto_financiero, dbo.eje_venta_c.numero_copias, dbo.eje_venta_c.observaciones, dbo.eje_venta_c.observaciones_internas, 
                      dbo.eje_venta_c.adjuntos, dbo.eje_venta_c.sys_logs, dbo.eje_venta_c.sys_borrado, dbo.eje_venta_c.sys_timestamp, dbo.eje_venta_c.sys_oid, 
                      dbo.eje_venta_c.codigo_pais_cliente, dbo.eje_alba_c.su_pedido, dbo.eje_alba_c.sys_oid AS sys_oid_alba, dbo.eje_venta_c.referencia,                       
                      dbo.eje_venta_c.codigo_divisa, dbo.eje_venta_c.cambio_divisa, dbo.eje_venta_c.codigo_tarifa, 
                      dbo.eje_venta_c.identificador_dir_envio, dbo.eje_venta_c.alias_dir_envio, dbo.eje_venta_c.nombre_dir_envio, dbo.eje_venta_c.domicilio_dir_envio, 
                      dbo.eje_venta_c.sucursal_dir_envio, dbo.eje_venta_c.codigo_postal_dir_envio, dbo.eje_venta_c.poblacion_dir_envio, dbo.eje_venta_c.provincia_dir_envio, 
                      dbo.eje_venta_c.codigo_pais_dir_envio, dbo.eje_venta_c.telefono_dir_envio, dbo.eje_venta_c.movil_dir_envio, dbo.eje_venta_c.email_dir_envio, 
                      dbo.eje_venta_c.fax_dir_envio, dbo.eje_venta_c.codigo_portes, dbo.eje_venta_c.codigo_tipo_iva_portes, dbo.eje_venta_c.aplicar_en_totales_portes, 
                      dbo.eje_venta_c.importe_portes, dbo.eje_venta_c.cargo_financiero, dbo.eje_venta_c.realizado_por, dbo.eje_venta_c.codigo_agencia, dbo.eje_venta_c.piramidal, 
                      dbo.eje_venta_c.aplicar_cargo_financiero, dbo.eje_venta_c.codigo_centro_venta, dbo.eje_venta_c.criterio_conjuntacion, 
                      dbo.eje_venta_c.aplicar_cargo_financiero_dias, dbo.eje_alba_c.albaran_retenido, dbo.eje_alba_c.motivo_retencion, dbo.eje_venta_c.compensar_abono, 
                      dbo.eje_alba_c.codigo_ruta_reparto, dbo.eje_venta_c.pdf_generado,dbo.eje_venta_t.entrega_a_cuenta,dbo.eje_venta_t.base_imponible,dbo.eje_venta_t.cuota_cargo_financiero,dbo.eje_venta_t.cuota_dto_comercial,
                      dbo.eje_venta_t.cuota_dto_financiero,dbo.eje_venta_t.cuota_iva,dbo.eje_venta_t.cuota_re,dbo.eje_venta_t.neto_lineas,dbo.eje_venta_t.total
FROM         dbo.eje_venta_c INNER JOIN
                      dbo.eje_alba_c ON dbo.eje_venta_c.empresa = dbo.eje_alba_c.empresa AND dbo.eje_venta_c.ejercicio = dbo.eje_alba_c.ejercicio AND 
                      dbo.eje_venta_c.codigo_tipo_documento = dbo.eje_alba_c.codigo_tipo_documento AND dbo.eje_venta_c.serie = dbo.eje_alba_c.serie AND 
                      dbo.eje_venta_c.numero = dbo.eje_alba_c.numero LEFT OUTER JOIN
                      dbo.eje_venta_t ON dbo.eje_venta_c.empresa = dbo.eje_venta_t.empresa AND dbo.eje_venta_c.ejercicio = dbo.eje_venta_t.ejercicio AND 
                      dbo.eje_venta_c.codigo_tipo_documento = dbo.eje_venta_t.codigo_tipo_documento AND dbo.eje_venta_c.serie = dbo.eje_venta_t.serie AND 
                      dbo.eje_venta_c.numero = dbo.eje_venta_t.numero
WHERE     (dbo.eje_venta_c.codigo_tipo_documento = 'AV')


GO

ALTER VIEW [dbo].[vv_venta_c_factura] with encryption
AS
SELECT     dbo.eje_venta_c.empresa, dbo.eje_venta_c.ejercicio, dbo.eje_venta_c.periodo, dbo.eje_venta_c.codigo_tipo_documento, dbo.eje_venta_c.serie, 
                      dbo.eje_venta_c.codigo_tipo_cond_venta, dbo.eje_venta_c.numero, dbo.eje_venta_c.fecha, dbo.eje_venta_c.situacion, dbo.eje_venta_c.codigo_tercero, 
                      dbo.eje_venta_c.codigo_cliente, dbo.eje_venta_c.nombre_cliente, dbo.eje_venta_c.razon_social_cliente, dbo.eje_venta_c.nif_cliente, 
                      dbo.eje_venta_c.domicilio_cliente, dbo.eje_venta_c.codigo_postal_cliente, dbo.eje_venta_c.poblacion_cliente, dbo.eje_venta_c.provincia_cliente, 
                      dbo.eje_venta_c.codigo_forma_pago, dbo.eje_venta_c.codigo_tabla_iva, dbo.eje_venta_c.codigo_representante, dbo.eje_venta_c.dto_comercial, 
                      dbo.eje_venta_c.dto_financiero, dbo.eje_venta_c.numero_copias, dbo.eje_venta_c.observaciones, dbo.eje_venta_c.observaciones_internas, 
                      dbo.eje_venta_c.adjuntos, dbo.eje_venta_c.sys_logs, dbo.eje_venta_c.sys_borrado, dbo.eje_venta_c.sys_timestamp, dbo.eje_venta_c.codigo_pais_cliente, 
                      dbo.eje_venta_c.referencia, dbo.eje_factura_c.contabilizada, dbo.eje_venta_c.sys_oid, dbo.eje_factura_c.sys_oid AS sys_oid_factura,
                      dbo.eje_venta_c.codigo_divisa, dbo.eje_venta_c.cambio_divisa, dbo.eje_venta_c.codigo_tarifa, 
                      dbo.eje_venta_c.identificador_dir_envio, dbo.eje_venta_c.alias_dir_envio, dbo.eje_venta_c.nombre_dir_envio, dbo.eje_venta_c.domicilio_dir_envio, 
                      dbo.eje_venta_c.sucursal_dir_envio, dbo.eje_venta_c.codigo_postal_dir_envio, dbo.eje_venta_c.poblacion_dir_envio, dbo.eje_venta_c.provincia_dir_envio, 
                      dbo.eje_venta_c.codigo_pais_dir_envio, dbo.eje_venta_c.telefono_dir_envio, dbo.eje_venta_c.movil_dir_envio, dbo.eje_venta_c.email_dir_envio, 
                      dbo.eje_venta_c.fax_dir_envio, dbo.eje_venta_c.codigo_portes, dbo.eje_venta_c.codigo_tipo_iva_portes, dbo.eje_venta_c.aplicar_en_totales_portes, 
                      dbo.eje_venta_c.importe_portes, dbo.eje_venta_c.cargo_financiero, dbo.eje_venta_c.realizado_por, dbo.eje_venta_c.codigo_agencia, dbo.eje_venta_c.piramidal, 
                      dbo.eje_venta_c.aplicar_cargo_financiero, dbo.eje_venta_c.codigo_centro_venta, dbo.eje_venta_c.identificador_banco, dbo.eje_venta_c.nombre_banco, 
                      dbo.eje_venta_c.domicilio_banco, dbo.eje_venta_c.sucursal_banco, dbo.eje_venta_c.codigo_postal_banco, dbo.eje_venta_c.poblacion_banco, 
                      dbo.eje_venta_c.provincia_banco, dbo.eje_venta_c.iban_code_banco, dbo.eje_venta_c.swift_code_banco, dbo.eje_venta_c.clave_entidad_banco, 
                      dbo.eje_venta_c.clave_sucursal_banco, dbo.eje_venta_c.digito_control_banco, dbo.eje_venta_c.cuenta_corriente_banco, dbo.eje_venta_c.criterio_conjuntacion, 
                      dbo.eje_venta_c.aplicar_cargo_financiero_dias, dbo.eje_factura_c.fecha_devengo, dbo.eje_venta_c.compensar_abono, dbo.eje_factura_c.nombre_dir_pago, 
                      dbo.eje_factura_c.domicilio_dir_pago, dbo.eje_factura_c.codigo_postal_dir_pago, dbo.eje_factura_c.poblacion_dir_pago, dbo.eje_factura_c.provincia_dir_pago, 
                      dbo.eje_factura_c.codigo_pais_dir_pago, dbo.eje_factura_c.telefono_dir_pago, dbo.eje_factura_c.movil_dir_pago, dbo.eje_factura_c.email_dir_pago, 
                      dbo.eje_factura_c.fax_dir_pago, dbo.eje_factura_c.alias_dir_pago, dbo.eje_factura_c.identificador_dir_pago, dbo.eje_factura_c.sucursal_dir_pago, 
                      dbo.eje_venta_c.pdf_generado,dbo.eje_factura_c.cliente_impagado,dbo.eje_venta_t.entrega_a_cuenta,dbo.eje_venta_t.base_imponible,dbo.eje_venta_t.cuota_cargo_financiero,dbo.eje_venta_t.cuota_dto_comercial,
                      dbo.eje_venta_t.cuota_dto_financiero,dbo.eje_venta_t.cuota_iva,dbo.eje_venta_t.cuota_re,dbo.eje_venta_t.neto_lineas,dbo.eje_venta_t.total
FROM         dbo.eje_venta_c INNER JOIN
                      dbo.eje_factura_c ON dbo.eje_venta_c.empresa = dbo.eje_factura_c.empresa AND dbo.eje_venta_c.ejercicio = dbo.eje_factura_c.ejercicio AND 
                      dbo.eje_venta_c.codigo_tipo_documento = dbo.eje_factura_c.codigo_tipo_documento AND dbo.eje_venta_c.serie = dbo.eje_factura_c.serie AND 
                      dbo.eje_venta_c.numero = dbo.eje_factura_c.numero LEFT OUTER JOIN
                      dbo.eje_venta_t ON dbo.eje_venta_c.empresa = dbo.eje_venta_t.empresa AND dbo.eje_venta_c.ejercicio = dbo.eje_venta_t.ejercicio AND 
                      dbo.eje_venta_c.codigo_tipo_documento = dbo.eje_venta_t.codigo_tipo_documento AND dbo.eje_venta_c.serie = dbo.eje_venta_t.serie AND 
                      dbo.eje_venta_c.numero = dbo.eje_venta_t.numero
WHERE     (dbo.eje_venta_c.codigo_tipo_documento = 'FV')


GO

ALTER VIEW [dbo].[vv_venta_c_pedido] with encryption
AS
SELECT     dbo.eje_venta_c.empresa, dbo.eje_venta_c.ejercicio, dbo.eje_venta_c.periodo, dbo.eje_venta_c.codigo_tipo_documento, dbo.eje_venta_c.serie, 
                      dbo.eje_venta_c.codigo_tipo_cond_venta, dbo.eje_venta_c.numero, dbo.eje_venta_c.fecha, dbo.eje_venta_c.situacion, dbo.eje_venta_c.codigo_tercero, 
                      dbo.eje_venta_c.codigo_cliente, dbo.eje_venta_c.nombre_cliente, dbo.eje_venta_c.razon_social_cliente, dbo.eje_venta_c.nif_cliente, 
                      dbo.eje_venta_c.domicilio_cliente, dbo.eje_venta_c.codigo_postal_cliente, dbo.eje_venta_c.poblacion_cliente, dbo.eje_venta_c.provincia_cliente, 
                      dbo.eje_venta_c.codigo_forma_pago, dbo.eje_venta_c.codigo_tabla_iva, dbo.eje_venta_c.codigo_representante, dbo.eje_venta_c.dto_comercial, 
                      dbo.eje_venta_c.dto_financiero, dbo.eje_venta_c.numero_copias, dbo.eje_venta_c.observaciones, dbo.eje_venta_c.observaciones_internas, 
                      dbo.eje_venta_c.adjuntos, dbo.eje_venta_c.sys_logs, dbo.eje_venta_c.sys_borrado, dbo.eje_venta_c.sys_timestamp, dbo.eje_venta_c.sys_oid, 
                      dbo.eje_venta_c.codigo_pais_cliente, dbo.eje_venta_c.referencia, dbo.eje_venta_c.codigo_divisa, dbo.eje_venta_c.cambio_divisa, dbo.eje_pedido_c.su_pedido, 
                      dbo.eje_pedido_c.fecha_entrega, dbo.eje_pedido_c.sys_oid AS sys_oid_pedido, dbo.eje_venta_c.codigo_tarifa, dbo.eje_venta_c.identificador_dir_envio, 
                      dbo.eje_venta_c.alias_dir_envio, dbo.eje_venta_c.nombre_dir_envio, dbo.eje_venta_c.domicilio_dir_envio, dbo.eje_venta_c.sucursal_dir_envio, 
                      dbo.eje_venta_c.codigo_postal_dir_envio, dbo.eje_venta_c.poblacion_dir_envio, dbo.eje_venta_c.provincia_dir_envio, dbo.eje_venta_c.codigo_pais_dir_envio, 
                      dbo.eje_venta_c.telefono_dir_envio, dbo.eje_venta_c.movil_dir_envio, dbo.eje_venta_c.email_dir_envio, dbo.eje_venta_c.fax_dir_envio, 
                      dbo.eje_venta_c.codigo_portes, dbo.eje_venta_c.codigo_tipo_iva_portes, dbo.eje_venta_c.aplicar_en_totales_portes, dbo.eje_venta_c.importe_portes, 
                      dbo.eje_venta_c.cargo_financiero, dbo.eje_venta_c.realizado_por, dbo.eje_venta_c.codigo_agencia, dbo.eje_venta_c.piramidal, 
                      dbo.eje_venta_c.aplicar_cargo_financiero, dbo.eje_venta_c.codigo_centro_venta, dbo.eje_venta_c.criterio_conjuntacion, 
                      dbo.eje_venta_c.aplicar_cargo_financiero_dias, dbo.eje_venta_c.compensar_abono, dbo.eje_pedido_c.codigo_ruta_reparto, dbo.eje_venta_c.pdf_generado,
                      dbo.eje_venta_t.entrega_a_cuenta,dbo.eje_venta_t.base_imponible,dbo.eje_venta_t.cuota_cargo_financiero,dbo.eje_venta_t.cuota_dto_comercial,
                      dbo.eje_venta_t.cuota_dto_financiero,dbo.eje_venta_t.cuota_iva,dbo.eje_venta_t.cuota_re,dbo.eje_venta_t.neto_lineas,dbo.eje_venta_t.total
FROM         dbo.eje_pedido_c INNER JOIN
                      dbo.eje_venta_c ON dbo.eje_pedido_c.empresa = dbo.eje_venta_c.empresa AND dbo.eje_pedido_c.ejercicio = dbo.eje_venta_c.ejercicio AND 
                      dbo.eje_pedido_c.codigo_tipo_documento = dbo.eje_venta_c.codigo_tipo_documento AND dbo.eje_pedido_c.serie = dbo.eje_venta_c.serie AND 
                      dbo.eje_pedido_c.numero = dbo.eje_venta_c.numero LEFT OUTER JOIN
                      dbo.eje_venta_t ON dbo.eje_venta_c.empresa = dbo.eje_venta_t.empresa AND dbo.eje_venta_c.ejercicio = dbo.eje_venta_t.ejercicio AND 
                      dbo.eje_venta_c.codigo_tipo_documento = dbo.eje_venta_t.codigo_tipo_documento AND dbo.eje_venta_c.serie = dbo.eje_venta_t.serie AND 
                      dbo.eje_venta_c.numero = dbo.eje_venta_t.numero
WHERE     (dbo.eje_venta_c.codigo_tipo_documento = 'PV')

GO

ALTER VIEW [dbo].[vv_venta_c_ticket] with encryption
AS
SELECT     dbo.eje_venta_c.empresa,dbo.eje_venta_c.ejercicio, dbo.eje_venta_c.periodo, dbo.eje_venta_c.codigo_tipo_documento, dbo.eje_venta_c.serie, codigo_tipo_cond_venta, dbo.eje_venta_c.numero, fecha, situacion, codigo_tercero, codigo_cliente, nombre_cliente, 
                      razon_social_cliente, nif_cliente, domicilio_cliente, codigo_postal_cliente, poblacion_cliente, provincia_cliente, codigo_forma_pago, codigo_tabla_iva, 
                      codigo_representante, dto_comercial, dto_financiero, numero_copias, observaciones, observaciones_internas, adjuntos, dbo.eje_venta_c.sys_logs, dbo.eje_venta_c.sys_borrado, dbo.eje_venta_c.sys_timestamp, 
                      dbo.eje_venta_c.sys_oid, codigo_pais_cliente, referencia, codigo_divisa, cambio_divisa, codigo_tarifa, identificador_dir_envio, alias_dir_envio, nombre_dir_envio, 
                      domicilio_dir_envio, sucursal_dir_envio, codigo_postal_dir_envio, poblacion_dir_envio, provincia_dir_envio, codigo_pais_dir_envio, telefono_dir_envio, 
                      movil_dir_envio, email_dir_envio, fax_dir_envio, codigo_portes, codigo_tipo_iva_portes, aplicar_en_totales_portes, importe_portes, cargo_financiero, realizado_por, 
                      codigo_agencia, identificador_banco, nombre_banco, domicilio_banco, sucursal_banco, codigo_postal_banco, poblacion_banco, provincia_banco, iban_code_banco, 
                      swift_code_banco, clave_entidad_banco, clave_sucursal_banco, digito_control_banco, cuenta_corriente_banco, telefono_cliente, fax_cliente, email_cliente, 
                      web_cliente, pdf_generado, piramidal, aplicar_cargo_financiero, codigo_centro_venta, criterio_conjuntacion, aplicar_cargo_financiero_dias, compensar_abono,
                      dbo.eje_venta_t.entrega_a_cuenta,dbo.eje_venta_t.base_imponible,dbo.eje_venta_t.cuota_cargo_financiero,dbo.eje_venta_t.cuota_dto_comercial,
                      dbo.eje_venta_t.cuota_dto_financiero,dbo.eje_venta_t.cuota_iva,dbo.eje_venta_t.cuota_re,dbo.eje_venta_t.neto_lineas,dbo.eje_venta_t.total
FROM         dbo.eje_venta_c LEFT OUTER JOIN
                      dbo.eje_venta_t ON dbo.eje_venta_c.empresa = dbo.eje_venta_t.empresa AND dbo.eje_venta_c.ejercicio = dbo.eje_venta_t.ejercicio AND 
                      dbo.eje_venta_c.codigo_tipo_documento = dbo.eje_venta_t.codigo_tipo_documento AND dbo.eje_venta_c.serie = dbo.eje_venta_t.serie AND 
                      dbo.eje_venta_c.numero = dbo.eje_venta_t.numero
WHERE     (dbo.eje_venta_c.codigo_tipo_documento = 'TV')

GO


ALTER VIEW [dbo].[vv_riesgo_albaranes_clientes] with encryption
AS
SELECT     empresa, codigo_cliente, SUM(ISNULL(total, 0)-ISNULL(entrega_a_cuenta,0)) AS riesgo
FROM         dbo.vv_venta_c_alba
WHERE     (situacion <> 'F')
GROUP BY codigo_cliente, empresa

go
ALTER VIEW [dbo].[vv_riesgo_facturas_clientes] with encryption
AS
SELECT     empresa, codigo_cliente, SUM(ISNULL(total, 0)-ISNULL(entrega_a_cuenta,0)) AS riesgo
FROM         dbo.vv_venta_c_factura
WHERE     (situacion <> 'C')
GROUP BY codigo_cliente, empresa

GO
