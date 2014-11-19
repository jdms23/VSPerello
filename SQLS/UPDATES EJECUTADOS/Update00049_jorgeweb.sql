CREATE VIEW vw_emp_existencias
AS
SELECT     empresa, codigo_almacen, codigo_articulo, SUM(stock) AS total_stock
FROM        emp_existencias
GROUP BY empresa, codigo_almacen, codigo_articulo;