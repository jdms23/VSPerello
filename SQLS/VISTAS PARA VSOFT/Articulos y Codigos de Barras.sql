SELECT     dbo.PARTI.Codigo AS Código, dbo.PARTI.Descripc AS Descripción, dbo.PARTI.Clave AS [Clave Especial], dbo.PARTI.Proveedo AS Proveedor, 
                      dbo.PARTI.TipoArti AS oTipo, dbo.PARTI.CodBarra AS [Código EAN],
                    dbo.PARTI.Pvp_01 AS [Precio Venta Base], 
                      dbo.PARTI.Iva, dbo.PCOBA.CBarras
FROM         dbo.PARTI INNER JOIN
                      dbo.PCOBA ON dbo.PARTI.GRP_ID = dbo.PCOBA.GRP_ID AND dbo.PARTI.Codigo = dbo.PCOBA.Codigo
WHERE     (dbo.PARTI.Activo = '1') AND (dbo.PARTI.Selector = '1') AND (dbo.PARTI.GRP_ID = 'e_000001j')