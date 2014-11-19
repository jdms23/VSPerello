
-- LISTA DE CUENTAS FINANCIERAS
-- EL CAMPO DE RELACION CON LA VISTA DE CLIENTES ES EL CAMPO CUENTA
-- (EN LA VISTA DE CLIENTES ES EL CAMPO CODIGO
-- En esta vista podeis ver el campo clase cuenta, el cual es un 1 para CLIENTES y un 0 para PROVEEDORES
-- EL CAMPO GRP_ID, ES LA EMPRESA...
-- E_000001J CORRESPONDE A MARTINEZ
-- E_000002J CORRESPONDE A BATMAR
-- E_000003J CORRESPONDE A AME
-- E_000007J CORRESPONDE A MACC
-- LOS 3 ULTIMOS CAMPOS CORRESPONDEN A SUBCUENTAS DE CLIENTES, IMPAGADOS Y CARTES

SELECT     dbo.FACDE.Codigo AS Cuenta, dbo.FACDE.Nombre, dbo.FACDE.RiesgoLi AS [Crédito Máximo], dbo.FACDE.ClaseCta AS [Clase Cuenta], 
                      dbo.FACDE.DomicilA AS Domicilio, dbo.FACDE.LocalidA AS Localidad, dbo.GPAI1.Nombre AS Provincia, dbo.GPAI0.Nombre AS País, 
                      dbo.FACDE.Tercero AS Titular, dbo.FTERC.Nombre AS [Nombre Titular], dbo.FTERC.IdFiscal AS NIF, dbo.FACDE.CodBanco AS Entidad, 
                      dbo.FACDE.CodAgenc AS Sucursal, dbo.FACDE.DigCtrol AS DC, dbo.FACDE.NumCta AS [Nº Cuenta], dbo.FACDE.ConTelef AS [Nº Teléfono], 
                      dbo.FACDE.Fax AS [Nº Fax], dbo.FACDE.Entidad AS [Nombre Entidad], dbo.FACDE.Domicili AS [Domicilio Entidad], 
                      dbo.FACDE.Localid AS [Localidad Entidad], dbo.FACDE.Moneda, dbo.CMONE.Descrip AS [Nombre Moneda], dbo.FACDE.Modalida AS [Código Pago], 
                      dbo.SFPCA.Descripc AS [Descripción de Pago],  dbo.FACDE.GRP_ID, dbo.FACDE.CodPostA AS CPostal,
         		   dbo.FACDE.SubCoPla, dbo.FACDE.SubEfCob, dbo.FACDE.SubEfImp
FROM         dbo.FACDE LEFT OUTER JOIN
                      dbo.CMONE ON dbo.FACDE.Moneda = dbo.CMONE.Codigo AND dbo.FACDE.GRP_ID = dbo.CMONE.GRP_ID LEFT OUTER JOIN
                      dbo.SFPCA ON dbo.FACDE.Modalida = dbo.SFPCA.Codigo AND dbo.FACDE.GRP_ID = dbo.SFPCA.GRP_ID LEFT OUTER JOIN
                      dbo.GPAI1 ON dbo.FACDE.TerritoA = dbo.GPAI1.CodProvi AND dbo.FACDE.PaisA = dbo.GPAI1.CodPais LEFT OUTER JOIN
                      dbo.GPAI0 ON dbo.FACDE.PaisA = dbo.GPAI0.CodPais LEFT OUTER JOIN
                      dbo.FTERC ON dbo.FACDE.Tercero = dbo.FTERC.Codigo AND dbo.FACDE.GRP_ID = dbo.FTERC.GRP_ID

WHERE DBO.FACDE.GRP_ID NOT LIKE 'X%'