USE [vs_alcaraz]
GO

/****** Object:  View [dbo].[vf_emp_proveedores_cond_compra_cuentas]    Script Date: 02/26/2012 12:30:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vf_emp_proveedores_cond_compra_cuentas]
AS
SELECT     dbo.emp_proveedores_cond_compra.empresa, dbo.eje_proveedores_cond_compra_cuentas.ejercicio, dbo.emp_proveedores_cond_compra.codigo_proveedor, 
                      dbo.emp_proveedores_cond_compra.codigo_tipo_cond_compra, dbo.emp_proveedores_cond_compra.codigo_forma_pago, 
                      dbo.emp_proveedores_cond_compra.dia_pago1, dbo.emp_proveedores_cond_compra.dia_pago2, dbo.emp_proveedores_cond_compra.dia_pago3, 
                      dbo.emp_proveedores_cond_compra.vacaciones_desde, dbo.emp_proveedores_cond_compra.vacaciones_hasta, 
                      dbo.emp_proveedores_cond_compra.descuento_comercial, dbo.emp_proveedores_cond_compra.dto_lineas_1, dbo.emp_proveedores_cond_compra.dto_lineas_2, 
                      dbo.emp_proveedores_cond_compra.dto_lineas_3, dbo.emp_proveedores_cond_compra.dto_lineas_4, dbo.emp_proveedores_cond_compra.sys_oid, 
                      dbo.emp_proveedores_cond_compra.codigo_tabla_iva, dbo.emp_proveedores_cond_compra.codigo_zona, dbo.emp_proveedores_cond_compra.predeterminada, 
                      dbo.emp_proveedores_cond_compra.codigo_divisa, dbo.emp_proveedores_cond_compra.irpf, dbo.emp_proveedores_cond_compra.descuento_financiero, 
                      dbo.emp_proveedores_cond_compra.cargo_financiero, dbo.emp_proveedores_cond_compra.serie_pedidos, dbo.emp_proveedores_cond_compra.serie_albaranes, 
                      dbo.emp_proveedores_cond_compra.serie_facturas, dbo.emp_proveedores_cond_compra.no_agrupar_albaranes, 
                      dbo.emp_proveedores_cond_compra.codigo_banco_pago, dbo.emp_proveedores_cond_compra.codigo_como_cliente, 
                      dbo.eje_proveedores_cond_compra_cuentas.subcuenta, dbo.eje_proveedores_cond_compra_cuentas.subcuenta_efectos, 
                      dbo.eje_proveedores_cond_compra_cuentas.sys_oid AS sys_oid_cuentas, dbo.eje_proveedores_cond_compra_cuentas.SUBCUENTA_COMPRAS
FROM         dbo.emp_proveedores_cond_compra INNER JOIN
                      dbo.eje_proveedores_cond_compra_cuentas ON dbo.emp_proveedores_cond_compra.empresa = dbo.eje_proveedores_cond_compra_cuentas.empresa AND 
                      dbo.emp_proveedores_cond_compra.codigo_proveedor = dbo.eje_proveedores_cond_compra_cuentas.codigo_proveedor AND 
                      dbo.emp_proveedores_cond_compra.codigo_tipo_cond_compra = dbo.eje_proveedores_cond_compra_cuentas.codigo_tipo_cond_compra

GO

create TRIGGER [dbo].[vf_emp_proveedores_cond_compra_cuentas_bd]
   ON [dbo].[vf_emp_proveedores_cond_compra_cuentas]
   INSTEAD OF DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	DELETE [emp_proveedores_cond_compra] 
		FROM emp_proveedores_cond_compra
			inner join deleted as d ON emp_proveedores_cond_compra.sys_oid = d.sys_oid

/*Aunque este no hace falta por la clave ajena en cascada*/			
	DELETE [eje_proveedores_cond_compra_cuentas]
      from eje_proveedores_cond_compra_cuentas
       inner join deleted as d on eje_proveedores_cond_compra_cuentas.sys_oid = d.sys_oid_cuentas
END

GO


