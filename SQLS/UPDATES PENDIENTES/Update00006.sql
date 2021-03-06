USE vs_martinez
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[eje_cuentas_au]
   ON  [dbo].[eje_cuentas] 
	 AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	 DECLARE @empresa dm_empresas
	 DECLARE @ejercicio dm_ejercicios
	 DECLARE @codigo dm_subcuenta
	 DECLARE @descripcion dm_nombres
	 DECLARE @digitos dm_entero_corto
	 DECLARE @adjuntos dm_adjuntos
	 DECLARE @nif dm_nif
	 DECLARE @tipo dm_entero_corto
	 DECLARE @subtipo dm_entero_corto
	 DECLARE @porc_iva dm_porcentajes
	 DECLARE @porc_re	dm_porcentajes
	 
 	DECLARE actualizados CURSOR LOCAL FOR 
	SELECT empresa,ejercicio,codigo,descripcion,digitos
		,adjuntos,nif,tipo,subtipo,porc_iva,porc_re
	  FROM inserted

	OPEN actualizados
 	FETCH NEXT FROM actualizados INTO @empresa,@ejercicio,@codigo,@descripcion,@digitos,
 		@adjuntos,@nif,@tipo,@subtipo,@porc_iva,@porc_re	  
	WHILE @@FETCH_STATUS = 0
	BEGIN  
	 IF UPDATE(descripcion) OR UPDATE(digitos) OR UPDATE(adjuntos) OR UPDATE(nif) OR UPDATE(tipo) OR UPDATE(subtipo)
			OR UPDATE(porc_iva)OR UPDATE(porc_re)
		 BEGIN
			 IF (SELECT matriz FROM gen_empresas WHERE codigo=@empresa) = 1
				BEGIN
				  UPDATE eje_cuentas SET descripcion=@descripcion,digitos=@digitos,adjuntos=@adjuntos,nif=@nif,tipo=@tipo,subtipo=@subtipo
						,porc_iva=@porc_iva,porc_re=@porc_re
						WHERE ejercicio=@ejercicio AND codigo=@codigo
				END
		END
		FETCH NEXT FROM Insertados INTO @empresa,@ejercicio,@codigo,@descripcion,@digitos,
		@adjuntos,@nif,@tipo,@subtipo,@porc_iva,@porc_re		
	 END
	 
	 CLOSE actualizados
	 DEALLOCATE actualizados
END 
