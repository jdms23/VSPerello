USE vs_martinez
GO
ALTER TRIGGER [dbo].[vf_emp_clientes_bu] 
   ON  [dbo].[vf_emp_clientes]
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
		report_albaranes=i.report_albaranes
	FROM emp_clientes AS C INNER JOIN inserted AS I on c.sys_oid = i.sys_oid 
		WHERE i.empresa = @pempresa AND i.codigo = @pCodigoCliente
	FETCH NEXT FROM actualizados INTO @pCodigo_tercero,@pSys_oid,@pEmpresa,@pCodigoCliente
	END
	CLOSE actualizados
	DEALLOCATE actualizados
END
