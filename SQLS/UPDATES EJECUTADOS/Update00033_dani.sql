USE [vs_martinez]
GO

/****** Object:  View [dbo].[vf_emp_existencias]    Script Date: 01/23/2012 10:42:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vf_emp_existencias]  WITH ENCRYPTION AS 
SELECT     dbo.emp_existencias.empresa, dbo.emp_existencias.codigo_almacen, dbo.emp_existencias.codigo_ubicacion, dbo.emp_existencias.codigo_articulo, 
                      dbo.emp_existencias.partida, dbo.emp_existencias.stock, dbo.emp_existencias.stock_reservado, dbo.emp_existencias.stock_disponible, 
                      dbo.emp_existencias.stock_pendiente, dbo.emp_existencias.stock_previsto, dbo.emp_existencias.fecha_entrada, dbo.emp_existencias.codigo_proveedor, 
                      dbo.emp_articulos.descripcion AS descripcion_articulo, dbo.emp_articulos.codigo_familia, dbo.emp_familias.descripcion AS descripcion_familia, 
                      dbo.emp_existencias.sys_oid, dbo.emp_articulos.control_stock, dbo.emp_existencias.precio_ultima_compra, dbo.emp_existencias.precio_medio_coste
FROM         dbo.emp_familias LEFT OUTER JOIN
                      dbo.emp_articulos ON dbo.emp_familias.empresa = dbo.emp_articulos.empresa AND dbo.emp_familias.codigo = dbo.emp_articulos.codigo_familia RIGHT OUTER JOIN
                      dbo.emp_existencias ON dbo.emp_articulos.empresa = dbo.emp_existencias.empresa AND dbo.emp_articulos.codigo = dbo.emp_existencias.codigo_articulo

GO
/****** Object:  Trigger [dbo].[vf_articulos_almacenes_stock_bi]    Script Date: 01/23/2012 10:35:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create TRIGGER [dbo].[vf_emp_existencias_bd]
   ON  [dbo].[vf_emp_existencias]
WITH ENCRYPTION   INSTEAD OF DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
    DELETE emp_existencias
	  FROM emp_existencias as E 
		INNER JOIN deleted as d ON E.sys_oid = d.sys_oid
END
go 

create TRIGGER [dbo].[vf_emp_existencias_bu]
   ON  [dbo].[vf_emp_existencias]
   INSTEAD OF UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for trigger here
    UPDATE emp_existencias SET [empresa] = i.empresa
      ,[codigo_almacen] = i.codigo_almacen
      ,[codigo_ubicacion] = i.codigo_ubicacion
      ,[codigo_articulo] = i.codigo_articulo
      ,[partida] = i.partida
      ,[stock] = i.stock
      ,[stock_reservado] = i.stock_reservado
      ,[stock_disponible] = i.stock_disponible
      ,[stock_pendiente] = i.stock_pendiente
      ,[stock_previsto] = i.stock_previsto
      ,[fecha_entrada] = i.fecha_entrada
      ,[codigo_proveedor] = i.codigo_proveedor
      ,[precio_ultima_compra] = i.precio_ultima_compra
      ,[precio_medio_coste] = i.precio_medio_coste
	  FROM emp_existencias as E
		INNER JOIN inserted as i ON E.sys_oid = i.sys_oid
	
END

go
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[vf_emp_existencias_bi]
   ON  [dbo].[vf_emp_existencias]
WITH ENCRYPTION INSTEAD OF INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for trigger here
    INSERT INTO emp_existencias ([empresa]
      ,[codigo_almacen]
      ,[codigo_ubicacion]
      ,[codigo_articulo]
      ,[partida]
      ,[stock]
      ,[stock_reservado]
      ,[stock_disponible]
      ,[stock_pendiente]
      ,[stock_previsto]
      ,[fecha_entrada]
      ,[codigo_proveedor]
      ,[precio_ultima_compra]
      ,[precio_medio_coste])
	SELECT [empresa]
      ,[codigo_almacen]
      ,[codigo_ubicacion]
      ,[codigo_articulo]
      ,[partida]
      ,[stock]
      ,[stock_reservado]
      ,[stock_disponible]
      ,[stock_pendiente]
      ,[stock_previsto]
      ,[fecha_entrada]
      ,[codigo_proveedor]
      ,[precio_ultima_compra]
      ,[precio_medio_coste]
	  FROM inserted
  
END