CREATE TRIGGER [dbo].[vf_emp_proveedores_cond_compra_cuentas_bi] 
   ON  [dbo].[vf_emp_proveedores_cond_compra_cuentas]
   instead of INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO [emp_proveedores_cond_compra]
           ([empresa],[codigo_proveedor],[codigo_tipo_cond_compra],[codigo_forma_pago],[dia_pago1],[dia_pago2],[dia_pago3]
           ,[vacaciones_desde],[vacaciones_hasta],[descuento_comercial],[dto_lineas_1],[dto_lineas_2],[dto_lineas_3],[dto_lineas_4]
           ,[codigo_tabla_iva],[codigo_zona],[predeterminada],[codigo_divisa],[irpf],[descuento_financiero],[cargo_financiero]
           ,[serie_pedidos],[serie_albaranes],[serie_facturas],[no_agrupar_albaranes],[codigo_banco_pago],[codigo_como_cliente])
     select [empresa],[codigo_proveedor],[codigo_tipo_cond_compra],[codigo_forma_pago],[dia_pago1],[dia_pago2],[dia_pago3]
           ,[vacaciones_desde],[vacaciones_hasta],[descuento_comercial],[dto_lineas_1],[dto_lineas_2],[dto_lineas_3],[dto_lineas_4]
           ,[codigo_tabla_iva],[codigo_zona],[predeterminada],[codigo_divisa],[irpf],[descuento_financiero],[cargo_financiero]
           ,[serie_pedidos],[serie_albaranes],[serie_facturas],[no_agrupar_albaranes],[codigo_banco_pago],[codigo_como_cliente]
		from inserted           

	INSERT INTO [eje_proveedores_cond_compra_cuentas]
           ([empresa],[ejercicio],[codigo_proveedor],[codigo_tipo_cond_compra],[subcuenta],[subcuenta_efectos],[SUBCUENTA_COMPRAS])
	  select [empresa],[ejercicio],[codigo_proveedor],[codigo_tipo_cond_compra],[subcuenta],[subcuenta_efectos],[SUBCUENTA_COMPRAS]
	    from inserted

END

GO


CREATE TRIGGER [dbo].[vf_emp_proveedores_cond_compra_cuentas_bu]
   ON [dbo].[vf_emp_proveedores_cond_compra_cuentas]
   instead of update
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
UPDATE [emp_proveedores_cond_compra]
   SET [codigo_tipo_cond_compra] = i.codigo_tipo_cond_compra
      ,[codigo_forma_pago] = i.codigo_forma_pago
      ,[dia_pago1] = i.dia_pago1
      ,[dia_pago2] = i.dia_pago2
      ,[dia_pago3] = i.dia_pago3
      ,[vacaciones_desde] = i.vacaciones_desde
      ,[vacaciones_hasta] = i.vacaciones_hasta
      ,[descuento_comercial] = i.descuento_comercial
      ,[dto_lineas_1] = i.dto_lineas_1
      ,[dto_lineas_2] = i.dto_lineas_2
      ,[dto_lineas_3] = i.dto_lineas_3
      ,[dto_lineas_4] = i.dto_lineas_4
      ,[codigo_tabla_iva] = i.codigo_tabla_iva
      ,[codigo_zona] = i.codigo_zona
      ,[predeterminada] = i.predeterminada
      ,[codigo_divisa] = i.codigo_divisa
      ,[irpf] = i.irpf
      ,[descuento_financiero] = i.descuento_financiero
      ,[cargo_financiero] = i.cargo_financiero
      ,[serie_pedidos] = i.serie_pedidos
      ,[serie_albaranes] = i.serie_albaranes
      ,[serie_facturas] = i.serie_facturas
      ,[no_agrupar_albaranes] = i.no_agrupar_albaranes
      ,[codigo_banco_pago] = i.codigo_banco_pago
      ,[codigo_como_cliente] = i.codigo_como_cliente
  FROM emp_proveedores_cond_compra
   inner join inserted as i on emp_proveedores_cond_compra.sys_oid = i.sys_oid
   
UPDATE [eje_proveedores_cond_compra_cuentas]
   SET subcuenta = i.subcuenta,
	subcuenta_efectos = i.subcuenta_efectos,
	SUBCUENTA_COMPRAS = i.subcuenta_compras
  FROM eje_proveedores_cond_compra_cuentas
   inner join inserted as i on eje_proveedores_cond_compra_cuentas.sys_oid = i.sys_oid_cuentas
   

END

GO


