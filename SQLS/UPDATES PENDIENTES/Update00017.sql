USE vs_martinez
GO
ALTER TRIGGER [dbo].[vf_emp_empleados_bi] 
   ON  [dbo].[vf_emp_empleados]
   INSTEAD OF INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	DECLARE @pCodigo dm_char_corto
	DECLARE @pEmpresa dm_empresas
	DECLARE @pSysoid dm_oid
	DECLARE @pcodigo_tercero dm_codigos_n
	
	DECLARE insertados CURSOR LOCAL FOR SELECT codigo_tercero,sys_oid,empresa,codigo FROM inserted
	OPEN insertados
	FETCH NEXT FROM insertados INTO @pcodigo_tercero,@pSysoid,@pEmpresa,@pCodigo
	WHILE @@FETCH_STATUS = 0
	BEGIN
	--IF ( SELECT codigo_tercero FROM inserted) IS NULL OR (SELECT codigo_tercero FROM inserted) = 0
	IF @pcodigo_tercero IS NULL OR @pcodigo_tercero = 0
		BEGIN
			--DECLARE @pCodigo dm_char_corto
			--DECLARE @pEmpresa dm_empresas
			--SET @pCodigo = NULL
			--SET @pEmpresa = (SELECT empresa FROM inserted)
			EXEC vs_proximo_numero_serie @pempresa, '', '', 'TERCEROS', null, 1, @pcodigo_tercero OUTPUT
			
			INSERT INTO emp_terceros ( empresa, codigo, nombre,razon_social,nif,domicilio,codigo_postal,poblacion,provincia,telefono,
						movil, fax, email,web) 
				SELECT [empresa],CONVERT(int,@pcodigo_tercero),nombre,razon_social,nif,domicilio,codigo_postal,poblacion,provincia,telefono,
						movil, fax, email,web 
				   FROM inserted WHERE empresa=@pempresa AND codigo = @pcodigo
			INSERT INTO emp_empleados (empresa, codigo_tercero, codigo, activo, observaciones, adjuntos, fecha_creacion, fecha_modificacion, antiguedad, irpf) 
				SELECT empresa, CONVERT(int,@pcodigo_tercero), codigo, activo, observaciones, adjuntos, fecha_creacion, fecha_modificacion, antiguedad, irpf
				 FROM inserted WHERE empresa=@pempresa AND codigo = @pcodigo
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
				web=i.web
			  FROM emp_terceros AS T 
				INNER JOIN inserted AS i ON T.sys_oid = i.sys_oid_terceros WHERE i.sys_oid = @pSysoid
			INSERT INTO emp_empleados (empresa, codigo_tercero, codigo, activo, observaciones, adjuntos, fecha_creacion, fecha_modificacion, antiguedad, irpf) 
				SELECT empresa, codigo_tercero, codigo, activo, observaciones, adjuntos, fecha_creacion, fecha_modificacion, antiguedad, irpf
				 FROM inserted WHERE empresa=@pempresa AND codigo = @pcodigo

		END
		FETCH NEXT FROM insertados INTO @pcodigo_tercero,@pSysoid,@pEmpresa,@pCodigo
	END
	CLOSE insertados
	DEALLOCATE insertados
END

