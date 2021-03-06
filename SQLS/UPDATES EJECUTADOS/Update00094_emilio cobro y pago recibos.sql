USE vs_martinez
GO
/****** Object:  StoredProcedure [dbo].[vs_generar_asiento_cobro_efecto]    Script Date: 02/23/2012 17:22:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[vs_generar_asiento_cobro_recibo_venta]
 @pSys_oid_efecto dm_oid
,@pfecha dm_fechas_hora
,@pcodigo_banco dm_codigos_c
,@importe dm_importes
,@pmetalico dm_logico
,@pcodigo_patron dm_codigos_c

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
	declare @texto_fecha_vto char(12)
	
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
	set @texto_fecha_vto=ltrim(str(DAY(@fecha_vto))) + '/' + ltrim(STR(month(@fecha_vto))) + '/' + ltrim(str(year(@fecha_vto)))		
	set @apunte = 1
	declare cursor_patron CURSOR FOR 
		select codigo_tipo_apunte,codigo_concepto,patron from emp_apuntes_patron as ap 
			where ap.empresa=@empresa_matriz and ap.codigo=@pcodigo_patron
	OPEN cursor_patron
	FETCH NEXT FROM cursor_patron into @codigo_tipo_apunte,@codigo_concepto,@patron	
	WHILE @@FETCH_STATUS = 0
		BEGIN
		 SET @patron = REPLACE(@patron,'[nombre_cliente]',RTRIM(@nombre_cliente))
		 SET @patron = REPLACE(@patron,'[razon_social_cliente]',RTRIM(@razon_social_cliente))
		 SET @patron = REPLACE(@patron,'[numero_factura]',RTRIM(@numero_factura))
		 SET @patron = REPLACE(@patron,'[fecha_factura]',RTRIM(@fecha_factura))
		 SET @patron = REPLACE(@patron,'[numero_recibo]',RTRIM(@numero_recibo))
		 SET @patron = REPLACE(@patron,'[documento_pago]',RTRIM(isnull(@documento_pago,'')))		 
		 SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(isnull(@texto_fecha_vto,'')))		 		 
			IF @codigo_tipo_apunte = 'RV_BANCO' 			
					BEGIN
						set @subcta_banco = (select subcuenta from eje_bancos_subcuenta where empresa = @Empresa and ejercicio = @ejercicio and codigo_banco = @pcodigo_banco)
						INSERT INTO tmp_apuntes_traspaso
						 (apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,fecha,codigo_concepto,descripcion,subcuenta,importe_debe,importe_haber,serie_documento,numero_documento)
						 values (@apunte,@Empresa,@Ejercicio,@sys_timestamp,@sesion,'RV',@pSys_oid_efecto,@pFecha,@codigo_concepto,@patron,@subcta_banco,@importe,0,'',@numero_recibo)
						set @apunte = @apunte + 1	  
					END
				ELSE
					IF @codigo_tipo_apunte = 'RV_CLIENTE' 
					BEGIN
						if @pmetalico = 1 set @importe_metalico = @importe else	set @importe_metalico = 0												
						INSERT INTO tmp_apuntes_traspaso
						 (apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,fecha,codigo_concepto,descripcion,subcuenta,importe_debe,importe_haber,serie_documento,numero_documento,importe_metalico)
						 values (@apunte,@Empresa,@Ejercicio,@sys_timestamp,@sesion,'RV',@pSys_oid_efecto,@pFecha,@codigo_concepto,@patron,@subcta_cliente,0,@importe,'',@numero_recibo,@importe_metalico)
					
							set @apunte = @apunte + 1
					END
		FETCH NEXT FROM cursor_patron into @codigo_tipo_apunte,@codigo_concepto,@patron			
	end
	CLOSE cursor_patron
	DEALLOCATE cursor_patron

  UPDATE emp_efectos SET fecha_pago=@pfecha,
	importe_pendiente=importe - (isnull(importe_pagado,0) + @importe),
	importe_pagado = isnull(importe_pagado,0)+@importe,
	codigo_banco=@pcodigo_banco 
	WHERE sys_oid=@pSys_oid_efecto
  
  UPDATE emp_efectos SET situacion='COB' WHERE sys_oid=@pSys_oid_efecto and importe = importe_pagado

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

CREATE PROCEDURE [dbo].[vs_generar_asiento_pago_recibo_compra] 
 @pSys_oid_efecto dm_oid
,@pfecha dm_fechas_hora
,@pcodigo_banco dm_codigos_c
,@importe dm_importes
,@pmetalico dm_logico
,@pcodigo_patron dm_codigos_c
AS
BEGIN

	declare @Empresa dm_empresas
	declare @ejercicio dm_ejercicios
	declare @codigo_tipo_apunte dm_codigos_c
	declare @codigo_concepto dm_codigos_c
	declare @patron dm_char_largo
	declare @sesion dm_entero
	declare @sys_timestamp dm_fechas_hora
	declare @nombre_proveedor dm_nombres
	declare @razon_social_proveedor dm_nombres
	declare @numero_factura dm_numero_doc
	declare @fecha_Factura dm_fechas_hora
	declare @numero_recibo dm_numero_doc
	declare @fecha dm_fechas_hora
	declare @apunte dm_entero
	declare @subcta_proveedor dm_subcuenta
	declare @subcta_banco dm_subcuenta
	declare @importe_metalico dm_importes
	declare @empresa_matriz dm_empresas	
	declare @fecha_vto dm_fechas_hora
	declare @texto_fecha_vto char(12)
	declare @documento_pago dm_char_corto
		
	select @empresa_matriz = codigo from gen_empresas where matriz=1
	set @Sesion = @@SPID
	set @sys_timestamp = getdate()
	select  @empresa=empresa
			,@nombre_proveedor=nombre_proveedor
			,@razon_social_proveedor=razon_social_proveedor
			,@fecha_factura = fecha_factura
			,@numero_factura=numero_factura
			,@numero_recibo=numero
			,@subcta_proveedor=subcuenta
			,@fecha_vto=fecha_vto,
			@documento_pago=documento_pago
			FROM  vv_recibos_compra
			WHERE sys_oid = @pSys_oid_efecto

	select @ejercicio = ejercicio from emp_ejercicios 
		where empresa=@empresa and fecha_apertura <= @pfecha and fecha_cierre>=@pfecha

	set @apunte = 1
	set @texto_fecha_vto=ltrim(str(DAY(@fecha_vto))) + '/' + ltrim(STR(month(@fecha_vto))) + '/' + ltrim(str(year(@fecha_vto)))		
	declare cursor_patron CURSOR FOR 
		select codigo_tipo_apunte,codigo_concepto,patron 
		  from emp_apuntes_patron 
		    where empresa = @empresa_matriz and codigo = @pcodigo_patron
		
	OPEN cursor_patron
	FETCH NEXT FROM cursor_patron into @codigo_tipo_apunte,@codigo_concepto,@patron	
	WHILE @@FETCH_STATUS = 0
		BEGIN
		 SET @patron = REPLACE(@patron,'[nombre_proveedor]',RTRIM(@nombre_proveedor))
		 SET @patron = REPLACE(@patron,'[razon_social_proveedor]',RTRIM(@razon_social_proveedor))
		 SET @patron = REPLACE(@patron,'[numero_factura]',RTRIM(isnull(@numero_factura,'')))
--		 SET @patron = REPLACE(@patron,'[fecha_factura]',RTRIM(@fecha_factura))
		 SET @patron = REPLACE(@patron,'[documento_pago]',RTRIM(isnull(@documento_pago,'')))		 
		 SET @patron = REPLACE(@patron,'[numero_recibo]',RTRIM(@numero_recibo))
		 
		 SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(isnull(@texto_fecha_vto,'')))		 		 		
		 		 
			IF @codigo_tipo_apunte = 'RC_BANCO' 			
					BEGIN
						set @subcta_banco = (select subcuenta from eje_bancos_subcuenta where empresa = @Empresa and ejercicio = @ejercicio and codigo_banco = @pcodigo_banco)
						INSERT INTO tmp_apuntes_traspaso
						 (apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,fecha,codigo_concepto,descripcion,subcuenta,importe_debe,importe_haber,serie_documento,numero_documento)
						 values (@apunte,@Empresa,@Ejercicio,@sys_timestamp,@sesion,'RC',@pSys_oid_efecto,@pFecha,@codigo_Concepto,@patron,@subcta_banco,0,@importe,'',@numero_recibo)
						set @apunte = @apunte + 1	  
					END
			ELSE
				IF @codigo_tipo_apunte = 'RC_PROVEED' 
				BEGIN
					if @pmetalico = 1 
						set @importe_metalico = @importe 
					else	
						set @importe_metalico = 0						
					INSERT INTO tmp_apuntes_traspaso
						 (apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,fecha,codigo_concepto,descripcion,subcuenta,importe_debe,importe_haber,serie_documento,numero_documento,importe_metalico)
						 values (@apunte,@Empresa,@Ejercicio,@sys_timestamp,@sesion,'RC',@pSys_oid_efecto,@pFecha,@codigo_concepto,@patron,@subcta_proveedor,@importe,0,'',@numero_recibo,@importe_metalico)
					
					set @apunte = @apunte + 1
				END
			FETCH NEXT FROM cursor_patron into @codigo_tipo_apunte,@codigo_concepto,@patron	  
	end 
	
	UPDATE emp_efectos set
		fecha_pago=@pfecha,
		importe_pagado = ISNULL(importe_pagado,0) + @importe,
		importe_pendiente = ISNULL(importe,0) - (ISNULL(importe_pagado,0) + @importe),
		codigo_banco=@pcodigo_banco 
	WHERE sys_oid=@pSys_oid_efecto
	
	UPDATE emp_efectos SET situacion='PAG' WHERE sys_oid=@pSys_oid_efecto and importe_pagado=importe
	
	CLOSE cursor_patron
	DEALLOCATE cursor_patron
END
