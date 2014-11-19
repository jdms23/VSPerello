use vs_alcaraz
go 

alter table eje_factura_c add codigo_concepto_impagado dm_codigos_c
go 


ALTER VIEW [dbo].[vv_venta_c_factura] 
AS
SELECT     dbo.eje_venta_c.empresa, dbo.eje_venta_c.ejercicio, dbo.eje_venta_c.periodo, dbo.eje_venta_c.codigo_tipo_documento, dbo.eje_venta_c.serie, 
                      dbo.eje_venta_c.codigo_tipo_cond_venta, dbo.eje_venta_c.numero, dbo.eje_venta_c.fecha, dbo.eje_venta_c.situacion, dbo.eje_venta_c.codigo_tercero, 
                      dbo.eje_venta_c.codigo_cliente, dbo.eje_venta_c.nombre_cliente, dbo.eje_venta_c.razon_social_cliente, dbo.eje_venta_c.nif_cliente, 
                      dbo.eje_venta_c.domicilio_cliente, dbo.eje_venta_c.codigo_postal_cliente, dbo.eje_venta_c.poblacion_cliente, dbo.eje_venta_c.provincia_cliente, 
                      dbo.eje_venta_c.codigo_forma_pago, dbo.eje_venta_c.codigo_tabla_iva, dbo.eje_venta_c.codigo_representante, dbo.eje_venta_c.dto_comercial, 
                      dbo.eje_venta_c.dto_financiero, dbo.eje_venta_c.numero_copias, dbo.eje_venta_c.observaciones, dbo.eje_venta_c.observaciones_internas, 
                      dbo.eje_venta_c.adjuntos, dbo.eje_venta_c.sys_logs, dbo.eje_venta_c.sys_borrado, dbo.eje_venta_c.sys_timestamp, dbo.eje_venta_c.codigo_pais_cliente, 
                      dbo.eje_venta_c.referencia, dbo.eje_factura_c.contabilizada, dbo.eje_venta_c.sys_oid, dbo.eje_factura_c.sys_oid AS sys_oid_factura,
                      dbo.eje_venta_c.codigo_divisa, dbo.eje_venta_c.cambio_divisa, dbo.eje_venta_c.codigo_tarifa, 
                      dbo.eje_venta_c.identificador_dir_envio, dbo.eje_venta_c.alias_dir_envio, dbo.eje_venta_c.nombre_dir_envio, dbo.eje_venta_c.domicilio_dir_envio, 
                      dbo.eje_venta_c.sucursal_dir_envio, dbo.eje_venta_c.codigo_postal_dir_envio, dbo.eje_venta_c.poblacion_dir_envio, dbo.eje_venta_c.provincia_dir_envio, 
                      dbo.eje_venta_c.codigo_pais_dir_envio, dbo.eje_venta_c.telefono_dir_envio, dbo.eje_venta_c.movil_dir_envio, dbo.eje_venta_c.email_dir_envio, 
                      dbo.eje_venta_c.fax_dir_envio, dbo.eje_venta_c.codigo_portes, dbo.eje_venta_c.codigo_tipo_iva_portes, dbo.eje_venta_c.aplicar_en_totales_portes, 
                      dbo.eje_venta_c.importe_portes, dbo.eje_venta_c.cargo_financiero, dbo.eje_venta_c.realizado_por, dbo.eje_venta_c.codigo_agencia, dbo.eje_venta_c.piramidal, 
                      dbo.eje_venta_c.aplicar_cargo_financiero, dbo.eje_venta_c.codigo_centro_venta, dbo.eje_venta_c.identificador_banco, dbo.eje_venta_c.nombre_banco, 
                      dbo.eje_venta_c.domicilio_banco, dbo.eje_venta_c.sucursal_banco, dbo.eje_venta_c.codigo_postal_banco, dbo.eje_venta_c.poblacion_banco, 
                      dbo.eje_venta_c.provincia_banco, dbo.eje_venta_c.iban_code_banco, dbo.eje_venta_c.swift_code_banco, dbo.eje_venta_c.clave_entidad_banco, 
                      dbo.eje_venta_c.clave_sucursal_banco, dbo.eje_venta_c.digito_control_banco, dbo.eje_venta_c.cuenta_corriente_banco, dbo.eje_venta_c.criterio_conjuntacion, 
                      dbo.eje_venta_c.aplicar_cargo_financiero_dias, dbo.eje_factura_c.fecha_devengo, dbo.eje_venta_c.compensar_abono, dbo.eje_factura_c.nombre_dir_pago, 
                      dbo.eje_factura_c.domicilio_dir_pago, dbo.eje_factura_c.codigo_postal_dir_pago, dbo.eje_factura_c.poblacion_dir_pago, dbo.eje_factura_c.provincia_dir_pago, 
                      dbo.eje_factura_c.codigo_pais_dir_pago, dbo.eje_factura_c.telefono_dir_pago, dbo.eje_factura_c.movil_dir_pago, dbo.eje_factura_c.email_dir_pago, 
                      dbo.eje_factura_c.fax_dir_pago, dbo.eje_factura_c.alias_dir_pago, dbo.eje_factura_c.identificador_dir_pago, dbo.eje_factura_c.sucursal_dir_pago, 
                      dbo.eje_venta_c.pdf_generado,dbo.eje_factura_c.cliente_impagado,dbo.eje_venta_t.entrega_a_cuenta,dbo.eje_venta_t.base_imponible,dbo.eje_venta_t.cuota_cargo_financiero,dbo.eje_venta_t.cuota_dto_comercial,
                      dbo.eje_venta_t.cuota_dto_financiero,dbo.eje_venta_t.cuota_iva,dbo.eje_venta_t.cuota_re,dbo.eje_venta_t.neto_lineas,dbo.eje_venta_t.total,eje_Venta_t.pendiente_compensar,dbo.eje_factura_c.codigo_concepto_impagado
