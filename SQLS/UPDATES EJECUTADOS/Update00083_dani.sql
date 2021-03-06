USE [vs_martinez]
GO
/****** Object:  StoredProcedure [dbo].[vs_generar_asiento_orden_pago]    Script Date: 02/16/2012 10:29:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[vs_generar_asiento_orden_pago]
@pSys_oid_orden dm_oid

AS
BEGIN
begin try	
BEGIN TRANSACTION 

	declare @empresa dm_empresas
	declare @ejercicio dm_ejercicios
	declare @fecha dm_fechas_hora
	declare @fecha_bloqueo_ejercicio dm_fechas_hora
	declare @codigo_tipo_apunte dm_codigos_c
	declare @codigo_concepto dm_codigos_c
	declare @patron dm_char_largo
	declare @sesion dm_entero
	declare @sys_timestamp dm_fechas_hora
	declare @numero_efecto dm_numero_doc
	declare @numero_factura dm_numero_doc
	declare @numero_recibo dm_numero_doc
	declare @numero_orden dm_numero_doc
	declare @nombre_proveedor dm_nombres
	declare @razon_social_proveedor dm_nombres
	DECLARE @perror varchar(4000)
	declare @subcuenta_banco dm_subcuenta
	declare @documento_pago dm_char_corto
	declare @empresa_matriz dm_empresas 
	declare @fecha_vencimiento dm_fechas_hora
	declare @fecha_emision dm_fechas_hora
	declare @codigo_banco dm_codigos_c
	declare @importe_pendiente dm_importes
	declare @apunte dm_entero
	declare @subcuenta dm_subcuenta
	declare @subcuenta_efectos dm_subcuenta
	declare @sys_oid_efecto dm_oid
	declare @su_factura dm_char_corto
	declare @codigo_proveedor dm_codigos_n
	DECLARE @importe_total dm_importes
	
	select @empresa_matriz=codigo FROM gen_empresas WHERE matriz = 1
		
	select @Empresa=OP.empresa,@numero_orden=OP.numero,@fecha_vencimiento=OP.fecha_vto, @fecha_emision=OP.fecha_emision,
		@documento_pago=OP.documento_pago,@codigo_proveedor=op.codigo_proveedor,@nombre_proveedor=pr.nombre,
		@razon_social_proveedor=pr.razon_social,@codigo_banco=op.codigo_banco,@importe_total=op.importe
	  from emp_orden_pago_c as OP
		left outer join vf_emp_proveedores as PR ON pr.empresa = @empresa_matriz 
			AND pr.codigo = op.codigo_proveedor
	   WHERE OP.sys_oid = @pSys_oid_orden
	 
	select @ejercicio = ejercicio,@fecha_bloqueo_ejercicio=fecha_bloqueo 
	  from emp_ejercicios 
	  where empresa=@empresa and fecha_apertura <= @fecha_emision and fecha_cierre>=@fecha_emision
	  
	  select @subcuenta_efectos=CTAS.subcuenta_efectos 
	    FROM eje_proveedores_cond_compra_cuentas AS CTAS
			INNER JOIN emp_proveedores_cond_compra AS CC ON CC.empresa = CTAS.empresa 
				AND CC.codigo_proveedor = CTAS.codigo_proveedor
				AND CC.predeterminada = 1
	   WHERE CTAS.empresa = @empresa_matriz 
	     AND CTAS.ejercicio = @ejercicio
	     AND CTAS.codigo_proveedor = @codigo_proveedor
	
		if ISNULL(@subcuenta_efectos,'') = '' 
			raiserror('No encuentro la subcuenta de efectos para este proveedor',16,1)
			
	  select @subcuenta_banco=subcuenta
	    FROM eje_bancos_subcuenta
	   WHERE empresa = @empresa_matriz
	     AND ejercicio = @ejercicio
	     AND codigo_banco = @codigo_banco
	     
		if ISNULL(@subcuenta_banco, '') = ''
			raiserror('No encuentro la subcuenta del banco indicado', 16,1)
				     
		set @Sesion = @@SPID
		set @sys_timestamp = getdate()

		DELETE tmp_apuntes_traspaso 
		where empresa=@empresa
		and sys_oid_origen = @psys_oid_orden 
		and codigo_tipo_documento_origen = 'OP'
		
		/*Asiento EMISION pagare*/
		select @codigo_tipo_apunte=codigo_tipo_apunte,@codigo_concepto=codigo_concepto,@patron=ap.patron
		  from emp_apuntes_patron as ap 
			left join emp_asientos_patron as asto ON ap.empresa = asto.empresa and ap.codigo=asto.codigo 
		  where ap.empresa=@empresa_matriz 
		    and codigo_tipo_documento='OP' --Orden Pago Emision
		    and codigo_tipo_apunte='OP_EF_EMI'
					
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',ISNULL(RTRIM(@nombre_proveedor),''))
		SET @patron = REPLACE(@patron,'[razon_social_proveedor]',ISNULL(RTRIM(@razon_social_proveedor),''))
		SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(CONVERT(date, @fecha_vencimiento)))		    
		SET @patron = REPLACE(@patron,'[banco_pago]',ISNULL(RTRIM(@codigo_banco),''))		    
		SET @patron = REPLACE(@patron,'[numero_orden]',ISNULL(RTRIM(@numero_orden),''))
		SET @patron = REPLACE(@patron,'[documento_pago]',ISNULL(RTRIM(@documento_pago),''))
		
		declare cursor_recibos_orden cursor local for 
		select  dbo.emp_efectos.numero_factura,numero_efecto,emp_efectos.su_factura,
			emp_efectos.subcuenta,emp_efectos.importe_pendiente,emp_efectos.sys_oid
  		  FROM  emp_orden_pago_c
			INNER JOIN			
				dbo.emp_orden_pago_l ON emp_orden_pago_c.empresa=dbo.emp_orden_pago_l.empresa AND emp_orden_pago_c.numero=dbo.emp_orden_pago_l.numero
			INNER JOIN
			   dbo.emp_efectos ON dbo.emp_orden_pago_l.empresa = dbo.emp_efectos.empresa AND dbo.emp_orden_pago_l.numero_efecto = dbo.emp_efectos.numero
		 WHERE dbo.emp_orden_pago_c.sys_oid = @pSys_oid_orden
				
		SET @apunte = 0	
		OPEN cursor_recibos_orden
		FETCH NEXT FROM cursor_recibos_orden into @numero_factura, @numero_efecto,@su_factura, @subcuenta,@importe_pendiente,@sys_oid_efecto
		WHILE @@FETCH_STATUS = 0
		BEGIN			
			SET @patron = REPLACE(@patron,'[numero_factura]',ISNULL(RTRIM(@numero_factura),''))
			SET @patron = REPLACE(@patron,'[numero_efecto]',ISNULL(RTRIM(@numero_efecto),''))
			SET @patron = REPLACE(@patron,'[su_factura]',ISNULL(RTRIM(@su_factura),''))
			
			SET @apunte = @apunte + 1
			INSERT INTO tmp_apuntes_traspaso
				 (asiento, apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,
				 fecha,subcuenta,codigo_concepto,descripcion,importe_debe,importe_haber)
			  values (1, @apunte, @empresa, @Ejercicio ,@sys_timestamp,@sesion,'OP',@pSys_oid_orden,
						 @fecha_emision, @subcuenta, @codigo_concepto, @patron,@importe_pendiente,0)
									
			--UPDATE emp_efectos SET situacion='FU'
			-- WHERE sys_oid = @sys_oid_efecto

			FETCH NEXT FROM cursor_recibos_orden into @numero_factura, @numero_efecto,@su_factura, @subcuenta,@importe_pendiente,@sys_oid_efecto
					
		END  
				
		CLOSE cursor_recibos_orden
		DEALLOCATE cursor_recibos_orden

		select @codigo_tipo_apunte=codigo_tipo_apunte,@codigo_concepto=codigo_concepto,@patron=ap.patron
		  from emp_apuntes_patron as ap 
			left join emp_asientos_patron as asto ON ap.empresa = asto.empresa and ap.codigo=asto.codigo 
		  where ap.empresa=@empresa_matriz 
		    and codigo_tipo_documento='OP' --Efecto fusionado
		    and codigo_tipo_apunte='OP_EF_EMIF'
		    
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',ISNULL(RTRIM(@nombre_proveedor),''))
		SET @patron = REPLACE(@patron,'[razon_social_proveedor]',ISNULL(RTRIM(@razon_social_proveedor),''))
		SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(CONVERT(date, @fecha_vencimiento)))		    
		SET @patron = REPLACE(@patron,'[banco_pago]',ISNULL(RTRIM(@codigo_banco),''))		    
		SET @patron = REPLACE(@patron,'[numero_orden]',ISNULL(RTRIM(@numero_orden),''))
		SET @patron = REPLACE(@patron,'[documento_pago]',ISNULL(RTRIM(@documento_pago),''))
		
		SET @apunte = @apunte + 1
		INSERT INTO tmp_apuntes_traspaso
			(asiento, apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,
				 fecha,subcuenta,codigo_concepto,descripcion,importe_debe,importe_haber)
		  values (1, @apunte, @empresa, @Ejercicio ,@sys_timestamp,@sesion,'OP',@pSys_oid_orden,
			 @fecha_emision, @subcuenta_efectos, @codigo_concepto, @patron, 0, @importe_total)
			 
		/*Asiento COBRO pagare*/
		
		select @codigo_tipo_apunte=codigo_tipo_apunte,@codigo_concepto=codigo_concepto,@patron=ap.patron
		  from emp_apuntes_patron as ap 
			left join emp_asientos_patron as asto ON ap.empresa = asto.empresa and ap.codigo=asto.codigo 
		  where ap.empresa=@empresa_matriz 
		    and codigo_tipo_documento='OP' --Efecto fusionado
		    and codigo_tipo_apunte='OP_EFE_FUS'
		    
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',ISNULL(RTRIM(@nombre_proveedor),''))
		SET @patron = REPLACE(@patron,'[razon_social_proveedor]',ISNULL(RTRIM(@razon_social_proveedor),''))
		SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(CONVERT(date, @fecha_vencimiento)))		    
		SET @patron = REPLACE(@patron,'[banco_pago]',ISNULL(RTRIM(@codigo_banco),''))		    
		SET @patron = REPLACE(@patron,'[numero_orden]',ISNULL(RTRIM(@numero_orden),''))
		SET @patron = REPLACE(@patron,'[documento_pago]',ISNULL(RTRIM(@documento_pago),''))
		
		SET @apunte = 1
		INSERT INTO tmp_apuntes_traspaso
			(asiento, apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,
				 fecha,subcuenta,codigo_concepto,descripcion,importe_debe,importe_haber)
		  values (2, @apunte, @empresa, @Ejercicio ,@sys_timestamp,@sesion,'OP',@pSys_oid_orden,
			 @fecha_vencimiento, @subcuenta_efectos, @codigo_concepto, @patron, @importe_total, 0)

		select @codigo_tipo_apunte=codigo_tipo_apunte,@codigo_concepto=codigo_concepto,@patron=ap.patron
		  from emp_apuntes_patron as ap 
			left join emp_asientos_patron as asto ON ap.empresa = asto.empresa and ap.codigo=asto.codigo 
		  where ap.empresa=@empresa_matriz 
		    and codigo_tipo_documento='OP' --Efecto fusionado
		    and codigo_tipo_apunte='OP_BANCO'
		    
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',ISNULL(RTRIM(@nombre_proveedor),''))
		SET @patron = REPLACE(@patron,'[razon_social_proveedor]',ISNULL(RTRIM(@razon_social_proveedor),''))
		SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(CONVERT(date, @fecha_vencimiento)))		    
		SET @patron = REPLACE(@patron,'[banco_pago]',ISNULL(RTRIM(@codigo_banco),''))		    
		SET @patron = REPLACE(@patron,'[numero_orden]',ISNULL(RTRIM(@numero_orden),''))
		SET @patron = REPLACE(@patron,'[documento_pago]',ISNULL(RTRIM(@documento_pago),''))
		
		SET @apunte = @apunte + 1
		INSERT INTO tmp_apuntes_traspaso
			(asiento, apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,
				 fecha,subcuenta,codigo_concepto,descripcion,importe_debe,importe_haber)
		  values (2, @apunte, @empresa, @Ejercicio ,@sys_timestamp,@sesion,'OP',@pSys_oid_orden,
			 @fecha_vencimiento, @subcuenta_banco, @codigo_concepto, @patron, 0, @importe_total)
			 	
--		UPDATE emp_orden_pago_c 
--			SET situacion='C' 
--		 WHERE sys_oid=@pSys_oid_orden
		
--		EXEC vs_traspasar_asiento 'OP',@pSys_oid_orden

		COMMIT 

END TRY
/****CONTROL DE ERRORES *****/
BEGIN CATCH
	set @pError = 'ERROR AL CONTABILIZAR la orden de pago (' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + ERROR_MESSAGE()
	ROLLBACK
	RAISERROR(@pError,16,1)
END CATCH

END


