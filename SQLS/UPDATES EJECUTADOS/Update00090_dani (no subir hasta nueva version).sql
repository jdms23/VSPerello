USE [vs_martinez]
GO

/****** Object:  View [dbo].[vv_albaranes_compra_pendientes_facturar]    Script Date: 02/17/2012 12:27:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vv_albaranes_compra_pendientes_facturar]
AS
SELECT     dbo.vv_compra_c_alba.sys_oid, dbo.vv_compra_c_alba.empresa, dbo.vv_compra_c_alba.ejercicio, dbo.vv_compra_c_alba.periodo, 
                      dbo.vv_compra_c_alba.codigo_tipo_documento, dbo.vv_compra_c_alba.serie, dbo.vv_compra_c_alba.numero, dbo.vv_compra_c_alba.codigo_tipo_cond_compra, 
                      dbo.vv_compra_c_alba.fecha, dbo.vv_compra_c_alba.situacion, dbo.vv_compra_c_alba.codigo_proveedor, dbo.vv_compra_c_alba.razon_social_proveedor, 
                      dbo.vv_compra_c_alba.nif_proveedor, dbo.vv_compra_c_alba.codigo_forma_pago, dbo.vv_compra_c_alba.codigo_tabla_iva, dbo.vv_compra_c_alba.dto_comercial, 
                      dbo.vv_compra_c_alba.dto_financiero, dbo.emp_proveedores_cond_compra.no_agrupar_albaranes, dbo.emp_proveedores_cond_compra.serie_facturas, 
                      dbo.emp_series.descripcion AS descripcion_serie, dbo.vv_compra_c_alba.su_albaran, dbo.vv_compra_c_alba.su_fecha_albaran, dbo.eje_compra_t.base_imponible, 
                      dbo.eje_compra_t.cuota_iva, dbo.eje_compra_t.total,dbo.emp_series.empresa_contabilizar
FROM         dbo.vv_compra_c_alba INNER JOIN
                      dbo.emp_proveedores ON dbo.vv_compra_c_alba.empresa = dbo.emp_proveedores.empresa AND 
                      dbo.vv_compra_c_alba.codigo_proveedor = dbo.emp_proveedores.codigo INNER JOIN
                      dbo.eje_compra_t ON dbo.vv_compra_c_alba.empresa = dbo.eje_compra_t.empresa AND dbo.vv_compra_c_alba.ejercicio = dbo.eje_compra_t.ejercicio AND 
                      dbo.vv_compra_c_alba.codigo_tipo_documento = dbo.eje_compra_t.codigo_tipo_documento AND dbo.vv_compra_c_alba.serie = dbo.eje_compra_t.serie AND 
                      dbo.vv_compra_c_alba.numero = dbo.eje_compra_t.numero LEFT OUTER JOIN
                      dbo.emp_series ON dbo.vv_compra_c_alba.empresa = dbo.emp_series.empresa AND dbo.vv_compra_c_alba.ejercicio = dbo.emp_series.ejercicio AND 
                      dbo.vv_compra_c_alba.serie = dbo.emp_series.codigo LEFT OUTER JOIN
                      dbo.emp_proveedores_cond_compra ON dbo.vv_compra_c_alba.empresa = dbo.emp_proveedores_cond_compra.empresa AND 
                      dbo.vv_compra_c_alba.codigo_proveedor = dbo.emp_proveedores_cond_compra.codigo_proveedor AND 
                      dbo.vv_compra_c_alba.codigo_tipo_cond_compra = dbo.emp_proveedores_cond_compra.codigo_tipo_cond_compra
WHERE     (dbo.vv_compra_c_alba.situacion = 'N') AND (dbo.emp_series.codigo_tipo_documento = 'AC')

GO


