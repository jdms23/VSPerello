use vs_martinez
go
--alter table emp_ejercicios add subcuenta_diferencias_positivas dm_subcuenta null
--alter table emp_ejercicios add subcuenta_diferencias_negativas dm_subcuenta null
go
update emp_ejercicios set subcuenta_diferencias_positivas='7690000000'
update emp_ejercicios set subcuenta_diferencias_negativas='6690000000'

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[vs_calcular_vencimientos]
	   @empresa dm_empresas
      ,@ejercicio dm_ejercicios
      ,@codigo_tipo_documento dm_codigos_c
      ,@serie dm_codigos_c
      ,@numero dm_numero_doc
AS
BEGIN
	SET NOCOUNT OFF

DECLARE @efectos INT
DECLARE @resto dm_importes
DECLARE @fecha_vto dm_fechas_hora
DECLARE @importe dm_importes
DECLARE @numero_linea dm_entero_corto = 1
DECLARE @lcUpdate varchar(1000)

DECLARE @eje_facturas_vtos AS TABLE ( orden INT,
	 empresa dm_empresas,
	 ejercicio dm_ejercicios,
	 codigo_tipo_documento dm_codigos_c,
	 SERIE dm_codigos_c,
	 numero dm_numero_doc,
	 fecha  DATE,
	 vto dm_entero_corto,
	 porcentaje dm_porcentajes,
	 efecto dm_entero,
	 total dm_importes,
	 importe dm_importes,
	 dia1 dm_entero_corto,
	 dia2 dm_entero_corto,
	 dia3 dm_entero_corto,
	 fecha_vto DATE,
	 fdesde DATE,
	 fhasta DATE,
	 fdif INT )
	 
	INSERT INTO @eje_facturas_vtos (orden,empresa,ejercicio,codigo_tipo_documento,serie,numero,fecha,fecha_vto,vto,porcentaje,efecto,total,importe,dia1,dia2,dia3
				,fdesde,fhasta )
			SELECT ROW_NUMBER() OVER (ORDER BY fecha),VC.empresa, VC.ejercicio, VC.codigo_tipo_documento, VC.serie, VC.numero,fecha,DATEADD(day,convert(int,VT.vencimiento),vc.fecha),convert(int,VT.vencimiento)
					, VT.porcentaje,VT.numero AS efectos, SUM(vct.total-isnull(VCT.entrega_a_cuenta,0)-isnull(VCT.importe_compensado,0)),SUM((vct.total-isnull(VCT.entrega_a_cuenta,0)-isnull(VCT.importe_compensado,0))*vt.porcentaje/100 ),CV.dia_pago1, CV.dia_pago2, CV.dia_pago3, 
					CV.vacaciones_desde, CV.vacaciones_hasta
			FROM eje_venta_c AS VC
				INNER JOIN eje_venta_t AS VCT ON VCT.empresa = VC.empresa AND VCT.ejercicio = VC.ejercicio AND VCT.codigo_tipo_documento = VC.codigo_tipo_documento
				AND VCT.serie = VC.serie AND VCT.numero = VC.numero
				INNER JOIN emp_formas_pago AS FP ON VC.empresa = FP.empresa AND VC.codigo_forma_pago = FP.codigo
				INNER JOIN emp_formas_pago_vtos AS VT ON FP.empresa = VT.empresa AND FP.codigo = VT.codigo_forma_pago
				INNER JOIN emp_clientes_cond_venta AS CV ON VC.empresa = CV.empresa AND VC.codigo_cliente = CV.codigo_cliente  AND VC.codigo_tipo_cond_venta = CV.codigo_tipo_cond_venta
				INNER JOIN emp_clientes AS CL ON VC.empresa = CL.empresa AND VC.codigo_cliente = CL.codigo
				LEFT OUTER JOIN dbo.emp_bancos AS B ON CL.empresa = B.empresa AND CL.codigo_banco_cobro = B.codigo
				WHERE (isnull(vc.compensar_abono,0)=0 or vct.total> 0) and VC.empresa=@empresa AND VC.ejercicio=@ejercicio AND VC.codigo_tipo_documento=@codigo_tipo_documento AND VC.serie=@serie AND VC.numero=@numero
				GROUP BY VC.empresa,VC.ejercicio,VC.codigo_tipo_documento,VC.serie,VC.numero,VT.vencimiento,VT.porcentaje,VC.fecha,VT.numero,CV.dia_pago1,CV.dia_pago2
	 				,CV.dia_pago3, CV.vacaciones_desde, CV.vacaciones_hasta,B.clave_entidad,B.clave_sucursal,B.digito_control,B.cuenta_corriente,B.codigo,FP.codigo_tipo_efecto
	 UPDATE @eje_facturas_vtos SET dia1=CASE
													WHEN dia1=0 THEN NULL
													ELSE dia1
													END,
											dia2=CASE
													WHEN dia2=0 THEN NULL
													ELSE dia2
													END,
											dia3=CASE
													WHEN dia3=0 THEN NULL
													ELSE dia3
													END
	
	UPDATE @eje_facturas_vtos SET fecha=fecha_vto
	UPDATE @eje_facturas_vtos SET fecha_vto = 
	  CASE
        WHEN fecha_vto < CAST(CONVERT(CHAR(6), fecha_vto, 112 ) + RIGHT('00' + CAST(ISNULL(dia1,DAY(fecha_vto)) AS VARCHAR(2)), 2) AS DATE)
        THEN DATEADD(DAY, ISNULL(dia1-DAY(fecha_vto),0) ,fecha_vto )
       ELSE
          CASE
            WHEN fecha_vto < CAST(CONVERT(CHAR(6), fecha_vto, 112 ) + RIGHT('00' + CAST(ISNULL(dia2,DAY(fecha_vto)) AS VARCHAR(2)), 2) AS DATE)
            THEN DATEADD(DAY, ISNULL(dia2-DAY(fecha_vto),0) ,fecha_vto )
           ELSE
            CASE WHEN fecha_vto < CAST(CONVERT(CHAR(6), fecha_vto, 112 ) + RIGHT('00' + CAST(ISNULL(dia3,DAY(fecha_vto)) AS VARCHAR(2)), 2) AS DATE)
              THEN DATEADD(DAY, ISNULL(dia3-DAY(fecha_vto),0) ,fecha_vto )
              ELSE
				CASE
					WHEN DAY(fecha_vto) IN (dia1,dia2,dia3) OR dia1 IS NULL OR dia1=0
					THEN fecha_vto
				 ELSE
					DATEADD(DAY,
					DATEDIFF (DAY,fecha_vto,DATEADD(DAY,-1,DATEADD(MONTH,1,DATEADD(DAY,1-DATEPART(DAY,fecha_vto),fecha_vto))))+ISNULL(dia1,1),fecha_vto)
				END
             END
          END
      END   

