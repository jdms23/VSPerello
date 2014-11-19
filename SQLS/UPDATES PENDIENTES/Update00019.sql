USE vs_martinez
GO
ALTER TRIGGER [dbo].[vf_emp_empleados_bd] 
   ON  [dbo].[vf_emp_empleados]
   INSTEAD OF DELETE
AS 
BEGIN
	SET NOCOUNT ON;
-- Verifica que es borrado
	DELETE emp_empleados FROM emp_empleados AS E 
	  inner join deleted AS d on E.sys_oid = d.sys_oid
END
