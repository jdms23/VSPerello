SELECT      dbo.uvw_FIC_SSELP_PCTAS01.GRP_ID, 
                      dbo.uvw_FIC_SSELP_PCTAS01.C�digo, dbo.uvw_FIC_SSELP_PCTAS01.Nombre, dbo.uvw_FIC_SSELP_PCTAS01.[Raz�n Social], 
                      dbo.uvw_FIC_SSELP_PCTAS01.Domicilio, dbo.uvw_FIC_SSELP_PCTAS01.Localidad, dbo.uvw_FIC_SSELP_PCTAS01.Pa�s, 
                      dbo.uvw_FIC_SSELP_PCTAS01.Provincia, dbo.uvw_FIC_SSELP_PCTAS01.[C�digo Postal], dbo.uvw_FIC_SSELP_PCTAS01.Nif, 
                      dbo.uvw_FIC_SSELP_PCTAS01.[N� Tel�fono], dbo.uvw_FIC_SSELP_PCTAS01.[N� Tel�fono 2], dbo.uvw_FIC_SSELP_PCTAS01.[N� Fax], 
                      dbo.uvw_FIC_SSELP_PCTAS01.[Clave Especial], dbo.uvw_FIC_SSELP_PCTAS01.[Direcci�n E-Mail], dbo.uvw_FIC_SSELP_PCTAS01.[Direcci�n Web], 
                      dbo.uvw_FIC_SSELP_PCTAS01.[Fecha Alta], 
                      dbo.uvw_FIC_SSELP_PCTAS01.[Cuenta Compras], 
                      dbo.uvw_FIC_SSELP_PCTAS01.[Nombre Cuenta Compras],  dbo.PCTAC.IVA
  
FROM         dbo.uvw_FIC_SSELP_PCTAS01 INNER JOIN
                      dbo.PCTAC ON dbo.uvw_FIC_SSELP_PCTAS01.GRP_ID = dbo.PCTAC.GRP_ID AND dbo.uvw_FIC_SSELP_PCTAS01.C�digo = dbo.PCTAC.Codigo