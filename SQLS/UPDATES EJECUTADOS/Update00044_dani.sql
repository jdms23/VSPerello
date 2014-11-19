USE vs_martinez
GO 

ALTER TABLE eje_presup_c ADD origen_web dm_logico DEFAULT 0
GO 

update eje_presup_c set origen_web = 0
GO 

ALTER VIEW [dbo].[vv_venta_c_presup]
WITH ENCRYPTION AS
SELECT     dbo.eje_venta_c.empresa, dbo.eje_venta_c.ejercicio, dbo.eje_venta_c.periodo, dbo.eje_venta_c.codigo_tipo_documento, dbo.eje_venta_c.serie, 
                      dbo.eje_venta_c.codigo_tipo_cond_venta, dbo.eje_venta_c.numero, dbo.eje_venta_c.fecha, dbo.eje_venta_c.situacion, dbo.eje_venta_c.codigo_tercero, 
                      dbo.eje_venta_c.codigo_cliente, dbo.eje_venta_c.nombre_cliente, dbo.eje_venta_c.razon_social_cliente, dbo.eje_venta_c.nif_cliente, 
                      dbo.eje_venta_c.domicilio_cliente, dbo.eje_venta_c.codigo_postal_cliente, dbo.eje_venta_c.poblacion_cliente, dbo.eje_venta_c.provincia_cliente, 
                      dbo.eje_venta_c.codigo_forma_pago, dbo.eje_venta_c.codigo_tabla_iva, dbo.eje_venta_c.codigo_representante, dbo.eje_venta_c.dto_comercial, 
                      dbo.eje_venta_c.dto_financiero, dbo.eje_venta_c.numero_copias, dbo.eje_venta_c.observaciones, dbo.eje_venta_c.observaciones_internas, 
                      dbo.eje_venta_c.adjuntos, dbo.eje_venta_c.sys_logs, dbo.eje_venta_c.sys_borrado, dbo.eje_venta_c.sys_timestamp, dbo.eje_venta_c.sys_oid, 
                      dbo.eje_venta_c.codigo_pais_cliente, dbo.eje_venta_c.referencia, dbo.eje_venta_c.codigo_divisa, dbo.eje_venta_c.cambio_divisa, dbo.eje_venta_c.codigo_tarifa, 
                      dbo.eje_presup_c.atencion_de, dbo.eje_presup_c.dias_validez, dbo.eje_presup_c.sys_oid AS sys_oid_presup, dbo.eje_venta_c.identificador_dir_envio, 
                      dbo.eje_venta_c.alias_dir_envio, dbo.eje_venta_c.nombre_dir_envio, dbo.eje_venta_c.domicilio_dir_envio, dbo.eje_venta_c.sucursal_dir_envio, 
                      dbo.eje_venta_c.codigo_postal_dir_envio, dbo.eje_venta_c.poblacion_dir_envio, dbo.eje_venta_c.provincia_dir_envio, dbo.eje_venta_c.codigo_pais_dir_envio, 
                      dbo.eje_venta_c.telefono_dir_envio, dbo.eje_venta_c.movil_dir_envio, dbo.eje_venta_c.email_dir_envio, dbo.eje_venta_c.fax_dir_envio, 
                      dbo.eje_venta_c.codigo_portes, dbo.eje_venta_c.codigo_tipo_iva_portes, dbo.eje_venta_c.aplicar_en_totales_portes, dbo.eje_venta_c.importe_portes, 
                      dbo.eje_venta_c.cargo_financiero, dbo.eje_venta_c.realizado_por, dbo.eje_venta_c.codigo_agencia, dbo.eje_venta_c.identificador_banco, 
                      dbo.eje_venta_c.nombre_banco, dbo.eje_venta_c.domicilio_banco, dbo.eje_venta_c.sucursal_banco, dbo.eje_venta_c.codigo_postal_banco, 
                      dbo.eje_venta_c.poblacion_banco, dbo.eje_venta_c.provincia_banco, dbo.eje_venta_c.iban_code_banco, dbo.eje_venta_c.swift_code_banco, 
                      dbo.eje_venta_c.clave_entidad_banco, dbo.eje_venta_c.clave_sucursal_banco, dbo.eje_venta_c.digito_control_banco, dbo.eje_venta_c.cuenta_corriente_banco, 
                      dbo.eje_venta_c.telefono_cliente, dbo.eje_venta_c.fax_cliente, dbo.eje_venta_c.email_cliente, dbo.eje_venta_c.web_cliente, dbo.eje_venta_c.piramidal, 
                      dbo.eje_venta_c.aplicar_cargo_financiero, dbo.eje_venta_c.codigo_centro_venta, dbo.eje_venta_c.criterio_conjuntacion, 
                      dbo.eje_venta_c.aplicar_cargo_financiero_dias, dbo.eje_venta_c.pdf_generado, dbo.eje_presup_c.origen_web
