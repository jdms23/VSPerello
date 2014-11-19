USE [vs_alcaraz]
GO

/****** Object:  View [dbo].[vf_emp_clientes_cond_venta_cuentas]    Script Date: 02/26/2012 12:00:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vf_emp_clientes_cond_venta_cuentas]
AS
SELECT     dbo.emp_clientes_cond_venta.empresa, dbo.emp_clientes_cond_venta.codigo_cliente, dbo.emp_clientes_cond_venta.codigo_tipo_cond_venta, 
                      dbo.eje_clientes_cond_venta_cuentas.ejercicio, dbo.emp_clientes_cond_venta.codigo_forma_pago, dbo.emp_clientes_cond_venta.dia_pago1, 
                      dbo.emp_clientes_cond_venta.dia_pago2, dbo.emp_clientes_cond_venta.dia_pago3, dbo.emp_clientes_cond_venta.vacaciones_desde, 
                      dbo.emp_clientes_cond_venta.vacaciones_hasta, dbo.emp_clientes_cond_venta.descuento_comercial, dbo.emp_clientes_cond_venta.descuento_financiero, 
                      dbo.emp_clientes_cond_venta.aplicar_cargo_financiero, dbo.emp_clientes_cond_venta.aplicar_cargo_financiero_dias, dbo.emp_clientes_cond_venta.codigo_tarifa, 
                      dbo.emp_clientes_cond_venta.dto_lineas_1, dbo.emp_clientes_cond_venta.dto_lineas_2, dbo.emp_clientes_cond_venta.no_agrupar_albaranes, 
                      dbo.emp_clientes_cond_venta.facturacion_mensual, dbo.emp_clientes_cond_venta.serie_pedidos, dbo.emp_clientes_cond_venta.serie_albaranes, 
                      dbo.emp_clientes_cond_venta.serie_facturas, dbo.emp_clientes_cond_venta.serie_abonos_facturas, dbo.emp_clientes_cond_venta.albaran_valorado, 
                      dbo.emp_clientes_cond_venta.numero_copias_pedido, dbo.emp_clientes_cond_venta.numero_copias_albaran, 
                      dbo.emp_clientes_cond_venta.numero_copias_factura, dbo.emp_clientes_cond_venta.sys_oid, dbo.emp_clientes_cond_venta.codigo_tabla_iva, 
                      dbo.emp_clientes_cond_venta.codigo_representante, dbo.emp_clientes_cond_venta.codigo_zona, dbo.emp_clientes_cond_venta.predeterminada, 
                      dbo.emp_clientes_cond_venta.codigo_divisa, dbo.emp_clientes_cond_venta.agrupar_por_dir_envio, dbo.eje_clientes_cond_venta_cuentas.subcuenta, 
                      dbo.eje_clientes_cond_venta_cuentas.subcuenta_efectos, dbo.eje_clientes_cond_venta_cuentas.subcuenta_riesgo, 
                      dbo.eje_clientes_cond_venta_cuentas.subcuenta_impagados, dbo.eje_clientes_cond_venta_cuentas.sys_oid AS sys_oid_cuentas
FROM         dbo.emp_clientes_cond_venta INNER JOIN
                      dbo.eje_clientes_cond_venta_cuentas ON dbo.emp_clientes_cond_venta.empresa = dbo.eje_clientes_cond_venta_cuentas.empresa AND 
                      dbo.emp_clientes_cond_venta.codigo_cliente = dbo.eje_clientes_cond_venta_cuentas.codigo_cliente AND 
                      dbo.emp_clientes_cond_venta.codigo_tipo_cond_venta = dbo.eje_clientes_cond_venta_cuentas.codigo_tipo_cond_venta

GO

CREATE TRIGGER [dbo].[vf_emp_clientes_cond_venta_cuentas_bd]
   ON [dbo].[vf_emp_clientes_cond_venta_cuentas]
   INSTEAD OF DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	DELETE [emp_clientes_cond_venta] 
		FROM emp_clientes_cond_venta
			inner join deleted as d ON emp_clientes_cond_venta.sys_oid = d.sys_oid

/*Aunque este no hace falta por la clave ajena en cascada*/			
	DELETE [eje_clientes_cond_venta_cuentas]
      from eje_clientes_cond_venta_cuentas
       inner join deleted as d on eje_clientes_cond_venta_cuentas.sys_oid = d.sys_oid_cuentas
END
GO

