USE [vs_perello]
GO

/****** Object:  View [dbo].[vr_ficha_parcela_asociado]    Script Date: 03/28/2015 13:53:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vr_ficha_parcela_asociado] AS 
	SELECT P.empresa, P.ejercicio, P.codigo_proveedor, S.nombre as nombre_proveedor, P.codigo_parcela, C.codigo_subparcela, 
		P.descripcion as descripcion_parcela, P.partida, C.superficie, C.codigo_articulo as codigo_articulo_actual, C.descripcion as descripcion_actual, 
		C.linea, A.distancia_aclareo, C.fecha_siembra, C.semana_siembra, C.fecha_recoleccion_prevista, C.sys_oid,
		CAnt.codigo_articulo AS codigo_articulo_anterior, CAnt.descripcion AS descripcion_anterior,
		TC.fecha_tratamiento, TL.materia_activa, TL.dosis_por_litro, TL.cantidad_cc, TL.litros, TL.numero_registro, TL.plazo_seguridad, TL.codigo_plaga, PL.descripcion AS descripcion_plaga,
		CONVERT(int, ROW_NUMBER() OVER (PARTITION BY C.empresa, C.ejercicio, C.codigo_proveedor, C.codigo_parcela, C.codigo_subparcela, C.linea ORDER BY TC.fecha)) AS orden_tratamiento
	  FROM eje_parcelas AS P 
		INNER JOIN vf_eje_parcelas_subparcelas_cultivos AS C ON C.empresa = P.empresa
			AND C.ejercicio = P.ejercicio
			AND C.codigo_proveedor = P.codigo_proveedor
			AND C.codigo_parcela = P.codigo_parcela
		INNER JOIN vf_emp_proveedores AS S ON S.empresa = P.empresa
			AND S.codigo = P.codigo_proveedor
		INNER JOIN emp_articulos AS A ON A.empresa = C.empresa
			AND A.codigo = C.codigo_articulo
		LEFT OUTER JOIN vf_eje_parcelas_subparcelas_cultivos AS CAnt ON CAnt.empresa = C.empresa
			AND CAnt.ejercicio = C.ejercicio
			AND CAnt.codigo_proveedor = C.codigo_proveedor
			AND CAnt.codigo_parcela = C.codigo_parcela
			AND CAnt.codigo_subparcela = C.codigo_subparcela
			AND CAnt.linea = (C.linea - 1)
		LEFT OUTER JOIN eje_tratamientos_c AS TC ON TC.empresa = C.empresa
			AND TC.ejercicio = C.ejercicio
			AND TC.codigo_proveedor = C.codigo_proveedor
			AND TC.codigo_parcela = C.codigo_parcela
			AND TC.codigo_subparcela = C.codigo_subparcela
			AND TC.linea_cultivo = C.linea
		LEFT OUTER JOIN vf_eje_tratamientos_l AS TL ON TL.empresa = TC.empresa
			AND TL.ejercicio = TC.ejercicio
			AND TL.codigo_tipo_documento = TC.codigo_tipo_documento
			AND TL.serie = TC.serie
			AND TL.numero = TC.numero
		LEFT OUTER JOIN gen_tipos_opciones AS PL ON PL.codigo_tipo = 'PLAGAS'
			AND PL.codigo_opcion = TL.codigo_plaga


GO


