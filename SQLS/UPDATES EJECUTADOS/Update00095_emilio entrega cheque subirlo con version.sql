USE vs_martinez
GO
/****** Object:  StoredProcedure [dbo].[vs_generar_asiento_entrega_cheque]    Script Date: 02/23/2012 18:41:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[vs_generar_asiento_entrega_cheque] 
 @pSys_oid_efecto dm_oid
,@pfecha_asiento dm_fechas_hora
,@pfecha_vencimiento dm_fechas_hora
,@pNumeroCheque dm_char_corto
,@pConcepto dm_codigos_c
AS
BEGIN
begin try	
BEGIN TRANSACTION 
	declare @Empresa dm_empresas
	declare @Empresa_matriz dm_empresas
	declare @ejercicio dm_ejercicios
	declare @codigo_tipo_apunte dm_codigos_c
	declare @codigo_concepto dm_codigos_c
	declare @patron dm_char_largo
	declare @sesion dm_entero
	declare @sys_timestamp dm_fechas_hora
	declare @codigo_cliente dm_codigos_n
	declare @nombre_cliente dm_nombres
	declare @razon_social_cliente dm_nombres
	declare @numero_factura dm_numero_doc
	declare @fecha_Factura dm_fechas_hora
	declare @numero_recibo dm_numero_doc
	declare @fecha dm_fechas_hora
	declare @apunte dm_entero
	declare @subcta_cliente dm_subcuenta
	declare @subcta_efectos dm_subcuenta
	declare @importe dm_importes
		
	DECLARE @perror varchar(4000)

	set @Sesion = @@SPID
	set @sys_timestamp = getdate()
	select  @empresa=empresa
			,@codigo_cliente=codigo_cliente			
			,@nombre_cliente=nombre_cliente
			,@razon_social_cliente=razon_social_cliente
			,@fecha_factura = fecha_factura
			,@numero_factura=numero_factura
			,@numero_recibo=numero
			,@subcta_cliente=subcuenta	
			,@importe=importe_pendiente	
			FROM  vv_recibos_venta
			WHERE sys_oid = @pSys_oid_efecto

	select @Empresa_matriz=codigo from gen_empresas where matriz=1
	
	select @ejercicio = ejercicio from emp_ejercicios 
		where empresa=@empresa and fecha_apertura <= @pfecha_asiento and fecha_cierre>=@pfecha_asiento
		
	select @subcta_efectos = subcuenta_efectos 
		from eje_clientes_cond_venta_cuentas 
		where empresa=@Empresa_matriz and ejercicio=@ejercicio and codigo_cliente=@codigo_cliente and codigo_tipo_cond_venta='1'
	
	set @apunte = 1	
		
	IF isnull(@subcta_cliente,'') <> '' AND ISNULL(@subcta_efectos,'') <> ''
	BEGIN
		set @codigo_concepto = @pConcepto
		set @patron = dbo.trim(@pNumeroCheque) + ' Vto: ' + ltrim(str(DAY(@pfecha_vencimiento))) + '/' + ltrim(STR(month(@pfecha_vencimiento))) + '/' + ltrim(str(year(@pfecha_vencimiento)))
		INSERT INTO tmp_apuntes_traspaso
		 (apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,fecha,codigo_concepto,descripcion,subcuenta,importe_debe,importe_haber,serie_documento,numero_documento)
		 values (@apunte,@Empresa,@Ejercicio,@sys_timestamp,@sesion,'RV',@pSys_oid_efecto,@pfecha_asiento,@codigo_concepto,@patron,@subcta_efectos,@importe,0,'',@numero_recibo)
		set @apunte = @apunte + 1	  		 
		set @codigo_concepto = '1000008'  
		set @patron = @numero_recibo

		INSERT INTO tmp_apuntes_traspaso
		 (apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,fecha,codigo_concepto,descripcion,subcuenta,importe_debe,importe_haber,serie_documento,numero_documento)
		 values (@apunte,@Empresa,@Ejercicio,@sys_timestamp,@sesion,'RV',@pSys_oid_efecto,@pfecha_asiento,@codigo_concepto,@patron,@subcta_cliente,0,@importe,'',@numero_recibo)
		

		UPDATE emp_efectos SET situacion='EC',
			subcuenta=@subcta_efectos,
			fecha_vto=@pfecha_vencimiento,
			documento_pago = @pNumeroCheque
		 WHERE sys_oid=@pSys_oid_efecto
		EXEC vs_traspasar_asiento 'RV',@pSys_oid_efecto
	END	 
	ELSE
		raiserror('SUBCUENTA DE CLIENTE O EFECTOS NO VALIDA',16,1)
		
	COMMIT 
END TRY
/****CONTROL DE ERRORES *****/
BEGIN CATCH
	set @pError = 'ERROR AL CONTABILIZAR el cobro del efecto(' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + ERROR_MESSAGE()
	ROLLBACK
	RAISERROR(@pError,16,1)
END CATCH
	
END


