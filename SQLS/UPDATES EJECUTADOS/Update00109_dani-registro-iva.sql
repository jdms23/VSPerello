USE [vsolution]
GO
/****** Object:  StoredProcedure [dbo].[vs_generar_asiento_compra]    Script Date: 03/06/2012 13:16:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[vs_generar_asiento_compra]
	@pempresa dm_empresas,
	@pejercicio dm_ejercicios,
	@pcodigo_tipo_documento dm_codigos_c ,
	@pserie dm_codigos_c ,
	@pnumero dm_numero_doc ,
	@psys_oid dm_oid
	
 
AS
BEGIN 

	/*Este procedimiento hará como mínimo 3 inserts en la tabla tmp_apuntes_traspaso:
	uno con la cuenta del cliente y el total de la factura.
	otro u otros por cada uno de los registros de la tabla eje_venta_i para la factura
	pasada por parametro
	otro y otros por cada uno de los registros de la vista vf_desglose_subcuenta_ventas
	para la factura pasada por parametro. */

	declare @subcuenta_proveedor dm_subcuenta
	declare @subcuenta_compras dm_subcuenta
	declare @subcuenta_compras_defecto dm_subcuenta
	declare @subcuenta_iva dm_subcuenta
	declare @subcuenta_re dm_subcuenta
	declare @subcuenta_cargo_financiero dm_subcuenta
	declare @subcuenta_dto_comercial dm_subcuenta
	declare @subcuenta_dto_financiero dm_subcuenta
	declare @subcuenta_portes dm_subcuenta
	declare @iva dm_porcentajes
	declare @re dm_porcentajes
	declare @cuota_iva dm_importes
	declare @cuota_re dm_importes
	declare @base_imponible dm_importes
	declare @apunte dm_entero_corto = 1
	declare @cuota_cargo_financiero dm_importes
	declare @cuota_dto_financiero dm_importes
	declare @cuota_dto_comercial dm_importes
	declare @total dm_importes
	declare @fecha dm_fechas_hora
	declare @codigo_tipo_apunte dm_codigos_c
	declare @codigo_concepto dm_codigos_c
	declare @patron dm_char_largo
	declare @sesion dm_entero
	declare @sys_timestamp dm_fechas_hora
	declare @nif_proveedor dm_nif
	declare @nombre_proveedor dm_nombres
	declare @razon_social_proveedor dm_nombres
	declare @numero_factura dm_numero_doc
	declare @codigo_proveedor dm_codigos_n
	declare @serie dm_codigos_c
	declare @su_factura dm_char_corto
	declare @su_fecha_factura dm_fechas_hora
	DECLARE @empresa_destino dm_empresas
	declare @importe_portes dm_importes
	declare @aplicar_en_totales dm_logico
	declare @numero_documento_iva dm_char_corto
	
	set @Sesion = @@SPID
	set @sys_timestamp = getdate()
	
	set @empresa_destino=(select isnull(empresa_contabilizar,@pempresa) from emp_series where empresa=@pempresa and codigo=@pserie and ejercicio=@pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento)	
	DELETE tmp_apuntes_traspaso where sys_oid_origen = @psys_oid and codigo_tipo_documento_origen = @pcodigo_tipo_documento
	select @total=total,@cuota_cargo_financiero=cuota_cargo_financiero,@cuota_dto_financiero=cuota_dto_financiero,@cuota_dto_comercial=cuota_dto_comercial from eje_compra_t where empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero
