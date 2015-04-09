use vs_perello
go 

/*
ALTER TABLE emp_clientes ADD codigo_destino_directo dm_codigos_c,
	codigo_agencia_directo dm_codigos_c,
	codigo_destino_indirecto dm_codigos_c,
	codigo_agencia_indirecto dm_codigos_c
GO 

ALTER TABLE emp_clientes  WITH NOCHECK ADD  CONSTRAINT FK_emp_clientes_emp_destinos_directos FOREIGN KEY([empresa], [codigo_destino_directo])
REFERENCES [dbo].[emp_destinos] ([empresa], [codigo])
GO

ALTER TABLE emp_clientes CHECK CONSTRAINT FK_emp_clientes_emp_destinos_directos
GO


ALTER TABLE emp_clientes  WITH NOCHECK ADD  CONSTRAINT FK_emp_clientes_emp_agencias_directos FOREIGN KEY([empresa], [codigo_agencia_directo])
REFERENCES [dbo].[emp_agencias] ([empresa], [codigo])
GO

ALTER TABLE emp_clientes CHECK CONSTRAINT FK_emp_clientes_emp_agencias_directos
GO

ALTER TABLE emp_clientes  WITH NOCHECK ADD  CONSTRAINT FK_emp_clientes_emp_destinos_indirectos FOREIGN KEY([empresa], [codigo_destino_indirecto])
REFERENCES [dbo].[emp_destinos] ([empresa], [codigo])
GO

ALTER TABLE emp_clientes CHECK CONSTRAINT FK_emp_clientes_emp_destinos_indirectos
GO


ALTER TABLE emp_clientes  WITH NOCHECK ADD  CONSTRAINT FK_emp_clientes_emp_agencias_indirectos FOREIGN KEY([empresa], [codigo_agencia_indirecto])
REFERENCES [dbo].[emp_agencias] ([empresa], [codigo])
GO

ALTER TABLE emp_clientes CHECK CONSTRAINT FK_emp_clientes_emp_agencias_indirectos
GO

GO

ALTER VIEW [dbo].[vf_emp_clientes_completo]
AS
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
          dbo.emp_terceros.codigo_pais, dbo.emp_clientes.excluir_ofertas, dbo.emp_clientes.observaciones_internas_bloqueo, 
          dbo.emp_clientes.codigo_subzona, dbo.emp_clientes.codigo_almacen_habitual, dbo.emp_clientes.compensar_abonos, 
          dbo.emp_clientes.codigo_ruta_reparto, dbo.emp_clientes.report_albaranes, dbo.emp_clientes.subir_web,dbo.emp_clientes.tarifa_reducida,
          dbo.emp_clientes.aceptada_domiciliacion, dbo.emp_clientes_cond_venta.dia_pago1, dbo.emp_clientes_cond_venta.dia_pago2, dbo.emp_clientes_cond_venta.dia_pago3,
          dbo.emp_clientes_cond_venta.vacaciones_desde, dbo.emp_clientes_cond_venta.vacaciones_hasta, dbo.emp_clientes_cond_venta.dto_lineas_1, dbo.emp_clientes_cond_venta.dto_lineas_2,
          dbo.emp_clientes_cond_venta.descuento_comercial, dbo.emp_clientes_cond_venta.descuento_financiero, dbo.emp_clientes_cond_venta.codigo_tarifa, dbo.emp_clientes_cond_venta.codigo_forma_pago,
          dbo.emp_clientes_cond_venta.no_agrupar_albaranes, dbo.emp_clientes_cond_venta.facturacion_mensual, dbo.emp_clientes_cond_venta.albaran_valorado, 
          dbo.emp_clientes_cond_venta.numero_copias_albaran, dbo.emp_clientes_cond_venta.numero_copias_factura, dbo.emp_clientes_cond_venta.codigo_tabla_iva,
          dbo.emp_clientes_cond_venta.codigo_representante, dbo.emp_clientes_cond_venta.predeterminada, dbo.emp_clientes_cond_venta.codigo_divisa, dbo.emp_clientes_cond_venta.agrupar_por_dir_envio,
          dbo.emp_clientes_cond_venta.porcentaje_irpf, dbo.emp_clientes_cond_venta.enviar_factura_por_fax, dbo.emp_clientes_cond_venta.enviar_factura_por_email,
          dbo.eje_clientes_cond_venta_cuentas.ejercicio, dbo.eje_clientes_cond_venta_cuentas.subcuenta, dbo.eje_clientes_cond_venta_cuentas.subcuenta_efectos, 
          dbo.eje_clientes_cond_venta_cuentas.subcuenta_impagados, dbo.eje_clientes_cond_venta_cuentas.subcuenta_riesgo, dbo.eje_clientes_cond_venta_cuentas.subcuenta_divisas, 
          dbo.eje_clientes_cond_venta_cuentas.subcuenta_retenciones, dbo.emp_clientes.observaciones_albaran, dbo.emp_clientes.observaciones_factura,
		  dbo.emp_clientes.su_codigo_proveedor, dbo.emp_clientes.codigo_ean, dbo.eje_clientes_cond_venta_cuentas.subcuenta_ventas, dbo.emp_clientes.diario,
		  emp_clientes.codigo_destino_directo, emp_clientes.codigo_agencia_directo, emp_clientes.codigo_destino_indirecto, emp_clientes.codigo_agencia_indirecto
FROM dbo.emp_clientes
	INNER JOIN dbo.emp_terceros ON dbo.emp_clientes.empresa = dbo.emp_terceros.empresa 
		AND dbo.emp_clientes.codigo_tercero = dbo.emp_terceros.codigo
	LEFT OUTER JOIN dbo.emp_clientes_cond_venta ON dbo.emp_clientes_cond_venta.empresa = dbo.emp_clientes.empresa
		AND dbo.emp_clientes_cond_venta.codigo_cliente = dbo.emp_clientes.codigo
		AND dbo.emp_clientes_cond_venta.codigo_tipo_cond_venta = '1'
	LEFT OUTER JOIN dbo.eje_clientes_cond_venta_cuentas ON dbo.eje_clientes_cond_venta_cuentas.empresa = dbo.emp_clientes_cond_venta.empresa
		AND dbo.eje_clientes_cond_venta_cuentas.codigo_cliente = dbo.emp_clientes_cond_venta.codigo_cliente
		AND dbo.eje_clientes_cond_venta_cuentas.codigo_tipo_cond_venta = dbo.emp_clientes_cond_venta.codigo_tipo_cond_venta


GO

ALTER TRIGGER [dbo].[vf_emp_clientes_completo_bi] 
   ON  [dbo].[vf_emp_clientes_completo]
   INSTEAD OF INSERT
AS 
BEGIN
	SET NOCOUNT OFF;
	DECLARE @pCodigo dm_char_corto
	DECLARE @pEmpresa dm_empresas
	DECLARE @pcodigo_tercero dm_codigos_n
	DECLARE @pSysoid dm_oid
	
	DECLARE insertados CURSOR LOCAL FOR 
		SELECT codigo,codigo_tercero,empresa 
		  FROM inserted
		  
	OPEN insertados
	FETCH NEXT FROM insertados INTO @pcodigo,@pCodigo_Tercero,@pempresa
	WHILE @@FETCH_STATUS = 0
	BEGIN
	IF @pcodigo_tercero IS NULL OR @pcodigo_tercero  = 0
		BEGIN
		
			EXEC vs_proximo_numero_serie @pempresa, '', '', 'TERCEROS', null, 1, @pcodigo_tercero OUTPUT
			
			INSERT INTO emp_terceros ( empresa, codigo, nombre,razon_social,nif,domicilio,codigo_postal,poblacion,provincia,codigo_pais,telefono,
						movil, fax, email,web,es_cliente) 
				SELECT empresa,CONVERT(int,@pcodigo_tercero),nombre,razon_social,nif,domicilio,codigo_postal,poblacion,provincia,codigo_pais,telefono,
						movil, fax, email,web,1
				  FROM inserted 
				 WHERE inserted.empresa = @pEmpresa
				   AND inserted.codigo = @pCodigo
		END
	ELSE
		BEGIN		
			UPDATE emp_terceros SET nombre=i.nombre, razon_social = i.razon_social, nif=i.nif, domicilio=i.domicilio, codigo_postal=i.codigo_postal,
				poblacion=i.poblacion, provincia=i.provincia, telefono=i.telefono, movil=i.movil, fax =i.fax, email=i.email, web=i.web,
				codigo_pais=i.codigo_pais
			  FROM emp_terceros AS T 
				INNER JOIN inserted AS i ON T.sys_oid = i.sys_oid_terceros
			 WHERE i.empresa = @pEmpresa
			   AND i.codigo = @pCodigo
		END
		
		INSERT INTO emp_clientes (empresa,codigo_tercero,codigo,activo,riesgo_maximo,riesgo_cyc,riesgo_contable,observaciones_riesgo,bloqueado,razon_bloqueado,observaciones,adjuntos, 
			fecha_creacion,fecha_modificacion,codigo_grupo,codigo_banco_cobro,solo_tickets,evolucion_bdi, evolucion_credito,tipo_cliente_bdi,ventas_e_impagados,margen_maniobra_riesgo,
			codigo_zona,codigo_gestor_cobros,codigo_tipo_facturacion,observaciones_bloqueo,criterio_facturacion1,criterio_facturacion2,criterio_facturacion3,activo_web,
			usuario_web,password_web,excluir_ofertas,observaciones_internas_bloqueo,codigo_subzona,codigo_almacen_habitual,compensar_abonos,codigo_ruta_reparto,report_albaranes,
			subir_web,aceptada_domiciliacion,observaciones_albaran, observaciones_factura, su_codigo_proveedor,codigo_ean,diario,
			codigo_destino_directo, codigo_agencia_directo, codigo_destino_indirecto, codigo_agencia_indirecto) 
		SELECT empresa,CONVERT(int,@pcodigo_tercero),codigo, activo, riesgo_maximo,riesgo_cyc,riesgo_contable,observaciones_riesgo,bloqueado,razon_bloqueado,observaciones,adjuntos, 
			fecha_creacion,fecha_modificacion,codigo_grupo,codigo_banco_cobro,solo_tickets,evolucion_bdi, evolucion_credito,tipo_cliente_bdi,ventas_e_impagados,margen_maniobra_riesgo,
			codigo_zona,codigo_gestor_cobros,codigo_tipo_facturacion,observaciones_bloqueo,criterio_facturacion1,criterio_facturacion2,criterio_facturacion3,activo_web,
			usuario_web,password_web,excluir_ofertas,observaciones_internas_bloqueo,codigo_subzona,codigo_almacen_habitual,compensar_abonos,codigo_ruta_reparto,report_albaranes,
			subir_web,aceptada_domiciliacion, observaciones_albaran, observaciones_factura, su_codigo_proveedor,codigo_ean,diario,
			codigo_destino_directo, codigo_agencia_directo, codigo_destino_indirecto, codigo_agencia_indirecto
		 FROM inserted 
		WHERE inserted.empresa = @pEmpresa
			  AND inserted.codigo = @pCodigo
		
		INSERT INTO emp_clientes_cond_venta (empresa, codigo_cliente, codigo_tipo_cond_venta, predeterminada, dia_pago1,dia_pago2,dia_pago3,vacaciones_desde,vacaciones_hasta,
			dto_lineas_1,dto_lineas_2, descuento_comercial, descuento_financiero, codigo_tarifa, no_agrupar_albaranes, facturacion_mensual, albaran_valorado, numero_copias_albaran,
			numero_copias_factura, codigo_tabla_iva, codigo_representante, codigo_divisa, agrupar_por_dir_envio,porcentaje_irpf,enviar_factura_por_email,enviar_factura_por_fax,
			codigo_forma_pago)
			SELECT empresa, codigo, '1', 1, dia_pago1,dia_pago2,dia_pago3,vacaciones_desde,vacaciones_hasta,
				dto_lineas_1,dto_lineas_2, descuento_comercial, descuento_financiero, codigo_tarifa, no_agrupar_albaranes, facturacion_mensual, albaran_valorado, numero_copias_albaran,
				numero_copias_factura, codigo_tabla_iva, codigo_representante, codigo_divisa, agrupar_por_dir_envio,porcentaje_irpf,enviar_factura_por_email,enviar_factura_por_fax,
				codigo_forma_pago
			  FROM inserted 
			 WHERE inserted.empresa = @pEmpresa
			   AND inserted.codigo = @pCodigo
			  
		INSERT INTO eje_clientes_cond_venta_cuentas (empresa, ejercicio, codigo_cliente, codigo_tipo_cond_venta, subcuenta, subcuenta_efectos, subcuenta_impagados, subcuenta_riesgo,
			subcuenta_divisas, subcuenta_retenciones, subcuenta_ventas)
			SELECT empresa, ejercicio, codigo, '1', subcuenta, subcuenta_efectos, subcuenta_impagados, subcuenta_riesgo,
				subcuenta_divisas, subcuenta_retenciones, subcuenta_ventas
			  FROM inserted
			 WHERE inserted.empresa = @pEmpresa
			   AND inserted.codigo = @pCodigo
		
		FETCH NEXT FROM insertados INTO @pcodigo,@pCodigo_Tercero,@pempresa
		
	END
	
	CLOSE insertados
	DEALLOCATE insertados
END

GO
ALTER TRIGGER [dbo].[vf_emp_clientes_completo_bu] 
   ON  [dbo].[vf_emp_clientes_completo]
   INSTEAD OF UPDATE
AS 
BEGIN
	SET NOCOUNT ON
	DECLARE @pCodigo_tercero dm_codigos_n
	DECLARE @pCodigo dm_char_corto
	DECLARE @pEmpresa dm_empresas
	DECLARE @pSysOid dm_oid
	DECLARE @pCodigoCliente dm_codigos_n

	DECLARE actualizados CURSOR LOCAL FOR 
	SELECT codigo_tercero,sys_oid,empresa FROM inserted
	OPEN actualizados
	FETCH NEXT FROM actualizados INTO @pcodigo_tercero,@psysoid,@pempresa
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		--SET @pCodigo_tercero = (SELECT codigo_tercero FROM inserted)
		IF UPDATE(codigo_tercero)
			BEGIN
				IF @pCodigo_tercero IS NULL OR @pCodigo_tercero = 0
					BEGIN
						--DECLARE @pEmpresa dm_empresas
						--SET @pEmpresa = (SELECT empresa FROM inserted)
						--SET @pCodigo = NULL
						EXEC vs_proximo_numero_serie @pempresa, '', '', 'TERCEROS', null, 1, @pCodigo OUTPUT
						INSERT INTO emp_terceros ( empresa, codigo, nombre,razon_social,nif,domicilio,codigo_postal,poblacion,provincia,codigo_pais,telefono,
						movil, fax, email,web,es_proveedor) SELECT [empresa],CONVERT(int,@pCodigo),nombre,razon_social,nif,domicilio,codigo_postal,poblacion,provincia,codigo_pais,telefono,
						movil, fax, email,web,1 FROM inserted WHERE sys_oid = @pSysOid
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
					codigo_pais=i.codigo_pais,
					telefono=i.telefono, 
					movil=i.movil, 
					fax =i.fax, 
					email=i.email, 
					web=i.web,
					es_proveedor=1
				FROM emp_terceros AS t 
					INNER JOIN inserted as i ON t.sys_oid = i.sys_oid_terceros 
				WHERE i.sys_oid = @pSysOid
					
		UPDATE emp_clientes SET 
			empresa=i.empresa,
			codigo_tercero=i.codigo_tercero,
			codigo=i.codigo,
			activo=i.activo,
			riesgo_maximo=i.riesgo_maximo,
			riesgo_cyc=i.riesgo_cyc,
			riesgo_contable=i.riesgo_contable,
			observaciones_riesgo=i.observaciones_riesgo,
			bloqueado=i.bloqueado,
			razon_bloqueado=i.razon_bloqueado,
			observaciones=i.observaciones,
			adjuntos=i.adjuntos, 
			fecha_creacion=i.fecha_creacion,
			fecha_modificacion=i.fecha_modificacion,
			codigo_grupo=i.codigo_grupo,
			codigo_banco_cobro=i.codigo_banco_cobro,
			solo_tickets=i.solo_tickets,
			evolucion_bdi=i.evolucion_bdi, 
			evolucion_credito=i.evolucion_credito,
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
			activo_web=i.activo_web,
			usuario_web=i.usuario_web,
			password_web=i.password_web,
			excluir_ofertas=i.excluir_ofertas,
			observaciones_internas_bloqueo=i.observaciones_internas_bloqueo,
			codigo_subzona=i.codigo_subzona,
			codigo_almacen_habitual=i.codigo_almacen_habitual,
			compensar_abonos=i.compensar_abonos,
			codigo_ruta_reparto=i.codigo_ruta_reparto,
			report_albaranes=i.report_albaranes,
			subir_web=i.subir_web,
			aceptada_domiciliacion=i.aceptada_domiciliacion,
			observaciones_albaran=i.observaciones_albaran,
			observaciones_factura=i.observaciones_factura,
			su_codigo_proveedor=i.su_codigo_proveedor,
			codigo_ean=i.codigo_ean,
			diario=i.diario,
			codigo_destino_directo = i.codigo_destino_directo,
			codigo_agencia_directo = i.codigo_agencia_directo,
			codigo_destino_indirecto = i.codigo_destino_indirecto,
			codigo_agencia_indirecto = i.codigo_agencia_indirecto
		FROM emp_clientes AS C 
			INNER JOIN inserted AS I on c.sys_oid = i.sys_oid 
	   WHERE i.sys_oid = @pSysOid	
	  
	  UPDATE emp_clientes_cond_venta SET 
			codigo_tipo_cond_venta='1',
			predeterminada=i.predeterminada, 
			dia_pago1=i.dia_pago1,
			dia_pago2=i.dia_pago2,
			dia_pago3=i.dia_pago3,
			vacaciones_desde=i.vacaciones_desde,
			vacaciones_hasta=i.vacaciones_hasta,
			dto_lineas_1=i.dto_lineas_1,
			dto_lineas_2=i.dto_lineas_2, 
			descuento_comercial=i.descuento_comercial, 
			descuento_financiero=i.descuento_financiero, 
			codigo_tarifa=i.codigo_tarifa, 
			no_agrupar_albaranes =i.no_agrupar_albaranes, 
			facturacion_mensual =i.facturacion_mensual, 
			albaran_valorado =i.albaran_valorado, 
			numero_copias_albaran = i.numero_copias_albaran,
			numero_copias_factura=i.numero_copias_factura, 
			codigo_tabla_iva=i.codigo_tabla_iva, 
			codigo_representante=i.codigo_representante, 
			codigo_divisa=i.codigo_divisa, 
			agrupar_por_dir_envio=i.agrupar_por_dir_envio,
			porcentaje_irpf=i.porcentaje_irpf,
			enviar_factura_por_email=i.enviar_factura_por_email,
			enviar_factura_por_fax=i.enviar_factura_por_fax,
			codigo_forma_pago=i.codigo_forma_pago	  
		  FROM emp_clientes_cond_venta
			INNER JOIN inserted AS I ON i.empresa = emp_clientes_cond_venta.empresa
			  AND i.codigo = emp_clientes_cond_venta.codigo_cliente
		WHERE i.sys_oid = @pSysOid
			  	
		UPDATE eje_clientes_cond_venta_cuentas SET 
			subcuenta = inserted.subcuenta, 
			subcuenta_efectos = inserted.subcuenta_efectos, 
			subcuenta_impagados = inserted.subcuenta_impagados,
			subcuenta_riesgo = inserted.subcuenta_riesgo,
			subcuenta_divisas = inserted.subcuenta_divisas,
			subcuenta_retenciones = inserted.subcuenta_retenciones,
			subcuenta_ventas = inserted.subcuenta_ventas
		  FROM eje_clientes_cond_venta_cuentas AS C 
			INNER JOIN inserted ON inserted.empresa = C.empresa
			  AND inserted.ejercicio = C.ejercicio
			  AND inserted.codigo= C.codigo_cliente
		 WHERE inserted.sys_oid = @pSysOid		
		
		IF @@ROWCOUNT = 0 
		BEGIN
			INSERT eje_clientes_cond_venta_cuentas (empresa, ejercicio, codigo_cliente, codigo_tipo_cond_venta, subcuenta, subcuenta_efectos, subcuenta_impagados, subcuenta_riesgo,
					subcuenta_divisas, subcuenta_retenciones, subcuenta_ventas)
				SELECT empresa, ejercicio, codigo, '1', subcuenta, subcuenta_efectos, subcuenta_impagados, subcuenta_riesgo,
						subcuenta_divisas, subcuenta_retenciones, subcuenta_ventas
				  FROM inserted
				 WHERE inserted.sys_oid = @pSysOid				   			
		END
		FETCH NEXT FROM actualizados INTO @pcodigo_tercero,@psysoid,@pempresa
		
	END
	CLOSE actualizados
	DEALLOCATE actualizados
END

ALTER TABLE eje_camiones ADD envio_directo dm_logico 
GO 

CREATE TABLE [dbo].[emp_tipos_caja_verano](
	[empresa] [dbo].[dm_empresas] NOT NULL,
	[codigo] [dbo].[dm_codigos_c] NOT NULL,
	[tipo_caja] [dbo].[dm_char_muy_corto] NOT NULL,
	[descripcion] [dbo].[dm_char_corto] NULL,
	[tara] [dbo].[dm_pesos] NULL,
	[peso] [dbo].[dm_pesos] NULL,
	[sys_logs] [dbo].[dm_memo] NULL,
	[sys_borrado] [dbo].[dm_logico] NULL,
	[sys_timestamp] [dbo].[dm_fechas_hora] NULL DEFAULT (getdate()),
	[sys_oid] [dbo].[dm_oid] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_emp_tipos_caja_verano] PRIMARY KEY CLUSTERED 
(
	[empresa] ASC,
	[codigo] ASC,
	[tipo_caja] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

create unique index UK_emp_tipos_caja_verano ON emp_tipos_caja_verano (sys_oid)
go 

*/