FROM         dbo.eje_venta_c INNER JOIN
                      dbo.eje_factura_c ON dbo.eje_venta_c.empresa = dbo.eje_factura_c.empresa AND dbo.eje_venta_c.ejercicio = dbo.eje_factura_c.ejercicio AND 
                      dbo.eje_venta_c.codigo_tipo_documento = dbo.eje_factura_c.codigo_tipo_documento AND dbo.eje_venta_c.serie = dbo.eje_factura_c.serie AND 
                      dbo.eje_venta_c.numero = dbo.eje_factura_c.numero LEFT OUTER JOIN
                      dbo.eje_venta_t ON dbo.eje_venta_c.empresa = dbo.eje_venta_t.empresa AND dbo.eje_venta_c.ejercicio = dbo.eje_venta_t.ejercicio AND 
                      dbo.eje_venta_c.codigo_tipo_documento = dbo.eje_venta_t.codigo_tipo_documento AND dbo.eje_venta_c.serie = dbo.eje_venta_t.serie AND 
                      dbo.eje_venta_c.numero = dbo.eje_venta_t.numero
WHERE     (dbo.eje_venta_c.codigo_tipo_documento = 'FV')


GO

ALTER TRIGGER [dbo].[vv_venta_c_factura_bi]
   ON  [dbo].[vv_venta_c_factura]
   INSTEAD OF INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	INSERT INTO eje_venta_c (
			empresa,ejercicio,periodo,codigo_tipo_documento,serie,codigo_tipo_cond_venta,numero,fecha,situacion,codigo_tercero
			,codigo_cliente,nombre_cliente,razon_social_cliente,nif_cliente,domicilio_cliente,codigo_postal_cliente
			,poblacion_cliente,provincia_cliente,codigo_forma_pago,codigo_Tabla_iva,codigo_representante,dto_comercial
			,dto_financiero,numero_copias,observaciones,observaciones_internas,adjuntos,codigo_pais_cliente,referencia
			,codigo_divisa,cambio_divisa,codigo_tarifa,identificador_dir_envio,alias_dir_envio,nombre_dir_envio,domicilio_dir_envio
			,sucursal_dir_envio,codigo_postal_dir_envio,poblacion_dir_envio,provincia_dir_envio,codigo_pais_dir_envio
			,telefono_dir_envio,movil_dir_envio,email_dir_envio,fax_dir_envio,codigo_portes,codigo_tipo_iva_portes,aplicar_en_totales_portes
			,importe_portes,cargo_financiero,realizado_por,codigo_agencia,piramidal,aplicar_cargo_financiero,codigo_centro_venta
			,identificador_banco, nombre_banco, domicilio_banco, sucursal_banco, codigo_postal_banco, poblacion_banco
			,provincia_banco, iban_code_banco, swift_code_banco, clave_entidad_banco, clave_sucursal_banco, digito_control_banco
			, cuenta_corriente_banco,criterio_conjuntacion,aplicar_cargo_financiero_dias,compensar_abono,pdf_generado)
	 SELECT empresa,ejercicio,periodo,codigo_tipo_documento,serie,codigo_tipo_cond_venta,numero,fecha,situacion,codigo_tercero
			,codigo_cliente,nombre_cliente,razon_social_cliente,nif_cliente,domicilio_cliente,codigo_postal_cliente
			,poblacion_cliente,provincia_cliente,codigo_forma_pago,codigo_Tabla_iva,codigo_representante,dto_comercial
			,dto_financiero,numero_copias,observaciones,observaciones_internas,adjuntos,codigo_pais_cliente,referencia
			,codigo_divisa,cambio_divisa,codigo_tarifa,identificador_dir_envio,alias_dir_envio,nombre_dir_envio,domicilio_dir_envio
			,sucursal_dir_envio,codigo_postal_dir_envio,poblacion_dir_envio,provincia_dir_envio,codigo_pais_dir_envio,telefono_dir_envio
			,movil_dir_envio,email_dir_envio,fax_dir_envio,codigo_portes,codigo_tipo_iva_portes,aplicar_en_totales_portes
			,importe_portes,cargo_financiero,realizado_por,codigo_agencia,codigo_cliente,aplicar_cargo_financiero,codigo_centro_venta
			,identificador_banco, nombre_banco, domicilio_banco, sucursal_banco, codigo_postal_banco, poblacion_banco
			,provincia_banco, iban_code_banco, swift_code_banco, clave_entidad_banco, clave_sucursal_banco, digito_control_banco
			, cuenta_corriente_banco,criterio_conjuntacion,aplicar_cargo_financiero_dias,compensar_abono,pdf_generado
			 FROM INSERTED
			 
			 
	INSERT INTO eje_factura_c (empresa,ejercicio,codigo_tipo_documento,serie,numero,contabilizada,fecha_devengo,identificador_dir_pago,alias_dir_pago,sucursal_dir_pago,nombre_dir_pago, domicilio_dir_pago, codigo_postal_dir_pago, poblacion_dir_pago, provincia_dir_pago, codigo_pais_dir_pago, telefono_dir_pago, movil_dir_pago, email_dir_pago, fax_dir_pago,cliente_impagado,codigo_concepto_impagado) 
		SELECT empresa,ejercicio,codigo_tipo_documento,serie,numero,contabilizada,fecha_devengo,identificador_dir_pago,alias_dir_pago,sucursal_dir_pago,nombre_dir_pago, domicilio_dir_pago, codigo_postal_dir_pago, poblacion_dir_pago, provincia_dir_pago, codigo_pais_dir_pago, telefono_dir_pago, movil_dir_pago, email_dir_pago, fax_dir_pago,cliente_impagado,codigo_concepto_impagado
		  FROM INSERTED
	
	SET NOCOUNT OFF;