UPDATE @eje_facturas_vtos SET fdif=DATEDIFF(DAY,fecha,fecha_vto)+1 WHERE dia1 IS NOT NULL
--UPDATE @eje_facturas_vtos SET fecha_vto = DATEADD(DAY,vto-fdif ,fecha_vto) WHERE dia1 IS NOT NULL
--UPDATE @eje_facturas_vtos SET fecha_vto = DATEADD(DAY,ISNULL(dia1,0)-DAY(fecha_vto) ,fecha_vto) WHERE dia1 IS NOT NULL

UPDATE @eje_facturas_vtos SET fecha_vto =
CONVERT(char(2),ISNULL(dia1,1))+'-'+
CONVERT(char(2),
MONTH((DATEADD(MONTH,
ISNULL((SELECT TOP 1 DATEDIFF(MONTH,fecha_vto,fhasta)+1 FROM @eje_facturas_vtos WHERE fecha_vto BETWEEN fdesde AND fhasta),0)
,fecha_vto)) ))+'-'+
CONVERT(char(4),
YEAR((DATEADD(MONTH,
ISNULL((SELECT TOP 1 DATEDIFF(MONTH,fecha_vto,fhasta)+1 FROM @eje_facturas_vtos WHERE fecha_vto BETWEEN fdesde AND fhasta),0)
,fecha_vto))) ) FROM @eje_facturas_vtos
 WHERE fecha_vto BETWEEN fdesde AND fhasta OR MONTH(fecha_vto) > MONTH(fhasta)

