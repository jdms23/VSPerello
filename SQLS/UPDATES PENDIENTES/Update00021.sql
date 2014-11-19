USE vs_martinez
GO
ALTER TRIGGER [dbo].[vf_emp_proveedores_bu] 
   ON  [dbo].[vf_emp_proveedores]
   INSTEAD OF UPDATE
AS 
BEGIN
	SET NOCOUNT ON
	DECLARE @pCodigo_tercero dm_codigos_n
	DECLARE @pCodigo dm_char_corto
	DECLARE @pEmpresa dm_empresas
	DECLARE @pSysOid dm_oid

	DECLARE actualizados CURSOR LOCAL FOR SELECT codigo_tercero,sys_oid,empresa FROM inserted
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
				FROM emp_terceros AS t INNER JOIN inserted as i ON t.sys_oid = i.sys_oid_terceros 
				WHERE i.sys_oid = @pSysOid
				
	UPDATE emp_proveedores SET 
		empresa=i.empresa,
		codigo_tercero= @pCodigo_tercero,
		codigo=i.codigo,
		activo=i.activo,
		observaciones=i.observaciones,
		adjuntos=i.adjuntos,
		fecha_creacion=i.fecha_creacion,
		fecha_modificacion=i.fecha_modificacion,
		acreedor = i.acreedor,
		codigo_banco_pago=i.codigo_banco_pago,
		importe_minimo_portes=i.importe_minimo_portes
	FROM emp_proveedores AS C 
		INNER JOIN inserted AS I on c.sys_oid = i.sys_oid 
		WHERE i.sys_oid = @pSysOid
	FETCH NEXT FROM actualizados INTO @pcodigo_tercero,@psysoid,@pempresa
	END
	CLOSE actualizados
	DEALLOCATE actualizados
END
