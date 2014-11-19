USE vs_martinez
-- ================================================
-- Template generated from Template Explorer using:
-- Create Trigger (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- See additional Create Trigger templates for more
-- examples of different Trigger statements.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER eje_venta_compensar_ad
   ON  eje_venta_compensar
with ENCRYPTION   AFTER DELETE
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
		SELECT eje_venta_c.empresa, eje_venta_c.ejercicio, eje_venta_c.codigo_tipo_documento, eje_venta_c.serie, eje_venta_c.numero
		  FROM deleted 
			INNER JOIN eje_venta_c ON eje_venta_c.sys_oid = deleted.sys_oid_abono
	
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
GO
