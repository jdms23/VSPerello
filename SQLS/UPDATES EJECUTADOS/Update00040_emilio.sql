USE vs_martinez
/****** Object:  StoredProcedure [dbo].[vs_generar_asiento_cobro_efecto]    Script Date: 01/24/2012 17:21:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[vs_generar_asiento_impago]
 @pSys_oid_efecto dm_oid
,@pfecha dm_fechas_hora
,@pcodigo_banco dm_codigos_c
,@importe_gastos dm_importes
,@subcuenta_gastos dm_subcuenta
,@usuario dm_codigos_c
with encryption
AS
BEGIN
begin try	
BEGIN TRANSACTION 
	declare @Empresa dm_empresas
	declare @ejercicio dm_ejercicios
	declare @codigo_tipo_apunte dm_codigos_c
	declare @codigo_concepto dm_codigos_c
	declare @patron dm_char_largo
	declare @sesion dm_entero
	declare @sys_timestamp dm_fechas_hora
	declare @nombre_cliente dm_nombres
	declare @razon_social_cliente dm_nombres
	declare @numero_factura dm_numero_doc
	declare @fecha_Factura dm_fechas_hora
	declare @numero_recibo dm_numero_doc
	declare @fecha dm_fechas_hora
	declare @apunte dm_entero
	declare @subcta_cliente dm_subcuenta
	declare @subcta_banco dm_subcuenta
	declare @importe dm_importes
	declare @importe_banco dm_importes
	declare @observaciones dm_memo
	
	DECLARE @perror varchar(4000)

	set @Sesion = @@SPID
	set @sys_timestamp = getdate()
	select  @empresa=empresa
			,@ejercicio=ejercicio
			,@nombre_cliente=nombre_cliente
			,@razon_social_cliente=razon_social_cliente
			,@fecha_factura = fecha_factura
			,@numero_factura=numero_factura
			,@numero_recibo=numero
			,@subcta_cliente=subcuenta,
			@importe = importe
			FROM  vv_recibos_venta
			WHERE sys_oid = @pSys_oid_efecto

	set @apunte = 1
	set @patron = 'IMPAGO EFECTO ' + rtrim(@numero_recibo) + ' ' + rtrim(@nombre_cliente)

	INSERT INTO tmp_apuntes_traspaso
	 (apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,fecha,codigo_concepto,descripcion,subcuenta,importe_debe,importe_haber,serie_documento,numero_documento)
	 values (@apunte,@Empresa,@Ejercicio,@sys_timestamp,@sesion,'RV',@pSys_oid_efecto,@pFecha,@codigo_concepto,@patron,@subcta_cliente,@importe,0,'',@numero_recibo)
	
	set @apunte = @apunte + 1
	set @importe_banco = @importe + ISNULL(@importe_gastos,0)
	set @subcta_banco = (select subcuenta from eje_bancos_subcuenta where empresa = @Empresa and ejercicio = @ejercicio and codigo_banco = @pcodigo_banco)
	if isnull(@importe_gastos,0) > 0
		begin			
			INSERT INTO tmp_apuntes_traspaso
				 (apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,fecha,codigo_concepto,descripcion,subcuenta,importe_debe,importe_haber,serie_documento,numero_documento)
				 values (@apunte,@Empresa,@Ejercicio,@sys_timestamp,@sesion,'RV',@pSys_oid_efecto,@pFecha,@codigo_concepto,@patron,@subcuenta_gastos,@importe_gastos,0,'',@numero_recibo)
			set @apunte = @apunte + 1	  			
		end
	
	INSERT INTO tmp_apuntes_traspaso
		 (apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,fecha,codigo_concepto,descripcion,subcuenta,importe_debe,importe_haber,serie_documento,numero_documento)
		 values (@apunte,@Empresa,@Ejercicio,@sys_timestamp,@sesion,'RV',@pSys_oid_efecto,@pFecha,@codigo_concepto,@patron,@subcta_banco,0,@importe_banco,'',@numero_recibo)
		set @apunte = @apunte + 1	  

	set @observaciones = 'Impago introducido por ' + @usuario	  		

	UPDATE emp_efectos SET situacion='IM',observaciones=@observaciones WHERE sys_oid=@pSys_oid_efecto
	EXEC vs_traspasar_asiento 'RV',@pSys_oid_efecto
	COMMIT 
END TRY
/****CONTROL DE ERRORES *****/
BEGIN CATCH
	set @pError = 'ERROR AL CONTABILIZAR el impago del efecto(' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + ERROR_MESSAGE()
	ROLLBACK
	RAISERROR(@pError,16,1)
END CATCH
	
END

/*
exec vs_generar_asiento_descontar_remesa 'E_000001J','2011',2,'28-09-2011'

*/