END
GO 

ALTER TRIGGER [dbo].[vv_venta_c_factura_bu]
   ON  [dbo].[vv_venta_c_factura]
   INSTEAD OF UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	UPDATE eje_venta_c set empresa=i.empresa,ejercicio=i.ejercicio,codigo_tipo_documento=i.codigo_tipo_documento,serie=i.serie
		,numero=i.numero,periodo=i.periodo,codigo_tipo_cond_venta=i.codigo_tipo_cond_venta,fecha=i.fecha,situacion=i.situacion
		,codigo_tercero=i.codigo_tercero,codigo_cliente=i.codigo_cliente,nombre_cliente=i.nombre_cliente
		,razon_social_cliente=i.razon_social_cliente,nif_cliente=i.nif_cliente,domicilio_cliente=i.domicilio_cliente
		,codigo_postal_cliente=i.codigo_postal_cliente,poblacion_cliente=i.poblacion_cliente,provincia_cliente=i.provincia_cliente
		,codigo_forma_pago=i.codigo_forma_pago,codigo_Tabla_iva=i.codigo_Tabla_iva,codigo_representante=i.codigo_representante
		,dto_comercial=i.dto_comercial,dto_financiero=i.dto_financiero,numero_copias=i.numero_copias,observaciones=i.observaciones
		,observaciones_internas=i.observaciones_internas,adjuntos=i.adjuntos,codigo_pais_cliente=i.codigo_pais_cliente
		,referencia=i.referencia,codigo_divisa=i.codigo_divisa,cambio_divisa=i.cambio_divisa
		,codigo_tarifa=i.codigo_tarifa,identificador_dir_envio=i.identificador_dir_envio,alias_dir_envio=i.alias_dir_envio
		,nombre_dir_envio=i.nombre_dir_envio,domicilio_dir_envio=i.domicilio_dir_envio,sucursal_dir_envio=i.sucursal_dir_envio
		,codigo_postal_dir_envio=i.codigo_postal_dir_envio,poblacion_dir_envio=i.poblacion_dir_envio,provincia_dir_envio=i.provincia_dir_envio
		,codigo_pais_dir_envio=i.codigo_pais_dir_envio,telefono_dir_envio=i.telefono_dir_envio,movil_dir_envio=i.movil_dir_envio
		,email_dir_envio=i.email_dir_envio,fax_dir_envio=i.fax_dir_envio,codigo_portes=i.codigo_portes
		,codigo_tipo_iva_portes=i.codigo_tipo_iva_portes,aplicar_en_totales_portes=i.aplicar_en_totales_portes
		,importe_portes=i.importe_portes,cargo_financiero=i.cargo_financiero,realizado_por=i.realizado_por,codigo_agencia=i.codigo_agencia
		,piramidal=i.codigo_cliente,aplicar_cargo_financiero=i.aplicar_cargo_financiero,codigo_centro_venta=i.codigo_centro_venta
		,identificador_banco = i.identificador_banco, nombre_banco = i.nombre_banco, domicilio_banco=i.domicilio_banco, sucursal_banco=i.sucursal_banco
		,codigo_postal_banco=i.codigo_postal_banco, poblacion_banco=i.poblacion_banco,provincia_banco=i.provincia_banco, iban_code_banco=i.iban_code_banco
		,swift_code_banco=i.swift_code_banco, clave_entidad_banco=i.clave_entidad_banco, clave_sucursal_banco=i.clave_sucursal_banco
		,digito_control_banco=i.digito_control_banco, cuenta_corriente_banco=i.cuenta_corriente_banco,criterio_conjuntacion=i.criterio_conjuntacion
		,aplicar_cargo_financiero_dias=i.aplicar_cargo_financiero_dias,compensar_abono=i.compensar_abono,pdf_generado=i.pdf_generado
		FROM eje_venta_c INNER JOIN inserted AS i ON eje_venta_c.sys_oid = i.sys_oid
						 INNER JOIN deleted AS d ON i.sys_oid = d.sys_oid
		
	UPDATE eje_factura_c set 
		contabilizada=inserted.contabilizada,
		fecha_devengo=inserted.fecha_devengo,
		identificador_dir_pago=inserted.identificador_dir_pago,
		alias_dir_pago=inserted.alias_dir_pago,		
		nombre_dir_pago=inserted.nombre_dir_pago,
		sucursal_dir_pago=inserted.sucursal_dir_pago,
		domicilio_dir_pago=inserted.domicilio_dir_pago,
		codigo_postal_dir_pago=inserted.codigo_postal_dir_pago,
		poblacion_dir_pago=inserted.poblacion_dir_pago,
		provincia_dir_pago=inserted.provincia_dir_pago,
		codigo_pais_dir_pago=inserted.codigo_pais_dir_pago,
		telefono_dir_pago=inserted.telefono_dir_pago,
		movil_dir_pago=inserted.movil_dir_pago,
		email_dir_pago=inserted.email_dir_pago,
		fax_dir_pago=inserted.fax_dir_pago,
		cliente_impagado=inserted.cliente_impagado,
		codigo_concepto_impagado=inserted.codigo_concepto_impagado
		FROM eje_factura_c
		 INNER JOIN inserted ON eje_factura_c.sys_oid = inserted.sys_oid_factura
		 INNER JOIN deleted ON inserted.sys_oid_factura = deleted.sys_oid_factura
	
	SET NOCOUNT OFF;
