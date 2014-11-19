USE vsolution
GO 
/*
ALTER TABLE EMP_EJERCICIOS ADD subcuenta_portes_ventas dm_subcuenta
ALTER TABLE EMP_EJERCICIOS ADD subcuenta_portes_compras dm_subcuenta
GO

ALTER procedure [dbo].[vs_generar_asiento_venta]
	@pempresa dm_empresas,
	@pejercicio dm_ejercicios,
	@pcodigo_tipo_documento dm_codigos_c ,
	@pserie dm_codigos_c ,
	@pnumero dm_numero_doc
WITH ENCRYPTION AS
BEGIN 

	/*Este procedimiento hará como mínimo 3 inserts en la tabla tmp_apuntes_traspaso:
	uno con la cuenta del cliente y el total de la factura.
	otro u otros por cada uno de los registros de la tabla eje_venta_i para la factura
	pasada por parametro
	otro y otros por cada uno de los registros de la vista vf_desglose_subcuenta_ventas
	para la factura pasada por parametro. */

	declare @subcuenta_cliente dm_subcuenta
	declare @subcuenta_ventas dm_subcuenta
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
		
	set @Sesion = @@SPID
	set @sys_timestamp = getdate()

	set @pSys_oid = (Select sys_oid FROM eje_venta_c WHERE empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero)
	
	set @empresa_destino=(select isnull(empresa_contabilizar,@pempresa) from emp_series where empresa=@pempresa and ejercicio=@pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and codigo=@pserie)
	
	DELETE tmp_apuntes_traspaso where sys_oid_origen = @psys_oid and codigo_tipo_documento_origen = @pcodigo_tipo_documento
	
	--set @total = (select total from eje_venta_t where empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero)
	select @total=isnull(total,0),@cuota_cargo_financiero=cuota_cargo_financiero,@cuota_dto_financiero=cuota_dto_financiero,
		@cuota_dto_comercial=cuota_dto_comercial,@entregas=isnull(entrega_a_cuenta,0) 
	  from eje_venta_t where empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero
	  
	select @fecha=fecha,@nombre_cliente=nombre_cliente,@razon_social_cliente=razon_social_cliente,@nif_cliente=nif_cliente,@serie=serie,@numero_factura=numero
			,@codigo_cliente=codigo_cliente,@importe_portes=importe_portes,@aplicar_en_totales_portes = aplicar_en_totales_portes
	  FROM eje_venta_c 
	 where empresa=@pempresa 
	   and ejercicio = @pejercicio 
	   and codigo_tipo_documento=@pcodigo_tipo_documento 
	   and serie=@pserie 
	   and numero=@pnumero
	   
