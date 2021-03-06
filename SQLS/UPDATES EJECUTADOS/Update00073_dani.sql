USE vs_martinez
GO
/****** Object:  Trigger [dbo].[vf_emp_representantes_bi]    Script Date: 02/08/2012 17:44:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [dbo].[vf_emp_representantes_bi] 
   ON  [dbo].[vf_emp_representantes]
with encryption INSTEAD OF INSERT
AS 
BEGIN
	DECLARE @sys_oid dm_oid
	DECLARE @codigo_tercero dm_codigos_n
	DECLARE @Codigo dm_char_corto
	DECLARE @Empresa dm_empresas
	
	SET NOCOUNT ON;
	
	DECLARE Insertados CURSOR LOCAL FOR 
		SELECT empresa, codigo, codigo_tercero FROM inserted
		
	OPEN Insertados
	FETCH NEXT FROM Insertados INTO @empresa, @codigo, @codigo_tercero
	WHILE (@@FETCH_STATUS = 0)
	BEGIN		
		IF ISNULL(@codigo_tercero,0) = 0
		BEGIN
			
			EXEC vs_proximo_numero_serie @empresa, '', '', 'TERCEROS', null, 1, @codigo_tercero OUTPUT
				
			INSERT INTO emp_terceros ( empresa, codigo, nombre,razon_social,nif,domicilio,codigo_postal,poblacion,provincia,telefono,
						movil, fax, email,web) 
				SELECT empresa,CONVERT(int,@codigo_tercero),nombre,razon_social,nif,domicilio,codigo_postal,poblacion,provincia,telefono,
				   	   movil, fax, email,web 
				  FROM inserted 
				 WHERE empresa = @Empresa 
				   AND codigo = @Codigo
			
			INSERT INTO emp_representantes (empresa, codigo_tercero, codigo, activo, observaciones, adjuntos, fecha_creacion, fecha_modificacion, antiguedad, irpf, es_de_calle) 
			 SELECT empresa, CONVERT(int,@codigo_tercero), @Codigo, activo, observaciones, adjuntos, fecha_creacion, fecha_modificacion, antiguedad, irpf, es_de_calle 
			   FROM inserted
			  WHERE empresa = @Empresa 
				   AND codigo = @Codigo
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
				INNER JOIN inserted AS i ON T.empresa = i.empresa and T.codigo = i.codigo_tercero
			 WHERE t.empresa = @Empresa 
				   AND t.codigo = @codigo_tercero
				   
			INSERT INTO emp_representantes (empresa, codigo_tercero, codigo, activo, observaciones, adjuntos, fecha_creacion, fecha_modificacion, antiguedad, irpf, es_de_calle) 
				SELECT empresa, codigo_tercero, codigo, activo, observaciones, adjuntos, fecha_creacion, fecha_modificacion, antiguedad, irpf, es_de_calle 
				FROM inserted
			   WHERE empresa = @Empresa 
				   AND codigo = @Codigo
		END
		
		FETCH NEXT FROM Insertados INTO @empresa, @codigo, @codigo_tercero
	END 		
		
END

GO 

ALTER TRIGGER [dbo].[vf_emp_representantes_bu] 
   ON  [dbo].[vf_emp_representantes]
with encryption   INSTEAD OF UPDATE
AS 
BEGIN

	DECLARE @perror varchar(4000)
	
	SET NOCOUNT ON
	UPDATE emp_representantes SET 
		empresa=i.empresa,
		codigo_tercero=i.codigo_tercero,
		codigo=i.codigo,
		activo=i.activo,
		observaciones=i.observaciones,
		adjuntos=i.adjuntos,
		fecha_creacion=i.fecha_creacion,
		fecha_modificacion=i.fecha_modificacion,
		antiguedad=i.antiguedad,
		irpf=i.irpf,
		es_de_calle=i.es_de_calle
	FROM emp_representantes AS C 
		INNER JOIN inserted AS I on c.empresa = i.empresa AND c.codigo = i.codigo
			
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
	FROM emp_terceros AS c
		INNER JOIN inserted as i ON c.empresa = i.empresa and c.codigo = i.codigo_tercero
				
END

