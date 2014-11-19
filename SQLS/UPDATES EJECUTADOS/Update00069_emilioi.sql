USE vs_martinez
GO

/****** Object:  View [dbo].[vr_lineas_pedidos_pendientes]    Script Date: 02/02/2012 12:37:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vr_lineas_pedidos_compra]
with encryption
AS
SELECT     dbo.eje_compra_c.empresa, dbo.eje_compra_c.ejercicio, dbo.eje_compra_c.codigo_tipo_documento, dbo.eje_compra_c.serie, dbo.eje_compra_c.numero, 
                      dbo.eje_compra_c.fecha, dbo.eje_compra_c.codigo_proveedor, dbo.eje_compra_l.codigo_Articulo, dbo.eje_compra_l.descripcion, dbo.eje_compra_l.unidades, 
                      dbo.eje_compra_l.precio, ISNULL(dbo.eje_compra_l.dto1, 0) AS dto1, ISNULL(dbo.eje_compra_l.dto2, 0) AS dto2, dbo.eje_compra_l.total_linea, ISNULL(dbo.eje_compra_l.iva, 0)
                       AS iva, ISNULL(dbo.eje_compra_l.re, 0) AS re, dbo.eje_compra_c.sys_oid, dbo.eje_pedido_compra_l.unidades_pendientes, ISNULL(dbo.eje_pedido_compra_l.unidades_servidas, 0) 
                      AS unidades_servidas,ISNULL(dbo.eje_pedido_compra_l.unidades_anuladas, 0) AS unidades_anuladas,dbo.eje_compra_c.razon_social_proveedor, dbo.eje_compra_t.cuota_iva, dbo.eje_compra_t.cuota_re, dbo.eje_compra_t.cuota_cargo_financiero, 
                      dbo.eje_compra_t.total, dbo.eje_compra_t.base_imponible, dbo.gen_tipos_situaciones.descripcion AS situacion
FROM         dbo.eje_pedido_compra_l INNER JOIN
                      dbo.eje_compra_l ON dbo.eje_pedido_compra_l.empresa = dbo.eje_compra_l.empresa AND dbo.eje_pedido_compra_l.ejercicio = dbo.eje_compra_l.ejercicio AND 
                      dbo.eje_pedido_compra_l.codigo_tipo_documento = dbo.eje_compra_l.codigo_tipo_documento AND dbo.eje_pedido_compra_l.serie = dbo.eje_compra_l.serie AND 
                      dbo.eje_pedido_compra_l.numero = dbo.eje_compra_l.numero AND dbo.eje_pedido_compra_l.linea = dbo.eje_compra_l.linea INNER JOIN
                      dbo.eje_compra_c ON dbo.eje_compra_l.empresa = dbo.eje_compra_c.empresa AND dbo.eje_compra_l.ejercicio = dbo.eje_compra_c.ejercicio AND 
                      dbo.eje_compra_l.codigo_tipo_documento = dbo.eje_compra_c.codigo_tipo_documento AND dbo.eje_compra_l.serie = dbo.eje_compra_c.serie AND 
                      dbo.eje_compra_l.numero = dbo.eje_compra_c.numero INNER JOIN
                      dbo.eje_compra_t ON dbo.eje_compra_c.empresa = dbo.eje_compra_t.empresa AND dbo.eje_compra_c.ejercicio = dbo.eje_compra_t.ejercicio AND 
                      dbo.eje_compra_c.codigo_tipo_documento = dbo.eje_compra_t.codigo_tipo_documento AND dbo.eje_compra_c.serie = dbo.eje_compra_t.serie AND 
                      dbo.eje_compra_c.numero = dbo.eje_compra_t.numero INNER JOIN
                      dbo.gen_tipos_situaciones ON dbo.eje_pedido_compra_l.codigo_tipo_documento = dbo.gen_tipos_situaciones.codigo_tipo_documento AND 
                      dbo.eje_compra_c.situacion = dbo.gen_tipos_situaciones.codigo_situacion


GO


