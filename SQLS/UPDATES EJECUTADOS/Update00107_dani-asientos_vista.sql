USE [vs_martinez]
GO

/****** Object:  View [dbo].[vf_eje_asientos]    Script Date: 03/05/2012 17:42:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vf_eje_asientos]
AS
SELECT     dbo.eje_asientos.empresa, dbo.eje_asientos.ejercicio, dbo.eje_asientos.periodo, dbo.eje_asientos.diario, dbo.eje_asientos.fecha, dbo.eje_asientos.asiento, 
                      dbo.eje_asientos.sys_oid, dbo.eje_asientos.observaciones, dbo.eje_asientos.tipo_asiento, dbo.eje_asientos.traspasado_de_gestion, 
                      dbo.eje_asientos.registro_bloqueado, dbo.eje_asientos.fecha_importacion, SUM(dbo.eje_apuntes.importe_debe) AS importe_debe, 
                      SUM(dbo.eje_apuntes.importe_haber) AS importe_haber, SUM(dbo.eje_apuntes.importe_debe - dbo.eje_apuntes.importe_haber) AS saldo
FROM         dbo.eje_asientos LEFT OUTER JOIN
                      dbo.eje_apuntes ON dbo.eje_asientos.empresa = dbo.eje_apuntes.empresa
                      AND dbo.eje_asientos.ejercicio = dbo.eje_apuntes.ejercicio
                      AND dbo.eje_asientos.diario = dbo.eje_apuntes.diario
                      AND dbo.eje_asientos.asiento = dbo.eje_apuntes.asiento
GROUP BY dbo.eje_asientos.empresa, dbo.eje_asientos.ejercicio, dbo.eje_asientos.periodo, dbo.eje_asientos.diario, dbo.eje_asientos.fecha, dbo.eje_asientos.asiento, 
                      dbo.eje_asientos.sys_oid, dbo.eje_asientos.observaciones, dbo.eje_asientos.tipo_asiento, dbo.eje_asientos.traspasado_de_gestion, 
                      dbo.eje_asientos.registro_bloqueado, dbo.eje_asientos.fecha_importacion

GO
