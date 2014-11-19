use vsolution
go
alter table eje_venta_c add irpf dm_porcentajes null
go
alter table eje_venta_t add cuota_irpf dm_importes null
go

ALTER TRIGGER [dbo].[eje_venta_c_bi]
   ON  [dbo].[eje_venta_c]
   INSTEAD OF INSERT
AS 
BEGIN
	DECLARE @codigo_tipo_documento dm_codigos_c
	SET NOCOUNT ON;
	
	SET @codigo_tipo_documento = (SELECT TOP 1 codigo_tipo_documento FROM inserted)
	IF  @codigo_tipo_documento <> 'TV'  
		INSERT INTO eje_venta_c (
				empresa,ejercicio,codigo_tipo_documento,serie,codigo_tipo_cond_venta,numero,fecha,situacion,codigo_tercero
				,codigo_cliente,nombre_cliente,razon_social_cliente,nif_cliente,domicilio_cliente,codigo_postal_cliente
				,poblacion_cliente,provincia_cliente,codigo_forma_pago,codigo_Tabla_iva,codigo_representante,dto_comercial
				,dto_financiero,numero_copias,observaciones,observaciones_internas,adjuntos,codigo_pais_cliente,referencia
				,codigo_divisa,cambio_divisa,codigo_tarifa,identificador_dir_envio,alias_dir_envio,nombre_dir_envio,domicilio_dir_envio
				,sucursal_dir_envio,codigo_postal_dir_envio,poblacion_dir_envio,provincia_dir_envio,codigo_pais_dir_envio
				,telefono_dir_envio,movil_dir_envio,email_dir_envio,fax_dir_envio,codigo_portes,codigo_tipo_iva_portes,aplicar_en_totales_portes
				,importe_portes,cargo_financiero,realizado_por,codigo_agencia,periodo,piramidal,aplicar_cargo_financiero
				,codigo_centro_venta,criterio_conjuntacion,aplicar_cargo_financiero_dias,compensar_abono
				,identificador_banco, nombre_banco, domicilio_banco, sucursal_banco, codigo_postal_banco, poblacion_banco
			,provincia_banco, iban_code_banco, swift_code_banco, clave_entidad_banco, clave_sucursal_banco, digito_control_banco
			, cuenta_corriente_banco,irpf)
		 SELECT empresa,ejercicio,codigo_tipo_documento,serie,codigo_tipo_cond_venta,numero,fecha,situacion,codigo_tercero
				,codigo_cliente,nombre_cliente,razon_social_cliente,nif_cliente,domicilio_cliente,codigo_postal_cliente
				,poblacion_cliente,provincia_cliente,codigo_forma_pago,codigo_Tabla_iva,codigo_representante,dto_comercial
				,dto_financiero,numero_copias,observaciones,observaciones_internas,adjuntos,codigo_pais_cliente,referencia
				,codigo_divisa,cambio_divisa,codigo_tarifa,identificador_dir_envio,alias_dir_envio,nombre_dir_envio,domicilio_dir_envio
				,sucursal_dir_envio,codigo_postal_dir_envio,poblacion_dir_envio,provincia_dir_envio,codigo_pais_dir_envio,telefono_dir_envio
				,movil_dir_envio,email_dir_envio,fax_dir_envio,codigo_portes,codigo_tipo_iva_portes,aplicar_en_totales_portes
				,importe_portes,cargo_financiero,realizado_por,codigo_agencia
				  ,(SELECT PR.periodo
					FROM eje_periodos AS PR WHERE i.empresa = pr.empresa AND i.ejercicio = PR.ejercicio AND 
					i.fecha between pr.desde_fecha and pr.hasta_fecha AND PR.tipo LIKE '%G%')
					,piramidal,aplicar_cargo_financiero,codigo_centro_venta,criterio_conjuntacion,aplicar_cargo_financiero_dias,compensar_abono
					,identificador_banco, nombre_banco, domicilio_banco, sucursal_banco, codigo_postal_banco, poblacion_banco
			,provincia_banco, iban_code_banco, swift_code_banco, clave_entidad_banco, clave_sucursal_banco, digito_control_banco
			, cuenta_corriente_banco,irpf
		  			FROM inserted AS i
	ELSE
		
		/***Dejamos el identificador dir envio para poder buscar por la piramidal 
			Aunque eliminamos el resto de campos porque es un ticket ***/
		
		INSERT INTO eje_venta_c (
				empresa,ejercicio,codigo_tipo_documento,serie,codigo_tipo_cond_venta,numero,fecha,situacion,codigo_tercero
				,codigo_cliente,nombre_cliente,razon_social_cliente,nif_cliente,domicilio_cliente,codigo_postal_cliente
				,poblacion_cliente,provincia_cliente,codigo_forma_pago,codigo_Tabla_iva,codigo_representante,dto_comercial
				,dto_financiero,numero_copias,observaciones,observaciones_internas,adjuntos,codigo_pais_cliente,referencia
				,codigo_divisa,cambio_divisa,codigo_tarifa,identificador_dir_envio,alias_dir_envio,nombre_dir_envio,domicilio_dir_envio
				,sucursal_dir_envio,codigo_postal_dir_envio,poblacion_dir_envio,provincia_dir_envio,codigo_pais_dir_envio
				,telefono_dir_envio,movil_dir_envio,email_dir_envio,fax_dir_envio,codigo_portes,codigo_tipo_iva_portes,aplicar_en_totales_portes
				,importe_portes,cargo_financiero,realizado_por,codigo_agencia,periodo,piramidal,aplicar_cargo_financiero,codigo_centro_venta,criterio_conjuntacion
				,aplicar_cargo_financiero_dias,compensar_abono
				,identificador_banco, nombre_banco, domicilio_banco, sucursal_banco, codigo_postal_banco, poblacion_banco
			,provincia_banco, iban_code_banco, swift_code_banco, clave_entidad_banco, clave_sucursal_banco, digito_control_banco
			, cuenta_corriente_banco
				)				
		 SELECT i.empresa,i.ejercicio,i.codigo_tipo_documento,i.serie,i.codigo_tipo_cond_venta,i.numero,i.fecha,i.situacion,C.codigo_tercero
				,C.codigo,C.nombre,C.razon_social,C.nif,C.domicilio,C.codigo_postal
				,C.poblacion,C.provincia,i.codigo_forma_pago,i.codigo_Tabla_iva,i.codigo_representante,i.dto_comercial
				,i.dto_financiero,i.numero_copias,i.observaciones,i.observaciones_internas,i.adjuntos,C.codigo_pais,i.referencia
				,i.codigo_divisa,i.cambio_divisa,i.codigo_tarifa,i.identificador_dir_envio,'',c.nombre,C.domicilio
				,'',c.codigo_postal,C.poblacion,C.provincia,C.codigo_pais,''
				,'','','',i.codigo_portes,i.codigo_tipo_iva_portes,i.aplicar_en_totales_portes
				,i.importe_portes,i.cargo_financiero,i.realizado_por,i.codigo_agencia
				  ,(SELECT PR.periodo
					FROM eje_periodos AS PR WHERE i.empresa = pr.empresa AND i.ejercicio = PR.ejercicio AND 
					i.fecha between pr.desde_fecha and pr.hasta_fecha AND PR.tipo LIKE '%G%')
					,i.codigo_cliente,aplicar_cargo_financiero,codigo_centro_venta,i.criterio_conjuntacion,i.aplicar_cargo_financiero_dias,i.compensar_abono
					,identificador_banco, nombre_banco, domicilio_banco, sucursal_banco, codigo_postal_banco, poblacion_banco
			,provincia_banco, iban_code_banco, swift_code_banco, clave_entidad_banco, clave_sucursal_banco, digito_control_banco
			, cuenta_corriente_banco
		  			FROM inserted AS i 
		  				INNER JOIN gen_empresas AS E ON e.codigo = i.empresa
		  					INNER JOIN vf_emp_clientes AS C ON C.empresa = E.codigo AND C.codigo = E.codigo_clientes_tickets		
