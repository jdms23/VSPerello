USE [vs_perello]
GO

/****** Object:  Table [dbo].[emp_articulos_escandallo]    Script Date: 09/04/2015 10:07:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[emp_articulos_paletizacion](
	[empresa] [dbo].[dm_empresas] NOT NULL,
	[codigo_articulo] [dbo].[dm_codigo_articulo] NOT NULL,
	[linea] [dbo].[dm_entero] NOT NULL,
	[desde_cajas] [dbo].[dm_entero] NOT NULL,
	[hasta_cajas] [dbo].[dm_entero] NOT NULL,
	[cajas_por_palet] [dbo].[dm_entero] NOT NULL,
	[sys_logs] [dbo].[dm_memo] NULL,
	[sys_borrado] [dbo].[dm_logico] NULL,
	[sys_timestamp] [dbo].[dm_fechas_hora] NULL DEFAULT (getdate()),
	[sys_oid] [dbo].[dm_oid] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_emp_articulos_paletizacion] PRIMARY KEY CLUSTERED 
(
	[empresa] ASC,
	[codigo_articulo] ASC,
	[linea] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[emp_articulos_paletizacion]  WITH NOCHECK ADD  CONSTRAINT [FK_emp_articulos_paletizacion_emp_articulos] FOREIGN KEY([empresa], [codigo_articulo])
REFERENCES [dbo].[emp_articulos] ([empresa], [codigo])
ON UPDATE CASCADE
ON DELETE CASCADE
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[emp_articulos_paletizacion] CHECK CONSTRAINT [FK_emp_articulos_paletizacion_emp_articulos]
GO

CREATE UNIQUE INDEX UK_emp_articulos_paletizacion ON emp_articulos_paletizacion (sys_oid ASC)
GO 


ALTER VIEW [dbo].[vf_eje_montaje_palets_cajas] AS 
SELECT P.empresa, P.ejercicio, P.fecha, P.numero_palet, C.linea, P.codigo_cliente, CL.nombre as nombre_cliente,
	P.codigo_destino, D.descripcion as descripcion_destino,
	P.codigo_agencia, AG.descripcion as descripcion_agencia,
	C.codigo_articulo, A.descripcion as descripcion_articulo, 
	(CASE 
		WHEN ISNULL(AP.cajas_por_palet,0) > 0 THEN AP.cajas_por_palet
		WHEN ISNULL(A.envases_por_palet,0) > 0 THEN A.envases_por_palet
		ELSE 70
	END) AS envases_por_palet,
	C.codigo_calidad, ACA.descripcion as descripcion_calidad, 
	C.codigo_confeccion, AC.descripcion as descripcion_confeccion, 
	C.numero_cajas, C.precio, P.sscc, P.impreso, P.completo,
	P.sys_oid as sys_oid_palet, C.sys_oid as sys_oid_caja, C.sys_oid_linea_pedido
  FROM eje_montaje_palets AS P 
	LEFT OUTER JOIN eje_montaje_palets_cajas AS C ON C.empresa = P.empresa 
		AND C.ejercicio = P.ejercicio
		AND C.fecha = P.fecha
		AND C.numero_palet = P.numero_palet
	LEFT OUTER JOIN vf_emp_clientes AS CL ON CL.empresa = P.empresa 
		AND CL.codigo = P.codigo_cliente
	LEFT OUTER JOIN emp_destinos AS D ON D.empresa = P.empresa 
		AND D.codigo = P.codigo_destino
	LEFT OUTER JOIN emp_agencias AS AG ON AG.empresa = P.empresa 
		AND AG.codigo = P.codigo_agencia
	LEFT OUTER JOIN emp_articulos AS A ON A.empresa = C.empresa
		AND A.codigo = C.codigo_articulo
	LEFT OUTER JOIN emp_articulos_calidades AS ACA ON ACA.empresa = C.empresa
		AND ACA.codigo_articulo = C.codigo_articulo
		AND ACA.codigo_calidad = C.codigo_calidad
	LEFT OUTER JOIN emp_articulos_confecciones AS AC ON AC.empresa = C.empresa
		AND AC.codigo_articulo = C.codigo_articulo
		AND AC.codigo_confeccion = C.codigo_confeccion 
	LEFT OUTER JOIN emp_articulos_paletizacion AS AP ON AP.empresa = C.empresa
		AND AP.codigo_articulo = C.codigo_articulo
		AND C.numero_cajas BETWEEN AP.desde_cajas AND AP.hasta_cajas

GO
