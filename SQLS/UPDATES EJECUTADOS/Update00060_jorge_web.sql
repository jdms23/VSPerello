USE [vs_martinez]
GO

/****** Object:  View [dbo].[vw_emp_existencias]    Script Date: 01/31/2012 10:22:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

alter VIEW [dbo].[vw_emp_existencias]
with encryption
AS
SELECT     dbo.emp_existencias.empresa, dbo.emp_existencias.codigo_almacen, dbo.emp_existencias.codigo_articulo, SUM(dbo.emp_existencias.stock) AS total_stock
FROM         dbo.emp_existencias INNER JOIN
                      dbo.emp_almacenes_ubicaciones ON dbo.emp_existencias.empresa = dbo.emp_almacenes_ubicaciones.empresa AND 
                      dbo.emp_existencias.codigo_almacen = dbo.emp_almacenes_ubicaciones.codigo_almacen AND 
                      dbo.emp_existencias.codigo_ubicacion = dbo.emp_almacenes_ubicaciones.codigo
WHERE     (dbo.emp_almacenes_ubicaciones.no_inventario = 0)
GROUP BY dbo.emp_existencias.empresa, dbo.emp_existencias.codigo_almacen, dbo.emp_existencias.codigo_articulo

GO


