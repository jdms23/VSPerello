USE vs_martinez
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[vf_emp_clientes_bi] 
   ON  [dbo].[vf_emp_clientes]
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
					report_albaranes) 
					SELECT empresa,CONVERT(int,@pCodigo),codigo,isnull(activo,0),riesgo_maximo,riesgo_cyc,riesgo_contable,
						observaciones_riesgo,ISNULL(bloqueado,0),razon_bloqueado,observaciones,adjuntos,fecha_creacion,fecha_modificacion,
						codigo_grupo,codigo_banco_cobro,ISNULL(solo_tickets,0),evolucion_credito,evolucion_bdi,tipo_cliente_bdi,ventas_e_impagados,
						margen_maniobra_riesgo,codigo_zona,codigo_gestor_cobros,codigo_tipo_facturacion,observaciones_bloqueo,
						criterio_facturacion1,criterio_facturacion2,criterio_facturacion3,ISNULL(activo_web,0),usuario_web,password_web,
						ISNULL(excluir_ofertas,0),observaciones_internas_bloqueo,codigo_subzona,codigo_almacen_habitual,ISNULL(compensar_abonos,0),codigo_ruta_reparto,
						report_albaranes
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
					report_albaranes) 
					SELECT empresa,codigo_tercero,codigo,ISNULL(activo,0),riesgo_maximo,riesgo_cyc,riesgo_contable,
						observaciones_riesgo,ISNULL(bloqueado,0),razon_bloqueado,observaciones,adjuntos,fecha_creacion,fecha_modificacion,
						codigo_grupo,codigo_banco_cobro,ISNULL(solo_tickets,0),evolucion_credito,evolucion_bdi,tipo_cliente_bdi,ventas_e_impagados,
						margen_maniobra_riesgo,codigo_zona,codigo_gestor_cobros,codigo_tipo_facturacion,observaciones_bloqueo,
						criterio_facturacion1,criterio_facturacion2,criterio_facturacion3,ISNULL(activo_web,0),usuario_web,password_web,
						ISNULL(excluir_ofertas,0), observaciones_internas_bloqueo,codigo_subzona,codigo_almacen_habitual,ISNULL(compensar_abonos,0),codigo_ruta_reparto,
						report_albaranes
					 FROM inserted WHERE empresa = @pEmpresa AND codigo = @pCodigo_Cliente
		END
		FETCH NEXT FROM insertados INTO @codigo_tercero,@sys_oid,@pEmpresa,@pCodigo_Cliente
	END
	CLOSE insertados
	DEALLOCATE insertados
END
