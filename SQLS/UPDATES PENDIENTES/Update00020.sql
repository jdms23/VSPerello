USE vs_martinez
GO
ALTER TRIGGER [dbo].[vf_emp_proveedores_bi] 
   ON  [dbo].[vf_emp_proveedores]
   INSTEAD OF INSERT
AS 
BEGIN
	SET NOCOUNT OFF;
	DECLARE @pCodigo dm_char_corto
	DECLARE @pEmpresa dm_empresas
	DECLARE @pcodigo_tercero dm_codigos_n
	DECLARE @pSysoid dm_oid
	DECLARE insertados CURSOR LOCAL FOR SELECT codigo,codigo_tercero,empresa FROM inserted
	OPEN insertados
	FETCH NEXT FROM insertados INTO @pcodigo,@pCodigo_Tercero,@pempresa
	WHILE @@FETCH_STATUS = 0
	BEGIN
	IF @pcodigo_tercero IS NULL OR @pcodigo_tercero  = 0
		BEGIN
		--DECLARE @pCodigo dm_char_corto
		--DECLARE @pEmpresa dm_empresas
		--SET @pCodigo = NULL
		--SET @pEmpresa = (SELECT empresa FROM inserted)
			EXEC vs_proximo_numero_serie @pempresa, '', '', 'TERCEROS', null, 1, @pcodigo_tercero OUTPUT
			INSERT INTO emp_terceros ( empresa, codigo, nombre,razon_social,nif,domicilio,codigo_postal,poblacion,provincia,codigo_pais,telefono,
						movil, fax, email,web,es_proveedor) 
				SELECT [empresa],CONVERT(int,@pcodigo_tercero),nombre,razon_social,nif,domicilio,codigo_postal,poblacion,provincia,codigo_pais,telefono,
						movil, fax, email,web,1
				FROM inserted WHERE empresa = @pEmpresa AND codigo = @pcodigo
			INSERT INTO emp_proveedores (empresa,codigo_tercero,codigo,activo,observaciones,adjuntos,fecha_creacion,fecha_modificacion,acreedor,codigo_banco_pago,importe_minimo_portes ) 
				SELECT empresa,CONVERT(int,@pcodigo_tercero),codigo,activo,observaciones,adjuntos,fecha_creacion,fecha_modificacion,acreedor,codigo_banco_pago,importe_minimo_portes
				 FROM inserted WHERE empresa = @pEmpresa AND codigo = @pcodigo
		END
	ELSE
		BEGIN
			UPDATE emp_terceros SET nombre=i.nombre, razon_social = i.razon_social, nif=i.nif, domicilio=i.domicilio, codigo_postal=i.codigo_postal,
				poblacion=i.poblacion, provincia=i.provincia, telefono=i.telefono, movil=i.movil, fax =i.fax, email=i.email, web=i.web,
				codigo_pais=i.codigo_pais
			  FROM emp_terceros AS T INNER JOIN inserted AS i ON T.sys_oid = i.sys_oid_terceros
			INSERT INTO emp_proveedores (empresa,codigo_tercero,codigo,activo,observaciones,adjuntos,fecha_creacion,fecha_modificacion,acreedor,codigo_banco_pago,importe_minimo_portes ) 
					SELECT empresa,codigo_tercero,codigo,activo,observaciones,adjuntos,fecha_creacion,fecha_modificacion,acreedor,codigo_banco_pago,importe_minimo_portes
					 FROM inserted WHERE empresa = @pEmpresa AND codigo = @pcodigo
		END
		FETCH NEXT FROM insertados INTO @pcodigo,@pCodigo_Tercero,@pempresa
	END
	CLOSE insertados
	DEALLOCATE insertados
END