--	set @fecha = (select fecha from eje_venta_c where empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero)
	set @subcuenta_cliente = (select subcuenta from vf_subcuenta_cliente_factura where sys_oid=@psys_oid)
	if @total=0 or @total is null 
		return
		
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
					insert into tmp_apuntes_traspaso
					(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,importe_debe,importe_haber)
					values
					(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
					@subcuenta_cliente,@codigo_concepto,@patron,@pserie,@pnumero,@total,0)

					SET @apunte = @apunte + 1				
					END
				ELSE
					IF @codigo_tipo_apunte = 'FV_IVA' OR @codigo_tipo_apunte = 'TV_IVA'
					BEGIN
						declare cursor_desglose_iva CURSOR FOR
						SELECT base_imponible,iva,re,cuota_iva,cuota_re,cuenta_iva,cuenta_re 
							FROM vf_desglose_venta_subcuenta_iva
							where sys_oid=@psys_oid 
						
						OPEN cursor_desglose_iva
							FETCH NEXT FROM cursor_desglose_iva into @base_imponible,@iva,@re,@cuota_iva,@cuota_re,@subcuenta_iva,@subcuenta_re
							WHILE @@FETCH_STATUS = 0
							BEGIN
								insert into tmp_apuntes_traspaso
								(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,importe_debe,importe_haber,modelo_iva,modelo_347,base_imponible,iva,re,contrapartida,nif,razon_social)
								values
								(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
								@subcuenta_iva,@codigo_concepto,@patron,@pserie,@pnumero,0,@cuota_iva+@cuota_re,1,1,@base_imponible,@iva,@re,@subcuenta_cliente,@nif_cliente,@razon_social_cliente)
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
							@subcuenta_iva,@codigo_concepto,@patron,@pserie,@pnumero,0,0,1,1,@cuota_cargo_financiero,0,0,@subcuenta_cliente,@nif_cliente,@razon_social_cliente)
							SET @apunte = @apunte + 1														
						END						
						
					END
					ELSE
						IF @codigo_tipo_apunte = 'FV_VENTA'	OR @codigo_tipo_apunte = 'TV_VENTA'	
						BEGIN
							select @subcuenta_cargo_financiero=subcuenta_cargo_financiero,@subcuenta_dto_comercial=subcuenta_dto_comercial,
								@subcuenta_dto_financiero=subcuenta_dto_financiero,@subcuenta_dif_positivas=subcuenta_diferencias_positivas,
								@subcuenta_dif_negativas=subcuenta_diferencias_negativas,@subcuenta_portes_ventas=subcuenta_portes_ventas 
							from emp_ejercicios 
							where empresa=@empresa_destino and ejercicio=@pejercicio							
							if @cuota_cargo_financiero<>0
							BEGIN								
								insert into tmp_apuntes_traspaso
								(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,importe_debe,importe_haber)
								values
								(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
								@subcuenta_cargo_financiero,@codigo_concepto,@patron,@pserie,@pnumero,0,@cuota_cargo_financiero)				
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
							IF isnull(@importe_portes,0)<>0 AND ISNULL(@aplicar_en_totales_portes,0) = 1 
							BEGIN
								insert into tmp_apuntes_traspaso
								(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,importe_debe,importe_haber)
								values
								(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
								@subcuenta_portes_ventas,@codigo_concepto,@patron,@pserie,@pnumero,0,@importe_portes)
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
										insert into tmp_apuntes_traspaso
										(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,importe_debe,importe_haber)
										values
										(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
										@subcuenta_ventas,@codigo_concepto,@patron,@pserie,@pnumero,0,@base_imponible)				
										SET @apunte = @apunte + 1
										FETCH NEXT FROM cursor_desglose_venta into @base_imponible,@subcuenta_ventas
							END
							
							CLOSE cursor_desglose_venta
							DEALLOCATE cursor_desglose_venta
							
							if @total - @entregas = -0.01
								begin
									insert into tmp_apuntes_traspaso
										(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,importe_debe,importe_haber)
									values
										(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
											@subcuenta_cliente,@codigo_concepto,@patron,@pserie,@pnumero,0.01,0)

									SET @apunte = @apunte + 1
									insert into tmp_apuntes_traspaso
										(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,importe_debe,importe_haber)
									values
										(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
										@subcuenta_dif_positivas,@codigo_concepto,@patron,@pserie,@pnumero,0,0.01)				
									SET @apunte = @apunte + 1
								end
							if @total - @entregas = 0.01
								begin
									insert into tmp_apuntes_traspaso
										(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,importe_debe,importe_haber)
									values
										(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
											@subcuenta_cliente,@codigo_concepto,@patron,@pserie,@pnumero,0,0.01)

									SET @apunte = @apunte + 1
									insert into tmp_apuntes_traspaso
										(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,importe_debe,importe_haber)
									values
										(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
										@subcuenta_dif_negativas,@codigo_concepto,@patron,@pserie,@pnumero,0.01,0)				
									SET @apunte = @apunte + 1
								end

						END				
		FETCH NEXT FROM cursor_patron into @codigo_tipo_apunte,@codigo_concepto,@patron	
	end
	CLOSE cursor_patron
	DEALLOCATE cursor_patron

END

GO 