FROM         dbo.eje_venta_c INNER JOIN
                      dbo.eje_presup_c ON dbo.eje_venta_c.empresa = dbo.eje_presup_c.empresa AND dbo.eje_venta_c.ejercicio = dbo.eje_presup_c.ejercicio AND 
                      dbo.eje_venta_c.codigo_tipo_documento = dbo.eje_presup_c.codigo_tipo_documento AND dbo.eje_venta_c.serie = dbo.eje_presup_c.serie AND 
                      dbo.eje_venta_c.numero = dbo.eje_presup_c.numero
WHERE     (dbo.eje_venta_c.codigo_tipo_documento = 'PRE')

GO

ALTER TRIGGER [dbo].[vv_venta_c_presup_bi]
   ON  [dbo].[vv_venta_c_presup]
WITH ENCRYPTION   INSTEAD OF INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	SET NOCOUNT ON;
	
	INSERT INTO eje_venta_c (
			empresa,ejercicio,periodo,codigo_tipo_documento,serie,codigo_tipo_cond_venta,numero,fecha,situacion,codigo_tercero
			,codigo_cliente,nombre_cliente,razon_social_cliente,nif_cliente,domicilio_cliente,codigo_postal_cliente
			,poblacion_cliente,provincia_cliente,codigo_forma_pago,codigo_Tabla_iva,codigo_representante,dto_comercial
			,dto_financiero,numero_copias,observaciones,observaciones_internas,adjuntos,codigo_pais_cliente,referencia
			,codigo_divisa,cambio_divisa,codigo_tarifa,identificador_dir_envio,alias_dir_envio,nombre_dir_envio,domicilio_dir_envio
			,sucursal_dir_envio,codigo_postal_dir_envio,poblacion_dir_envio,provincia_dir_envio,codigo_pais_dir_envio
			,telefono_dir_envio,movil_dir_envio,email_dir_envio,fax_dir_envio,codigo_portes,codigo_tipo_iva_portes,aplicar_en_totales_portes
			,importe_portes,cargo_financiero,realizado_por,codigo_agencia,identificador_banco,nombre_banco, domicilio_banco, sucursal_banco
			,codigo_postal_banco,poblacion_banco, provincia_banco, iban_code_banco, swift_code_banco, clave_entidad_banco, clave_sucursal_banco
			,digito_control_banco, cuenta_corriente_banco, telefono_cliente, fax_cliente, email_cliente, web_cliente,piramidal,aplicar_cargo_financiero
			,codigo_centro_venta,criterio_conjuntacion,aplicar_cargo_financiero_dias,pdf_generado)
	 SELECT empresa,ejercicio,periodo,codigo_tipo_documento,serie,codigo_tipo_cond_venta,numero,fecha,situacion,codigo_tercero
			,codigo_cliente,nombre_cliente,razon_social_cliente,nif_cliente,domicilio_cliente,codigo_postal_cliente
			,poblacion_cliente,provincia_cliente,codigo_forma_pago,codigo_Tabla_iva,codigo_representante,dto_comercial
			,dto_financiero,numero_copias,observaciones,observaciones_internas,adjuntos,codigo_pais_cliente,referencia
			,codigo_divisa,cambio_divisa,codigo_tarifa,identificador_dir_envio,alias_dir_envio,nombre_dir_envio,domicilio_dir_envio
			,sucursal_dir_envio,codigo_postal_dir_envio,poblacion_dir_envio,provincia_dir_envio,codigo_pais_dir_envio,telefono_dir_envio
			,movil_dir_envio,email_dir_envio,fax_dir_envio,codigo_portes,codigo_tipo_iva_portes,aplicar_en_totales_portes
			,importe_portes,cargo_financiero,realizado_por,codigo_agencia,identificador_banco,nombre_banco, domicilio_banco, sucursal_banco
			,codigo_postal_banco,poblacion_banco, provincia_banco, iban_code_banco, swift_code_banco, clave_entidad_banco, clave_sucursal_banco
			,digito_control_banco, cuenta_corriente_banco, telefono_cliente, fax_cliente, email_cliente, web_cliente,codigo_cliente,aplicar_cargo_financiero
			,codigo_centro_venta,criterio_conjuntacion,aplicar_cargo_financiero_dias,pdf_generado
			 FROM INSERTED
		 
	INSERT INTO eje_presup_c (empresa,ejercicio,codigo_tipo_documento,serie,numero,atencion_de,dias_validez,origen_web) 
	 SELECT empresa,ejercicio,codigo_tipo_documento,serie,numero,atencion_de,dias_validez,origen_web 
	 FROM INSERTED
	
	SET NOCOUNT OFF;

