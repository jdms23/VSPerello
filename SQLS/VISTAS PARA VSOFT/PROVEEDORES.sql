SELECT      dbo.uvw_FIC_SSELP_PCTAS01.GRP_ID, 
                      dbo.uvw_FIC_SSELP_PCTAS01.Código, dbo.uvw_FIC_SSELP_PCTAS01.Nombre, dbo.uvw_FIC_SSELP_PCTAS01.[Razón Social], 
                      dbo.uvw_FIC_SSELP_PCTAS01.Domicilio, dbo.uvw_FIC_SSELP_PCTAS01.Localidad, dbo.uvw_FIC_SSELP_PCTAS01.País, 
                      dbo.uvw_FIC_SSELP_PCTAS01.Provincia, dbo.uvw_FIC_SSELP_PCTAS01.[Código Postal], dbo.uvw_FIC_SSELP_PCTAS01.Nif, 
                      dbo.uvw_FIC_SSELP_PCTAS01.[Nº Teléfono], dbo.uvw_FIC_SSELP_PCTAS01.[Nº Teléfono 2], dbo.uvw_FIC_SSELP_PCTAS01.[Nº Fax], 
                      dbo.uvw_FIC_SSELP_PCTAS01.[Clave Especial], dbo.uvw_FIC_SSELP_PCTAS01.[Dirección E-Mail], dbo.uvw_FIC_SSELP_PCTAS01.[Dirección Web], 
                      dbo.uvw_FIC_SSELP_PCTAS01.[Fecha Alta], 
                      dbo.uvw_FIC_SSELP_PCTAS01.[Cuenta Compras], 
                      dbo.uvw_FIC_SSELP_PCTAS01.[Nombre Cuenta Compras],  dbo.PCTAC.IVA
  
FROM         dbo.uvw_FIC_SSELP_PCTAS01 INNER JOIN
                      dbo.PCTAC ON dbo.uvw_FIC_SSELP_PCTAS01.GRP_ID = dbo.PCTAC.GRP_ID AND dbo.uvw_FIC_SSELP_PCTAS01.Código = dbo.PCTAC.Codigo