END

go


ALTER TRIGGER [dbo].[eje_venta_c_au]
   ON  [dbo].[eje_venta_c]
   AFTER UPDATE
AS 
BEGIN

	SET NOCOUNT ON;
	DECLARE @sys_oid dm_oid
	DECLARE @periodo dm_entero
	DECLARE @empresa dm_empresas
	DECLARE @ejercicio dm_ejercicios
	DECLARE @codigo_tipo_documento dm_codigos_c
	DECLARE @serie dm_codigos_C
	DECLARE @numero	dm_numero_doc
	DECLARE @perror INT
		
	DECLARE INSERTADOS CURSOR LOCAL FOR 
		SELECT empresa,ejercicio,codigo_tipo_documento,serie,numero
		  FROM inserted
	OPEN insertados
	FETCH NEXT FROM insertados INTO @empresa,@ejercicio,@codigo_tipo_documento,@serie,@numero
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		 IF update(fecha)
			BEGIN
				SET @periodo = (SELECT PR.periodo
					FROM inserted INNER JOIN
					dbo.eje_periodos AS PR ON inserted.empresa = PR.empresa AND inserted.ejercicio = PR.ejercicio
					WHERE inserted.fecha between pr.desde_fecha and pr.hasta_fecha AND PR.tipo LIKE '%G%')
				UPDATE eje_venta_c SET periodo = @periodo where empresa=@empresa AND ejercicio=@ejercicio AND numero=@numero AND serie=@serie AND @codigo_tipo_documento=codigo_tipo_documento
			END
		if update(dto_comercial) or update(dto_financiero) or update(irpf)
			EXEC @perror = vs_eje_venta_t @empresa,@ejercicio,@codigo_tipo_documento,@serie,@numero
			IF @perror <> 0
			BEGIN
				ROLLBACK
				RETURN
			END
		FETCH NEXT FROM insertados INTO @empresa,@ejercicio,@codigo_tipo_documento,@serie,@numero
	END
	close insertados
	deallocate insertados
	SET NOCOUNT OFF;

