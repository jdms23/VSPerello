USE vs_martinez
GO
/****** Object:  StoredProcedure [dbo].[vs_generar_asiento_arqueo_caja]    Script Date: 01/18/2012 17:05:26 ******/
/*** OJO. PUEDEN HABER DE DISTINTAS EMPRESA DESTINO *****/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[vs_generar_asiento_arqueo_caja]
	@psys_oid dm_oid
AS
BEGIN 
	declare @empresa dm_empresas
	declare @empresa_destino dm_empresas
	declare @ejercicio dm_ejercicios
	declare @codigo_banco dm_codigos_c
	declare @subcuenta_banco dm_subcuenta	
	declare @saldo dm_importes
	declare @fecha_asiento dm_fechas_hora
	declare @apunte dm_entero_corto = 1	
	declare @debe dm_importes
	declare @haber dm_importes
	declare @importe dm_importes
	declare @serie dm_codigos_c
	declare @numero dm_char_corto
	declare @subcuenta dm_subcuenta
	declare @codigo_concepto dm_codigos_c
	declare @descripcion_apunte dm_char_largo
	DECLARE @perror varchar(4000)	
	
	
	declare @sesion dm_entero
	declare @sys_timestamp dm_fechas_hora
		
	set @Sesion = @@SPID
	set @sys_timestamp = getdate()
	

	begin try	

	BEGIN TRANSACTION 	
	
	DELETE tmp_apuntes_traspaso where codigo_tipo_documento_origen='ARQ' AND sys_oid_origen=@psys_oid

	select @empresa=empresa,@codigo_banco=codigo_banco,@fecha_asiento=fecha,@descripcion_apunte=descripcion from emp_arqueo_caja where sys_oid=@psys_oid
		
	declare cursor_desglose_empresa CURSOR FOR select empresa_destino,SUM(isnull(importe,0)) as saldo from eje_mov_caja where sys_oid_arqueo=@psys_oid group by empresa_destino 
	open cursor_desglose_empresa
	FETCH NEXT FROM cursor_desglose_empresa INTO @empresa_destino,@saldo
	WHILE @@FETCH_STATUS = 0
	BEGIN
		select @ejercicio=(select ejercicio from emp_ejercicios where empresa=@empresa_destino and fecha_apertura <= @fecha_asiento and fecha_cierre>=@fecha_asiento)	
		set @subcuenta_banco = (select subcuenta from eje_bancos_subcuenta where empresa=@empresa_destino and ejercicio=@ejercicio and codigo_banco=@codigo_banco)
		if @saldo >= 0
			begin
				set @debe=@saldo
				set @haber=0
			end
		else
			begin
				set @debe=0
				set @haber=@saldo
			end

		set @codigo_concepto='1000032'
		SET @numero = 'CAJA ' + CONVERT(CHAR(12),@fecha_asiento)
		insert into tmp_apuntes_traspaso
		(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,importe_debe,importe_haber,modelo_iva,modelo_347)
		values
		(@sys_timestamp,@sesion,@empresa_destino,@ejercicio,'ARQ',@psys_oid,@fecha_asiento,@apunte,
		@subcuenta_banco,@codigo_concepto,@descripcion_apunte,@serie,@numero,@debe,@haber,0,0)
		SET @apunte = @apunte + 1
		declare cursor_arqueo_caja CURSOR FOR
		SELECT isnull(importe,0),serie,numero,subcuenta,codigo_concepto,descripcion_apunte
			FROM eje_mov_caja
			where sys_oid_arqueo=@psys_oid and empresa_destino=@empresa_destino
		
		OPEN cursor_arqueo_caja
			FETCH NEXT FROM cursor_arqueo_caja into @importe,@serie,@numero,@subcuenta,@codigo_concepto,@descripcion_apunte
			WHILE @@FETCH_STATUS = 0
			BEGIN
				if @importe >= 0
					begin
						set @debe=0
						set @haber=@importe
					end
				else
					begin
						set @debe=@importe
						set @haber=0
					end

				insert into tmp_apuntes_traspaso
				(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,importe_debe,importe_haber,modelo_iva,modelo_347)
				values
				(@sys_timestamp,@sesion,@empresa_destino,@ejercicio,'ARQ',@psys_oid,@fecha_asiento,@apunte,
				@subcuenta,@codigo_concepto,@descripcion_apunte,@serie,@numero,@debe,@haber,0,0)
				FETCH NEXT FROM cursor_arqueo_caja into @importe,@serie,@numero,@subcuenta,@codigo_concepto,@descripcion_apunte
				SET @apunte = @apunte + 1
			END
		CLOSE cursor_arqueo_caja
		DEALLOCATE cursor_arqueo_caja
							
		FETCH NEXT FROM cursor_desglose_empresa INTO @empresa_destino,@saldo
	END
			
	update emp_arqueo_caja set situacion='P' WHERE sys_oid=@psys_oid
	
	COMMIT 
	END TRY
/****CONTROL DE ERRORES *****/
	BEGIN CATCH
		set @pError = 'ERROR AL GENERAR ARQUEO CAJA(' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + ERROR_MESSAGE()
		ROLLBACK
		RAISERROR(@pError,16,1)
	END CATCH	
	
END