USE [vs_martinez]
GO
/****** Object:  Trigger [dbo].[emp_conceptos_apuntes_ai]    Script Date: 02/29/2012 17:41:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[emp_conceptos_apuntes_ad]
   ON  [dbo].[emp_conceptos_apuntes] with encryption
	 AFTER delete
AS 
BEGIN
	SET NOCOUNT ON;
	 DECLARE @empresa dm_empresas
	 DECLARE @codigo dm_subcuenta
	 DECLARE @descripcion dm_nombres

	 DECLARE Borrados CURSOR LOCAL FOR 
		SELECT empresa,codigo,descripcion
		  FROM deleted
	 
	OPEN Borrados
 	FETCH NEXT FROM Borrados INTO @empresa,@codigo,@descripcion
	
	WHILE @@FETCH_STATUS = 0
	BEGIN  
		IF (SELECT TOP 1 matriz FROM gen_empresas WHERE codigo=@empresa) = 1
		BEGIN
		  DELETE emp_conceptos_apuntes 
		   WHERE empresa <> @empresa AND codigo = @codigo
		END
		FETCH NEXT FROM Borrados INTO @empresa,@codigo,@descripcion
	END
	
	CLOSE Borrados
END 
