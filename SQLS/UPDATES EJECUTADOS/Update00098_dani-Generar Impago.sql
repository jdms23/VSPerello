USE [vsolution]
GO
/****** Object:  StoredProcedure [dbo].[vs_generar_asiento_impago]    Script Date: 02/28/2012 17:27:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[vs_generar_asiento_impago]
 @pSys_oid_efecto dm_oid
,@pfecha dm_fechas_hora
,@pcodigo_banco dm_codigos_c
,@importe_gastos dm_importes
,@subcuenta_gastos dm_subcuenta
,@asiento_patron dm_codigos_c
,@usuario dm_codigos_c

AS
BEGIN
	declare @Empresa dm_empresas
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
	declare @subcta_banco dm_subcuenta
	declare @importe dm_importes
	declare @importe_banco dm_importes
	declare @observaciones dm_memo
	declare @empresa_matriz dm_empresas
	declare @fecha_vencimiento dm_fechas_hora
	declare @codigo_banco dm_codigos_c
	declare @numero_remesa dm_numero_doc
	declare @documento_pago dm_char_corto
	declare @serie dm_codigos_c
	
	DECLARE @perror varchar(4000)

BEGIN TRY

	BEGIN TRANSACTION

	set @Sesion = @@SPID
	set @sys_timestamp = getdate()
	select  @empresa=empresa
			,@codigo_cliente=codigo_cliente
			,@nombre_cliente=nombre_cliente
			,@razon_social_cliente=razon_social_cliente
			,@fecha_factura = fecha_factura
			,@serie=serie
			,@numero_factura=numero_factura
			,@numero_recibo=numero
			,@importe = importe
			,@fecha_vencimiento=fecha_vto
			,@codigo_banco=codigo_banco
			,@numero_remesa=numero_remesa
			,@documento_pago=documento_pago
			FROM  vv_recibos_venta
			WHERE sys_oid = @pSys_oid_efecto
	
	select @empresa_matriz=codigo FROM gen_empresas WHERE matriz = 1	
	select @ejercicio=(select ejercicio from emp_ejercicios where empresa=@empresa and fecha_apertura <= @pfecha and fecha_cierre>=@pfecha)	
	
	SELECT @subcta_cliente = subcuenta_impagados 
	  from eje_clientes_cond_venta_cuentas 
	 where empresa = @Empresa 
	   and ejercicio=@ejercicio 
	   and codigo_cliente=@codigo_cliente 
	   and codigo_tipo_cond_venta='1'

    if ISNULL(@subcta_cliente, '') = ''
    BEGIN
		SET @perror = 'No encuentro la subcuenta de impagados para este cliente.'
		RAISERROR('',16,1)
	END	

	select @codigo_concepto=ap.codigo_concepto,@codigo_tipo_apunte=codigo_tipo_apunte,@patron=ap.patron
	  from emp_apuntes_patron as ap 
		left join emp_asientos_patron as asto ON ap.empresa = asto.empresa and ap.codigo=asto.codigo 
     where asto.empresa=@empresa_matriz 
		and asto.codigo=@asiento_patron
		and codigo_tipo_documento='IMP' --IMPAGADO
		and codigo_tipo_apunte='IMP_CLIENT' -- Apunte del cliente
	
	if @@ROWCOUNT = 0 
    BEGIN
		SET @perror = 'No encuentro la definición del apunte IMP_CLIENT.'
		RAISERROR('',16,1)
	END	
					
	set @apunte = 1

	SET @patron = REPLACE(@patron,'[nombre_cliente]',ISNULL(RTRIM(@nombre_cliente),''))
	SET @patron = REPLACE(@patron,'[razon_social_cliente]',ISNULL(RTRIM(@razon_social_cliente),''))
	SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(CONVERT(date, @fecha_vencimiento)))		    
	SET @patron = REPLACE(@patron,'[banco_pago]',ISNULL(RTRIM(@pcodigo_banco),''))		    
	SET @patron = REPLACE(@patron,'[numero_remesa]',ISNULL(RTRIM(@numero_remesa),''))
	SET @patron = REPLACE(@patron,'[documento_pago]',ISNULL(RTRIM(@documento_pago),''))		
	SET @patron = REPLACE(@patron,'[numero_factura]',ISNULL(RTRIM(@numero_factura),''))
	SET @patron = REPLACE(@patron,'[serie]',ISNULL(RTRIM(@serie),''))
	SET @patron = REPLACE(@patron,'[numero_recibo]',ISNULL(RTRIM(@numero_recibo),''))
	
	INSERT INTO tmp_apuntes_traspaso
	 (apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,fecha,codigo_concepto,descripcion,subcuenta,importe_debe,importe_haber,serie_documento,numero_documento)
	 values (@apunte,@Empresa,@Ejercicio,@sys_timestamp,@sesion,'RV',@pSys_oid_efecto,@pFecha,@codigo_concepto,@patron,@subcta_cliente,@importe,0,'',@numero_recibo)
	
	if isnull(@importe_gastos,0) > 0
	begin			
		select @codigo_concepto=ap.codigo_concepto,@codigo_tipo_apunte=codigo_tipo_apunte,@patron=ap.patron
		  from emp_apuntes_patron as ap 
			left join emp_asientos_patron as asto ON ap.empresa = asto.empresa and ap.codigo=asto.codigo 
		 where asto.empresa=@empresa_matriz 
			and asto.codigo=@asiento_patron
			and codigo_tipo_documento='IMP' --IMPAGADO
			and codigo_tipo_apunte='IMP_GASTOS' -- Apunte del banco

		if @@ROWCOUNT = 0
		BEGIN
			SET @perror = 'No encuentro la definicion del apunte de GASTOS.'
			RAISERROR('',16,1)
		END	
			
		set @apunte = @apunte + 1
		
		SET @patron = REPLACE(@patron,'[nombre_cliente]',ISNULL(RTRIM(@nombre_cliente),''))
		SET @patron = REPLACE(@patron,'[razon_social_cliente]',ISNULL(RTRIM(@razon_social_cliente),''))
		SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(CONVERT(date, @fecha_vencimiento)))		    
		SET @patron = REPLACE(@patron,'[banco_pago]',ISNULL(RTRIM(@codigo_banco),''))		    
		SET @patron = REPLACE(@patron,'[numero_remesa]',ISNULL(RTRIM(@numero_remesa),''))
		SET @patron = REPLACE(@patron,'[documento_pago]',ISNULL(RTRIM(@documento_pago),''))		
		SET @patron = REPLACE(@patron,'[numero_factura]',ISNULL(RTRIM(@numero_factura),''))
		SET @patron = REPLACE(@patron,'[serie]',ISNULL(RTRIM(@serie),''))
		SET @patron = REPLACE(@patron,'[numero_recibo]',ISNULL(RTRIM(@numero_recibo),''))
	
		INSERT INTO tmp_apuntes_traspaso
				 (apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,fecha,codigo_concepto,descripcion,subcuenta,importe_debe,importe_haber,serie_documento,numero_documento)
				 values (@apunte,@Empresa,@Ejercicio,@sys_timestamp,@sesion,'RV',@pSys_oid_efecto,@pFecha,@codigo_concepto,@patron,@subcuenta_gastos,@importe_gastos,0,'',@numero_recibo)
			set @apunte = @apunte + 1	  			
	end
	
	select @codigo_concepto=ap.codigo_concepto,@codigo_tipo_apunte=codigo_tipo_apunte,@patron=ap.patron
	  from emp_apuntes_patron as ap 
		left join emp_asientos_patron as asto ON ap.empresa = asto.empresa and ap.codigo=asto.codigo 
	 where asto.empresa=@empresa_matriz 
		and asto.codigo=@asiento_patron
		and codigo_tipo_documento='IMP' --IMPAGADO
		and codigo_tipo_apunte='IMP_BANCO' -- Apunte del banco
		
    if @@ROWCOUNT = 0
    BEGIN
		SET @perror = 'No encuentro la definicion del apunte IMP_BANCO'
		RAISERROR('',16,1)
	END	
		
	set @apunte = @apunte + 1
	
	SET @patron = REPLACE(@patron,'[nombre_cliente]',ISNULL(RTRIM(@nombre_cliente),''))
	SET @patron = REPLACE(@patron,'[razon_social_cliente]',ISNULL(RTRIM(@razon_social_cliente),''))
	SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(CONVERT(date, @fecha_vencimiento)))		    
	SET @patron = REPLACE(@patron,'[banco_pago]',ISNULL(RTRIM(@codigo_banco),''))		    
	SET @patron = REPLACE(@patron,'[numero_remesa]',ISNULL(RTRIM(@numero_remesa),''))
	SET @patron = REPLACE(@patron,'[documento_pago]',ISNULL(RTRIM(@documento_pago),''))		
	SET @patron = REPLACE(@patron,'[numero_factura]',ISNULL(RTRIM(@numero_factura),''))
	SET @patron = REPLACE(@patron,'[serie]',ISNULL(RTRIM(@serie),''))
	SET @patron = REPLACE(@patron,'[numero_recibo]',ISNULL(RTRIM(@numero_recibo),''))

	set @importe_banco = @importe + ISNULL(@importe_gastos,0)
	set @subcta_banco = (select subcuenta from eje_bancos_subcuenta where empresa = @Empresa and ejercicio = @ejercicio and codigo_banco = @pcodigo_banco)
	
    if ISNULL(@subcta_banco, '') = ''
    BEGIN
		SET @perror = 'No encuentro la subcuenta del banco del impago.'
		RAISERROR('',16,1)
	END	

	INSERT INTO tmp_apuntes_traspaso
		 (apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,fecha,codigo_concepto,descripcion,subcuenta,importe_debe,importe_haber,serie_documento,numero_documento)
		 values (@apunte,@Empresa,@Ejercicio,@sys_timestamp,@sesion,'RV',@pSys_oid_efecto,@pFecha,@codigo_concepto,@patron,@subcta_banco,0,@importe_banco,'',@numero_recibo)
		set @apunte = @apunte + 1	  

	set @observaciones = 'Impago introducido por ' + @usuario	  		

	UPDATE emp_efectos SET subcuenta=@subcta_cliente,
		situacion='IM',
		gastos_financieros_dev=@importe_gastos,
		observaciones=@observaciones,
		importe_pagado=0,
		importe_pendiente=importe 
	 WHERE sys_oid=@pSys_oid_efecto
	 
	EXEC vs_traspasar_asiento 'RV',@pSys_oid_efecto

	COMMIT 
	
END TRY
/****CONTROL DE ERRORES *****/
BEGIN CATCH
	set @pError = 'ERROR AL CONTABILIZAR el impago del efecto(' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + ISNULL(@pError,'') + CHAR(13) + CHAR(10) + ERROR_MESSAGE()
	ROLLBACK
	RAISERROR(@pError,16,1)
END CATCH
	
END

/*
exec vs_generar_asiento_descontar_remesa 'E_000001J','2011',2,'28-09-2011'

*/