END

GO 

/****** Object:  StoredProcedure [dbo].[vs_generar_asiento_venta]    Script Date: 02/29/2012 09:38:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
			,@codigo_cliente=codigo_cliente,@importe_portes=importe_portes,@aplicar_en_totales_portes = aplicar_en_totales_portes
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
								(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,importe_debe,importe_haber,modelo_iva,modelo_347,base_imponible,iva,re,contrapartida,nif,razon_social)
								values
								(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
								@subcuenta_iva,@codigo_concepto,@patron,@pserie,@pnumero,@importe_debe,@importe_haber,1,1,@base_imponible,@iva,@re,@subcuenta_cliente,@nif_cliente,@razon_social_cliente)
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
								if @subcuenta_ventas='' or ISNULL(@subcuenta_ventas,'')=''
									set @subcuenta_ventas = @subcuenta_ventas_defecto								
								
								set @importe_haber = @base_imponible 
								set @importe_debe = 0
								insert into tmp_apuntes_traspaso
								(sys_timestamp,sesion,empresa,ejercicio,codigo_tipo_documento_origen,sys_oid_origen,fecha,apunte,subcuenta,codigo_concepto,descripcion,serie_documento,numero_documento,importe_debe,importe_haber)
								values
								(@sys_timestamp,@sesion,@empresa_destino,@pejercicio,@pcodigo_tipo_documento,@psys_oid,@fecha,@apunte,
								@subcuenta_ventas,@codigo_concepto,@patron,@pserie,@pnumero,@importe_debe,@importe_haber)				
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

