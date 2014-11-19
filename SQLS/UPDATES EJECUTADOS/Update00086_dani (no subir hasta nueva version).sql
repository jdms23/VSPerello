/** Comprobar primero esto anotar y borrar los proveedores **/
/*
select * from eje_proveedores_cond_compra_cuentas AS CTA
	left outer join emp_proveedores_cond_compra AS CC ON cc.empresa = cta.empresa and cc.codigo_proveedor = cta.codigo_proveedor and cc.codigo_tipo_cond_compra = cta.codigo_tipo_cond_compra
where cc.codigo_proveedor is null	
*/

/*
delete eje_proveedores_cond_compra_cuentas
from eje_proveedores_cond_compra_cuentas AS CTA
	left outer join emp_proveedores_cond_compra AS CC ON cc.empresa = cta.empresa and cc.codigo_proveedor = cta.codigo_proveedor and cc.codigo_tipo_cond_compra = cta.codigo_tipo_cond_compra
where cc.codigo_proveedor is null	
*/

USE [vs_martinez]
GO

ALTER TABLE [dbo].[eje_proveedores_cond_compra_cuentas]  WITH CHECK ADD  CONSTRAINT [FK_eje_proveedores_cond_compra_cuentas_emp_proveedores_cond_compra] FOREIGN KEY([empresa], [codigo_proveedor], [codigo_tipo_cond_compra])
REFERENCES [dbo].[emp_proveedores_cond_compra] ([empresa], [codigo_proveedor], [codigo_tipo_cond_compra])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[eje_proveedores_cond_compra_cuentas] CHECK CONSTRAINT [FK_eje_proveedores_cond_compra_cuentas_emp_proveedores_cond_compra]
GO


