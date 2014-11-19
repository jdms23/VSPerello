USE vs_martinez
GO
ALTER TRIGGER [dbo].[vf_emp_empleados_bu] 
   ON  [dbo].[vf_emp_empleados]
   INSTEAD OF UPDATE
AS 
BEGIN
	SET NOCOUNT ON
	UPDATE emp_empleados SET 
		empresa=i.empresa,
		codigo_tercero=i.codigo_tercero,
		codigo=i.codigo,
		activo=i.activo,
		observaciones=i.observaciones,
		adjuntos=i.adjuntos,
		fecha_creacion=i.fecha_creacion,
		fecha_modificacion=i.fecha_modificacion,
		antiguedad=i.antiguedad,
		irpf=i.irpf
		FROM emp_empleados AS C 
		INNER JOIN inserted AS I on c.sys_oid = i.sys_oid
		
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
	FROM emp_terceros AS t
		INNER JOIN inserted as i ON t.sys_oid = i.sys_oid_terceros
END

