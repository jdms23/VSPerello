select * from eje_compra_l 
	inner join emp_articulos on eje_compra_l.empresa = emp_articulos.empresa and eje_compra_l.codigo_Articulo = emp_articulos.codigo
where codigo_familia = '07r2a9'

use vs_martinez
go
begin transaction 
ALTER TABLE emp_precios_proveedores
    NOCHECK CONSTRAINT FK_emp_precios_proveedores_emp_articulos
go 
update emp_articulos set codigo = rtrim(codigo_familia) + SUBSTRING(codigo, 5,9)
where codigo_familia = '07r2a9'
go 
ALTER TABLE emp_precios_proveedores
    CHECK CONSTRAINT FK_emp_precios_proveedores_emp_articulos
go 
commit
go 

select codigo, rtrim(codigo_familia) + SUBSTRING(codigo, 5,9) from emp_articulos
where codigo_familia = '07r2a9'