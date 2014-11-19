use vs_martinez
go 


	alter table emp_codigos_barras add subir_web dm_logico 
	
	GO
	
	ALTER TABLE [dbo].[emp_codigos_barras] ADD  CONSTRAINT [DF_emp_codigos_barras_subir_web]  DEFAULT ((1)) FOR [subir_web] 
	
	GO

	update emp_codigos_barras set subir_web = 0 
	
	GO
	
	ALTER TABLE [dbo].[emp_articulos] DROP CONSTRAINT [DF_emp_articulos_subir_web] 
	
	GO
	
	ALTER TABLE [dbo].[emp_articulos] ADD  CONSTRAINT [DF_emp_articulos_subir_web]  DEFAULT ((1)) FOR [subir_web] 
	
	GO 
	
	UPDATE emp_articulos SET subir_web = 0 

	GO 

	alter table emp_clientes add subir_web dm_logico default(1)
	go 


	update emp_clientes set subir_web = 0 ;
	
	GO 
	
	ALTER VIEW [dbo].[vf_emp_clientes]
	WITH ENCRYPTION AS
	SELECT     dbo.emp_terceros.nombre, dbo.emp_terceros.razon_social, dbo.emp_terceros.nif, dbo.emp_terceros.domicilio, dbo.emp_terceros.codigo_postal, 
						  dbo.emp_terceros.poblacion, dbo.emp_terceros.provincia, dbo.emp_terceros.telefono, dbo.emp_terceros.movil, dbo.emp_terceros.fax, dbo.emp_terceros.email, 
						  dbo.emp_terceros.web, dbo.emp_terceros.sys_oid AS sys_oid_terceros, dbo.emp_clientes.empresa, dbo.emp_clientes.codigo_tercero, dbo.emp_clientes.codigo, 
						  dbo.emp_clientes.activo, dbo.emp_clientes.riesgo_maximo, dbo.emp_clientes.riesgo_cyc, dbo.emp_clientes.riesgo_contable, 
						  dbo.emp_clientes.observaciones_riesgo, dbo.emp_clientes.bloqueado, dbo.emp_clientes.razon_bloqueado, dbo.emp_clientes.observaciones, 
						  dbo.emp_clientes.adjuntos, dbo.emp_clientes.fecha_creacion, dbo.emp_clientes.fecha_modificacion, dbo.emp_clientes.sys_logs, dbo.emp_clientes.sys_borrado, 
						  dbo.emp_clientes.sys_timestamp, dbo.emp_clientes.sys_oid, dbo.emp_clientes.codigo_grupo, dbo.emp_clientes.codigo_banco_cobro, 
						  dbo.emp_clientes.solo_tickets, dbo.emp_clientes.evolucion_credito, dbo.emp_clientes.evolucion_bdi, dbo.emp_clientes.tipo_cliente_bdi, 
						  dbo.emp_clientes.ventas_e_impagados, dbo.emp_clientes.margen_maniobra_riesgo, dbo.emp_clientes.codigo_zona, dbo.emp_clientes.codigo_gestor_cobros, 
						  dbo.emp_clientes.codigo_tipo_facturacion, dbo.emp_clientes.observaciones_bloqueo, dbo.emp_clientes.criterio_facturacion1, dbo.emp_clientes.criterio_facturacion2, 
						  dbo.emp_clientes.criterio_facturacion3, dbo.emp_clientes.activo_web, dbo.emp_clientes.usuario_web, dbo.emp_clientes.password_web, 
						  dbo.emp_terceros.codigo_pais, dbo.gen_paises.nombre AS nombre_pais, dbo.emp_clientes.excluir_ofertas, dbo.emp_clientes.observaciones_internas_bloqueo, 
						  dbo.emp_clientes.codigo_subzona, dbo.emp_clientes.codigo_almacen_habitual, dbo.emp_clientes.compensar_abonos, 
						  dbo.emp_gestor_cobros.descripcion AS descripcion_gestor_cobro, dbo.emp_clientes.codigo_ruta_reparto, dbo.emp_clientes.report_albaranes, 
						  dbo.emp_clientes.subir_web
	FROM         dbo.emp_clientes INNER JOIN
						  dbo.emp_terceros ON dbo.emp_clientes.empresa = dbo.emp_terceros.empresa AND dbo.emp_clientes.codigo_tercero = dbo.emp_terceros.codigo LEFT OUTER JOIN
						  dbo.emp_gestor_cobros ON dbo.emp_clientes.empresa = dbo.emp_gestor_cobros.empresa AND 
						  dbo.emp_clientes.codigo_gestor_cobros = dbo.emp_gestor_cobros.codigo LEFT OUTER JOIN
						  dbo.gen_paises ON dbo.emp_terceros.codigo_pais = dbo.gen_paises.codigo

	GO

	ALTER TRIGGER [dbo].[vf_emp_clientes_bi] 
	   ON  [dbo].[vf_emp_clientes]
	WITH ENCRYPTION   INSTEAD OF INSERT
	AS 
	BEGIN
		SET NOCOUNT ON
		IF ( SELECT codigo_tercero FROM inserted) IS NULL OR (SELECT codigo_tercero FROM inserted) = 0
			BEGIN
				DECLARE @pCodigo dm_char_corto
				DECLARE @pEmpresa dm_empresas
				SET @pEmpresa = (SELECT empresa FROM inserted)
				EXEC vs_proximo_numero_serie @pempresa, '', '', 'TERCEROS', null, 1, @pCodigo OUTPUT
				
				INSERT INTO emp_terceros ( empresa, codigo, nombre,razon_social,nif,domicilio,codigo_postal,poblacion,provincia,telefono,
							movil, fax, email,web) 
					SELECT [empresa],CONVERT(int,@pCodigo),nombre,razon_social,nif,domicilio,codigo_postal,poblacion,provincia,telefono,
							movil, fax, email,web 
					   FROM inserted
				
				INSERT INTO emp_clientes (empresa,codigo_tercero,codigo,activo,riesgo_maximo,riesgo_cyc,riesgo_contable,
						observaciones_riesgo,bloqueado,razon_bloqueado,observaciones,adjuntos,fecha_creacion,fecha_modificacion,
						codigo_grupo,codigo_banco_cobro,solo_tickets,evolucion_credito,evolucion_bdi,tipo_cliente_bdi,ventas_e_impagados,
						margen_maniobra_riesgo,codigo_zona,codigo_gestor_cobros,codigo_tipo_facturacion,observaciones_bloqueo,
						criterio_facturacion1,criterio_facturacion2,criterio_facturacion3,activo_web,usuario_web,password_web,
						excluir_ofertas, observaciones_internas_bloqueo,codigo_subzona,codigo_almacen_habitual,compensar_abonos,codigo_ruta_reparto,
						report_albaranes,subir_web) 
						SELECT empresa,CONVERT(int,@pCodigo),codigo,isnull(activo,0),riesgo_maximo,riesgo_cyc,riesgo_contable,
							observaciones_riesgo,ISNULL(bloqueado,0),razon_bloqueado,observaciones,adjuntos,fecha_creacion,fecha_modificacion,
							codigo_grupo,codigo_banco_cobro,ISNULL(solo_tickets,0),evolucion_credito,evolucion_bdi,tipo_cliente_bdi,ventas_e_impagados,
							margen_maniobra_riesgo,codigo_zona,codigo_gestor_cobros,codigo_tipo_facturacion,observaciones_bloqueo,
							criterio_facturacion1,criterio_facturacion2,criterio_facturacion3,ISNULL(activo_web,0),usuario_web,password_web,
							ISNULL(excluir_ofertas,0),observaciones_internas_bloqueo,codigo_subzona,codigo_almacen_habitual,ISNULL(compensar_abonos,0),codigo_ruta_reparto,
							report_albaranes,subir_web
						 FROM inserted
			END
		ELSE
			BEGIN
				UPDATE emp_terceros SET 
					nombre=i.nombre, 
					razon_social = i.razon_social, 
					nif=i.nif, 
					domicilio=i.domicilio, 
					codigo_postal=i.codigo_postal,
					poblacion=i.poblacion, 
					provincia=i.provincia, 
					telefono=i.telefono, 
					movil=i.movil, 
					fax =i.fax, 
					email=i.email, 
					web=i.web,
					es_cliente=1
				  FROM emp_terceros AS T INNER JOIN inserted AS i ON T.sys_oid = i.sys_oid_terceros
				  
				INSERT INTO emp_clientes (empresa,codigo_tercero,codigo,activo,riesgo_maximo,riesgo_cyc,riesgo_contable,
						observaciones_riesgo,bloqueado,razon_bloqueado,observaciones,adjuntos,fecha_creacion,fecha_modificacion,
						codigo_grupo,codigo_banco_cobro,solo_tickets,evolucion_credito,evolucion_bdi,tipo_cliente_bdi,ventas_e_impagados,
						margen_maniobra_riesgo,codigo_zona,codigo_gestor_cobros,codigo_tipo_facturacion,observaciones_bloqueo,
						criterio_facturacion1,criterio_facturacion2,criterio_facturacion3,activo_web,usuario_web,password_web,
						excluir_ofertas, observaciones_internas_bloqueo,codigo_subzona,codigo_almacen_habitual,compensar_abonos,codigo_ruta_reparto,
						report_albaranes,subir_web) 
						SELECT empresa,codigo_tercero,codigo,ISNULL(activo,0),riesgo_maximo,riesgo_cyc,riesgo_contable,
							observaciones_riesgo,ISNULL(bloqueado,0),razon_bloqueado,observaciones,adjuntos,fecha_creacion,fecha_modificacion,
							codigo_grupo,codigo_banco_cobro,ISNULL(solo_tickets,0),evolucion_credito,evolucion_bdi,tipo_cliente_bdi,ventas_e_impagados,
							margen_maniobra_riesgo,codigo_zona,codigo_gestor_cobros,codigo_tipo_facturacion,observaciones_bloqueo,
							criterio_facturacion1,criterio_facturacion2,criterio_facturacion3,ISNULL(activo_web,0),usuario_web,password_web,
							ISNULL(excluir_ofertas,0), observaciones_internas_bloqueo,codigo_subzona,codigo_almacen_habitual,ISNULL(compensar_abonos,0),codigo_ruta_reparto,
							report_albaranes,subir_web
						 FROM inserted
			END
	END

	GO 

	ALTER TRIGGER [dbo].[vf_emp_clientes_bu] 
	   ON  [dbo].[vf_emp_clientes]
	WITH ENCRYPTION   INSTEAD OF UPDATE
	AS 
	BEGIN
		SET NOCOUNT ON
		DECLARE @pCodigo_tercero dm_codigos_n
		DECLARE @pCodigo dm_char_corto
		SET @pCodigo_tercero = (SELECT codigo_tercero FROM inserted)
		IF UPDATE(codigo_tercero)
			BEGIN
				IF @pCodigo_tercero IS NULL OR @pCodigo_tercero = 0
					BEGIN
						DECLARE @pEmpresa dm_empresas
						SET @pEmpresa = (SELECT empresa FROM inserted)
						EXEC vs_proximo_numero_serie @pempresa, '', '', 'TERCEROS', null, 1, @pCodigo OUTPUT
						INSERT INTO emp_terceros ( empresa, codigo, nombre,razon_social,nif,domicilio,codigo_postal,poblacion,provincia,telefono,
						movil, fax, email,web,es_cliente) SELECT [empresa],CONVERT(int,@pCodigo),nombre,razon_social,nif,domicilio,codigo_postal,poblacion,provincia,telefono,
						movil, fax, email,web,1 FROM inserted
						SET @pCodigo_tercero = CONVERT(int,@pCodigo)
					END
			END	
		ELSE
			IF UPDATE(nombre) OR UPDATE(razon_social) OR UPDATE(nif) OR UPDATE(domicilio) OR  UPDATE(codigo_postal) OR  UPDATE(poblacion)
			 OR  UPDATE(provincia) OR  UPDATE(telefono) OR  UPDATE(movil) OR  UPDATE(fax) OR  UPDATE(email) OR UPDATE(web)
				UPDATE emp_terceros SET 
					nombre=i.nombre, 
					razon_social = i.razon_social, 
					nif=i.nif, 
					domicilio=i.domicilio, 
					codigo_postal=i.codigo_postal,
					poblacion=i.poblacion, 
					provincia=i.provincia, 
					telefono=i.telefono, 
					movil=i.movil, 
					fax =i.fax, 
					email=i.email, 
					web=i.web,
					es_cliente = 1
				FROM emp_terceros AS t INNER JOIN inserted as i ON t.sys_oid = i.sys_oid_terceros
		UPDATE emp_clientes SET 
			empresa=i.empresa,
			codigo_tercero= @pCodigo_tercero, --i.codigo_tercero,
			codigo=i.codigo,
			activo=ISNULL(i.activo,0),		
			riesgo_maximo=i.riesgo_maximo,
			riesgo_cyc=i.riesgo_cyc,
			riesgo_contable=i.riesgo_contable,
			observaciones_riesgo=i.observaciones_riesgo,
			bloqueado=ISNULL(i.bloqueado,0),
			razon_bloqueado=i.razon_bloqueado,
			observaciones=i.observaciones,
			adjuntos=i.adjuntos,
			fecha_creacion=i.fecha_creacion,
			fecha_modificacion=i.fecha_modificacion,
			codigo_grupo=i.codigo_grupo,
			codigo_banco_cobro=i.codigo_banco_cobro,
			solo_tickets=ISNULL(i.solo_tickets,0),
			evolucion_credito=i.evolucion_credito,
			evolucion_bdi=i.evolucion_bdi,
			tipo_cliente_bdi=i.tipo_cliente_bdi,
			ventas_e_impagados=i.ventas_e_impagados,
			margen_maniobra_riesgo=i.margen_maniobra_riesgo,
			codigo_zona=i.codigo_zona,
			codigo_gestor_cobros=i.codigo_gestor_cobros,
			codigo_tipo_facturacion=i.codigo_tipo_facturacion,
			observaciones_bloqueo=i.observaciones_bloqueo,
			criterio_facturacion1=i.criterio_facturacion1,
			criterio_facturacion2=i.criterio_facturacion2,
			criterio_facturacion3=i.criterio_facturacion3,
			activo_web=ISNULL(i.activo_web,0),
			usuario_web=i.usuario_web,
			password_web=i.password_web,
			excluir_ofertas=ISNULL(i.excluir_ofertas,0),
			observaciones_internas_bloqueo=i.observaciones_internas_bloqueo,
			codigo_subzona=i.codigo_subzona,
			codigo_almacen_habitual=i.codigo_almacen_habitual,
			compensar_abonos=ISNULL(i.compensar_abonos,0),
			codigo_ruta_reparto=i.codigo_ruta_reparto,
			report_albaranes=i.report_albaranes,
			subir_web=i.subir_web
		FROM emp_clientes AS C INNER JOIN inserted AS I on c.sys_oid = i.sys_oid
	END

	GO 

	ALTER VIEW [dbo].[vv_venta_c_alba] 
	WITH ENCRYPTION AS
	SELECT     dbo.eje_venta_c.empresa, dbo.eje_venta_c.ejercicio, dbo.eje_venta_c.periodo, dbo.eje_venta_c.codigo_tipo_documento, dbo.eje_venta_c.serie, 
						  dbo.eje_venta_c.codigo_tipo_cond_venta, dbo.eje_venta_c.numero, dbo.eje_venta_c.fecha, dbo.eje_venta_c.situacion, dbo.eje_venta_c.codigo_tercero, 
						  dbo.eje_venta_c.codigo_cliente, dbo.eje_venta_c.nombre_cliente, dbo.eje_venta_c.razon_social_cliente, dbo.eje_venta_c.nif_cliente, 
						  dbo.eje_venta_c.domicilio_cliente, dbo.eje_venta_c.codigo_postal_cliente, dbo.eje_venta_c.poblacion_cliente, dbo.eje_venta_c.provincia_cliente, 
						  dbo.eje_venta_c.codigo_forma_pago, dbo.eje_venta_c.codigo_tabla_iva, dbo.eje_venta_c.codigo_representante, dbo.eje_venta_c.dto_comercial, 
						  dbo.eje_venta_c.dto_financiero, dbo.eje_venta_c.numero_copias, dbo.eje_venta_c.observaciones, dbo.eje_venta_c.observaciones_internas, 
						  dbo.eje_venta_c.adjuntos, dbo.eje_venta_c.sys_logs, dbo.eje_venta_c.sys_borrado, dbo.eje_venta_c.sys_timestamp, dbo.eje_venta_c.sys_oid, 
						  dbo.eje_venta_c.codigo_pais_cliente, dbo.eje_alba_c.su_pedido, dbo.eje_alba_c.sys_oid AS sys_oid_alba, dbo.eje_venta_c.referencia, 
						  dbo.eje_venta_t.cuota_dto_comercial, dbo.eje_venta_t.cuota_dto_financiero, dbo.eje_venta_t.base_imponible, dbo.eje_venta_t.cuota_iva, dbo.eje_venta_t.cuota_re, 
						  dbo.eje_venta_t.neto_lineas, dbo.eje_venta_t.total, dbo.eje_venta_c.codigo_divisa, dbo.eje_venta_c.cambio_divisa, dbo.eje_venta_c.codigo_tarifa, 
						  dbo.eje_venta_c.identificador_dir_envio, dbo.eje_venta_c.alias_dir_envio, dbo.eje_venta_c.nombre_dir_envio, dbo.eje_venta_c.domicilio_dir_envio, 
						  dbo.eje_venta_c.sucursal_dir_envio, dbo.eje_venta_c.codigo_postal_dir_envio, dbo.eje_venta_c.poblacion_dir_envio, dbo.eje_venta_c.provincia_dir_envio, 
						  dbo.eje_venta_c.codigo_pais_dir_envio, dbo.eje_venta_c.telefono_dir_envio, dbo.eje_venta_c.movil_dir_envio, dbo.eje_venta_c.email_dir_envio, 
						  dbo.eje_venta_c.fax_dir_envio, dbo.eje_venta_c.codigo_portes, dbo.eje_venta_c.codigo_tipo_iva_portes, dbo.eje_venta_c.aplicar_en_totales_portes, 
						  dbo.eje_venta_c.importe_portes, dbo.eje_venta_c.cargo_financiero, dbo.eje_venta_c.realizado_por, dbo.eje_venta_c.codigo_agencia, dbo.eje_venta_c.piramidal, 
						  dbo.eje_venta_c.aplicar_cargo_financiero, dbo.eje_venta_c.codigo_centro_venta, dbo.eje_venta_c.criterio_conjuntacion, 
						  dbo.eje_venta_c.aplicar_cargo_financiero_dias, dbo.eje_alba_c.albaran_retenido, dbo.eje_alba_c.motivo_retencion, dbo.eje_venta_c.compensar_abono, 
						  dbo.eje_alba_c.codigo_ruta_reparto, dbo.eje_venta_c.pdf_generado
	FROM         dbo.eje_venta_c INNER JOIN
						  dbo.eje_alba_c ON dbo.eje_venta_c.empresa = dbo.eje_alba_c.empresa AND dbo.eje_venta_c.ejercicio = dbo.eje_alba_c.ejercicio AND 
						  dbo.eje_venta_c.codigo_tipo_documento = dbo.eje_alba_c.codigo_tipo_documento AND dbo.eje_venta_c.serie = dbo.eje_alba_c.serie AND 
						  dbo.eje_venta_c.numero = dbo.eje_alba_c.numero LEFT OUTER JOIN
						  dbo.eje_venta_t ON dbo.eje_venta_c.empresa = dbo.eje_venta_t.empresa AND dbo.eje_venta_c.ejercicio = dbo.eje_venta_t.ejercicio AND 
						  dbo.eje_venta_c.codigo_tipo_documento = dbo.eje_venta_t.codigo_tipo_documento AND dbo.eje_venta_c.serie = dbo.eje_venta_t.serie AND 
						  dbo.eje_venta_c.numero = dbo.eje_venta_t.numero
	WHERE     (dbo.eje_venta_c.codigo_tipo_documento = 'AV')

	GO

	ALTER TRIGGER [dbo].[vv_venta_c_alba_bi]
	   ON  [dbo].[vv_venta_c_alba]
	WITH ENCRYPTION   INSTEAD OF INSERT
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
				,criterio_conjuntacion,aplicar_cargo_financiero_dias,compensar_abono,pdf_generado)
		 SELECT empresa,ejercicio,periodo,codigo_tipo_documento,serie,codigo_tipo_cond_venta,numero,fecha,situacion,codigo_tercero
				,codigo_cliente,nombre_cliente,razon_social_cliente,nif_cliente,domicilio_cliente,codigo_postal_cliente
				,poblacion_cliente,provincia_cliente,codigo_forma_pago,codigo_Tabla_iva,codigo_representante,dto_comercial
				,dto_financiero,numero_copias,observaciones,observaciones_internas,adjuntos,codigo_pais_cliente,referencia
				,codigo_divisa,cambio_divisa,codigo_tarifa,identificador_dir_envio,alias_dir_envio,nombre_dir_envio,domicilio_dir_envio
				,sucursal_dir_envio,codigo_postal_dir_envio,poblacion_dir_envio,provincia_dir_envio,codigo_pais_dir_envio,telefono_dir_envio
				,movil_dir_envio,email_dir_envio,fax_dir_envio,codigo_portes,codigo_tipo_iva_portes,aplicar_en_totales_portes
				,importe_portes,cargo_financiero,realizado_por,codigo_agencia,codigo_cliente,aplicar_cargo_financiero,codigo_centro_venta
				,criterio_conjuntacion,aplicar_cargo_financiero_dias,compensar_abono,pdf_generado
				 FROM INSERTED
		INSERT INTO eje_alba_c (empresa,ejercicio,codigo_tipo_documento,serie,numero,su_pedido,albaran_retenido,motivo_retencion,codigo_ruta_reparto)
		 SELECT empresa,ejercicio,codigo_tipo_documento,serie,numero,su_pedido,albaran_retenido,motivo_retencion,codigo_ruta_reparto FROM INSERTED
		
		SET NOCOUNT OFF;
	END

	GO 

	ALTER TRIGGER [dbo].[vv_venta_c_alba_bu]
	   ON  [dbo].[vv_venta_c_alba]
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
			,piramidal=i.codigo_cliente,aplicar_cargo_financiero=i.aplicar_cargo_financiero,codigo_centro_venta=i.codigo_centro_venta
			,criterio_conjuntacion=i.criterio_conjuntacion,aplicar_cargo_financiero_dias=i.aplicar_cargo_financiero_dias,compensar_abono=i.compensar_abono
			,pdf_generado=i.pdf_generado
			FROM eje_venta_c INNER JOIN inserted AS i ON eje_venta_c.sys_oid = i.sys_oid
							 INNER JOIN deleted AS d ON i.sys_oid = d.sys_oid
			
		UPDATE eje_alba_c set su_pedido=i.su_pedido,albaran_retenido=i.albaran_retenido,motivo_retencion=i.motivo_retencion,codigo_ruta_reparto=i.codigo_ruta_reparto
			FROM eje_alba_c
			 INNER JOIN inserted AS i ON eje_alba_c.sys_oid = i.sys_oid_alba
			 INNER JOIN deleted ON i.sys_oid_alba = deleted.sys_oid_alba
		
		SET NOCOUNT OFF;
	END

	GO 

	ALTER VIEW [dbo].[vv_venta_c_factura]
	WITH ENCRYPTION AS
	SELECT     dbo.eje_venta_c.empresa, dbo.eje_venta_c.ejercicio, dbo.eje_venta_c.periodo, dbo.eje_venta_c.codigo_tipo_documento, dbo.eje_venta_c.serie, 
						  dbo.eje_venta_c.codigo_tipo_cond_venta, dbo.eje_venta_c.numero, dbo.eje_venta_c.fecha, dbo.eje_venta_c.situacion, dbo.eje_venta_c.codigo_tercero, 
						  dbo.eje_venta_c.codigo_cliente, dbo.eje_venta_c.nombre_cliente, dbo.eje_venta_c.razon_social_cliente, dbo.eje_venta_c.nif_cliente, 
						  dbo.eje_venta_c.domicilio_cliente, dbo.eje_venta_c.codigo_postal_cliente, dbo.eje_venta_c.poblacion_cliente, dbo.eje_venta_c.provincia_cliente, 
						  dbo.eje_venta_c.codigo_forma_pago, dbo.eje_venta_c.codigo_tabla_iva, dbo.eje_venta_c.codigo_representante, dbo.eje_venta_c.dto_comercial, 
						  dbo.eje_venta_c.dto_financiero, dbo.eje_venta_c.numero_copias, dbo.eje_venta_c.observaciones, dbo.eje_venta_c.observaciones_internas, 
						  dbo.eje_venta_c.adjuntos, dbo.eje_venta_c.sys_logs, dbo.eje_venta_c.sys_borrado, dbo.eje_venta_c.sys_timestamp, dbo.eje_venta_c.codigo_pais_cliente, 
						  dbo.eje_venta_c.referencia, dbo.eje_factura_c.contabilizada, dbo.eje_venta_c.sys_oid, dbo.eje_factura_c.sys_oid AS sys_oid_factura, 
						  dbo.eje_venta_t.cuota_dto_comercial, dbo.eje_venta_t.cuota_dto_financiero, dbo.eje_venta_t.base_imponible, dbo.eje_venta_t.cuota_iva, dbo.eje_venta_t.cuota_re, 
						  dbo.eje_venta_t.neto_lineas, dbo.eje_venta_t.total, dbo.eje_venta_c.codigo_divisa, dbo.eje_venta_c.cambio_divisa, dbo.eje_venta_c.codigo_tarifa, 
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
						  dbo.eje_venta_c.pdf_generado
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
	WITH ENCRYPTION   INSTEAD OF INSERT
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
				 
				 
		INSERT INTO eje_factura_c (empresa,ejercicio,codigo_tipo_documento,serie,numero,contabilizada,fecha_devengo,identificador_dir_pago,alias_dir_pago,sucursal_dir_pago,nombre_dir_pago, domicilio_dir_pago, codigo_postal_dir_pago, poblacion_dir_pago, provincia_dir_pago, codigo_pais_dir_pago, telefono_dir_pago, movil_dir_pago, email_dir_pago, fax_dir_pago) 
			SELECT empresa,ejercicio,codigo_tipo_documento,serie,numero,contabilizada,fecha_devengo,identificador_dir_pago,alias_dir_pago,sucursal_dir_pago,nombre_dir_pago, domicilio_dir_pago, codigo_postal_dir_pago, poblacion_dir_pago, provincia_dir_pago, codigo_pais_dir_pago, telefono_dir_pago, movil_dir_pago, email_dir_pago, fax_dir_pago 
			  FROM INSERTED
		
		SET NOCOUNT OFF;

	END
	
	GO 
	
	ALTER TRIGGER [dbo].[vv_venta_c_factura_bu]
	   ON  [dbo].[vv_venta_c_factura]
	WITH ENCRYPTION   INSTEAD OF UPDATE
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
			fax_dir_pago=inserted.fax_dir_pago
			FROM eje_factura_c
			 INNER JOIN inserted ON eje_factura_c.sys_oid = inserted.sys_oid_factura
			 INNER JOIN deleted ON inserted.sys_oid_factura = deleted.sys_oid_factura
		
		SET NOCOUNT OFF;
	END

	GO 

	ALTER VIEW [dbo].[vv_venta_c_pedido]
	WITH ENCRYPTION AS
	SELECT     dbo.eje_venta_c.empresa, dbo.eje_venta_c.ejercicio, dbo.eje_venta_c.periodo, dbo.eje_venta_c.codigo_tipo_documento, dbo.eje_venta_c.serie, 
						  dbo.eje_venta_c.codigo_tipo_cond_venta, dbo.eje_venta_c.numero, dbo.eje_venta_c.fecha, dbo.eje_venta_c.situacion, dbo.eje_venta_c.codigo_tercero, 
						  dbo.eje_venta_c.codigo_cliente, dbo.eje_venta_c.nombre_cliente, dbo.eje_venta_c.razon_social_cliente, dbo.eje_venta_c.nif_cliente, 
						  dbo.eje_venta_c.domicilio_cliente, dbo.eje_venta_c.codigo_postal_cliente, dbo.eje_venta_c.poblacion_cliente, dbo.eje_venta_c.provincia_cliente, 
						  dbo.eje_venta_c.codigo_forma_pago, dbo.eje_venta_c.codigo_tabla_iva, dbo.eje_venta_c.codigo_representante, dbo.eje_venta_c.dto_comercial, 
						  dbo.eje_venta_c.dto_financiero, dbo.eje_venta_c.numero_copias, dbo.eje_venta_c.observaciones, dbo.eje_venta_c.observaciones_internas, 
						  dbo.eje_venta_c.adjuntos, dbo.eje_venta_c.sys_logs, dbo.eje_venta_c.sys_borrado, dbo.eje_venta_c.sys_timestamp, dbo.eje_venta_c.sys_oid, 
						  dbo.eje_venta_c.codigo_pais_cliente, dbo.eje_venta_c.referencia, dbo.eje_venta_c.codigo_divisa, dbo.eje_venta_c.cambio_divisa, dbo.eje_pedido_c.su_pedido, 
						  dbo.eje_pedido_c.fecha_entrega, dbo.eje_pedido_c.sys_oid AS sys_oid_pedido, dbo.eje_venta_c.codigo_tarifa, dbo.eje_venta_c.identificador_dir_envio, 
						  dbo.eje_venta_c.alias_dir_envio, dbo.eje_venta_c.nombre_dir_envio, dbo.eje_venta_c.domicilio_dir_envio, dbo.eje_venta_c.sucursal_dir_envio, 
						  dbo.eje_venta_c.codigo_postal_dir_envio, dbo.eje_venta_c.poblacion_dir_envio, dbo.eje_venta_c.provincia_dir_envio, dbo.eje_venta_c.codigo_pais_dir_envio, 
						  dbo.eje_venta_c.telefono_dir_envio, dbo.eje_venta_c.movil_dir_envio, dbo.eje_venta_c.email_dir_envio, dbo.eje_venta_c.fax_dir_envio, 
						  dbo.eje_venta_c.codigo_portes, dbo.eje_venta_c.codigo_tipo_iva_portes, dbo.eje_venta_c.aplicar_en_totales_portes, dbo.eje_venta_c.importe_portes, 
						  dbo.eje_venta_c.cargo_financiero, dbo.eje_venta_c.realizado_por, dbo.eje_venta_c.codigo_agencia, dbo.eje_venta_c.piramidal, 
						  dbo.eje_venta_c.aplicar_cargo_financiero, dbo.eje_venta_c.codigo_centro_venta, dbo.eje_venta_t.total, dbo.eje_venta_c.criterio_conjuntacion, 
						  dbo.eje_venta_c.aplicar_cargo_financiero_dias, dbo.eje_venta_c.compensar_abono, dbo.eje_pedido_c.codigo_ruta_reparto, dbo.eje_venta_c.pdf_generado
	FROM         dbo.eje_pedido_c INNER JOIN
						  dbo.eje_venta_c ON dbo.eje_pedido_c.empresa = dbo.eje_venta_c.empresa AND dbo.eje_pedido_c.ejercicio = dbo.eje_venta_c.ejercicio AND 
						  dbo.eje_pedido_c.codigo_tipo_documento = dbo.eje_venta_c.codigo_tipo_documento AND dbo.eje_pedido_c.serie = dbo.eje_venta_c.serie AND 
						  dbo.eje_pedido_c.numero = dbo.eje_venta_c.numero LEFT OUTER JOIN
						  dbo.eje_venta_t ON dbo.eje_venta_c.empresa = dbo.eje_venta_t.empresa AND dbo.eje_venta_c.ejercicio = dbo.eje_venta_t.ejercicio AND 
						  dbo.eje_venta_c.codigo_tipo_documento = dbo.eje_venta_t.codigo_tipo_documento AND dbo.eje_venta_c.serie = dbo.eje_venta_t.serie AND 
						  dbo.eje_venta_c.numero = dbo.eje_venta_t.numero
	WHERE     (dbo.eje_venta_c.codigo_tipo_documento = 'PV')

	GO

	ALTER TRIGGER [dbo].[vv_venta_c_pedido_bi]
	   ON  [dbo].[vv_venta_c_pedido]
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
				,importe_portes,cargo_financiero,realizado_por,codigo_agencia,piramidal,aplicar_cargo_financiero,codigo_centro_venta
				,criterio_conjuntacion,aplicar_cargo_financiero_dias,compensar_abono,pdf_generado)
		 SELECT empresa,ejercicio,periodo,codigo_tipo_documento,serie,codigo_tipo_cond_venta,numero,fecha,situacion,codigo_tercero
				,codigo_cliente,nombre_cliente,razon_social_cliente,nif_cliente,domicilio_cliente,codigo_postal_cliente
				,poblacion_cliente,provincia_cliente,codigo_forma_pago,codigo_Tabla_iva,codigo_representante,dto_comercial
				,dto_financiero,numero_copias,observaciones,observaciones_internas,adjuntos,codigo_pais_cliente,referencia
				,codigo_divisa,cambio_divisa,codigo_tarifa,identificador_dir_envio,alias_dir_envio,nombre_dir_envio,domicilio_dir_envio
				,sucursal_dir_envio,codigo_postal_dir_envio,poblacion_dir_envio,provincia_dir_envio,codigo_pais_dir_envio,telefono_dir_envio
				,movil_dir_envio,email_dir_envio,fax_dir_envio,codigo_portes,codigo_tipo_iva_portes,aplicar_en_totales_portes
				,importe_portes,cargo_financiero,realizado_por,codigo_agencia,codigo_cliente,aplicar_cargo_financiero,codigo_centro_venta
				,criterio_conjuntacion,aplicar_cargo_financiero_dias,compensar_abono,pdf_generado
				 FROM INSERTED
		INSERT INTO eje_pedido_c (empresa,ejercicio,codigo_tipo_documento,serie,numero,su_pedido,fecha_entrega,codigo_ruta_reparto)
		 SELECT empresa,ejercicio,codigo_tipo_documento,serie,numero,su_pedido,fecha_entrega,codigo_ruta_reparto FROM INSERTED
		
		SET NOCOUNT OFF;

	END

	GO 

	ALTER TRIGGER [dbo].[vv_venta_c_pedido_bu]
	   ON  [dbo].[vv_venta_c_pedido]
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
			,piramidal=i.codigo_cliente,aplicar_cargo_financiero=i.aplicar_cargo_financiero,codigo_centro_venta=i.codigo_centro_venta
			,criterio_conjuntacion=i.criterio_conjuntacion,aplicar_cargo_financiero_dias=i.aplicar_cargo_financiero_dias,compensar_abono=i.compensar_abono
			,pdf_generado=i.pdf_generado
			FROM eje_venta_c INNER JOIN inserted AS i ON eje_venta_c.sys_oid = i.sys_oid
							 INNER JOIN deleted AS d ON i.sys_oid = d.sys_oid
		UPDATE eje_pedido_c set 
			su_pedido=inserted.su_pedido, 
			fecha_entrega=inserted.fecha_entrega,
			codigo_ruta_reparto = inserted.codigo_ruta_reparto
		FROM eje_pedido_c 
			INNER JOIN inserted ON eje_pedido_c.sys_oid = inserted.sys_oid_pedido
			INNER JOIN deleted ON inserted.sys_oid_pedido = deleted.sys_oid_pedido
		
		SET NOCOUNT OFF;
	END

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
						  dbo.eje_venta_c.aplicar_cargo_financiero_dias, dbo.eje_venta_c.pdf_generado
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
			 
		INSERT INTO eje_presup_c (empresa,ejercicio,codigo_tipo_documento,serie,numero,atencion_de,dias_validez) SELECT empresa,ejercicio,codigo_tipo_documento,serie,numero,atencion_de,dias_validez FROM INSERTED
		
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
			UPDATE eje_presup_c set atencion_de=inserted.atencion_de,dias_validez=inserted.dias_validez
			FROM eje_presup_c INNER JOIN inserted ON eje_presup_c.sys_oid = inserted.sys_oid_presup
							 INNER JOIN deleted ON inserted.sys_oid_presup = deleted.sys_oid_presup
		
		SET NOCOUNT OFF;
	END

	GO 
	
