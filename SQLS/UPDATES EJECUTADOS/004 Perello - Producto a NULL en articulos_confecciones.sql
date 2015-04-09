use vs_perello
go 

update emp_articulos_confecciones set codigo_producto = NULL

	update eje_proveedores_cond_compra_cuentas set subcuenta = NULL
	  from eje_proveedores_cond_compra_cuentas
		left outer join eje_cuentas on eje_cuentas.empresa = eje_proveedores_cond_compra_cuentas.empresa
			and eje_cuentas.ejercicio = eje_proveedores_cond_compra_cuentas.ejercicio
			and eje_cuentas.codigo = eje_proveedores_cond_compra_cuentas.subcuenta
	where eje_cuentas.codigo is null

	update eje_proveedores_cond_compra_cuentas set subcuenta_aportaciones = NULL
	  from eje_proveedores_cond_compra_cuentas
		left outer join eje_cuentas on eje_cuentas.empresa = eje_proveedores_cond_compra_cuentas.empresa
			and eje_cuentas.ejercicio = eje_proveedores_cond_compra_cuentas.ejercicio
			and eje_cuentas.codigo = eje_proveedores_cond_compra_cuentas.subcuenta_aportaciones
	where eje_cuentas.codigo is null

	update eje_proveedores_cond_compra_cuentas set SUBCUENTA_COMPRAS = NULL
	  from eje_proveedores_cond_compra_cuentas
		left outer join eje_cuentas on eje_cuentas.empresa = eje_proveedores_cond_compra_cuentas.empresa
			and eje_cuentas.ejercicio = eje_proveedores_cond_compra_cuentas.ejercicio
			and eje_cuentas.codigo = eje_proveedores_cond_compra_cuentas.SUBCUENTA_COMPRAS
	where eje_cuentas.codigo is null

	update eje_proveedores_cond_compra_cuentas set subcuenta_retenciones = NULL
	  from eje_proveedores_cond_compra_cuentas
		left outer join eje_cuentas on eje_cuentas.empresa = eje_proveedores_cond_compra_cuentas.empresa
			and eje_cuentas.ejercicio = eje_proveedores_cond_compra_cuentas.ejercicio
			and eje_cuentas.codigo = eje_proveedores_cond_compra_cuentas.subcuenta_retenciones
	where eje_cuentas.codigo is null

	update eje_proveedores_cond_compra_cuentas set subcuenta_efectos = NULL
	  from eje_proveedores_cond_compra_cuentas
		left outer join eje_cuentas on eje_cuentas.empresa = eje_proveedores_cond_compra_cuentas.empresa
			and eje_cuentas.ejercicio = eje_proveedores_cond_compra_cuentas.ejercicio
			and eje_cuentas.codigo = eje_proveedores_cond_compra_cuentas.subcuenta_efectos
	where eje_cuentas.codigo is null
	
	
	
	update eje_clientes_cond_venta_cuentas set subcuenta = NULL
	  from eje_clientes_cond_venta_cuentas
		left outer join eje_cuentas on eje_cuentas.empresa = eje_clientes_cond_venta_cuentas.empresa
			and eje_cuentas.ejercicio = eje_clientes_cond_venta_cuentas.ejercicio
			and eje_cuentas.codigo = eje_clientes_cond_venta_cuentas.subcuenta
	where eje_cuentas.codigo is null

	update eje_clientes_cond_venta_cuentas set subcuenta_divisas = NULL
	  from eje_clientes_cond_venta_cuentas
		left outer join eje_cuentas on eje_cuentas.empresa = eje_clientes_cond_venta_cuentas.empresa
			and eje_cuentas.ejercicio = eje_clientes_cond_venta_cuentas.ejercicio
			and eje_cuentas.codigo = eje_clientes_cond_venta_cuentas.subcuenta_divisas
	where eje_cuentas.codigo is null

	update eje_clientes_cond_venta_cuentas set SUBCUENTA_ventaS = NULL
	  from eje_clientes_cond_venta_cuentas
		left outer join eje_cuentas on eje_cuentas.empresa = eje_clientes_cond_venta_cuentas.empresa
			and eje_cuentas.ejercicio = eje_clientes_cond_venta_cuentas.ejercicio
			and eje_cuentas.codigo = eje_clientes_cond_venta_cuentas.SUBCUENTA_ventaS
	where eje_cuentas.codigo is null

	update eje_clientes_cond_venta_cuentas set subcuenta_retenciones = NULL
	  from eje_clientes_cond_venta_cuentas
		left outer join eje_cuentas on eje_cuentas.empresa = eje_clientes_cond_venta_cuentas.empresa
			and eje_cuentas.ejercicio = eje_clientes_cond_venta_cuentas.ejercicio
			and eje_cuentas.codigo = eje_clientes_cond_venta_cuentas.subcuenta_retenciones
	where eje_cuentas.codigo is null

	update eje_clientes_cond_venta_cuentas set subcuenta_efectos = NULL
	  from eje_clientes_cond_venta_cuentas
		left outer join eje_cuentas on eje_cuentas.empresa = eje_clientes_cond_venta_cuentas.empresa
			and eje_cuentas.ejercicio = eje_clientes_cond_venta_cuentas.ejercicio
			and eje_cuentas.codigo = eje_clientes_cond_venta_cuentas.subcuenta_efectos
	where eje_cuentas.codigo is null

	update eje_clientes_cond_venta_cuentas set subcuenta_riesgo = NULL
	  from eje_clientes_cond_venta_cuentas
		left outer join eje_cuentas on eje_cuentas.empresa = eje_clientes_cond_venta_cuentas.empresa
			and eje_cuentas.ejercicio = eje_clientes_cond_venta_cuentas.ejercicio
			and eje_cuentas.codigo = eje_clientes_cond_venta_cuentas.subcuenta_riesgo
	where eje_cuentas.codigo is null

alter table emp_articulos_confecciones
	drop constraint FK_emp_articulos_confecciones_emp_articulos_producto
	
alter table emp_articulos_confecciones drop column codigo_producto