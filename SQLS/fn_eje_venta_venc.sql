USE [vsolution]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_eje_venta_venc]    Script Date: 10/19/2011 17:06:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_eje_venta_venc]
(
	-- Add the parameters for the function here
	@empresa [dbo].[dm_empresas],
	@ejercicio [dbo].[dm_ejercicios],
	@codigo_tipo_documento [dbo].[dm_codigos_c],
	@serie [dbo].[dm_codigos_c],
	@numero [dbo].[dm_codigos_c])
RETURNS 
@tc_venc TABLE 
(
	[empresa] [dbo].[dm_empresas] NOT NULL,
	[ejercicio] [dbo].[dm_ejercicios] NOT NULL,
	[codigo_tipo_documento] [dbo].[dm_codigos_c] NOT NULL,
	[serie] [dbo].[dm_codigos_c] NOT NULL,
	[numero] [dbo].[dm_codigos_c] NOT NULL,	
	[fecha_vto1] [dbo].[dm_fechas_hora] DEFAULT 0,
	[fecha_vto2] [dbo].[dm_fechas_hora] DEFAULT 0,
	[fecha_vto3] [dbo].[dm_fechas_hora] DEFAULT 0,
	[fecha_vto4] [dbo].[dm_fechas_hora] DEFAULT 0,
	[fecha_vto5] [dbo].[dm_fechas_hora] DEFAULT 0,
	[fecha_vto6] [dbo].[dm_fechas_hora] DEFAULT 0,
	[importe1] [dbo].[dm_importes] DEFAULT 0,
	[importe2] [dbo].[dm_importes] DEFAULT 0,
	[importe3] [dbo].[dm_importes] DEFAULT 0,
	[importe4] [dbo].[dm_importes] DEFAULT 0,
	[importe5] [dbo].[dm_importes] DEFAULT 0,
	[importe6] [dbo].[dm_importes] DEFAULT 0
)
AS
BEGIN
	DECLARE @efecto dm_entero
	DECLARE @fecha_vto dm_fechas_hora
	DECLARE @importe dm_importes

	/* SELECT *  FROM eje_venta_venc
		SELECT * FROM fn_eje_venta_venc('E_000001J','2011','AV','ALBARANES','AV/0031')
	*/
	DECLARE cursor_fn_eje_venta_venc CURSOR LOCAL FOR SELECT efecto,fecha_vto,importe FROM eje_venta_venc
		WHERE @empresa=empresa  AND
		@ejercicio=ejercicio AND
		@codigo_tipo_documento=codigo_tipo_documento AND
		@serie=serie AND
		@numero=numero
		
	OPEN cursor_fn_eje_venta_venc
	FETCH NEXT FROM cursor_fn_eje_venta_venc INTO @efecto,@fecha_vto,@importe
	
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		IF NOT EXISTS (SELECT * FROM @tc_venc)
			INSERT INTO @tc_venc (empresa,ejercicio,codigo_tipo_documento,serie,numero,fecha_vto1,importe1) 
			VALUES (@empresa,@ejercicio,@codigo_tipo_documento,@serie,@numero,@fecha_vto,@importe)
		
		IF @efecto = 1 and not (@importe is null)
			UPDATE @tc_venc SET fecha_vto1=@fecha_vto, importe1=@importe
		IF @efecto = 2 and not (@importe is null)
			UPDATE @tc_venc SET fecha_vto2=@fecha_vto, importe2=@importe
		IF @efecto = 3 and not (@importe is null)
			UPDATE @tc_venc SET fecha_vto3=@fecha_vto, importe3=@importe
		IF @efecto = 4 and not (@importe is null)
			UPDATE @tc_venc SET fecha_vto4=@fecha_vto, importe4=@importe
		IF @efecto = 5 and not (@importe is null)
			UPDATE @tc_venc SET fecha_vto5=@fecha_vto, importe5=@importe
		IF @efecto = 6 and not (@importe is null)
			UPDATE @tc_venc SET fecha_vto6=@fecha_vto, importe6=@importe

		FETCH NEXT FROM cursor_fn_eje_venta_venc INTO @efecto,@fecha_vto,@importe
	END
	
	CLOSE cursor_fn_eje_venta_venc
	DEALLOCATE cursor_fn_eje_venta_venc

	RETURN
END
