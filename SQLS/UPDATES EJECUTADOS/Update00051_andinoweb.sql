USE [vs_martinez]
GO

/****** Object:  View [dbo].[vw_emp_clientes]    Script Date: 01/25/2012 18:48:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_emp_clientes]
AS
SELECT     dbo.emp_terceros.nombre, dbo.emp_terceros.razon_social, dbo.emp_terceros.nif, dbo.emp_terceros.domicilio, dbo.emp_terceros.codigo_postal, 
                      dbo.emp_terceros.poblacion, dbo.emp_terceros.provincia, dbo.emp_terceros.telefono, dbo.emp_terceros.movil, dbo.emp_terceros.fax, dbo.emp_terceros.email, 
                      dbo.emp_terceros.web, dbo.emp_terceros.sys_oid AS sys_oid_terceros, dbo.emp_clientes.empresa, dbo.emp_clientes.codigo_tercero, dbo.emp_clientes.codigo, 
                      dbo.emp_clientes.activo, dbo.emp_clientes.riesgo_maximo, dbo.emp_clientes.riesgo_cyc, dbo.emp_clientes.riesgo_contable, 
                      dbo.emp_clientes.observaciones_riesgo, dbo.emp_clientes.bloqueado, dbo.emp_clientes.razon_bloqueado, dbo.emp_clientes.observaciones, 
                      dbo.emp_clientes.adjuntos, dbo.emp_clientes.fecha_creacion, dbo.emp_clientes.fecha_modificacion, dbo.emp_clientes.sys_logs, dbo.emp_clientes.sys_borrado, 
                      dbo.emp_clientes.sys_timestamp, dbo.emp_clientes.sys_oid, dbo.emp_clientes.codigo_grupo, dbo.emp_clientes.codigo_banco_cobro, 
                      dbo.emp_clientes.solo_tickets, dbo.emp_clientes.evolucion_credito, dbo.emp_clientes.evolucion_bdi, dbo.emp_clientes.tipo_cliente_bdi, 
                      dbo.emp_clientes.ventas_e_impagados, dbo.emp_clientes.margen_maniobra_riesgo, dbo.emp_clientes.codigo_zona, dbo.emp_clientes.codigo_gestor_cobros, 
                      dbo.emp_clientes.codigo_tipo_facturacion, dbo.emp_clientes.observaciones_bloqueo, dbo.emp_clientes.criterio_facturacion1, dbo.emp_clientes.criterio_facturacion2, 
                      dbo.emp_clientes.criterio_facturacion3, dbo.emp_clientes.activo_web, dbo.emp_clientes.usuario_web, dbo.emp_clientes.password_web, 
                      dbo.emp_terceros.codigo_pais, dbo.gen_paises.nombre AS nombre_pais, dbo.emp_clientes.excluir_ofertas, dbo.emp_clientes.observaciones_internas_bloqueo, 
                      dbo.emp_clientes.codigo_subzona, dbo.emp_clientes.codigo_almacen_habitual, dbo.emp_clientes.compensar_abonos, 
                      dbo.emp_gestor_cobros.descripcion AS descripcion_gestor_cobro, dbo.emp_clientes.codigo_ruta_reparto, dbo.emp_clientes.report_albaranes, 
                      dbo.emp_clientes.subir_web
FROM         dbo.emp_clientes INNER JOIN
                      dbo.emp_terceros ON dbo.emp_clientes.empresa = dbo.emp_terceros.empresa AND dbo.emp_clientes.codigo_tercero = dbo.emp_terceros.codigo LEFT OUTER JOIN
                      dbo.emp_gestor_cobros ON dbo.emp_clientes.empresa = dbo.emp_gestor_cobros.empresa AND 
                      dbo.emp_clientes.codigo_gestor_cobros = dbo.emp_gestor_cobros.codigo LEFT OUTER JOIN
                      dbo.gen_paises ON dbo.emp_terceros.codigo_pais = dbo.gen_paises.codigo

GO