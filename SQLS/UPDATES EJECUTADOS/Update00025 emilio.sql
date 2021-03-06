USE vs_martinez
GO
/****** Object:  StoredProcedure [dbo].[vs_generar_asiento_orden_pago]    Script Date: 01/19/2012 18:40:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[vs_generar_asiento_fusion_efectos]
@pSys_oid_fusion dm_oid

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
	declare @codigo_cliente dm_codigos_n
	declare @numero_efecto dm_numero_doc
	declare @numero_factura dm_numero_doc
	declare @numero_recibo dm_numero_doc
	declare @numero_fusion dm_numero_doc
	declare @nombre_cliente dm_nombres
	declare @razon_social_cliente dm_nombres
	declare @importe_fusion dm_importes
	DECLARE @perror varchar(4000)
	declare @subcuenta_cliente dm_subcuenta
	
	select @Empresa=empresa,@numero_fusion=numero,@fecha=fecha_emision,@codigo_cliente=codigo_cliente,@importe_fusion=importe from emp_fusion_efectos_c where sys_oid = @psys_oid_fusion
	select @ejercicio = ejercicio,@fecha_bloqueo_ejercicio=fecha_bloqueo from emp_ejercicios where empresa=@empresa and fecha_apertura <= @fecha and fecha_cierre>=@fecha
	select @subcuenta_cliente = subcuenta from eje_clientes_cond_venta_cuentas where empresa = @empresa and ejercicio=@ejercicio and codigo_cliente=@codigo_cliente and codigo_tipo_cond_venta='1'

		set @Sesion = @@SPID
		set @sys_timestamp = getdate()

		DELETE tmp_apuntes_traspaso where empresa=@empresa and sys_oid_origen = @psys_oid_fusion and codigo_tipo_documento_origen = 'FE'

		set @codigo_concepto = ''
		set @patron = 'FUSIÓN EFECTO Nº' + RTRIM(@numero_fusion)
		INSERT INTO tmp_apuntes_traspaso
				 (apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,fecha,codigo_concepto,descripcion,subcuenta,importe_debe,importe_haber)
				 values (1,@Empresa,@Ejercicio,@sys_timestamp,@sesion,'FE',@psys_oid_fusion,@Fecha,@codigo_concepto,@patron,@subcuenta_cliente,0,@importe_fusion)
				   
		INSERT INTO tmp_apuntes_traspaso
			 (apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,fecha,subcuenta,codigo_concepto,descripcion,importe_debe,importe_haber)
			SELECT row_number() over (order by L.sys_oid)+1 AS apunte,C.empresa,@Ejercicio ,@sys_timestamp,@sesion,'OP',c.sys_oid,
					 @Fecha, @subcuenta_cliente,@codigo_concepto,@patron,0, L.importe AS importe_apunte
			FROM dbo.emp_fusion_efectos_c AS C INNER JOIN
				  dbo.emp_fusion_efectos_l AS l ON C.empresa = L.empresa AND C.numero = L.numero 
			WHERE c.sys_oid = @psys_oid_fusion

		  UPDATE emp_fusion_efectos_c SET situacion='C' WHERE sys_oid=@psys_oid_fusion
		  UPDATE emp_efectos SET situacion='FE'
		  FROM emp_efectos
		   INNER JOIN emp_fusion_efectos_l ON emp_efectos.empresa = emp_fusion_efectos_l.empresa and emp_efectos.numero=emp_fusion_efectos_l.numero_efecto
		   WHERE emp_fusion_efectos_l.empresa=@Empresa AND emp_fusion_efectos_l.numero=@numero_fusion
			
		
		EXEC vs_traspasar_asiento 'FE',@psys_oid_fusion
		COMMIT 

END TRY
/****CONTROL DE ERRORES *****/
BEGIN CATCH
	set @pError = 'ERROR AL CONTABILIZAR la orden de pago (' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + ERROR_MESSAGE()
	ROLLBACK
	RAISERROR(@pError,16,1)
END CATCH

END

