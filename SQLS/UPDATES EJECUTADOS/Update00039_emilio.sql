USE vs_martinez
GO

/****** Object:  View [dbo].[vf_emp_arqueo_caja]    Script Date: 01/24/2012 17:01:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vf_emp_arqueo_caja] with encryption
AS
SELECT     dbo.eje_mov_caja.codigo_tipo_mov, dbo.gen_tipos_mov_caja.descripcion, dbo.eje_mov_caja.fecha, dbo.eje_mov_caja.importe, dbo.eje_mov_caja.codigo_banco, 
                      dbo.eje_mov_caja.usuario, dbo.eje_mov_caja.codigo_tipo_documento, dbo.eje_mov_caja.serie, dbo.eje_mov_caja.numero, dbo.eje_mov_caja.sys_oid, 
                      dbo.eje_mov_caja.empresa, dbo.eje_mov_caja.ejercicio, dbo.gen_tipos_documentos.descripcion AS tipo_documento, dbo.eje_mov_caja.sys_timestamp, 
                      dbo.eje_mov_caja.sys_oid_arqueo, dbo.eje_mov_caja.codigo_concepto, dbo.eje_mov_caja.descripcion_apunte, dbo.eje_mov_caja.subcuenta, 
                      dbo.eje_mov_caja.empresa_destino, dbo.gen_empresas.nombre AS nombre_empresa_destino,eje_mov_caja.codigo_representante,vf_emp_representantes.nombre as nombre_representante
FROM         dbo.eje_mov_caja INNER JOIN
                      dbo.gen_tipos_mov_caja ON dbo.eje_mov_caja.codigo_tipo_mov = dbo.gen_tipos_mov_caja.codigo LEFT OUTER JOIN
                      dbo.gen_empresas ON dbo.eje_mov_caja.empresa_destino = dbo.gen_empresas.codigo LEFT OUTER JOIN
                      dbo.gen_tipos_documentos ON dbo.eje_mov_caja.codigo_tipo_documento = dbo.gen_tipos_documentos.codigo LEFT OUTER JOIN
                      dbo.vf_emp_representantes ON dbo.eje_mov_caja.empresa = dbo.vf_emp_representantes.empresa and eje_mov_caja.codigo_representante = vf_emp_representantes.codigo

GO


ALTER VIEW [dbo].[vr_arqueo_caja] with encryption
AS
SELECT     dbo.emp_arqueo_caja.numero, dbo.emp_bancos.alias, dbo.emp_arqueo_caja.descripcion, dbo.emp_arqueo_caja.fecha, dbo.emp_arqueo_caja.saldo, 
                      dbo.gen_tipos_situaciones.descripcion AS descripcion_situacion, A.descripcion AS descripcion_movimiento, A.importe, A.tipo_documento, A.serie, 
                      A.numero AS numero_movimiento, A.subcuenta, dbo.gen_tipos_situaciones.descripcion AS desc_situacion, dbo.emp_arqueo_caja.sys_oid, A.usuario, 
                      A.sys_timestamp AS fecha_entrada, dbo.emp_arqueo_caja.saldo_inicial, A.empresa_destino, A.nombre_empresa_destino, A.codigo_concepto, A.descripcion_apunte, 
                      A.sys_oid_arqueo, A.codigo_tipo_mov,A.codigo_representante,A.nombre_representante
FROM         dbo.emp_arqueo_caja INNER JOIN
                      dbo.vf_emp_arqueo_caja AS A ON dbo.emp_arqueo_caja.sys_oid = A.sys_oid_arqueo LEFT OUTER JOIN
                      dbo.emp_bancos ON dbo.emp_arqueo_caja.empresa = dbo.emp_bancos.empresa AND 
                      dbo.emp_arqueo_caja.codigo_banco = dbo.emp_bancos.codigo LEFT OUTER JOIN
                      dbo.gen_tipos_situaciones ON dbo.emp_arqueo_caja.situacion = dbo.gen_tipos_situaciones.codigo_situacion
WHERE     (dbo.gen_tipos_situaciones.codigo_tipo_documento = 'ARQ')

GO
