USE vs_martinez
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vf_desglose_subcuenta_compras_facreedor]
with encryption
AS
SELECT     dbo.eje_compra_c.sys_oid, ISNULL(dbo.eje_compra_l.subcuenta_compras, '6000000000') AS subcuenta_compras, eje_factura_compra_l.codigo_concepto,SUM(dbo.eje_compra_l.total_linea) 
                      AS importe
FROM         dbo.eje_compra_c INNER JOIN
                      dbo.eje_compra_l ON dbo.eje_compra_c.empresa = dbo.eje_compra_l.empresa AND dbo.eje_compra_c.ejercicio = dbo.eje_compra_l.ejercicio AND 
                      dbo.eje_compra_c.codigo_tipo_documento = dbo.eje_compra_l.codigo_tipo_documento AND dbo.eje_compra_c.serie = dbo.eje_compra_l.serie AND 
                      dbo.eje_compra_c.numero = dbo.eje_compra_l.numero INNER JOIN
                      dbo.eje_factura_compra_l ON dbo.eje_factura_compra_l.empresa = dbo.eje_compra_l.empresa AND dbo.eje_factura_compra_l.ejercicio = dbo.eje_compra_l.ejercicio AND 
                      dbo.eje_factura_compra_l.codigo_tipo_documento = dbo.eje_compra_l.codigo_tipo_documento AND dbo.eje_factura_compra_l.serie = dbo.eje_compra_l.serie AND 
                      dbo.eje_factura_compra_l.numero = dbo.eje_compra_l.numero AND dbo.eje_factura_compra_l.linea = dbo.eje_compra_l.linea
GROUP BY dbo.eje_compra_c.sys_oid, dbo.eje_compra_l.subcuenta_compras,eje_factura_compra_l.codigo_concepto

GO




