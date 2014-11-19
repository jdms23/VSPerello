USE vs_martinez
go


alter table emp_articulos add unidades_minimas dm_unidades null 
go
alter table emp_articulos add porc_unidades_minimas dm_porcentajes null
go

ALTER TABLE emp_clientes add tarifa_reducida dm_porcentajes NULL default(0)
go

update emp_clientes set tarifa_reducida = 0
go

ALTER VIEW [dbo].[vf_emp_clientes]
with encryption
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
                      dbo.emp_terceros.codigo_pais, dbo.gen_paises.nombre AS nombre_pais, dbo.emp_clientes.excluir_ofertas, dbo.emp_clientes.observaciones_internas_bloqueo, 
                      dbo.emp_clientes.codigo_subzona, dbo.emp_clientes.codigo_almacen_habitual, dbo.emp_clientes.compensar_abonos, 
                      dbo.emp_gestor_cobros.descripcion AS descripcion_gestor_cobro, dbo.emp_clientes.codigo_ruta_reparto, dbo.emp_clientes.report_albaranes, 
                      dbo.emp_clientes.subir_web,dbo.emp_clientes.tarifa_reducida
FROM         dbo.emp_clientes INNER JOIN
                      dbo.emp_terceros ON dbo.emp_clientes.empresa = dbo.emp_terceros.empresa AND dbo.emp_clientes.codigo_tercero = dbo.emp_terceros.codigo LEFT OUTER JOIN
                      dbo.emp_gestor_cobros ON dbo.emp_clientes.empresa = dbo.emp_gestor_cobros.empresa AND 
                      dbo.emp_clientes.codigo_gestor_cobros = dbo.emp_gestor_cobros.codigo LEFT OUTER JOIN
                      dbo.gen_paises ON dbo.emp_terceros.codigo_pais = dbo.gen_paises.codigo

GO

ALTER TRIGGER [dbo].[vf_emp_clientes_bi] 
   ON  [dbo].[vf_emp_clientes] with encryption
   INSTEAD OF INSERT
AS 
BEGIN
	SET NOCOUNT OFF
	DECLARE @pCodigo dm_char_corto
	DECLARE @pEmpresa dm_empresas
	DECLARE @sys_oid dm_oid
	DECLARE @codigo_tercero dm_codigos_n
	DECLARE @pCodigo_Cliente dm_codigos_n
	
	DECLARE insertados CURSOR LOCAL FOR SELECT codigo_tercero,sys_oid,empresa,codigo FROM inserted
	OPEN insertados
	FETCH NEXT FROM insertados INTO @codigo_tercero,@sys_oid,@pEmpresa,@pCodigo_Cliente
	--SELECT * FROM inserted
	--RETURN
	WHILE @@FETCH_STATUS = 0
	BEGIN
	--IF ( SELECT codigo_tercero FROM inserted) IS NULL OR (SELECT codigo_tercero FROM inserted) = 0
	IF @codigo_tercero IS NULL OR @codigo_tercero = 0
		BEGIN
			SET @pCodigo = NULL
			--SET @pEmpresa = (SELECT empresa FROM inserted)
			EXEC vs_proximo_numero_serie @pempresa,'','','TERCEROS', null, 1, @pCodigo OUTPUT
			
			INSERT INTO emp_terceros ( empresa, codigo, nombre,razon_social,nif,domicilio,codigo_postal,poblacion,provincia,telefono,
						movil, fax, email,web) 
				SELECT [empresa],CONVERT(int,@pCodigo),nombre,razon_social,nif,domicilio,codigo_postal,poblacion,provincia,telefono,
						movil, fax, email,web 
				   FROM inserted WHERE empresa = @pEmpresa AND codigo = @pCodigo_Cliente
			
			INSERT INTO emp_clientes (empresa,codigo_tercero,codigo,activo,riesgo_maximo,riesgo_cyc,riesgo_contable,
					observaciones_riesgo,bloqueado,razon_bloqueado,observaciones,adjuntos,fecha_creacion,fecha_modificacion,
					codigo_grupo,codigo_banco_cobro,solo_tickets,evolucion_credito,evolucion_bdi,tipo_cliente_bdi,ventas_e_impagados,
					margen_maniobra_riesgo,codigo_zona,codigo_gestor_cobros,codigo_tipo_facturacion,observaciones_bloqueo,
					criterio_facturacion1,criterio_facturacion2,criterio_facturacion3,activo_web,usuario_web,password_web,
					excluir_ofertas, observaciones_internas_bloqueo,codigo_subzona,codigo_almacen_habitual,compensar_abonos,codigo_ruta_reparto,
					report_albaranes,subir_web,tarifa_reducida) 
					SELECT empresa,CONVERT(int,@pCodigo),codigo,isnull(activo,0),riesgo_maximo,riesgo_cyc,riesgo_contable,
						observaciones_riesgo,ISNULL(bloqueado,0),razon_bloqueado,observaciones,adjuntos,fecha_creacion,fecha_modificacion,
						codigo_grupo,codigo_banco_cobro,ISNULL(solo_tickets,0),evolucion_credito,evolucion_bdi,tipo_cliente_bdi,ventas_e_impagados,
						margen_maniobra_riesgo,codigo_zona,codigo_gestor_cobros,codigo_tipo_facturacion,observaciones_bloqueo,
						criterio_facturacion1,criterio_facturacion2,criterio_facturacion3,ISNULL(activo_web,0),usuario_web,password_web,
						ISNULL(excluir_ofertas,0),observaciones_internas_bloqueo,codigo_subzona,codigo_almacen_habitual,ISNULL(compensar_abonos,0),codigo_ruta_reparto,
						report_albaranes,subir_web,tarifa_reducida
					 FROM inserted WHERE empresa = @pEmpresa AND codigo = @pCodigo_Cliente
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
			   WHERE i.empresa = @pEmpresa AND i.codigo = @pCodigo_Cliente
			  
			INSERT INTO emp_clientes (empresa,codigo_tercero,codigo,activo,riesgo_maximo,riesgo_cyc,riesgo_contable,
					observaciones_riesgo,bloqueado,razon_bloqueado,observaciones,adjuntos,fecha_creacion,fecha_modificacion,
					codigo_grupo,codigo_banco_cobro,solo_tickets,evolucion_credito,evolucion_bdi,tipo_cliente_bdi,ventas_e_impagados,
					margen_maniobra_riesgo,codigo_zona,codigo_gestor_cobros,codigo_tipo_facturacion,observaciones_bloqueo,
					criterio_facturacion1,criterio_facturacion2,criterio_facturacion3,activo_web,usuario_web,password_web,
					excluir_ofertas, observaciones_internas_bloqueo,codigo_subzona,codigo_almacen_habitual,compensar_abonos,codigo_ruta_reparto,
					report_albaranes,subir_web,tarifa_reducida) 
					SELECT empresa,codigo_tercero,codigo,ISNULL(activo,0),riesgo_maximo,riesgo_cyc,riesgo_contable,
						observaciones_riesgo,ISNULL(bloqueado,0),razon_bloqueado,observaciones,adjuntos,fecha_creacion,fecha_modificacion,
						codigo_grupo,codigo_banco_cobro,ISNULL(solo_tickets,0),evolucion_credito,evolucion_bdi,tipo_cliente_bdi,ventas_e_impagados,
						margen_maniobra_riesgo,codigo_zona,codigo_gestor_cobros,codigo_tipo_facturacion,observaciones_bloqueo,
						criterio_facturacion1,criterio_facturacion2,criterio_facturacion3,ISNULL(activo_web,0),usuario_web,password_web,
						ISNULL(excluir_ofertas,0), observaciones_internas_bloqueo,codigo_subzona,codigo_almacen_habitual,ISNULL(compensar_abonos,0),codigo_ruta_reparto,
						report_albaranes,subir_web,tarifa_reducida
					 FROM inserted WHERE empresa = @pEmpresa AND codigo = @pCodigo_Cliente
		END
		FETCH NEXT FROM insertados INTO @codigo_tercero,@sys_oid,@pEmpresa,@pCodigo_Cliente
	END
	CLOSE insertados
	DEALLOCATE insertados