END

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
                      dbo.eje_venta_t.cuota_dto_financiero,dbo.eje_venta_t.cuota_iva,dbo.eje_venta_t.cuota_re,dbo.eje_venta_t.neto_lineas,dbo.eje_venta_t.total,eje_Venta_t.pendiente_compensar,dbo.eje_factura_c.codigo_concepto_impagado,eje_venta_c.irpf,eje_venta_t.cuota_irpf
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
			, cuenta_corriente_banco,criterio_conjuntacion,aplicar_cargo_financiero_dias,compensar_abono,pdf_generado,irpf)
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
			, cuenta_corriente_banco,criterio_conjuntacion,aplicar_cargo_financiero_dias,compensar_abono,pdf_generado,irpf
			 FROM INSERTED
			 
			 
	INSERT INTO eje_factura_c (empresa,ejercicio,codigo_tipo_documento,serie,numero,contabilizada,fecha_devengo,identificador_dir_pago,alias_dir_pago,sucursal_dir_pago,nombre_dir_pago, domicilio_dir_pago, codigo_postal_dir_pago, poblacion_dir_pago, provincia_dir_pago, codigo_pais_dir_pago, telefono_dir_pago, movil_dir_pago, email_dir_pago, fax_dir_pago,cliente_impagado,codigo_concepto_impagado) 
		SELECT empresa,ejercicio,codigo_tipo_documento,serie,numero,contabilizada,fecha_devengo,identificador_dir_pago,alias_dir_pago,sucursal_dir_pago,nombre_dir_pago, domicilio_dir_pago, codigo_postal_dir_pago, poblacion_dir_pago, provincia_dir_pago, codigo_pais_dir_pago, telefono_dir_pago, movil_dir_pago, email_dir_pago, fax_dir_pago,cliente_impagado,codigo_concepto_impagado
		  FROM INSERTED
	
	SET NOCOUNT OFF;

END


go

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
		,aplicar_cargo_financiero_dias=i.aplicar_cargo_financiero_dias,compensar_abono=i.compensar_abono,pdf_generado=i.pdf_generado,irpf=i.irpf
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
go

ALTER PROCEDURE [dbo].[vs_eje_venta_t]
	@empresa [dbo].[dm_empresas],
	@ejercicio [dbo].[dm_ejercicios],
	@codigo_tipo_documento [dbo].[dm_codigos_c],
	@serie [dbo].[dm_codigos_c],
	@numero dm_numero_doc
 AS
