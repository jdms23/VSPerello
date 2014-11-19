USE vs_martinez
GO

/****** Object:  View [dbo].[vv_ofertas_lote]    Script Date: 02/21/2012 17:21:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create VIEW [dbo].[vv_ofertas_lote]
AS
SELECT     dbo.emp_ofertas_c.empresa, dbo.emp_ofertas_c.numero, dbo.emp_ofertas_c.desde_fecha, dbo.emp_ofertas_c.hasta_fecha,  
                      dbo.emp_ofertas_c.unidades_lote, dbo.emp_ofertas_l.codigo_articulo, dbo.emp_ofertas_l.precio, dbo.emp_ofertas_l.dto
FROM         dbo.emp_ofertas_c INNER JOIN
                      dbo.emp_ofertas_l ON dbo.emp_ofertas_c.empresa = dbo.emp_ofertas_l.empresa AND dbo.emp_ofertas_c.numero = dbo.emp_ofertas_l.numero 
where isnull(unidades_lote,0)>0 and activa=1 and tipo=3

GO


