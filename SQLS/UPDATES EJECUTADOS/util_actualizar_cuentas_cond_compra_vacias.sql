use vs_martinez
go
update eje_proveedores_cond_compra_cuentas set subcuenta = '40000'+right(STR(codigo_proveedor),5) 
from eje_proveedores_cond_compra_cuentas as C inner join eje_cuentas as V on c.empresa = V.empresa and C.ejercicio = V.ejercicio 
where subcuenta is null and LEFT(LTRIM(STR(codigo_proveedor)),3)='400' and v.codigo = '40000'+right(STR(codigo_proveedor),5) 