go

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
	
	select @Empresa=empresa,@numero_orden=numero,@fecha=fecha_vto from emp_orden_pago_c where sys_oid = @pSys_oid_orden
	select @ejercicio = ejercicio,@fecha_bloqueo_ejercicio=fecha_bloqueo from emp_ejercicios where empresa=@empresa and fecha_apertura <= @fecha and fecha_cierre>=@fecha

		set @Sesion = @@SPID
		set @sys_timestamp = getdate()

		DELETE tmp_apuntes_traspaso where empresa=@empresa and sys_oid_origen = @psys_oid_orden and codigo_tipo_documento_origen = 'OP'

		select  @numero_factura=dbo.emp_efectos.numero_factura,@numero_efecto=numero_efecto
				FROM  emp_orden_pago_c
				INNER JOIN			
					dbo.emp_orden_pago_l ON emp_orden_pago_c.empresa=dbo.emp_orden_pago_l.empresa AND emp_orden_pago_c.numero=dbo.emp_orden_pago_l.numero
				INNER JOIN
					   dbo.emp_efectos ON dbo.emp_orden_pago_l.empresa = dbo.emp_efectos.empresa AND dbo.emp_orden_pago_l.numero_efecto = dbo.emp_efectos.numero
				WHERE dbo.emp_orden_pago_c.sys_oid = @pSys_oid_orden


		declare cursor_patron CURSOR FOR 
			select codigo_tipo_apunte,codigo_concepto,patron from emp_apuntes_patron as ap left join emp_asientos_patron as asto 
			ON ap.empresa = asto.empresa and ap.codigo=asto.codigo where ap.empresa=@empresa and codigo_tipo_documento='OP' 
		OPEN cursor_patron
		FETCH NEXT FROM cursor_patron into @codigo_tipo_apunte,@codigo_concepto,@patron	
		WHILE @@FETCH_STATUS = 0
			BEGIN
			
			SET @patron = REPLACE(@patron,'[nombre_proveedor]',RTRIM(@nombre_proveedor))
			SET @patron = REPLACE(@patron,'[razon_social_proveedor]',RTRIM(@razon_social_proveedor))
			SET @patron = REPLACE(@patron,'[numero_factura]',RTRIM(@numero_factura))
			SET @patron = REPLACE(@patron,'[fecha]',RTRIM(@fecha))
			SET @patron = REPLACE(@patron,'[numero_efecto]',RTRIM(@numero_efecto))
			SET @patron = REPLACE(@patron,'[numero_orden]',RTRIM(@numero_orden))
			
				IF @codigo_tipo_apunte = 'OP_BANCO' 			
						BEGIN
						
							INSERT INTO tmp_apuntes_traspaso
							 (apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,fecha,codigo_concepto,descripcion,subcuenta,importe_debe,importe_haber)
							   SELECT TOP (1) 1,@Empresa,@Ejercicio,@sys_timestamp,@sesion,'OP',@pSys_oid_orden,@Fecha,@codigo_concepto,@patron,@subcuenta_banco,0,importe
							  FROM emp_orden_pago_c WHERE sys_oid = @pSys_oid_orden
							  
						END
					ELSE
						IF @codigo_tipo_apunte = 'OP_EFECTO' 
						BEGIN
							INSERT INTO tmp_apuntes_traspaso
								 (apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,fecha,subcuenta,codigo_concepto,descripcion,importe_debe,importe_haber)
								SELECT row_number() over (order by L.sys_oid)+1 AS apunte,C.empresa,@Ejercicio ,@sys_timestamp,@sesion,'OP',c.sys_oid,
										 @Fecha, S.subcuenta AS sub_cta_apunte,@codigo_concepto,@patron,0, L.importe AS importe_apunte
								FROM dbo.emp_orden_pago_c AS C INNER JOIN
									  dbo.emp_orden_pago_l AS l ON C.empresa = L.empresa AND C.numero = L.numero INNER JOIN
									  dbo.eje_bancos_subcuenta AS S ON C.empresa = S.empresa AND C.codigo_banco = S.codigo_banco
								WHERE c.empresa=@Empresa and S.ejercicio=@ejercicio							
						END
						
			FETCH NEXT FROM cursor_patron into @codigo_tipo_apunte,@codigo_concepto,@patron	
		  UPDATE emp_orden_pago_c SET situacion='C' WHERE sys_oid=@pSys_oid_orden
		  UPDATE emp_efectos SET situacion='PG'
		  FROM emp_efectos
		   INNER JOIN emp_orden_pago_l ON emp_efectos.empresa = emp_orden_pago_l.empresa and emp_efectos.numero=emp_orden_pago_l.numero_efecto
		   WHERE emp_orden_pago_l.empresa=@Empresa AND emp_orden_pago_l.numero=@numero_orden
			
		end
		CLOSE cursor_patron
		DEALLOCATE cursor_patron
		
		EXEC vs_traspasar_asiento 'OP',@pSys_oid_orden
		COMMIT 

END TRY
/****CONTROL DE ERRORES *****/
BEGIN CATCH
	set @pError = 'ERROR AL CONTABILIZAR la orden de pago (' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + ERROR_MESSAGE()
	ROLLBACK
	RAISERROR(@pError,16,1)
END CATCH

END


