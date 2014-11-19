SELECT     TOP 100 PERCENT dbo.PDIRE.Cliente AS C�digo, dbo.PDIRE.Ficha, dbo.PDIRE.Nombre, dbo.PDIRE.Domicili AS Domicilio, 
                      dbo.PDIRE.Localida AS Localidad, dbo.GPAI1.Nombre AS Provincia, dbo.GPAI0.Nombre AS Pa�s, dbo.PDIRE.CPostal AS [C�digo Postal], 
                      dbo.PDIRE.Tlfno_1 AS [N� Tel�fono], dbo.PDIRE.Fax AS [N� Fax], dbo.PDIRE.GRP_ID
FROM         dbo.PDIRE LEFT OUTER JOIN
                      dbo.GPAI0 ON dbo.PDIRE.Pais = dbo.GPAI0.CodPais LEFT OUTER JOIN
                      dbo.GPAI1 ON dbo.PDIRE.Pais = dbo.GPAI1.CodPais AND dbo.PDIRE.Provinci = dbo.GPAI1.CodProvi
WHERE     (dbo.PDIRE.GRP_ID = 'E_000001J')
ORDER BY dbo.PDIRE.Ficha