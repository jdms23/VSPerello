USE vs_martinez
GO

/****** Object:  View [dbo].[vr_centros_representantes_t]    Script Date: 01/19/2012 19:10:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vr_centros_representantes_t]
AS
SELECT A.*
FROM  (SELECT C.empresa, C.ejercicio, C.centro_venta, C.nombre_representante, ISNULL(C.base_imponible, 0) AS total
FROM  vr_venta_cabecera AS C) AS TableOrigen PIVOT (SUM(total) FOR 
centro_venta IN ([AGRUFONT], [ALZIRA ALMACEN], [ALZIRA EXPOSICION], [NAVE GANDIA], [ONTENIENTE], [REQUENA], [TRINQUETE])) AS A

GO

ALTER VIEW [dbo].[vr_centros_series]
AS
SELECT  A.*
FROM (SELECT C.empresa, C.ejercicio, C.centro_venta, C.descripcion AS serie, ISNULL(C.base_imponible, 0) AS total
FROM vr_venta_cabecera AS C ) AS TableOrigen PIVOT (SUM(total) FOR 
 centro_venta IN ([AGRUFONT], [ALZIRA ALMACEN], [ALZIRA EXPOSICION], [NAVE GANDIA], [ONTENIENTE], [REQUENA], [TRINQUETE])) AS A

GO