END

go

ALTER TRIGGER [dbo].[vf_emp_clientes_bu] 
   ON  [dbo].[vf_emp_clientes] with encryption
   INSTEAD OF UPDATE
AS 
BEGIN
	SET NOCOUNT ON
	DECLARE @pCodigo_tercero dm_codigos_n
	DECLARE @pCodigo dm_char_corto
	DECLARE @psys_oid dm_oid
	DECLARE @pEmpresa dm_empresas
	DECLARE @pCodigoCliente dm_codigos_n
	
	DECLARE actualizados CURSOR LOCAL FOR SELECT codigo_tercero,sys_oid,empresa,codigo FROM inserted
	OPEN actualizados
	FETCH NEXT FROM actualizados INTO @pCodigo_tercero,@pSys_oid,@pEmpresa,@pCodigoCliente
	WHILE @@FETCH_STATUS = 0
	BEGIN
	--SET @pCodigo_tercero = (SELECT codigo_tercero FROM inserted)
	IF UPDATE(codigo_tercero)
		BEGIN
			IF @pCodigo_tercero IS NULL OR @pCodigo_tercero = 0
				BEGIN
					--DECLARE @pEmpresa dm_empresas
					--SET @pEmpresa = (SELECT empresa FROM inserted)
					SET @pCodigo = NULL
					EXEC vs_proximo_numero_serie @pempresa, '', '', 'TERCEROS', null, 1, @pCodigo OUTPUT
					INSERT INTO emp_terceros ( empresa, codigo, nombre,razon_social,nif,domicilio,codigo_postal,poblacion,provincia,telefono,
					movil, fax, email,web,es_cliente) SELECT [empresa],CONVERT(int,@pCodigo),nombre,razon_social,nif,domicilio,codigo_postal,poblacion,provincia,telefono,
					movil, fax, email,web,1 FROM inserted AS I WHERE i.empresa = @pempresa AND i.codigo = @pCodigoCliente
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
			 WHERE i.empresa = @pempresa AND i.codigo = @pCodigoCliente
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
		subir_web=i.subir_web,
		tarifa_reducida=i.tarifa_reducida
	FROM emp_clientes AS C INNER JOIN inserted AS I on c.sys_oid = i.sys_oid 
		WHERE i.empresa = @pempresa AND i.codigo = @pCodigoCliente
	FETCH NEXT FROM actualizados INTO @pCodigo_tercero,@pSys_oid,@pEmpresa,@pCodigoCliente
	END
	CLOSE actualizados
	DEALLOCATE actualizados
END