ALTER PROCEDURE [dbo].[vs_calcular_total_venta]
	@pempresa dm_empresas,
	@pejercicio dm_ejercicios,
	@pcodigo_tipo_documento dm_codigos_c,
	@pserie dm_codigos_c,
	@pnumero dm_numero_doc
WITH ENCRYPTION AS
BEGIN
	SET NOCOUNT ON
	DECLARE @codigo_tipo_iva dm_char_corto
	DECLARE @dto_comercial dm_porcentajes
	DECLARE @dto_financiero dm_porcentajes
	DECLARE @cuota_dto_comercial dm_importes
	DECLARE @cuota_dto_financiero dm_importes
	DECLARE @base_imponible dm_importes
	DECLARE @iva dm_porcentajes
	DECLARE @re dm_porcentajes
	DECLARE @cuota_iva dm_importes
	DECLARE @cuota_re dm_importes
	DECLARE @total_linea dm_importes
	DECLARE @importe_portes dm_importes
	DECLARE @aplicar_en_totales_portes dm_logico
	DECLARE @codigo_tipo_iva_portes dm_char_corto
	IF EXISTS(SELECT * FROM eje_venta_i WHERE @pempresa = empresa AND @pejercicio = ejercicio AND 
			@pcodigo_tipo_documento = codigo_tipo_documento AND @pserie = serie AND @pnumero = numero )
		DELETE eje_venta_i WHERE @pempresa = empresa AND @pejercicio = ejercicio AND 
			@pcodigo_tipo_documento = codigo_tipo_documento AND @pserie = serie AND @pnumero = numero
	DECLARE calcula CURSOR FOR
			SELECT l.codigo_tipo_iva, SUM(l.total_linea * ISNULL(c.dto_comercial,0)/100) AS cuota_dto_comercial, 
					  SUM(l.total_linea*ISNULL(c.dto_financiero,0)/100) AS cuota_dto_financiero, SUM(l.total_linea*ISNULL(l.iva, 0)/100) AS cuota_iva, 
					  SUM(l.total_linea*ISNULL(l.re,0)/100) AS cuota_re,SUM(l.total_linea) AS total_linea,ISNULL(iva,0),ISNULL(re,0)
					  ,ISNULL(c.importe_portes,0) AS importe_portes,c.aplicar_en_totales_portes,c.codigo_tipo_iva_portes
			FROM eje_venta_l AS l
			 INNER JOIN
					  eje_venta_c AS c ON l.empresa = c.empresa AND l.ejercicio = c.ejercicio AND l.codigo_tipo_documento = c.codigo_tipo_documento AND 
					  l.SERIE = c.serie AND l.numero = c.numero
			WHERE @pempresa=c.empresa AND @pejercicio=c.ejercicio AND @pcodigo_tipo_documento=c.codigo_tipo_documento AND @pserie=c.serie AND @pnumero = c.numero					  
			GROUP BY  l.codigo_tipo_iva,iva,re,c.aplicar_en_totales_portes,c.codigo_tipo_iva_portes, c.importe_portes
			
	OPEN calcula
	FETCH NEXT FROM calcula INTO @codigo_tipo_iva,@cuota_dto_comercial,@cuota_dto_financiero,@cuota_iva,@cuota_re
						,@total_linea,@iva,@re,@importe_portes,@aplicar_en_totales_portes,@codigo_tipo_iva_portes
							
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		--SET @cuota_dto_comercial = @total_linea * @dto_comercial / 100
		--SET @cuota_dto_financiero = @total_linea * @dto_financiero / 100
		SET @base_imponible = @total_linea - @cuota_dto_comercial - @cuota_dto_financiero
		SET @cuota_iva = @base_imponible * @iva / 100
		SET @cuota_re = @base_imponible * @re / 100

		IF @aplicar_en_totales_portes = 1 AND @codigo_tipo_iva_portes=@codigo_tipo_iva
		BEGIN		
			SET @base_imponible = @base_imponible + @importe_portes
			SET @cuota_iva = @base_imponible * ISNULL(@iva, 0)/100
			SET @cuota_re = @base_imponible * ISNULL(@re, 0)/100			
		END
		
		INSERT INTO eje_venta_i ( empresa,ejercicio,codigo_tipo_documento,serie,numero,codigo_tipo_iva,neto_lineas,
			cuota_dto_comercial,cuota_dto_financiero,base_imponible,iva,cuota_iva,re,cuota_re,total )
			VALUES (@pempresa,@pejercicio,@pcodigo_tipo_documento,@pserie,@pnumero,@codigo_tipo_iva,@total_linea,
			@cuota_dto_comercial,@cuota_dto_financiero,@base_imponible,@iva,@cuota_iva,@re,@cuota_re,@base_imponible + @cuota_iva + @cuota_re )

			IF EXISTS(
				SELECT DISTINCT vc.codigo_tipo_iva_portes, vc.aplicar_en_totales_portes, vc.numero, vi.codigo_tipo_iva, 
				vc.ejercicio FROM dbo.eje_venta_c AS vc
				LEFT OUTER JOIN
				eje_venta_i AS vi ON vc.empresa = vi.empresa AND vc.ejercicio = vi.ejercicio AND 
				vc.codigo_tipo_documento = vi.codigo_tipo_documento AND vc.serie = vi.serie AND 
				vc.numero = vi.numero AND vc.codigo_tipo_iva_portes = vi.codigo_tipo_iva
				WHERE (vc.aplicar_en_totales_portes = 1) AND (vi.codigo_tipo_iva IS NULL) AND 
				 @pempresa=vc.empresa AND @pejercicio=vc.ejercicio AND @pcodigo_tipo_documento=vc.codigo_tipo_documento AND
				  @pserie=vc.serie AND @pnumero = vc.numero			
			)
			
		INSERT INTO eje_venta_i (empresa,ejercicio,codigo_tipo_documento,serie,numero,codigo_tipo_iva,neto_lineas,iva,re
						,cuota_iva,cuota_re,base_imponible,total)
						SELECT DISTINCT vc.empresa, vc.ejercicio, vc.codigo_tipo_documento, vc.serie, vc.numero, 
									  vc.codigo_tipo_iva_portes, vc.importe_portes,ISNULL(IP.porcentaje_iva,0),ISNULL(IP.porcentaje_re,0)
									  ,vc.importe_portes * ISNULL(ip.porcentaje_iva, 0)/100,vc.importe_portes * ISNULL(ip.porcentaje_re, 0)/100
									  ,vc.importe_portes,total=vc.importe_portes+vc.importe_portes * ISNULL(ip.porcentaje_re, 0)/100+vc.importe_portes * ISNULL(ip.porcentaje_iva, 0)/100
						FROM  eje_venta_c AS vc INNER JOIN
								eje_iva_porcentajes AS IP ON vc.codigo_tipo_iva_portes = IP.codigo_tipo AND 
								vc.codigo_tabla_iva = IP.codigo_tabla AND vc.empresa = IP.empresa AND 
								vc.ejercicio = IP.ejercicio
						WHERE (vc.aplicar_en_totales_portes = 1) AND @pempresa=vc.empresa AND @pejercicio=vc.ejercicio
							 AND @pcodigo_tipo_documento=vc.codigo_tipo_documento AND @pserie=vc.serie AND @pnumero = vc.numero
		
		FETCH NEXT FROM calcula INTO @codigo_tipo_iva,@cuota_dto_comercial,@cuota_dto_financiero,@cuota_iva,@cuota_re
						,@total_linea,@iva,@re,@importe_portes,@aplicar_en_totales_portes,@codigo_tipo_iva_portes
	END
	
	EXEC vs_eje_venta_t @pEmpresa, @pEjercicio, @pCodigo_tipo_documento, @pSerie, @pNumero	
---	EXEC vs_calcular_vencimientos @pEmpresa, @pEjercicio, @pCodigo_tipo_documento, @pSerie, @pNumero	 			
END

*/
 