/****** Object:  StoredProcedure [dbo].[vs_generar_asiento_compra]    Script Date: 01/25/2012 13:52:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[vs_generar_asiento_factura_acreedor]
	@pempresa dm_empresas,
	@pejercicio dm_ejercicios,
	@pcodigo_tipo_documento dm_codigos_c ,
	@pserie dm_codigos_c ,
	@pnumero dm_numero_doc ,
	@psys_oid dm_oid
	
with encryption
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
	
	set @Sesion = @@SPID
	set @sys_timestamp = getdate()
	
	set @empresa_destino=(select isnull(empresa_contabilizar,@pempresa) from emp_series where empresa=@pempresa and codigo=@pserie and ejercicio=@pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento)	
	DELETE tmp_apuntes_traspaso where empresa=@pempresa and sys_oid_origen = @psys_oid and codigo_tipo_documento_origen = @pcodigo_tipo_documento
	select @total=total,@cuota_cargo_financiero=cuota_cargo_financiero,@cuota_dto_financiero=cuota_dto_financiero,@cuota_dto_comercial=cuota_dto_comercial from eje_compra_t where empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero
--	set @fecha = (select fecha from eje_compra_c where empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero)
	select @fecha=fecha,@nombre_proveedor=nombre_proveedor,@razon_social_proveedor=razon_social_proveedor,@nif_proveedor=nif_proveedor,@numero_factura=numero
			,@codigo_proveedor=codigo_proveedor,@su_factura=su_factura,@su_fecha_factura=su_fecha_factura
			from vv_compra_c_factura
			where empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero
	set @subcuenta_proveedor = (select subcuenta from vf_subcuenta_proveedor_factura where sys_oid=@psys_oid)


	declare cursor_patron CURSOR FOR 
		select codigo_tipo_apunte,codigo_concepto,patron from emp_apuntes_patron as ap left join emp_asientos_patron as asto 
		ON ap.empresa = asto.empresa and ap.codigo=asto.codigo where ap.empresa=@pempresa and codigo_tipo_documento='FC' 
	OPEN cursor_patron
	FETCH NEXT FROM cursor_patron into @codigo_tipo_apunte,@codigo_concepto,@patron	
	WHILE @@FETCH_STATUS = 0
		BEGIN
		
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',RTRIM(@nombre_proveedor))
		SET @patron = REPLACE(@patron,'[razon_social_proveedor]',RTRIM(@razon_social_proveedor) )
		SET @patron = REPLACE(@patron,'[numero_factura]',RTRIM(@numero_factura))
		SET @patron = REPLACE(@patron,'[fecha]',RTRIM(@fecha))
		SET @patron = REPLACE(@patron,'[codigo_proveedor]',RTRIM(@codigo_proveedor))
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',RTRIM(@nombre_proveedor))	
		SET @patron = REPLACE(@patron,'[su_factura]',RTRIM(@su_factura))	
		SET @patron = REPLACE(@patron,'[su_fecha_factura]',RTRIM(@su_fecha_factura))	
			
			IF @codigo_tipo_apunte = 'FC_PROVEED' 			
					BEGIN
					insert into tmp_apuntes_traspaso
					(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,importe_debe,importe_haber)
					values
					(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
					@subcuenta_proveedor,@codigo_concepto,@patron,@pserie,@pnumero,0,@total)

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
								(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,importe_debe,importe_haber,modelo_iva,modelo_347,base_imponible,iva,re,contrapartida,nif,razon_social)
								values
								(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
								@subcuenta_iva,@codigo_concepto,@patron,@pserie,@pnumero,@cuota_iva+@cuota_re,0,1,1,@base_imponible,@iva,@re,@subcuenta_proveedor,@nif_proveedor,@razon_social_proveedor)
							FETCH NEXT FROM cursor_desglose_iva into
								@base_imponible,@iva,@re,@cuota_iva,@cuota_re,@subcuenta_iva,@subcuenta_re
								SET @apunte = @apunte + 1
							END
						CLOSE cursor_desglose_iva
						DEALLOCATE cursor_desglose_iva
						if @cuota_cargo_financiero<>0
						BEGIN								
							insert into tmp_apuntes_traspaso
							(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,importe_debe,importe_haber,modelo_iva,modelo_347,base_imponible,iva,re,contrapartida,nif,razon_social)
							values
							(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
							@subcuenta_iva,@codigo_concepto,@patron,@pserie,@pnumero,0,0,1,1,@cuota_cargo_financiero,0,0,@subcuenta_proveedor,@nif_proveedor,@razon_social_proveedor)
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
									(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,importe_debe,importe_haber)
									values
									(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
									@subcuenta_cargo_financiero,@codigo_concepto,@patron,@pserie,@pnumero,@cuota_cargo_financiero,0)				
									SET @apunte = @apunte + 1														
								END						
							if @cuota_dto_financiero<>0
								BEGIN									
									insert into tmp_apuntes_traspaso
									(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,importe_debe,importe_haber)
									values
									(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
									@subcuenta_dto_financiero,@codigo_concepto,@patron,@pserie,@pnumero,@cuota_dto_financiero,0)				
									SET @apunte = @apunte + 1														
								END						
							if @cuota_dto_comercial<>0
								BEGIN									
									insert into tmp_apuntes_traspaso
									(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,importe_debe,importe_haber)
									values
									(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
									@subcuenta_dto_comercial,@codigo_concepto,@patron,@pserie,@pnumero,@cuota_dto_comercial,0)				
									SET @apunte = @apunte + 1														
								END						
								
								
							declare cursor_desglose_compra CURSOR FOR
								SELECT importe,subcuenta_compras,codigo_concepto FROM vf_desglose_subcuenta_compras_facreedor WHERE sys_oid=@psys_oid
							OPEN cursor_desglose_compra
								FETCH NEXT FROM cursor_desglose_compra into @base_imponible,@subcuenta_compras,@codigo_concepto_compra
								WHILE @@FETCH_STATUS = 0
									BEGIN
										insert into tmp_apuntes_traspaso
										(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,importe_debe,importe_haber)
										values
										(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
										@subcuenta_compras,@codigo_concepto_compra,@patron,@pserie,@pnumero,@base_imponible,0)				
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
END