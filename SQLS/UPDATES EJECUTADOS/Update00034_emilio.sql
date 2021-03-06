USE vsolution
GO

/****** Object:  StoredProcedure [dbo].[vs_generar_asiento_fusion_efectos]    Script Date: 01/23/2012 17:28:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[vs_generar_asiento_fusion_efectos]
@pSys_oid_fusion dm_oid

AS
BEGIN
begin try	
BEGIN TRANSACTION 

	declare @empresa dm_empresas
	declare @empresa_matriz dm_empresas
	declare @ejercicio dm_ejercicios
	declare @fecha dm_fechas_hora
	declare @codigo_tipo_efecto dm_codigos_c
	declare @fecha_vto dm_fechas_hora
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
	
	select @empresa_matriz = codigo from gen_empresas where matriz=1
	select @Empresa=empresa,@numero_fusion=numero,@fecha=fecha_emision,@fecha_vto=fecha_vto,@codigo_cliente=codigo_cliente,@importe_fusion=importe,@codigo_tipo_efecto=codigo_tipo_efecto
		from emp_fusion_efectos_c where sys_oid = @psys_oid_fusion
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
			SELECT row_number() over (order by L.sys_oid)+1 AS apunte,C.empresa,@Ejercicio ,@sys_timestamp,@sesion,'FE',c.sys_oid,
					 @Fecha, @subcuenta_cliente,@codigo_concepto,@patron,0, L.importe AS importe_apunte
			FROM dbo.emp_fusion_efectos_c AS C INNER JOIN
				  dbo.emp_fusion_efectos_l AS l ON C.empresa = L.empresa AND C.numero = L.numero 
			WHERE c.sys_oid = @psys_oid_fusion

		  UPDATE emp_fusion_efectos_c SET situacion='C' WHERE sys_oid=@psys_oid_fusion
		  UPDATE emp_efectos SET situacion='FU'
		  FROM emp_efectos
		   INNER JOIN emp_fusion_efectos_l ON emp_efectos.empresa = emp_fusion_efectos_l.empresa and emp_efectos.numero=emp_fusion_efectos_l.numero_efecto
		   WHERE emp_fusion_efectos_l.empresa=@Empresa AND emp_fusion_efectos_l.numero=@numero_fusion
			
		INSERT INTO emp_efectos (empresa,empresa_origen,tipo,numero,numero_factura,situacion,subcuenta,codigo_cliente,numero_vto,fecha_vto,fecha_libramiento,importe,importe_pendiente,codigo_tipo_efecto) 
			values (@empresa,@empresa_matriz,'V',@numero_fusion,'VARIAS','CA',@subcuenta_cliente,@codigo_cliente,1,@fecha_vto,@fecha,@importe_fusion,@importe_fusion,@codigo_tipo_efecto)
			
		EXEC vs_traspasar_asiento 'FE',@psys_oid_fusion
		COMMIT 

END TRY
/****CONTROL DE ERRORES *****/
BEGIN CATCH
	set @pError = 'ERROR AL CONTABILIZAR la fusion de efectos (' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + ERROR_MESSAGE()
	ROLLBACK
	RAISERROR(@pError,16,1)
END CATCH

END