END

GO 

ALTER TRIGGER [dbo].[vv_venta_c_presup_bi]
   ON  [dbo].[vv_venta_c_presup]
WITH ENCRYPTION   INSTEAD OF INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	SET NOCOUNT ON;
	
	INSERT INTO eje_venta_c (
			empresa,ejercicio,periodo,codigo_tipo_documento,serie,codigo_tipo_cond_venta,numero,fecha,situacion,codigo_tercero
			,codigo_cliente,nombre_cliente,razon_social_cliente,nif_cliente,domicilio_cliente,codigo_postal_cliente
			,poblacion_cliente,provincia_cliente,codigo_forma_pago,codigo_Tabla_iva,codigo_representante,dto_comercial
			,dto_financiero,numero_copias,observaciones,observaciones_internas,adjuntos,codigo_pais_cliente,referencia
			,codigo_divisa,cambio_divisa,codigo_tarifa,identificador_dir_envio,alias_dir_envio,nombre_dir_envio,domicilio_dir_envio
			,sucursal_dir_envio,codigo_postal_dir_envio,poblacion_dir_envio,provincia_dir_envio,codigo_pais_dir_envio
			,telefono_dir_envio,movil_dir_envio,email_dir_envio,fax_dir_envio,codigo_portes,codigo_tipo_iva_portes,aplicar_en_totales_portes
			,importe_portes,cargo_financiero,realizado_por,codigo_agencia,identificador_banco,nombre_banco, domicilio_banco, sucursal_banco
			,codigo_postal_banco,poblacion_banco, provincia_banco, iban_code_banco, swift_code_banco, clave_entidad_banco, clave_sucursal_banco
			,digito_control_banco, cuenta_corriente_banco, telefono_cliente, fax_cliente, email_cliente, web_cliente,piramidal,aplicar_cargo_financiero
			,codigo_centro_venta,criterio_conjuntacion,aplicar_cargo_financiero_dias,pdf_generado)
	 SELECT empresa,ejercicio,periodo,codigo_tipo_documento,serie,codigo_tipo_cond_venta,numero,fecha,situacion,codigo_tercero
			,codigo_cliente,nombre_cliente,razon_social_cliente,nif_cliente,domicilio_cliente,codigo_postal_cliente
			,poblacion_cliente,provincia_cliente,codigo_forma_pago,codigo_Tabla_iva,codigo_representante,dto_comercial
			,dto_financiero,numero_copias,observaciones,observaciones_internas,adjuntos,codigo_pais_cliente,referencia
			,codigo_divisa,cambio_divisa,codigo_tarifa,identificador_dir_envio,alias_dir_envio,nombre_dir_envio,domicilio_dir_envio
			,sucursal_dir_envio,codigo_postal_dir_envio,poblacion_dir_envio,provincia_dir_envio,codigo_pais_dir_envio,telefono_dir_envio
			,movil_dir_envio,email_dir_envio,fax_dir_envio,codigo_portes,codigo_tipo_iva_portes,aplicar_en_totales_portes
			,importe_portes,cargo_financiero,realizado_por,codigo_agencia,identificador_banco,nombre_banco, domicilio_banco, sucursal_banco
			,codigo_postal_banco,poblacion_banco, provincia_banco, iban_code_banco, swift_code_banco, clave_entidad_banco, clave_sucursal_banco
			,digito_control_banco, cuenta_corriente_banco, telefono_cliente, fax_cliente, email_cliente, web_cliente,codigo_cliente,aplicar_cargo_financiero
			,codigo_centro_venta,criterio_conjuntacion,aplicar_cargo_financiero_dias,pdf_generado
			 FROM INSERTED
		 
	INSERT INTO eje_presup_c (empresa,ejercicio,codigo_tipo_documento,serie,numero,atencion_de,dias_validez,origen_web) 
	 SELECT empresa,ejercicio,codigo_tipo_documento,serie,numero,atencion_de,dias_validez,origen_web 
	 FROM INSERTED
	
	SET NOCOUNT OFF;

