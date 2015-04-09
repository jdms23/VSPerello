use vs_perello
go 

SELECT *
  FROM  OPENROWSET(BULK  'C:\innova\DANI\VSPerello\SQLs\CLIENTES.TXT',
      FORMATFILE='C:\innova\DANI\VSPerello\SQLs\CLIENTES.FMT'     
      ) as t1 
where not codigo_vsoft is null
  AND ISNUMERIC(codigo_vsoft) = 1
ORDER BY convert(int, codigo_vsoft)
 


update emp_clientes set codigo_destino_directo = (case when ct.destino_directo = '0' then null else ct.destino_directo end),
	codigo_destino_indirecto = (case when ct.destino_indirecto = '0' then null else ct.destino_indirecto end),
	codigo_agencia_directo = (case when ct.transitario_directo = '0' then null else ct.transitario_directo end),
	codigo_agencia_indirecto = (case when ct.transitario_indirecto = '0' then null else ct.transitario_indirecto end)
  FROM emp_clientes as cg
	INNER JOIN OPENROWSET(BULK  'C:\innova\DANI\VSPerello\SQLs\CLIENTES.TXT',
      FORMATFILE='C:\innova\DANI\VSPerello\SQLs\CLIENTES.FMT'     
      ) as ct ON ct.codigo_vsoft = cg.codigo
WHERE not ct.codigo_vsoft is null
  AND ISNUMERIC(ct.codigo_vsoft) = 1
