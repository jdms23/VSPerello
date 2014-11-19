update sys_logs set alias_tabla = nombre_tabla,
	terminal = LTRIM(SUBSTRING(REGISTRO, CHARINDEX('Ordenador:',registro) + 10, CHARINDEX('Pantalla:',registro) - (CHARINDEX('Ordenador:',registro) + 10))),
	pantalla = LTRIM(SUBSTRING(REGISTRO, CHARINDEX('Pantalla:',registro) + 9, CHARINDEX(' ',registro, CHARINDEX('Pantalla:',registro) + 10) - (CHARINDEX('Pantalla:',registro) + 9))),
	operacion = (CASE 
		WHEN registro like '%Nuevo Registro%' THEN 'A'
		WHEN registro like '%Registro Eliminado%' THEN 'B'
		ELSE 'E'
		END)
