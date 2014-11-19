USE vs_martinez
GO
ALTER TRIGGER [dbo].[emp_empleados_ai]
   ON  [dbo].[emp_empleados]
   AFTER INSERT
AS 
BEGIN

	SET NOCOUNT ON;	
	update emp_terceros set es_empleado = 1 from emp_terceros 
	inner join inserted ON emp_terceros.empresa = inserted.empresa and emp_terceros.codigo = inserted.codigo_tercero

END
GO
