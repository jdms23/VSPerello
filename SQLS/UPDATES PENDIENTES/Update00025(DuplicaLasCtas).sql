USE vs_martinez
GO
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
	DECLARE @porc_re dm_porcentajes
	DECLARE @observa dm_memo

DECLARE Insertados CURSOR LOCAL FOR SELECT empresa,[ejercicio],C.[codigo],[descripcion],[digitos],C.[observaciones] ,
	C.[adjuntos],C.[nif],[tipo],[subtipo],[porc_iva],[porc_re] FROM eje_cuentas AS C--,gen_empresas AS E WHERE ISNULL(E.matriz,0) = 0 
OPEN Insertados
FETCH NEXT FROM Insertados INTO @empresa,@ejercicio,@codigo,@descripcion,@digitos,@observa,
@adjuntos,@nif,@tipo,@subtipo,@porc_iva,@porc_re

WHILE @@FETCH_STATUS = 0
	BEGIN  
		IF (SELECT TOP 1 matriz FROM gen_empresas WHERE codigo=@empresa) = 1
		BEGIN
		  INSERT INTO eje_cuentas (empresa,ejercicio,codigo,descripcion,digitos,adjuntos,nif,tipo,subtipo,porc_iva,porc_re)
		  SELECT codigo,@ejercicio,@codigo,@descripcion,@digitos,@adjuntos,@nif,@tipo,@subtipo,@porc_iva,@porc_re
			FROM gen_empresas 
		   WHERE ISNULL(matriz,0)=0
			 AND NOT EXISTS (select codigo FROM eje_cuentas WHERE empresa = gen_empresas.codigo AND ejercicio = @ejercicio AND codigo = @codigo) 
		END
		FETCH NEXT FROM Insertados INTO @empresa,@ejercicio,@codigo,@descripcion,@digitos,@observa,
		@adjuntos,@nif,@tipo,@subtipo,@porc_iva,@porc_re
	END

CLOSE Insertados
DEALLOCATE Insertados