SET @efectos = (select COUNT(*) from @eje_facturas_vtos)
UPDATE @eje_facturas_vtos SET importe = total / @efectos
SELECT @resto = (select SUM(importe) from @eje_facturas_vtos where orden <  @efectos)
UPDATE @eje_facturas_vtos SET importe = total - ISNULL(@resto,0) WHERE orden=@efectos

DELETE FROM eje_venta_vtos WHERE empresa=@empresa AND ejercicio=@ejercicio AND codigo_tipo_documento=@codigo_tipo_documento AND serie=@serie AND numero=@numero 

INSERT INTO eje_venta_vtos (empresa,ejercicio,codigo_tipo_documento,serie,numero,numero_vto,fecha_vto,importe)
	select vtos.empresa,vtos.ejercicio,vtos.codigo_tipo_documento,vtos.serie,vtos.numero,vtos.efecto,vtos.fecha_vto,vtos.importe
		FROM @eje_facturas_vtos as vtos where ISNULL(vtos.importe,0)<>0 and ISNULL(ABS(vtos.importe),0)<>0.01  

	DECLARE cursor_vs_eje_venta_t CURSOR FOR SELECT fecha_vto,importe FROM @eje_facturas_vtos
	OPEN cursor_vs_eje_venta_t
	FETCH NEXT FROM cursor_vs_eje_venta_t INTO @fecha_vto,@importe
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
			SET @lcUpdate = 'UPDATE eje_venta_t SET ' +
				'fecha_vto'+ cast(@numero_linea as varchar) + '=' + '''' + RTRIM(CONVERT(char(12),@fecha_vto,103)) + '''' + ',' + 
				'importe'+ cast(@numero_linea as varchar) + '=' + CAST(@importe AS VARCHAR(20)) +
				' WHERE empresa = ''' + @empresa + ''' AND ejercicio = ''' + @ejercicio + ''' AND codigo_tipo_documento = ''' + @codigo_tipo_documento + ''' AND serie = ''' + @serie + ''' AND numero = ''' + @numero + ''''
		  EXEC(@lcUPDATE)
	FETCH NEXT FROM cursor_vs_eje_venta_t INTO @fecha_vto,@importe
		SET @numero_linea = @numero_linea + 1
	END
	CLOSE cursor_vs_eje_venta_t
	deallocate cursor_vs_eje_venta_t

/*
exec vs_calcular_vencimientos 'E_000001J','2011','PRE','PRESUPUEST','OF//00014'
select * from eje_venta_t where empresa='E_000001J' AND ejercicio='2011' and numero='OF//00014' and codigo_tipo_documento='PRE'
*/

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
		
	set @Sesion = @@SPID
	set @sys_timestamp = getdate()

	set @pSys_oid = (Select sys_oid FROM eje_venta_c WHERE empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero)
	
	set @empresa_destino=(select isnull(empresa_contabilizar,@pempresa) from emp_series where empresa=@pempresa and codigo=@pserie and ejercicio=@pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento)
	DELETE tmp_apuntes_traspaso where sys_oid_origen = @psys_oid and codigo_tipo_documento_origen = @pcodigo_tipo_documento
	--set @total = (select total from eje_venta_t where empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero)
	select @total=isnull(total,0),@cuota_cargo_financiero=cuota_cargo_financiero,@cuota_dto_financiero=cuota_dto_financiero,
		@cuota_dto_comercial=cuota_dto_comercial,@entregas=isnull(entrega_a_cuenta,0) 
		from eje_venta_t where empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero
	select @fecha=fecha,@nombre_cliente=nombre_cliente,@razon_social_cliente=razon_social_cliente,@nif_cliente=nif_cliente,@serie=serie,@numero_factura=numero
			,@codigo_cliente=codigo_cliente FROM eje_venta_c where empresa=@pempresa and ejercicio = @pejercicio and codigo_tipo_documento=@pcodigo_tipo_documento and serie=@pserie and numero=@pnumero
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
								@subcuenta_dto_financiero=subcuenta_dto_financiero,
								@subcuenta_dif_positivas=subcuenta_diferencias_positivas,@subcuenta_dif_negativas=subcuenta_diferencias_negativas 
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
							
							
							declare cursor_desglose_venta CURSOR FOR
								SELECT importe,subcuenta_ventas FROM vf_desglose_subcuenta_ventas WHERE	sys_oid=@psys_oid and importe<>0 AND not importe is null
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