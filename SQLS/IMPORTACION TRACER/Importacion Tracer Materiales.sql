use vs_perello
go 

SELECT *
  FROM  OPENROWSET(BULK  'C:\innova\DANI\VSPerello\SQLs\MATERIALES.TXT',
      FORMATFILE='C:\innova\DANI\VSPerello\SQLs\MATERIALES.FMT'     
      ) as t1 
 


 SELECT a.codigo, a.codigo_tipo_caja, m.descripcion, m.cajas_mixto
 update emp_articulos set envases_por_palet = m.cajas_mixto
  FROM emp_articulos as a
	INNER JOIN OPENROWSET(BULK  'C:\innova\DANI\VSPerello\SQLs\MATERIALES.TXT',
      FORMATFILE='C:\innova\DANI\VSPerello\SQLs\MATERIALES.FMT'     
      ) as M ON M.codigo_vsoft = A.codigo_tipo_caja
WHERE ISNULL(M.cajas_mixto,0) <> 0
ORDER BY a.codigo