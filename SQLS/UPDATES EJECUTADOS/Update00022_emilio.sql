use vs_martinez
go
alter table emp_articulos add actualizar_etiqueta dm_logico null default(1)
go
update emp_articulos set actualizar_etiqueta=0 
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[emp_articulos_au]
   ON  [dbo].[emp_articulos]
   AFTER UPDATE
AS 
BEGIN

	SET NOCOUNT ON;
	
	IF UPDATE(pvp) or update(descripcion) or update(codigo_ean)
	BEGIN 					
		UPDATE emp_articulos SET actualizar_etiqueta = 1
		  FROM emp_articulos
			INNER JOIN inserted ON inserted.empresa = emp_articulos.empresa AND inserted.codigo = emp_articulos.codigo		
	END	
END

go