BEGIN

	SET NOCOUNT ON;
	declare @numero_abono dm_numero_doc
	declare @serie_abono dm_codigos_c
	DECLARE @base_imponible dm_importes	
	DECLARE @neto_lineas dm_importes
	DECLARE @iva dm_porcentajes
	DECLARE @cuota_iva dm_importes
	DECLARE @re dm_porcentajes
	DECLARE @cuota_re dm_importes
	DECLARE @numero_linea dm_entero
	DECLARE @dto_comercial dm_porcentajes
	DECLARE @dto_financiero dm_porcentajes
	declare @cuota_dto_comercial dm_importes
	declare @cuota_dto_financiero dm_importes
	declare @total dm_importes
	declare @cargo_financiero dm_importes
	declare @lcUpdate varchar(1000)
	declare @entrega_a_cuenta dm_importes
	declare @importe_compensado dm_importes
	declare @importe_ya_compensado dm_importes	
	declare @abonos_compensados dm_char_corto
	declare @importe_abonado dm_importes
	declare @fecha_entrega dm_fechas_hora
	declare @fecha_vto dm_fechas_hora
	DECLARE @importe dm_importes
	declare @aplicar_cargo_financiero dm_logico
	DECLARE @perror varchar(4000)
	DECLARE @compensar_abono dm_logico
	declare @codigo_cliente dm_codigos_n
	declare @pte_compensar dm_importes
	declare @total_factura dm_importes
	declare @sys_oid_abono dm_oid
	declare @empresa_contabilizar dm_empresas
	declare @empresa_abono dm_empresas
	declare @ejercicio_abono dm_ejercicios 
	declare @codigo_tipo_documento_abono dm_codigos_c
	declare @serie_abono_compensacion dm_codigos_c
	declare @numero_abono_compensacion dm_numero_doc
	DECLARE @irpf dm_porcentajes
	
	SET @numero_linea = 1

