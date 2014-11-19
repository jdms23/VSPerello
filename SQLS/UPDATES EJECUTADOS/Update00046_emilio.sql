USE vsolution
GO

/****** Object:  View [dbo].[vf_emp_articulos_grupos]    Script Date: 01/25/2012 10:40:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vf_emp_articulos_grupos] with encryption
AS
SELECT     dbo.emp_articulos_grupos.empresa, dbo.emp_articulos_grupos.codigo_articulo, dbo.emp_articulos_grupos.codigo_grupo, dbo.emp_articulos_grupos.sys_logs, 
                      dbo.emp_articulos_grupos.sys_borrado, dbo.emp_articulos_grupos.sys_oid, dbo.emp_articulos_grupos.sys_timestamp, 
                      dbo.emp_grupos_articulos.descripcion AS descripcion_grupo
FROM         dbo.emp_articulos_grupos LEFT JOIN
                      dbo.emp_grupos_articulos ON dbo.emp_articulos_grupos.empresa = dbo.emp_grupos_articulos.empresa AND 
                      dbo.emp_articulos_grupos.codigo_grupo = dbo.emp_grupos_articulos.codigo

GO

