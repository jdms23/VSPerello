
--- VISTA CON STOCK POR ALMACEN Y UBICACION DEL STOCK PROPIO
--
--  Esta vista recoge el stock por almacen y ubicacion del articulo '00r0vibl5', como ejemplo para que veais como generar el 
-- stock llegado el momento.


SELECT     TOP 100 PERCENT dbo.PEXIS.GRP_ID, dbo.PEXIS.Almacen AS Almacén, dbo.PEXIS.Articulo AS Artículo, ISNULL(dbo.PPTEX.Partida, '') AS Partida, 
                      ISNULL(dbo.PPART.Descript, '') AS Descript, CASE WHEN (dbo.PPTEX.Partida IS NULL) THEN SUM(dbo.PEXIS.CantEco) 
                      ELSE SUM(dbo.PPTEX.CantEco) END AS [Unidades Económicas], CASE WHEN (dbo.PPTEX.Partida IS NULL) THEN SUM(dbo.PEXIS.CantMan) 
                      ELSE SUM(dbo.PPTEX.CantMan) END AS [Unidades Manipulación]
FROM         dbo.PEXIS INNER JOIN
                      dbo.PTIST ON dbo.PEXIS.TipStock = dbo.PTIST.Codigo AND dbo.PEXIS.GRP_ID = dbo.PTIST.GRP_ID LEFT OUTER JOIN
                      dbo.PPTEX ON dbo.PPTEX.Almacen = dbo.PEXIS.Almacen AND dbo.PPTEX.GRP_ID = dbo.PEXIS.GRP_ID AND 
                      dbo.PEXIS.Articulo = dbo.PPTEX.Articulo AND dbo.PEXIS.TipStock = dbo.PPTEX.TipStock LEFT OUTER JOIN
                      dbo.PPART ON dbo.PPTEX.Almacen = dbo.PPART.Almacen AND dbo.PPTEX.GRP_ID = dbo.PPART.GRP_ID AND 
                      dbo.PPART.Articulo = dbo.PPTEX.Articulo AND dbo.PPART.Partida = dbo.PPTEX.Partida
WHERE     (dbo.PEXIS.TipStock = 'Dep')
GROUP BY dbo.PEXIS.GRP_ID, dbo.PEXIS.Almacen, dbo.PEXIS.Articulo, dbo.PPTEX.Partida, dbo.PPART.Descript
HAVING      (dbo.PEXIS.Articulo = '00r0vibl5') AND (CASE WHEN (dbo.PPTEX.Partida IS NULL) THEN SUM(dbo.PEXIS.CantEco) ELSE SUM(dbo.PPTEX.CantEco) 
                      END > 0)