USE vs_martinez
GO
/****** Object:  Trigger [dbo].[eje_venta_compensar_ad]    Script Date: 01/24/2012 16:37:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[eje_venta_entregas_ad]
   ON  [dbo].[eje_venta_entregas]
   AFTER DELETE
AS 
BEGIN
	DECLARE @empresa dm_empresas
	DECLARE @ejercicio dm_ejercicios
	DECLARE @codigo_tipo_documento dm_codigos_c
	DECLARE @serie dm_codigos_c
	DECLARE @numero dm_numero_doc
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	DECLARE Borrados CURSOR LOCAL FOR
		SELECT empresa, ejercicio, codigo_tipo_documento, serie, numero FROM deleted 
			
	
	OPEN Borrados
	FETCH NEXT FROM Borrados INTO @empresa, @ejercicio, @codigo_tipo_documento, @serie, @numero
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		exec vs_calcular_total_venta @empresa, @ejercicio, @codigo_tipo_documento, @serie, @numero
		
		FETCH NEXT FROM Borrados INTO @empresa, @ejercicio, @codigo_tipo_documento, @serie, @numero
	END 
	
	CLOSE Borrados
	DEALLOCATE Borrados
	
END