BEGIN TRY
 BEGIN TRANSACTION
	DELETE eje_venta_t 
	 WHERE empresa = @empresa 
	   AND ejercicio = @ejercicio
	   AND codigo_tipo_documento= @codigo_tipo_documento 
	   AND serie = @serie 
	   AND numero=@numero

	DECLARE cursor_vs_eje_venta_t CURSOR LOCAL FOR 
	 SELECT neto_lineas,cuota_dto_comercial,cuota_dto_financiero,base_imponible,iva,cuota_iva,re,cuota_re,total
				,eje_venta_c.cargo_financiero,aplicar_cargo_financiero,eje_venta_c.irpf
	   FROM eje_venta_i
	   INNER JOIN eje_venta_c 
	   ON dbo.eje_venta_i.empresa = dbo.eje_venta_c.empresa
	    AND dbo.eje_venta_i.ejercicio = dbo.eje_venta_c.ejercicio
	    AND dbo.eje_venta_i.codigo_tipo_documento = dbo.eje_venta_c.codigo_tipo_documento
	    AND dbo.eje_venta_i.serie = dbo.eje_venta_c.serie
	    AND dbo.eje_venta_i.numero = dbo.eje_venta_c.numero
	  WHERE eje_venta_i.empresa = @empresa  
	    AND	eje_venta_i.ejercicio = @ejercicio
	    AND	eje_venta_i.codigo_tipo_documento = @codigo_tipo_documento
	    AND	eje_venta_i.serie = @serie
	    AND	eje_venta_i.numero = @numero
	
	OPEN cursor_vs_eje_venta_t
	FETCH NEXT FROM cursor_vs_eje_venta_t INTO @neto_lineas,@cuota_dto_comercial,@cuota_dto_financiero,@base_imponible,@iva,@cuota_iva,@re,@cuota_re,@total,@cargo_financiero
						  ,@aplicar_cargo_financiero,@irpf
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		IF @numero_linea = 1 
			INSERT INTO eje_venta_t (empresa,ejercicio,codigo_tipo_documento,serie,numero,neto_lineas,cuota_dto_comercial,cuota_dto_financiero,base_imponible1,iva1,cuota_iva1,re1,cuota_re1,total,fecha_vto1,importe1) 
					VALUES (@empresa,@ejercicio,@codigo_tipo_documento,@serie,@numero,@neto_lineas,@cuota_dto_comercial,@cuota_dto_financiero,@base_imponible,@iva,@cuota_iva,@re,@cuota_re,@total,@fecha_vto,@importe)
		ELSE
		BEGIN
			SET @lcUpdate = 'UPDATE eje_venta_t SET ' +
				'neto_lineas = neto_lineas + ' + CAST(@neto_lineas AS varchar(20)) + ', ' + 
				'cuota_dto_comercial = cuota_dto_comercial + ' + CAST(@cuota_dto_comercial AS VARCHAR(20)) + ', ' +
				'cuota_dto_financiero = cuota_dto_financiero + ' + CAST(@cuota_dto_financiero AS VARCHAR(20)) + ', ' +
				'base_imponible' + cast(@numero_linea as varchar) + '=' + CAST(@base_imponible AS VARCHAR(20)) + ',' + 
				'iva' + cast(@numero_linea as varchar) + '=' + CAST(@iva AS VARCHAR(20)) + ',' + 
				'cuota_iva' + cast(@numero_linea as varchar) + '=' + CAST(@cuota_iva AS VARCHAR(20)) + ',' + 
				're'+ cast(@numero_linea as varchar) + '=' + CAST(@re AS VARCHAR(20)) + ',' + 
				'cuota_re'+ cast(@numero_linea as varchar) + '=' + CAST(@cuota_re AS VARCHAR(20)) + ',' +
				'total = total + ' + CAST(@total AS VARCHAR(20)) +
				' WHERE empresa = ''' + @empresa + ''' AND ejercicio = ''' + @ejercicio + ''' AND codigo_tipo_documento = ''' + @codigo_tipo_documento + ''' AND serie = ''' + @serie + ''' AND numero = ''' + @numero + ''''
			EXEC(@lcUPDATE)
		END
		FETCH NEXT FROM cursor_vs_eje_venta_t INTO @neto_lineas,@cuota_dto_comercial,@cuota_dto_financiero,@base_imponible,@iva,@cuota_iva,@re,@cuota_re,@total,@cargo_financiero
				,@aplicar_cargo_financiero,@irpf
		SET @numero_linea = @numero_linea + 1
	END
	
	CLOSE cursor_vs_eje_venta_t
	deallocate cursor_vs_eje_venta_t
	
	select @entrega_a_cuenta = ISNULL(SUM(isnull(entrega_a_cuenta,0)),0),@fecha_entrega=MAX(fecha_entrega) 
	 from eje_venta_entregas 
	 where empresa=@empresa 
	 and ejercicio = @ejercicio 
	 and codigo_tipo_documento=@codigo_tipo_documento 
	 and serie=@serie 
	 and numero=@numero	

	UPDATE eje_venta_t
		SET cuota_irpf=base_imponible * (ISNULL(@irpf,0)/100),entrega_a_cuenta =@entrega_a_cuenta,fecha_entrega=@fecha_Entrega,cuota_cargo_financiero=(base_imponible * ISNULL(@cargo_financiero,0)/100)
			,total = base_imponible + cuota_iva + cuota_re + (base_imponible * ISNULL(@cargo_financiero,0)/100) - (base_imponible * (ISNULL(@irpf,0)/100))
		WHERE empresa = @empresa  
			AND	ejercicio = @ejercicio
			AND	codigo_tipo_documento = @codigo_tipo_documento
			AND	serie = @serie
			AND	numero = @numero	
		
	if @codigo_tipo_documento = 'FV'
	BEGIN
		select @total_factura=isnull(total,0) from eje_venta_t where empresa=@empresa and ejercicio=@ejercicio 
			and codigo_tipo_documento=@codigo_tipo_documento and serie=@serie and numero=@numero
		if @total_factura < 0 AND (ABS(@total_factura) - ABS(@entrega_a_cuenta)) > 0.01
			update eje_venta_c set compensar_abono=C.compensar_abonos 
				from eje_venta_c as V inner join emp_clientes as C on C.empresa = V.empresa and C.codigo=V.codigo_cliente 
				where V.empresa=@empresa and V.ejercicio=@ejercicio and V.codigo_tipo_documento=@codigo_tipo_documento and V.serie=@serie and V.numero=@numero
		else
			update eje_venta_c set compensar_abono=0 
				where empresa=@empresa and ejercicio=@ejercicio and codigo_tipo_documento=@codigo_tipo_documento and serie=@serie and numero=@numero
	
		select @codigo_cliente=codigo_cliente,@compensar_abono=compensar_abono 
		  from eje_venta_c 
		 WHERE empresa = @empresa     
		   AND	ejercicio = @ejercicio    
		   AND	codigo_tipo_documento = @codigo_tipo_documento    
		   AND	serie = @serie    
		   AND	numero = @numero
		
		if @total_factura > 0 
		begin
			SELECT @empresa_contabilizar = isnull(empresa_contabilizar,empresa)
			  FROM emp_series
			 WHERE empresa = @empresa 
			 AND ejercicio = @ejercicio  
			 AND codigo_tipo_documento = @codigo_tipo_documento	
			 AND codigo = @serie 
			 
			DELETE eje_venta_compensar 
			 WHERE empresa = @empresa 
			 AND ejercicio = @ejercicio  
			 AND codigo_tipo_documento = @codigo_tipo_documento	
			 AND	serie = @serie 
			 AND	numero = @numero
		
			DECLARE cursor_abonos_pendientes cursor local for
				select eje_venta_c.sys_oid, eje_venta_c.empresa, eje_venta_c.ejercicio, eje_venta_c.codigo_tipo_documento,
					eje_venta_c.serie,eje_venta_c.numero,eje_venta_t.pendiente_compensar 
				from eje_venta_t 
					inner join eje_venta_c ON dbo.eje_venta_t.empresa = dbo.eje_venta_c.empresa
					AND dbo.eje_venta_t.ejercicio = dbo.eje_venta_c.ejercicio
					AND dbo.eje_venta_t.codigo_tipo_documento = dbo.eje_venta_c.codigo_tipo_documento
					AND dbo.eje_venta_t.serie = dbo.eje_venta_c.serie
					AND dbo.eje_venta_t.numero = dbo.eje_venta_c.numero 
					INNER JOIN emp_series ON emp_series.empresa = eje_venta_c.empresa 
					AND emp_series.ejercicio = eje_venta_c.ejercicio
					AND emp_series.codigo_tipo_documento = eje_venta_c.codigo_tipo_documento					
					AND emp_series.codigo = eje_venta_c.serie
				WHERE eje_venta_c.codigo_cliente = @codigo_cliente 
					and eje_venta_c.compensar_abono=1 
					AND eje_venta_c.empresa = @empresa  
					AND	eje_venta_c.codigo_tipo_documento = @codigo_tipo_documento					
					AND emp_series.empresa_contabilizar = @empresa_contabilizar and eje_venta_t.pendiente_compensar > 0
			
			SET @numero_linea = 1
			open cursor_abonos_pendientes
			FETCH NEXT FROM cursor_abonos_pendientes INTO @sys_oid_abono,@empresa_abono,@ejercicio_abono,@codigo_tipo_documento_abono,@serie_abono_compensacion,@numero_abono_compensacion,@pte_compensar
			WHILE (@@FETCH_STATUS = 0)
			BEGIN	 		
				if @total_factura >= @pte_compensar 
				begin
					insert into eje_venta_compensar (empresa,ejercicio,codigo_tipo_documento,serie,numero,linea,importe_compensado,sys_oid_abono) values
					(@empresa,@ejercicio,@codigo_tipo_documento,@serie,@numero,@numero_linea,@pte_compensar,@sys_oid_abono)				
				end
				ELSE
				begin
					insert into eje_venta_compensar (empresa,ejercicio,codigo_tipo_documento,serie,numero,linea,importe_compensado,sys_oid_abono) values
					(@empresa,@ejercicio,@codigo_tipo_documento,@serie,@numero,@numero_linea,@total_factura,@sys_oid_abono)				
				end
				exec vs_calcular_total_venta @empresa_abono,@ejercicio_abono,@codigo_tipo_documento_abono,@serie_abono_compensacion,@numero_abono_compensacion
				SET @numero_linea = @numero_linea + 1									
				FETCH NEXT FROM cursor_abonos_pendientes INTO @sys_oid_abono,@empresa_abono,@ejercicio_abono,@codigo_tipo_documento_abono,@serie_abono_compensacion,@numero_abono_compensacion,@pte_compensar
			END
			CLOSE cursor_abonos_pendientes
			deallocate cursor_abonos_pendientes		
		end 	
		
		select @importe_ya_compensado = isnull(SUM(importe_compensado),0) from eje_venta_compensar where sys_oid_abono = (select sys_oid from eje_venta_c where empresa=@empresa and ejercicio = @ejercicio and codigo_tipo_documento=@codigo_tipo_documento and serie=@serie and numero=@numero)
		set @importe_compensado=0
		set @abonos_compensados=''
		declare cursor_compensaciones cursor local for 
			select importe_compensado,serie_abono,numero_abono 
			from vf_compensaciones_abonos 
			where empresa=@empresa 
			and ejercicio = @ejercicio 
			and codigo_tipo_documento=@codigo_tipo_documento 
			and serie=@serie 
			and numero=@numero

		OPEN cursor_compensaciones
		FETCH NEXT FROM cursor_compensaciones INTO @importe_abonado,@serie_abono,@numero_abono
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			set @importe_compensado=@importe_compensado + @importe_abonado
			set @abonos_compensados = rtrim(@abonos_compensados) + ' ' + RTRIM(@serie_abono) + '-' + RTRIM(@numero_abono) 
			FETCH NEXT FROM cursor_compensaciones INTO @importe_abonado,@serie_abono,@numero_abono		
		END
		CLOSE cursor_compensaciones
		deallocate cursor_compensaciones
		
		
		UPDATE eje_venta_t
			SET importe_compensado=@importe_compensado,abonos_compensados=@abonos_compensados,cuota_cargo_financiero=(base_imponible * ISNULL(@cargo_financiero,0)/100)
				,total = base_imponible + cuota_iva + cuota_re + (base_imponible * ISNULL(@cargo_financiero,0)/100),
				pendiente_compensar=CASE
										WHEN (base_imponible + cuota_iva + cuota_re + round((base_imponible * ISNULL(@cargo_financiero,0)/100),2) >= 0) THEN 0
										WHEN @compensar_abono=1 and  (base_imponible + cuota_iva + cuota_re + round((base_imponible * ISNULL(@cargo_financiero,0)/100),2) < 0)
											THEN ((base_imponible + cuota_iva + cuota_re + (base_imponible * ISNULL(@cargo_financiero,0)/100)) + @importe_ya_compensado) * -1
											ELSE 0
										END															
			WHERE empresa = @empresa  
				AND	ejercicio = @ejercicio
				AND	codigo_tipo_documento = @codigo_tipo_documento
				AND	serie = @serie
				AND	numero = @numero
										
	END

	update eje_venta_c set codigo_forma_pago=case when B.es_visa=1 then 'TV' else '00' END
	from eje_venta_c as C inner join eje_venta_t as T on c.empresa=t.empresa and c.ejercicio=t.ejercicio and
		c.codigo_tipo_documento=t.codigo_tipo_documento and c.serie=t.serie and c.numero=t.numero
		inner join eje_mov_caja as M on C.empresa=M.empresa and C.ejercicio = M.ejercicio and C.codigo_tipo_documento=M.codigo_tipo_documento and C.serie=M.serie and C.numero=M.numero 
		inner join emp_bancos as B on M.empresa = B.empresa and M.codigo_banco = B.codigo
	where c.empresa = @empresa  
			AND	c.ejercicio = @ejercicio AND c.codigo_tipo_documento = @codigo_tipo_documento AND c.serie = @serie
			AND	c.numero = @numero and 		
			c.codigo_forma_pago<>'00' and isnull(t.total,0)-ISNULL(t.entrega_a_cuenta,0)=0 and ISNULL(t.entrega_a_cuenta,0)<>0 			
	
	COMMIT TRANSACTION
	END TRY
	
	BEGIN CATCH
		set @pError = 'ERROR AL CALCULAR TOTALES DE VENTA(' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + ERROR_MESSAGE()
	 	ROLLBACK
		RAISERROR(@pError,16,1)
	END CATCH

END

go
