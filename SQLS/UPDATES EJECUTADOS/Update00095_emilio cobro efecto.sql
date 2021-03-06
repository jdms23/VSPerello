USE vs_martinez
GO
/****** Object:  StoredProcedure [dbo].[vs_generar_asiento_cobro_efecto]    Script Date: 02/22/2012 17:21:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[vs_generar_asiento_cobro_efecto]
 @pSys_oid_efecto dm_oid
,@pfecha dm_fechas_hora
,@pcodigo_banco dm_codigos_c
,@importe dm_importes
,@pmetalico dm_logico
,@pConcepto dm_codigos_c
AS
BEGIN
begin try	
BEGIN TRANSACTION 
	declare @Empresa dm_empresas
	declare @empresa_matriz dm_empresas
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
	declare @importe_metalico dm_importes
	declare @documento_pago dm_char_corto
	declare @fecha_vto dm_fechas_hora
	
	DECLARE @perror varchar(4000)

	set @Sesion = @@SPID
	set @sys_timestamp = getdate()
	
	select @empresa_matriz = codigo from gen_empresas where matriz=1
	
	select  @empresa=empresa			
			,@nombre_cliente=nombre_cliente
			,@razon_social_cliente=razon_social_cliente
			,@fecha_factura = fecha_factura
			,@numero_factura=numero_factura
			,@numero_recibo=numero
			,@subcta_cliente=subcuenta
			,@documento_pago=documento_pago,
			@fecha_vto= fecha_vto
			FROM  vv_recibos_venta
			WHERE sys_oid = @pSys_oid_efecto

	select @ejercicio = ejercicio from emp_ejercicios 
		where empresa=@empresa and fecha_apertura <= @pfecha and fecha_cierre>=@pfecha
	set @apunte = 1
	declare cursor_patron CURSOR FOR 
		select codigo_tipo_apunte,codigo_concepto,patron from emp_apuntes_patron as ap left join emp_asientos_patron as asto 
		ON ap.empresa = asto.empresa and ap.codigo=asto.codigo where ap.empresa=@empresa_matriz and codigo_tipo_documento='RV' 
	OPEN cursor_patron
	FETCH NEXT FROM cursor_patron into @codigo_tipo_apunte,@codigo_concepto,@patron	
	WHILE @@FETCH_STATUS = 0
		BEGIN
		 SET @patron = REPLACE(@patron,'[nombre_cliente]',RTRIM(@nombre_cliente))
		 SET @patron = REPLACE(@patron,'[razon_social_cliente]',RTRIM(@razon_social_cliente))
		 SET @patron = REPLACE(@patron,'[numero_factura]',RTRIM(@numero_factura))
		 SET @patron = REPLACE(@patron,'[fecha_factura]',RTRIM(@fecha_factura))
		 SET @patron = REPLACE(@patron,'[numero_recibo]',RTRIM(@numero_recibo))
		SET @patron = REPLACE(@patron,'[documento_pago]',RTRIM(@documento_pago))		 
			IF @codigo_tipo_apunte = 'RV_BANCO' 			
					BEGIN
						set @subcta_banco = (select subcuenta from eje_bancos_subcuenta where empresa = @Empresa and ejercicio = @ejercicio and codigo_banco = @pcodigo_banco)
						INSERT INTO tmp_apuntes_traspaso
						 (apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,fecha,codigo_concepto,descripcion,subcuenta,importe_debe,importe_haber,serie_documento,numero_documento)
						 values (@apunte,@Empresa,@Ejercicio,@sys_timestamp,@sesion,'RV',@pSys_oid_efecto,@pFecha,@pConcepto,@patron,@subcta_banco,@importe,0,'',@numero_recibo)
						set @apunte = @apunte + 1	  
					END
				ELSE
					IF @codigo_tipo_apunte = 'RV_CLIENTE' 
					BEGIN
						if @pmetalico = 1 set @importe_metalico = @importe else	set @importe_metalico = 0						
						IF ISNULL(@documento_pago,'')<>'' set @patron = rtrim(@patron) + ' Vto:' + ltrim(str(DAY(@fecha_vto))) + '/' + ltrim(STR(month(@fecha_vto))) + '/' + ltrim(str(year(@fecha_vto)))
						
						INSERT INTO tmp_apuntes_traspaso
						 (apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,fecha,codigo_concepto,descripcion,subcuenta,importe_debe,importe_haber,serie_documento,numero_documento,importe_metalico)
						 values (@apunte,@Empresa,@Ejercicio,@sys_timestamp,@sesion,'RV',@pSys_oid_efecto,@pFecha,@codigo_concepto,@patron,@subcta_cliente,0,@importe,'',@numero_recibo,@importe_metalico)
					
							set @apunte = @apunte + 1
					END
		FETCH NEXT FROM cursor_patron into @codigo_tipo_apunte,@codigo_concepto,@patron	
	  UPDATE emp_efectos SET fecha_pago=@pfecha,importe_pagado = isnull(importe_pagado,0)+@importe,codigo_banco=@pcodigo_banco WHERE sys_oid=@pSys_oid_efecto
	  UPDATE emp_efectos SET situacion='COB' WHERE sys_oid=@pSys_oid_efecto and importe = importe_pagado
	  
		
	end
	CLOSE cursor_patron
	DEALLOCATE cursor_patron
	EXEC vs_traspasar_asiento 'RV',@pSys_oid_efecto
	COMMIT 
END TRY
/****CONTROL DE ERRORES *****/
BEGIN CATCH
	set @pError = 'ERROR AL CONTABILIZAR el cobro del efecto(' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + ERROR_MESSAGE()
	ROLLBACK
	RAISERROR(@pError,16,1)
END CATCH
	
END

go

ALTER PROCEDURE [dbo].[vs_generar_asiento_entrega_cheque] 
 @pSys_oid_efecto dm_oid
,@pfecha_asiento dm_fechas_hora
,@pfecha_vencimiento dm_fechas_hora
,@pNumeroCheque dm_char_corto
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
		set @codigo_concepto = '1000026'
		set @patron = @pNumeroCheque + ' Vto: ' + ltrim(str(DAY(@pfecha_vencimiento))) + '/' + ltrim(STR(month(@pfecha_vencimiento))) + '/' + ltrim(str(year(@pfecha_vencimiento)))
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