END

GO

ALTER TRIGGER [dbo].[vv_venta_c_presup_bu]
   ON  [dbo].[vv_venta_c_presup]
WITH ENCRYPTION   INSTEAD OF UPDATE
AS 
BEGIN
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
		,identificador_banco=i.identificador_banco,nombre_banco=i.nombre_banco, domicilio_banco=i.domicilio_banco, sucursal_banco=i.sucursal_banco
		,codigo_postal_banco=i.codigo_postal_banco,poblacion_banco=i.poblacion_banco, provincia_banco=i.provincia_banco, iban_code_banco=i.iban_code_banco
		,swift_code_banco=i.swift_code_banco, clave_entidad_banco=i.clave_entidad_banco, clave_sucursal_banco=i.clave_sucursal_banco
		,digito_control_banco=i.digito_control_banco, cuenta_corriente_banco=i.cuenta_corriente_banco
		,telefono_cliente=i.telefono_cliente, fax_cliente=i.fax_cliente, email_cliente=i.email_cliente, web_cliente=i.web_cliente,piramidal=i.codigo_cliente
		,aplicar_cargo_financiero=i.aplicar_cargo_financiero,codigo_centro_venta=i.codigo_centro_venta,criterio_conjuntacion=i.criterio_conjuntacion
		,aplicar_cargo_financiero_dias=i.aplicar_cargo_financiero_dias,pdf_generado=i.pdf_generado
		FROM eje_venta_c INNER JOIN inserted AS i ON eje_venta_c.sys_oid = i.sys_oid
						 INNER JOIN deleted AS d ON i.sys_oid = d.sys_oid
						 
						 
		UPDATE eje_presup_c set atencion_de=inserted.atencion_de,
			dias_validez=inserted.dias_validez,
			origen_web=inserted.origen_web
		FROM eje_presup_c INNER JOIN inserted ON eje_presup_c.sys_oid = inserted.sys_oid_presup
						 INNER JOIN deleted ON inserted.sys_oid_presup = deleted.sys_oid_presup
	
	SET NOCOUNT OFF;
END