CREATE TRIGGER [dbo].[vf_emp_clientes_cond_venta_cuentas_bi]
   ON [dbo].[vf_emp_clientes_cond_venta_cuentas]
   INSTEAD OF INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	INSERT INTO [emp_clientes_cond_venta]
           ([empresa],[codigo_cliente],[codigo_tipo_cond_venta],[codigo_forma_pago],[dia_pago1],[dia_pago2],[dia_pago3]
           ,[vacaciones_desde],[vacaciones_hasta],[descuento_comercial],[descuento_financiero],[aplicar_cargo_financiero]
           ,[aplicar_cargo_financiero_dias],[codigo_tarifa],[dto_lineas_1],[dto_lineas_2],[no_agrupar_albaranes],[facturacion_mensual]
           ,[serie_pedidos],[serie_albaranes],[serie_facturas],[serie_abonos_facturas],[albaran_valorado],[numero_copias_pedido]
           ,[numero_copias_albaran],[numero_copias_factura],[codigo_tabla_iva],[codigo_representante],[codigo_zona]
           ,[predeterminada],[codigo_divisa],[agrupar_por_dir_envio])
         SELECT [empresa],[codigo_cliente],[codigo_tipo_cond_venta],[codigo_forma_pago],[dia_pago1],[dia_pago2],[dia_pago3]
           ,[vacaciones_desde],[vacaciones_hasta],[descuento_comercial],[descuento_financiero],[aplicar_cargo_financiero]
           ,[aplicar_cargo_financiero_dias],[codigo_tarifa],[dto_lineas_1],[dto_lineas_2],[no_agrupar_albaranes],[facturacion_mensual]
           ,[serie_pedidos],[serie_albaranes],[serie_facturas],[serie_abonos_facturas],[albaran_valorado],[numero_copias_pedido]
           ,[numero_copias_albaran],[numero_copias_factura],[codigo_tabla_iva],[codigo_representante],[codigo_zona]
           ,[predeterminada],[codigo_divisa],[agrupar_por_dir_envio]
           FROM inserted

	INSERT INTO [eje_clientes_cond_venta_cuentas]
           ([empresa],[ejercicio],[codigo_cliente],[codigo_tipo_cond_venta],[subcuenta],[subcuenta_efectos]
           ,[subcuenta_riesgo],[subcuenta_impagados])     
	SELECT [empresa],[ejercicio],[codigo_cliente],[codigo_tipo_cond_venta],[subcuenta],[subcuenta_efectos]
           ,[subcuenta_riesgo],[subcuenta_impagados]
      FROM inserted



END
GO 

CREATE TRIGGER [dbo].[vf_emp_clientes_cond_venta_cuentas_bu]
   ON [dbo].[vf_emp_clientes_cond_venta_cuentas]
   INSTEAD OF UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	UPDATE [emp_clientes_cond_venta] SET
		codigo_tipo_cond_venta = i.codigo_tipo_cond_venta,
	       [codigo_forma_pago]=i.codigo_forma_pago,
	       [dia_pago1]=i.dia_pago1,
	       [dia_pago2]=i.dia_pago2,
	       [dia_pago3]=i.dia_pago3,
	       [vacaciones_desde]=i.vacaciones_desde,
	       [vacaciones_hasta]=i.vacaciones_hasta,
	       [descuento_comercial]=i.descuento_comercial,
	       [descuento_financiero]=i.descuento_financiero,
	       [aplicar_cargo_financiero]=i.aplicar_cargo_financiero,
	       [aplicar_cargo_financiero_dias]=i.aplicar_cargo_financiero_dias,
	       [codigo_tarifa]=i.codigo_tarifa,
	       [dto_lineas_1]=i.dto_lineas_1,
	       [dto_lineas_2]=i.dto_lineas_2,
	       [no_agrupar_albaranes]=i.no_agrupar_albaranes,
	       [facturacion_mensual]=i.facturacion_mensual,
	       [serie_pedidos]=i.serie_pedidos,
	       [serie_albaranes]=i.serie_albaranes,
	       [serie_facturas]=i.serie_facturas,
	       [serie_abonos_facturas]=i.serie_abonos_facturas,
	       [albaran_valorado]=i.albaran_valorado,
	       [numero_copias_pedido]=i.numero_copias_pedido,
	       [numero_copias_albaran]=i.numero_copias_albaran,
	       [numero_copias_factura]=i.numero_copias_factura,
	       [codigo_tabla_iva]=i.codigo_tabla_iva,
	       [codigo_representante]=i.codigo_representante,
	       [codigo_zona]=i.codigo_zona,
	       [predeterminada]=i.predeterminada,
	       [codigo_divisa]=i.codigo_divisa,
	       [agrupar_por_dir_envio]=i.agrupar_por_dir_envio
		FROM emp_clientes_cond_venta
			inner join inserted as i ON emp_clientes_cond_venta.sys_oid = i.sys_oid
			
	UPDATE [eje_clientes_cond_venta_cuentas] SET
           [subcuenta] = i.subcuenta,
           [subcuenta_efectos] = i.subcuenta_efectos,
           [subcuenta_riesgo]=i.subcuenta_riesgo,
           [subcuenta_impagados]=i.subcuenta_impagados
      from eje_clientes_cond_venta_cuentas
       inner join inserted as i on eje_clientes_cond_venta_cuentas.sys_oid = i.sys_oid_cuentas
END
