USE [vs_perello]
GO

/****** Object:  Table [dbo].[emp_articulos_plaguicidas]    Script Date: 16/03/2015 10:37:54 ******/
DROP TABLE [dbo].[emp_articulos_plaguicidas]
GO

ALTER TABLE emp_plaguicidas_plazos ADD autorizado dm_logico
GO 

UPDATE emp_plaguicidas_plazos SET autorizado = 1
GO 

ALTER VIEW [dbo].[vf_emp_plaguicidas_plazos]
AS
SELECT PP.empresa, PP.codigo_plaguicida, PP.linea, PP.codigo_articulo, A.descripcion, PP.desde_fecha, PP.hasta_fecha, PP.plazo_seguridad, 
		PP.autorizado, PP.sys_oid
  FROM emp_plaguicidas_plazos AS PP
	LEFT OUTER JOIN emp_articulos AS A ON A.empresa = PP.empresa
		AND A.codigo = PP.codigo_articulo


GO

ALTER TRIGGER [dbo].[vf_emp_plaguicidas_plazos_bi]
   ON  [dbo].[vf_emp_plaguicidas_plazos]
   INSTEAD OF INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for trigger here
	INSERT INTO emp_plaguicidas_plazos (empresa, codigo_plaguicida, linea, codigo_articulo, desde_fecha, hasta_fecha, plazo_seguridad, autorizado)
		SELECT empresa, codigo_plaguicida, linea, codigo_articulo, desde_fecha, hasta_fecha, plazo_seguridad, autorizado
		  FROM inserted
	
END

GO
ALTER TRIGGER [dbo].[vf_emp_plaguicidas_plazos_bu]
   ON  [dbo].[vf_emp_plaguicidas_plazos]
   INSTEAD OF UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for trigger here
	UPDATE emp_plaguicidas_plazos SET empresa = inserted.empresa,
		codigo_plaguicida = inserted.codigo_plaguicida,
		linea = inserted.linea,
		codigo_articulo = inserted.codigo_articulo,
		desde_fecha = inserted.desde_fecha,
		hasta_fecha = inserted.hasta_fecha,
		plazo_seguridad= inserted.plazo_seguridad,
		autorizado = inserted.autorizado
	 FROM emp_plaguicidas_plazos
		INNER JOIN inserted ON inserted.sys_oid = emp_plaguicidas_plazos.sys_oid
		
END
