USE vs_martinez

INSERT INTO eje_articulos_cuentas (empresa,ejercicio,codigo_articulo,subcuenta_ventas,subcuenta_compras)
SELECT emp_articulos.empresa, '2012', emp_articulos.codigo,'7000000000','6000000000' FROM emp_articulos
	LEFT OUTER JOIN eje_articulos_cuentas ON eje_articulos_cuentas.empresa = emp_articulos.empresa AND 
		eje_articulos_cuentas.codigo_articulo = emp_articulos.codigo AND 
		eje_articulos_cuentas.ejercicio = '2012' 
WHERE eje_articulos_cuentas.ejercicio IS NULL
		
		