USE [vs_martinez]
GO

/****** Object:  View [dbo].[vv_lineas_pedido_pendientes_servir]    Script Date: 01/24/2012 16:42:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_lineas_pedido_pendientes_servir]
AS
SELECT     dbo.vv_venta_l_pedido.empresa, dbo.vv_venta_l_pedido.ejercicio, dbo.vv_venta_l_pedido.codigo_tipo_documento, dbo.vv_venta_l_pedido.serie, 
                      dbo.vv_venta_l_pedido.numero, dbo.vv_venta_l_pedido.linea, dbo.vv_venta_l_pedido.codigo_Articulo, dbo.vv_venta_l_pedido.descripcion, 
                      dbo.vv_venta_l_pedido.unidades, dbo.vv_venta_l_pedido.unidades_servidas, dbo.vv_venta_l_pedido.unidades_anuladas, 
                      dbo.vv_venta_l_pedido.unidades_pendientes, dbo.vv_venta_l_pedido.precio, dbo.vv_venta_l_pedido.dto1, dbo.vv_venta_l_pedido.dto2, 
                      dbo.vv_venta_l_pedido.total_linea, dbo.vv_venta_l_pedido.sys_oid, dbo.vv_venta_l_pedido.codigo_almacen,
                      dbo.vv_venta_c_pedido.codigo_cliente,dbo.vv_venta_c_pedido.fecha, 
                      dbo.vv_venta_c_pedido.sys_oid AS sys_oid_documento, dbo.vv_venta_c_pedido.situacion, 
                      dbo.vv_venta_l_pedido.subcuenta_ventas, dbo.vv_venta_l_pedido.iva, dbo.vv_venta_l_pedido.re, ROUND(((((((ISNULL(dbo.vv_venta_l_pedido.unidades_pendientes, 
                      0) * ISNULL(dbo.vv_venta_l_pedido.precio, 0)) * (1 - ISNULL(dbo.vv_venta_l_pedido.dto1, 0) / 100)) * (1 - ISNULL(dbo.vv_venta_l_pedido.dto2, 0) / 100)) 
                      * (1 - ISNULL(dbo.vv_venta_c_pedido.dto_comercial, 0) / 100)) * (1 - ISNULL(dbo.vv_venta_c_pedido.dto_financiero, 0) / 100)) * (1 + ISNULL(dbo.vv_venta_l_pedido.iva,
                       0) / 100)) * (1 - ISNULL(dbo.vv_venta_l_pedido.re, 0) / 100), 2) AS total_pendiente
FROM         dbo.vv_venta_c_pedido INNER JOIN
                      dbo.vv_venta_l_pedido ON dbo.vv_venta_c_pedido.empresa = dbo.vv_venta_l_pedido.empresa AND 
                      dbo.vv_venta_c_pedido.ejercicio = dbo.vv_venta_l_pedido.ejercicio AND 
                      dbo.vv_venta_c_pedido.codigo_tipo_documento = dbo.vv_venta_l_pedido.codigo_tipo_documento AND 
                      dbo.vv_venta_c_pedido.serie = dbo.vv_venta_l_pedido.serie AND dbo.vv_venta_c_pedido.numero = dbo.vv_venta_l_pedido.numero
WHERE     (dbo.vv_venta_l_pedido.unidades_pendientes > 0) AND (dbo.vv_venta_c_pedido.situacion = 'N') AND (dbo.vv_venta_l_pedido.linea_origen_ecotasa IS NULL OR
                      dbo.vv_venta_l_pedido.linea_origen_ecotasa = 0) OR
                      (dbo.vv_venta_l_pedido.codigo_Articulo IS NULL OR
                      dbo.vv_venta_l_pedido.codigo_Articulo = '') AND (dbo.vv_venta_l_pedido.descripcion <> '')

GO
