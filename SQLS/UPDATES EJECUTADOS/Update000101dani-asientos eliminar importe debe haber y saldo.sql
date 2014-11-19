USE vsolution
GO 
/*
ALTER TABLE eje_asientos drop column importe_debe, importe_haber, saldo
go 

CREATE VIEW [dbo].[vf_eje_asientos]
AS
SELECT     dbo.eje_asientos.empresa, dbo.eje_asientos.ejercicio, dbo.eje_asientos.periodo, dbo.eje_asientos.diario, dbo.eje_asientos.fecha, dbo.eje_asientos.asiento, 
                      dbo.eje_asientos.sys_oid, dbo.eje_asientos.observaciones, dbo.eje_asientos.tipo_asiento, dbo.eje_asientos.traspasado_de_gestion, 
                      dbo.eje_asientos.registro_bloqueado, dbo.eje_asientos.fecha_importacion, SUM(dbo.eje_apuntes.importe_debe) AS importe_debe, 
                      SUM(dbo.eje_apuntes.importe_haber) AS importe_haber, SUM(dbo.eje_apuntes.importe_debe - dbo.eje_apuntes.importe_haber) AS saldo
FROM         dbo.eje_asientos INNER JOIN
                      dbo.eje_apuntes ON dbo.eje_asientos.empresa = dbo.eje_apuntes.empresa
                      AND dbo.eje_asientos.ejercicio = dbo.eje_apuntes.ejercicio
                      AND dbo.eje_asientos.diario = dbo.eje_apuntes.diario
                      AND dbo.eje_asientos.asiento = dbo.eje_apuntes.asiento
GROUP BY dbo.eje_asientos.empresa, dbo.eje_asientos.ejercicio, dbo.eje_asientos.periodo, dbo.eje_asientos.diario, dbo.eje_asientos.fecha, dbo.eje_asientos.asiento, 
                      dbo.eje_asientos.sys_oid, dbo.eje_asientos.observaciones, dbo.eje_asientos.tipo_asiento, dbo.eje_asientos.traspasado_de_gestion, 
                      db
                      o.eje_asientos.registro_bloqueado, dbo.eje_asientos.fecha_importacion

GO

CREATE TRIGGER vf_eje_asientos_bi
   ON  vf_eje_asientos
   INSTEAD OF INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	INSERT INTO [eje_asientos]([empresa],[ejercicio],[periodo],[diario],[fecha],[asiento],[observaciones],[tipo_asiento],[traspasado_de_gestion],[registro_bloqueado],[fecha_importacion])
		SELECT [empresa],[ejercicio],[periodo],[diario],[fecha],[asiento],[observaciones],[tipo_asiento],[traspasado_de_gestion],[registro_bloqueado],[fecha_importacion]
		  FROM inserted

END
GO

CREATE TRIGGER vf_eje_asientos_bu
   ON  vf_eje_asientos
   INSTEAD OF UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	UPDATE eje_asientos SET 
		[empresa]=i.empresa,
		[ejercicio]=i.ejercicio,
		[periodo]=i.periodo,
		[diario]=i.diario,
		[fecha]=i.fecha,
		[asiento]=i.asiento,
		[observaciones]=i.observaciones,
		[tipo_asiento]=i.tipo_asiento,
		[traspasado_de_gestion]=i.traspasado_de_gestion,
		[registro_bloqueado]=i.registro_bloqueado,
		[fecha_importacion]=i.fecha_importacion
	 FROM eje_asientos
		INNER JOIN inserted as i ON eje_asientos.sys_oid = i.sys_oid

END
GO

CREATE TRIGGER vf_eje_asientos_bd
   ON  vf_eje_asientos
   INSTEAD OF DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	DELETE eje_asientos 
	 FROM eje_asientos
		INNER JOIN deleted as D ON eje_asientos.sys_oid = D.sys_oid

END
GO

*/
