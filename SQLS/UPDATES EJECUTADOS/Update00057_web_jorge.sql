USE [vs_martinez]
GO

CREATE VIEW [dbo].[vw_vexportar_articulos_tarifas_descuentos]
AS
SELECT     dbo.emp_articulos.empresa, dbo.emp_articulos.codigo, dbo.emp_articulos.activo, LEFT(dbo.emp_articulos.descripcion, 50) AS descripcion_articulo, 
                      dbo.emp_articulos.codigo_proveedor_principal, dbo.emp_tarifas_familias.codigo_tarifa, dbo.emp_tarifas_familias.descuento, dbo.emp_articulos.pvp, 
                      dbo.emp_tarifas.descripcion AS descripcion_tarifa, dbo.vf_emp_proveedores.nombre AS nombre_proveedor
FROM         dbo.emp_articulos INNER JOIN
                      dbo.emp_familias ON dbo.emp_articulos.empresa = dbo.emp_familias.empresa AND dbo.emp_articulos.codigo_familia = dbo.emp_familias.codigo INNER JOIN
                      dbo.emp_tarifas_familias ON dbo.emp_familias.empresa = dbo.emp_tarifas_familias.empresa AND 
                      dbo.emp_familias.codigo = dbo.emp_tarifas_familias.codigo_familia INNER JOIN
                      dbo.vf_emp_proveedores ON dbo.emp_articulos.codigo_proveedor_principal = dbo.vf_emp_proveedores.codigo AND 
                      dbo.emp_articulos.empresa = dbo.vf_emp_proveedores.empresa INNER JOIN
                      dbo.emp_tarifas ON dbo.emp_tarifas_familias.empresa = dbo.emp_tarifas.empresa AND dbo.emp_tarifas_familias.codigo_tarifa = dbo.emp_tarifas.codigo