--	set @fecha = (select fecha from eje_compra_c where empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero)
	select @serie=serie,@fecha=fecha,@nombre_proveedor=nombre_proveedor,@razon_social_proveedor=razon_social_proveedor,@nif_proveedor=nif_proveedor,@numero_factura=numero
			,@codigo_proveedor=codigo_proveedor,@su_factura=su_factura,@su_fecha_factura=su_fecha_factura,@importe_portes=importe_portes,@aplicar_en_totales=aplicar_en_totales_portes
			from vv_compra_c_factura
			where empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero
	set @subcuenta_proveedor = (select subcuenta from vf_subcuenta_proveedor_factura where sys_oid=@psys_oid)

	set @numero_documento_iva = LEFT(@su_factura, 50)
	
	declare cursor_patron CURSOR FOR 
		select codigo_tipo_apunte,codigo_concepto,patron from emp_apuntes_patron as ap left join emp_asientos_patron as asto 
		ON ap.empresa = asto.empresa and ap.codigo=asto.codigo where ap.empresa=@pempresa and codigo_tipo_documento='FC' 
	OPEN cursor_patron
	FETCH NEXT FROM cursor_patron into @codigo_tipo_apunte,@codigo_concepto,@patron	
	WHILE @@FETCH_STATUS = 0
		BEGIN
		
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',RTRIM(@nombre_proveedor))
		SET @patron = REPLACE(@patron,'[razon_social_proveedor]',RTRIM(@razon_social_proveedor) )
		SET @patron = REPLACE(@patron,'[serie]',RTRIM(@serie))			
		SET @patron = REPLACE(@patron,'[numero_factura]',RTRIM(@numero_factura))
		SET @patron = REPLACE(@patron,'[numero_factura_compra]',RTRIM(@numero_factura))
		SET @patron = REPLACE(@patron,'[fecha]',RTRIM(@fecha))
		SET @patron = REPLACE(@patron,'[codigo_proveedor]',RTRIM(@codigo_proveedor))
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',RTRIM(@nombre_proveedor))	
		SET @patron = REPLACE(@patron,'[su_factura]',RTRIM(@su_factura))	
		SET @patron = REPLACE(@patron,'[su_fecha_factura]',RTRIM(@su_fecha_factura))	
			
			IF @codigo_tipo_apunte = 'FC_PROVEED' 			
					BEGIN
					insert into tmp_apuntes_traspaso
					(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
					values
					(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
					@subcuenta_proveedor,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,0,@total)

					SET @apunte = @apunte + 1				
					END
				ELSE
					IF @codigo_tipo_apunte = 'FC_IVA' 
					BEGIN
						declare cursor_desglose_iva CURSOR FOR
						SELECT base_imponible,iva,re,cuota_iva,cuota_re,cuenta_iva,cuenta_re 
							FROM vf_desglose_compra_subcuenta_iva
							where sys_oid=@psys_oid 
						
						OPEN cursor_desglose_iva
							FETCH NEXT FROM cursor_desglose_iva into @base_imponible,@iva,@re,@cuota_iva,@cuota_re,@subcuenta_iva,@subcuenta_re
							WHILE @@FETCH_STATUS = 0
							BEGIN
								insert into tmp_apuntes_traspaso
								(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber,modelo_iva,modelo_347,base_imponible,iva,re,contrapartida,nif,razon_social)
								values
								(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
								@subcuenta_iva,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,@cuota_iva+@cuota_re,0,1,1,@base_imponible,@iva,@re,@subcuenta_proveedor,@nif_proveedor,@razon_social_proveedor)
							FETCH NEXT FROM cursor_desglose_iva into
								@base_imponible,@iva,@re,@cuota_iva,@cuota_re,@subcuenta_iva,@subcuenta_re
								SET @apunte = @apunte + 1
							END
						CLOSE cursor_desglose_iva
						DEALLOCATE cursor_desglose_iva
						if @cuota_cargo_financiero<>0
						BEGIN								
							insert into tmp_apuntes_traspaso
							(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber,modelo_iva,modelo_347,base_imponible,iva,re,contrapartida,nif,razon_social)
							values
							(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
							@subcuenta_iva,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,0,0,1,1,@cuota_cargo_financiero,0,0,@subcuenta_proveedor,@nif_proveedor,@razon_social_proveedor)
							SET @apunte = @apunte + 1														
						END						
						
					END
					ELSE
						IF @codigo_tipo_apunte = 'FC_COMPRAS'	
						BEGIN
							select @subcuenta_compras_defecto=subcuenta_compras,
								@subcuenta_cargo_financiero=subcuenta_cargo_finan_compras,
								@subcuenta_dto_financiero=subcuenta_dto_finan_compras,
								@subcuenta_dto_comercial=subcuenta_dto_comer_compras,
								@subcuenta_portes=subcuenta_portes_compras
								from emp_ejercicios 
								where empresa=@empresa_destino and ejercicio=@pejercicio
								
							if @cuota_cargo_financiero<>0
								BEGIN									
									insert into tmp_apuntes_traspaso
									(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
									values
									(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
									@subcuenta_cargo_financiero,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,@cuota_cargo_financiero,0)				
									SET @apunte = @apunte + 1														
								END						
							if @cuota_dto_financiero<>0
								BEGIN									
									insert into tmp_apuntes_traspaso
									(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
									values
									(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
									@subcuenta_dto_financiero,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,0,@cuota_dto_financiero)				
									SET @apunte = @apunte + 1														
								END						
							if @cuota_dto_comercial<>0
								BEGIN									
									insert into tmp_apuntes_traspaso
									(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
									values
									(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
									@subcuenta_dto_comercial,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,0,@cuota_dto_comercial)				
									SET @apunte = @apunte + 1														
								END														
							IF isnull(@importe_portes,0)<>0 AND ISNULL(@aplicar_en_totales,0) = 1 
							BEGIN
									insert into tmp_apuntes_traspaso
									(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
									values
									(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
									@subcuenta_portes,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,@importe_portes,0)
									SET @apunte = @apunte + 1																						
							END
								
							declare cursor_desglose_compra CURSOR FOR
								SELECT importe,subcuenta_compras FROM vf_desglose_subcuenta_compras WHERE sys_oid=@psys_oid
							OPEN cursor_desglose_compra
								FETCH NEXT FROM cursor_desglose_compra into @base_imponible,@subcuenta_compras
								WHILE @@FETCH_STATUS = 0
									BEGIN
									
									if @subcuenta_compras='' or ISNULL(@subcuenta_compras,'')=''
										set @subcuenta_compras = @subcuenta_compras_defecto								

									
										insert into tmp_apuntes_traspaso
										(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
										values
										(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
										@subcuenta_compras,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,@base_imponible,0)				
										SET @apunte = @apunte + 1
										FETCH NEXT FROM cursor_desglose_compra into @base_imponible,@subcuenta_compras
									END
							CLOSE cursor_desglose_compra
							DEALLOCATE cursor_desglose_compra
						END				
		FETCH NEXT FROM cursor_patron into @codigo_tipo_apunte,@codigo_concepto,@patron	
	end
	CLOSE cursor_patron
	DEALLOCATE cursor_patron
END

GO 

ALTER procedure [dbo].[vs_generar_asiento_factura_acreedor]
	@pempresa dm_empresas,
	@pejercicio dm_ejercicios,
	@pcodigo_tipo_documento dm_codigos_c ,
	@pserie dm_codigos_c ,
	@pnumero dm_numero_doc ,
	@psys_oid dm_oid
	
 
AS
BEGIN 

	/*Este procedimiento hará como mínimo 3 inserts en la tabla tmp_apuntes_traspaso:
	uno con la cuenta del cliente y el total de la factura.
	otro u otros por cada uno de los registros de la tabla eje_venta_i para la factura
	pasada por parametro
	otro y otros por cada uno de los registros de la vista vf_desglose_subcuenta_ventas
	para la factura pasada por parametro. */

	declare @subcuenta_proveedor dm_subcuenta
	declare @subcuenta_compras dm_subcuenta
	declare @subcuenta_iva dm_subcuenta
	declare @subcuenta_re dm_subcuenta
	declare @subcuenta_cargo_financiero dm_subcuenta
	declare @subcuenta_dto_comercial dm_subcuenta
	declare @subcuenta_dto_financiero dm_subcuenta
	declare @iva dm_porcentajes
	declare @re dm_porcentajes
	declare @cuota_iva dm_importes
	declare @cuota_re dm_importes
	declare @base_imponible dm_importes
	declare @apunte dm_entero_corto = 1
	declare @cuota_cargo_financiero dm_importes
	declare @cuota_dto_financiero dm_importes
	declare @cuota_dto_comercial dm_importes
	declare @total dm_importes
	declare @fecha dm_fechas_hora
	declare @codigo_tipo_apunte dm_codigos_c
	declare @codigo_concepto dm_codigos_c
	declare @codigo_concepto_compra dm_codigos_c
	declare @patron dm_char_largo
	declare @sesion dm_entero
	declare @sys_timestamp dm_fechas_hora
	declare @nif_proveedor dm_nif
	declare @nombre_proveedor dm_nombres
	declare @razon_social_proveedor dm_nombres
	declare @numero_factura dm_numero_doc
	declare @codigo_proveedor dm_codigos_n
	declare @su_factura dm_char_corto
	declare @su_fecha_factura dm_fechas_hora
	DECLARE @empresa_destino dm_empresas
	DECLARE @serie dm_codigos_c
	DECLARE @referencia dm_char_corto
	declare @numero_documento_iva dm_char_corto
	
	set @Sesion = @@SPID
	set @sys_timestamp = getdate()
	
	set @empresa_destino=(select isnull(empresa_contabilizar,@pempresa) from emp_series where empresa=@pempresa and codigo=@pserie and ejercicio=@pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento)	
	DELETE tmp_apuntes_traspaso where sys_oid_origen = @psys_oid and codigo_tipo_documento_origen = @pcodigo_tipo_documento
	select @total=total,@cuota_cargo_financiero=cuota_cargo_financiero,@cuota_dto_financiero=cuota_dto_financiero,@cuota_dto_comercial=cuota_dto_comercial from eje_compra_t where empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero
--	set @fecha = (select fecha from eje_compra_c where empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero)
	select @serie=serie,@fecha=fecha,@nombre_proveedor=nombre_proveedor,@razon_social_proveedor=razon_social_proveedor,@nif_proveedor=nif_proveedor,@numero_factura=numero
			,@codigo_proveedor=codigo_proveedor,@su_factura=su_factura,@su_fecha_factura=su_fecha_factura,@referencia=referencia
			from vv_compra_c_factura
			where empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero
	set @subcuenta_proveedor = (select subcuenta from vf_subcuenta_proveedor_factura where sys_oid=@psys_oid)

	set @numero_documento_iva = LEFT(@su_factura, 50)
	
	declare cursor_patron CURSOR FOR 
		select codigo_tipo_apunte,codigo_concepto,patron from emp_apuntes_patron as ap left join emp_asientos_patron as asto 
		ON ap.empresa = asto.empresa and ap.codigo=asto.codigo where ap.empresa=@pempresa and codigo_tipo_documento='FC' 
	OPEN cursor_patron
	FETCH NEXT FROM cursor_patron into @codigo_tipo_apunte,@codigo_concepto,@patron	
	WHILE @@FETCH_STATUS = 0
		BEGIN
		
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',RTRIM(@nombre_proveedor))
		SET @patron = REPLACE(@patron,'[razon_social_proveedor]',RTRIM(@razon_social_proveedor) )
		SET @patron = REPLACE(@patron,'[numero_factura_compra]',RTRIM(@numero_factura))
		SET @patron = REPLACE(@patron,'[fecha]',RTRIM(@fecha))
		SET @patron = REPLACE(@patron,'[codigo_proveedor]',RTRIM(@codigo_proveedor))
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',RTRIM(@nombre_proveedor))	
		SET @patron = REPLACE(@patron,'[su_factura]',RTRIM(@su_factura))	
		SET @patron = REPLACE(@patron,'[su_fecha_factura]',RTRIM(@su_fecha_factura))	
		SET @patron = REPLACE(@patron,'[serie]',RTRIM(@serie))	
		---SET @patron = REPLACE(@patron,'[referencia]',RTRIM(@referencia))	
			
			IF @codigo_tipo_apunte = 'FC_PROVEED' 			
					BEGIN
					insert into tmp_apuntes_traspaso
					(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
					values
					(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
					@subcuenta_proveedor,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,0,@total)

					SET @apunte = @apunte + 1				
					END
				ELSE
					IF @codigo_tipo_apunte = 'FC_IVA' 
					BEGIN
						declare cursor_desglose_iva CURSOR FOR
						SELECT base_imponible,iva,re,cuota_iva,cuota_re,cuenta_iva,cuenta_re 
							FROM vf_desglose_compra_subcuenta_iva
							where sys_oid=@psys_oid 
						
						OPEN cursor_desglose_iva
							FETCH NEXT FROM cursor_desglose_iva into @base_imponible,@iva,@re,@cuota_iva,@cuota_re,@subcuenta_iva,@subcuenta_re
							WHILE @@FETCH_STATUS = 0
							BEGIN
								insert into tmp_apuntes_traspaso
								(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber,modelo_iva,modelo_347,base_imponible,iva,re,contrapartida,nif,razon_social)
								values
								(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
								@subcuenta_iva,@codigo_concepto,@patron,@pserie,@pnumero,LEFT(@su_factura,50),@cuota_iva+@cuota_re,0,1,1,@base_imponible,@iva,@re,@subcuenta_proveedor,@nif_proveedor,@razon_social_proveedor)
							FETCH NEXT FROM cursor_desglose_iva into
								@base_imponible,@iva,@re,@cuota_iva,@cuota_re,@subcuenta_iva,@subcuenta_re
								SET @apunte = @apunte + 1
							END
						CLOSE cursor_desglose_iva
						DEALLOCATE cursor_desglose_iva
						if @cuota_cargo_financiero<>0
						BEGIN								
							insert into tmp_apuntes_traspaso
							(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber,modelo_iva,modelo_347,base_imponible,iva,re,contrapartida,nif,razon_social)
							values
							(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
							@subcuenta_iva,@codigo_concepto,@patron,@pserie,@pnumero,LEFT(@su_factura,50),0,0,1,1,@cuota_cargo_financiero,0,0,@subcuenta_proveedor,@nif_proveedor,@razon_social_proveedor)
							SET @apunte = @apunte + 1														
						END						
						
					END
					ELSE
						IF @codigo_tipo_apunte = 'FC_COMPRAS'	
						BEGIN
							select @subcuenta_cargo_financiero=subcuenta_cargo_finan_compras,@subcuenta_dto_financiero=subcuenta_dto_finan_compras,@subcuenta_dto_comercial=subcuenta_dto_comer_compras 
								from emp_ejercicios 
								where empresa=@empresa_destino and ejercicio=@pejercicio
							if @cuota_cargo_financiero<>0
								BEGIN									
									insert into tmp_apuntes_traspaso
									(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
									values
									(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
									@subcuenta_cargo_financiero,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,@cuota_cargo_financiero,0)				
									SET @apunte = @apunte + 1														
								END						
							if @cuota_dto_financiero<>0
								BEGIN									
									insert into tmp_apuntes_traspaso
									(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
									values
									(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
									@subcuenta_dto_financiero,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,@cuota_dto_financiero,0)				
									SET @apunte = @apunte + 1														
								END						
							if @cuota_dto_comercial<>0
								BEGIN									
									insert into tmp_apuntes_traspaso
									(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
									values
									(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
									@subcuenta_dto_comercial,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,@cuota_dto_comercial,0)				
									SET @apunte = @apunte + 1														
								END						
								
								
							declare cursor_desglose_compra CURSOR FOR
								SELECT importe,subcuenta_compras,codigo_concepto FROM vf_desglose_subcuenta_compras_facreedor WHERE sys_oid=@psys_oid
							OPEN cursor_desglose_compra
								FETCH NEXT FROM cursor_desglose_compra into @base_imponible,@subcuenta_compras,@codigo_concepto_compra
								WHILE @@FETCH_STATUS = 0
									BEGIN
										insert into tmp_apuntes_traspaso
										(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
										values
										(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
										@subcuenta_compras,@codigo_concepto_compra,@patron,@pserie,@pnumero,@numero_documento_iva,@base_imponible,0)				
										SET @apunte = @apunte + 1
										FETCH NEXT FROM cursor_desglose_compra into @base_imponible,@subcuenta_compras,@codigo_concepto_compra
									END
							CLOSE cursor_desglose_compra
							DEALLOCATE cursor_desglose_compra
						END				
		FETCH NEXT FROM cursor_patron into @codigo_tipo_apunte,@codigo_concepto,@patron	
	end
	CLOSE cursor_patron
	DEALLOCATE cursor_patron
	
	update tmp_apuntes_traspaso set importe_debe = -importe_haber,
		importe_haber = 0
	 where sys_timestamp = @sys_timestamp
	   and sesion = @sesion
	   and importe_haber < 0 
	   
	update tmp_apuntes_traspaso set importe_haber = -importe_debe,
		importe_debe = 0
	 where sys_timestamp = @sys_timestamp
	   and sesion = @sesion
	   and importe_debe < 0 
	
END

GO 

ALTER procedure [dbo].[vs_generar_asiento_venta]
	@pempresa dm_empresas,
	@pejercicio dm_ejercicios,
	@pcodigo_tipo_documento dm_codigos_c ,
	@pserie dm_codigos_c ,
	@pnumero dm_numero_doc
AS
BEGIN 

	/*Este procedimiento hará como mínimo 3 inserts en la tabla tmp_apuntes_traspaso:
	uno con la cuenta del cliente y el total de la factura.
	otro u otros por cada uno de los registros de la tabla eje_venta_i para la factura
	pasada por parametro
	otro y otros por cada uno de los registros de la vista vf_desglose_subcuenta_ventas
	para la factura pasada por parametro. */

	declare @subcuenta_cliente dm_subcuenta
	declare @subcuenta_ventas dm_subcuenta
	declare @subcuenta_ventas_defecto dm_subcuenta
	declare @subcuenta_iva dm_subcuenta
	declare @subcuenta_re dm_subcuenta
	declare @subcuenta_cargo_financiero dm_subcuenta
	declare @subcuenta_dto_financiero dm_subcuenta
	declare @subcuenta_dto_comercial dm_subcuenta
	declare @subcuenta_dif_positivas dm_subcuenta
	declare @subcuenta_dif_negativas dm_subcuenta
	declare @iva dm_porcentajes
	declare @re dm_porcentajes	
	declare @cuota_iva dm_importes
	declare @cuota_re dm_importes
	declare @cuota_cargo_financiero dm_importes
	declare @cuota_dto_financiero dm_importes
	declare @cuota_dto_comercial dm_importes
	declare @base_imponible dm_importes
	declare @apunte dm_entero_corto = 1
	declare @total dm_importes
	declare @entregas dm_importes
	declare @fecha dm_fechas_hora
	declare @codigo_tipo_apunte dm_codigos_c
	declare @codigo_concepto dm_codigos_c
	declare @patron dm_char_largo
	declare @sesion dm_entero
	declare @sys_timestamp dm_fechas_hora
	declare @nif_cliente dm_nif
	declare @nombre_cliente dm_nombres
	declare @razon_social_cliente dm_nombres
	declare @serie dm_codigos_c
	declare @numero_factura dm_numero_doc
	declare @codigo_cliente dm_codigos_n
	DECLARE @empresa_destino dm_empresas
	DECLARE @pSys_oid dm_oid	
	DECLARE @importe_portes dm_importes
	DECLARE @aplicar_en_totales_portes dm_logico
	DECLARE @subcuenta_portes_ventas dm_subcuenta
	declare @cliente_impagado dm_logico
	declare @codigo_tipo_cond_venta dm_codigos_c
	declare @importe_debe dm_importes
	declare @importe_haber dm_importes
	declare @situacion dm_char_muy_corto
	declare @codigo_concepto_impagado dm_codigos_c
	declare @identificador_dir_envio dm_entero_corto
	declare @numero_documento_iva dm_char_corto
		
	set @Sesion = @@SPID
	set @sys_timestamp = getdate()

	Select @pSys_oid=sys_oid,@situacion=situacion FROM eje_venta_c WHERE empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero
	if @situacion <> 'N' 
		RETURN 
		
	set @empresa_destino=(select isnull(empresa_contabilizar,@pempresa) from emp_series where empresa=@pempresa and ejercicio=@pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and codigo=@pserie)
	
	DELETE tmp_apuntes_traspaso where sys_oid_origen = @psys_oid and codigo_tipo_documento_origen = @pcodigo_tipo_documento
	
	--set @total = (select total from eje_venta_t where empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero)
	select @total=isnull(total,0),@cuota_cargo_financiero=cuota_cargo_financiero,@cuota_dto_financiero=cuota_dto_financiero,
		@cuota_dto_comercial=cuota_dto_comercial,@entregas=isnull(entrega_a_cuenta,0) 
	  from eje_venta_t where empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero
	
	
	select @codigo_tipo_cond_venta=codigo_tipo_cond_venta,@fecha=fecha,@nombre_cliente=nombre_cliente,@razon_social_cliente=razon_social_cliente,@nif_cliente=nif_cliente,@serie=serie,@numero_factura=numero
			,@codigo_cliente=codigo_cliente,@identificador_dir_envio=identificador_dir_envio,@importe_portes=importe_portes,@aplicar_en_totales_portes = aplicar_en_totales_portes
	  FROM eje_venta_c 
	 where empresa=@pempresa 
	   and ejercicio = @pejercicio 
	   and codigo_tipo_documento=@pcodigo_tipo_documento 
	   and serie=@pserie 
	   and numero=@pnumero
	   
--	set @fecha = (select fecha from eje_venta_c where empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero)
	select @cliente_impagado = cliente_impagado, @codigo_concepto_impagado = codigo_concepto_impagado
	  from eje_factura_c 
	 where empresa=@pempresa 
	   and ejercicio = @pejercicio 
	   and codigo_tipo_documento=@pcodigo_tipo_documento 
	   and serie=@pserie 
	   and numero=@pnumero
	   
	if @cliente_impagado = 1
		set @subcuenta_cliente = (select subcuenta_impagados  from eje_clientes_cond_venta_cuentas where empresa=@pempresa and ejercicio=@pejercicio and codigo_tipo_cond_venta=@codigo_tipo_cond_venta and codigo_cliente=@codigo_cliente)
	else
		set @subcuenta_cliente = (select subcuenta from vf_subcuenta_cliente_factura where sys_oid=@psys_oid)
	if @total=0 or @total is null 
		return
	
	set @numero_documento_iva = LEFT(LTRIM(@pserie) + ' ' + LTRIM(@pNumero),50)
	
	declare cursor_patron CURSOR FOR 
		select codigo_tipo_apunte,codigo_concepto,patron from emp_apuntes_patron as ap left join emp_asientos_patron as asto 
		ON ap.empresa = asto.empresa and ap.codigo=asto.codigo where ap.empresa=@pempresa and codigo_tipo_documento=@pcodigo_tipo_documento
	OPEN cursor_patron
	FETCH NEXT FROM cursor_patron into @codigo_tipo_apunte,@codigo_concepto,@patron	
	WHILE @@FETCH_STATUS = 0
		BEGIN

		SET @patron = REPLACE(@patron,'[serie]',RTRIM(@serie))
		SET @patron = REPLACE(@patron,'[nombre_cliente]',RTRIM(@nombre_cliente))
		SET @patron = REPLACE(@patron,'[razon_social_cliente]',RTRIM(@razon_social_cliente))
		SET @patron = REPLACE(@patron,'[numero_factura]',RTRIM(@numero_factura))
		SET @patron = REPLACE(@patron,'[fecha]',RTRIM(@fecha))
		SET @patron = REPLACE(@patron,'[codigo_cliente]',RTRIM(@codigo_cliente))
		SET @patron = REPLACE(@patron,'[nombre_cliente]',RTRIM(@nombre_cliente))
		SET @patron = REPLACE(@patron,'[numero_ticket]',RTRIM(@numero_factura))
		
			IF @codigo_tipo_apunte = 'FV_CLIENTE' OR @codigo_tipo_apunte = 'TV_CLIENTE'
			BEGIN
					IF @cliente_impagado = 1 
						SET @codigo_concepto = '1000005'
						
					if @codigo_cliente=2
						set @patron=dbo.trim(@patron) + ' Ficha: ' + dbo.trim(@identificador_dir_envio) + ' ' + dbo.trim(@nombre_cliente)
					insert into tmp_apuntes_traspaso
					(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
					values
					(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
					@subcuenta_cliente,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,@total,0)

					SET @apunte = @apunte + 1				
			END
			ELSE
				IF @codigo_tipo_apunte = 'FV_IVA' OR @codigo_tipo_apunte = 'TV_IVA'
				BEGIN
						IF @cliente_impagado = 1 
							SET @codigo_concepto = '1000005'
							
						declare cursor_desglose_iva CURSOR FOR
						SELECT base_imponible,iva,re,cuota_iva,cuota_re,cuenta_iva,cuenta_re 
							FROM vf_desglose_venta_subcuenta_iva
							where sys_oid=@psys_oid 
						
						OPEN cursor_desglose_iva
							FETCH NEXT FROM cursor_desglose_iva into @base_imponible,@iva,@re,@cuota_iva,@cuota_re,@subcuenta_iva,@subcuenta_re
							WHILE @@FETCH_STATUS = 0
							BEGIN
								set @importe_haber = @cuota_iva+@cuota_re
								set @importe_debe = 0

								insert into tmp_apuntes_traspaso
								(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber,modelo_iva,modelo_347,base_imponible,iva,re,contrapartida,nif,razon_social)
								values
								(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
								@subcuenta_iva,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,@importe_debe,@importe_haber,1,1,@base_imponible,@iva,@re,@subcuenta_cliente,@nif_cliente,@razon_social_cliente)
							FETCH NEXT FROM cursor_desglose_iva into
								@base_imponible,@iva,@re,@cuota_iva,@cuota_re,@subcuenta_iva,@subcuenta_re
								SET @apunte = @apunte + 1
							END
						CLOSE cursor_desglose_iva
						DEALLOCATE cursor_desglose_iva						
						if @cuota_cargo_financiero<>0
						BEGIN								
							insert into tmp_apuntes_traspaso
							(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber,modelo_iva,modelo_347,base_imponible,iva,re,contrapartida,nif,razon_social)
							values
							(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
							@subcuenta_iva,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,0,0,1,1,@cuota_cargo_financiero,0,0,@subcuenta_cliente,@nif_cliente,@razon_social_cliente)
							SET @apunte = @apunte + 1														
						END						
						
				END
				ELSE
					IF @codigo_tipo_apunte = 'FV_VENTA'	OR @codigo_tipo_apunte = 'TV_VENTA'	
					BEGIN
							IF @cliente_impagado = 1 
								SET @codigo_concepto = @codigo_concepto_impagado
						
							select @subcuenta_ventas_defecto=subcuenta_ventas,@subcuenta_cargo_financiero=subcuenta_cargo_financiero,@subcuenta_dto_comercial=subcuenta_dto_comercial,
								@subcuenta_dto_financiero=subcuenta_dto_financiero,@subcuenta_dif_positivas=subcuenta_diferencias_positivas,
								@subcuenta_dif_negativas=subcuenta_diferencias_negativas,@subcuenta_portes_ventas=subcuenta_portes_ventas 
							from emp_ejercicios 
							where empresa=@empresa_destino and ejercicio=@pejercicio							
							if @cuota_cargo_financiero<>0
							BEGIN								
								insert into tmp_apuntes_traspaso
								(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
								values
								(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
								@subcuenta_cargo_financiero,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,0,@cuota_cargo_financiero)				
								SET @apunte = @apunte + 1														
							END						
							if @cuota_dto_financiero<>0
							BEGIN								
								insert into tmp_apuntes_traspaso
								(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
								values
								(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
								@subcuenta_dto_financiero,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,@cuota_dto_financiero,0)				
								SET @apunte = @apunte + 1														
							END						
							if @cuota_dto_comercial<>0
							BEGIN								
								insert into tmp_apuntes_traspaso
								(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
								values
								(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
								@subcuenta_dto_comercial,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,@cuota_dto_comercial,0)				
								SET @apunte = @apunte + 1														
							END	
							IF isnull(@importe_portes,0)<>0 AND ISNULL(@aplicar_en_totales_portes,0) = 1 
							BEGIN
								insert into tmp_apuntes_traspaso
								(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
								values
								(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
								@subcuenta_portes_ventas,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,0,@importe_portes)
								SET @apunte = @apunte + 1																						
							END
														
							declare cursor_desglose_venta CURSOR FOR
								SELECT importe,subcuenta_ventas 
								  FROM vf_desglose_subcuenta_ventas 
								 WHERE sys_oid=@psys_oid 
								   and importe<>0 
								   AND not importe is null
								
							OPEN cursor_desglose_venta
							FETCH NEXT FROM cursor_desglose_venta into @base_imponible,@subcuenta_ventas
							WHILE @@FETCH_STATUS = 0
							BEGIN
								if @subcuenta_ventas='' or ISNULL(@subcuenta_ventas,'')=''
									set @subcuenta_ventas = @subcuenta_ventas_defecto								
								
								set @importe_haber = @base_imponible 
								set @importe_debe = 0
								insert into tmp_apuntes_traspaso
								(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
								values
								(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
								@subcuenta_ventas,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,@importe_debe,@importe_haber)				
								SET @apunte = @apunte + 1
								FETCH NEXT FROM cursor_desglose_venta into @base_imponible,@subcuenta_ventas
							END
							
							CLOSE cursor_desglose_venta
							DEALLOCATE cursor_desglose_venta
							
							if @total - @entregas = -0.01
								begin
									insert into tmp_apuntes_traspaso
										(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
									values
										(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
											@subcuenta_cliente,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,0.01,0)

									SET @apunte = @apunte + 1
									insert into tmp_apuntes_traspaso
										(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
									values
										(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
										@subcuenta_dif_positivas,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,0,0.01)				
									SET @apunte = @apunte + 1
								end
							if @total - @entregas = 0.01
								begin
									insert into tmp_apuntes_traspaso
										(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
									values
										(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
											@subcuenta_cliente,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,0,0.01)

									SET @apunte = @apunte + 1
									insert into tmp_apuntes_traspaso
										(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,numero_documento_iva,importe_debe,importe_haber)
									values
										(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
										@subcuenta_dif_negativas,@codigo_concepto,@patron,@pserie,@pnumero,@numero_documento_iva,0.01,0)				
									SET @apunte = @apunte + 1
								end

					END				
		FETCH NEXT FROM cursor_patron into @codigo_tipo_apunte,@codigo_concepto,@patron	
	end
	CLOSE cursor_patron
	DEALLOCATE cursor_patron

END

GO 

ALTER PROCEDURE [dbo].[vs_traspasar_asiento]
 @pcodigo_tipo_documento dm_codigos_c,
 @psys_oid dm_entero
AS
BEGIN
	 DECLARE @pAsiento dm_asiento=0
	 DECLARE @pEmpresa dm_empresas
	 DECLARE @pEjercicio dm_ejercicios
	 DECLARE @pDebe dm_importes
	 DECLARE @phaber dm_importes
	 DECLARE @pSys_oid_destino dm_oid
	 DECLARE @pFecha dm_fechas_hora
	 DECLARE @pFecha_creacion dm_fechas_hora
	 DECLARE @pUsuario VARCHAR(100)	 
	 DECLARE @NumAsiento dm_asiento 

	declare cursor_desglose_empresa CURSOR FOR 
		select distinct empresa,ejercicio,asiento 
		  from tmp_apuntes_traspaso 
		 WHERE codigo_tipo_documento_origen=@pcodigo_tipo_documento and sys_oid_origen=@psys_oid AND traspasado=0
	
	open cursor_desglose_empresa
	FETCH NEXT FROM cursor_desglose_empresa INTO @pempresa,@pejercicio,@NumAsiento
	WHILE @@FETCH_STATUS = 0
	BEGIN
		/*
		 SELECT @pDebe=SUM(isnull(importe_debe,0)),@phaber=SUM(isnull(importe_haber,0)) 
		   FROM tmp_apuntes_traspaso
		  WHERE codigo_tipo_documento_origen=@pcodigo_tipo_documento 
		    and sys_oid_origen=@psys_oid 
		    AND traspasado=0 
		    and empresa=@pempresa
		    ANd ejercicio=@pEjercicio
		    AND asiento=@NumAsiento
		*/
		 EXEC vs_proximo_numero_serie @pempresa,@pEjercicio, 'ASTO', 'ASIENTOS',NULL, 1, @pAsiento OUTPUT

		 INSERT INTO eje_asientos (empresa,ejercicio,asiento,fecha,tipo_asiento,diario,traspasado_de_gestion)
		 SELECT TOP(1) empresa,ejercicio,@pAsiento,fecha,'N',1,1
		 FROM tmp_apuntes_traspaso 
		 WHERE codigo_tipo_documento_origen=@pcodigo_tipo_documento 
		   and sys_oid_origen=@psys_oid 
		   AND traspasado=0 
		   and empresa=@pempresa
		   AND ejercicio=@pEjercicio
		   AND asiento=@NumAsiento
		 
		 SET @pSys_oid_destino=(select sys_oid from eje_asientos where empresa=@pEmpresa and ejercicio=@pEjercicio and asiento=@pAsiento and diario=1)
		 
		 INSERT INTO eje_apuntes (empresa,ejercicio,asiento,diario,fecha,tipo_asiento,apunte,subcuenta,importe_debe,importe_haber
						 ,descripcion,serie_documento,numero_documento,numero_documento_iva,codigo_concepto,modelo_iva,modelo_347,base_imponible,iva,re,importe_metalico,contrapartida,traspasado_de_gestion,nif,razon_social)
		 SELECT empresa,ejercicio,@pAsiento,1,fecha,'N',apunte,subcuenta,importe_debe,importe_haber,descripcion,serie_documento
					,numero_documento,numero_documento_iva,codigo_concepto,modelo_iva,modelo_347,base_imponible,iva,re,importe_metalico,contrapartida,1,NIF,razon_social
		 FROM tmp_apuntes_traspaso 
		 WHERE codigo_tipo_documento_origen=@pcodigo_tipo_documento 
		   and sys_oid_origen=@psys_oid 
		   AND traspasado=0 
		   and empresa=@pempresa
		   AND ejercicio=@pEjercicio
		   AND asiento=@NumAsiento

		 SELECT @pFecha_creacion = sys_timestamp,@pFecha=fecha FROM eje_asientos WHERE sys_oid= @pSys_oid_destino
		 
		 SELECT TOP 1 @pUsuario=usuario 
		   FROM sys_logins AS L
		  WHERE spid=@@SPID
		  AND activa=1	
		  ORDER BY sys_oid DESC	  
		  
		 UPDATE tmp_apuntes_traspaso SET traspasado=1,codigo_tipo_documento_destino='ASTO',sys_oid_destino=@pSys_oid_destino
		 WHERE codigo_tipo_documento_origen=@pcodigo_tipo_documento 
		   and sys_oid_origen=@psys_oid 
		   AND traspasado=0 
		   and empresa=@pempresa
		   AND ejercicio=@pEjercicio
		   AND asiento=@NumAsiento

		 INSERT INTO gen_nav_documentos (tipo_documento_origen,oid_documento_origen,numero_documento_origen,fecha_documento_origen
						 ,tipo_documento_destino,numero_documento_destino,oid_documento_destino,fecha_documento_destino,usuario_creacion
						 ,fecha_creacion)
		SELECT TOP 1 codigo_tipo_documento_origen,sys_oid_origen,numero_documento,fecha,'ASTO',@pAsiento,@pSys_oid_destino
	 			 ,@pFecha,@pUsuario,@pFecha_creacion
				FROM tmp_apuntes_traspaso 
				WHERE codigo_tipo_documento_origen=@pcodigo_tipo_documento and sys_oid_origen=@psys_oid
				 AND sys_oid_destino=@pSys_oid_destino 
				
		FETCH NEXT FROM cursor_desglose_empresa INTO @pempresa,@pejercicio,@NumAsiento
	END	 
END

