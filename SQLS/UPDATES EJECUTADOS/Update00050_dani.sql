USE vs_martinez
GO 

alter table sys_logs add alias_tabla dm_char_corto
GO 
alter table sys_logs add pantalla dm_char_corto
GO 
alter table sys_logs add terminal dm_char_corto
GO 
alter table sys_logs add operacion dm_char_muy_corto
GO 

update sys_logs set alias_tabla = nombre_tabla,
	terminal = LEFT(registro, CHARINDEX('Pantalla:',registro)-1),
	pantalla = LTRIM(SUBSTRING(REGISTRO, CHARINDEX('Pantalla:',registro) + 9, CHARINDEX(' ',registro, CHARINDEX('Pantalla:',registro) + 10) - (CHARINDEX('Pantalla:',registro) + 9))),
	operacion = (CASE 
		WHEN registro like '%Nuevo Registro%' THEN 'A'
		WHEN registro like '%Registro Eliminado%' THEN 'B'
		ELSE 'E'
		END)
GO 