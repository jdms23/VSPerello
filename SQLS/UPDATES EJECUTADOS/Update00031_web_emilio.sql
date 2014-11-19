USE vs_martinez
GO

/****** Object:  View [dbo].[vf_emp_recibos_ventas]    Script Date: 01/19/2012 17:46:29 ******/

alter table emp_efectos add pdf_generado dm_logico null default(0)
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vf_emp_recibos_ventas] with encryption
AS
SELECT     empresa, numero, tipo, ejercicio, codigo_tipo_documento, serie, fecha_factura, numero_factura, situacion, subcuenta, importe, codigo_tercero, importe_pendiente, 
                      adjuntos, observaciones, clave_entidad, clave_sucursal, digito_control, cuenta_corriente, sys_logs, sys_borrado, sys_timestamp, numero_vto, sys_oid, 
                      numero_remesa, fecha_vto, codigo_banco, fecha_libramiento, documento_pago, importe_pagado, fecha_pago, codigo_tipo_efecto, su_factura, empresa_origen, 
                      provisional, codigo_cliente, pdf_generado
FROM         dbo.emp_efectos
WHERE     (tipo = 'V')

GO

ALTER VIEW [dbo].[vw_emp_recibos_ventas] with encryption
AS
SELECT     dbo.vf_emp_recibos_ventas.empresa, dbo.vf_emp_recibos_ventas.numero, dbo.vf_emp_recibos_ventas.tipo, dbo.vf_emp_recibos_ventas.ejercicio, 
                      dbo.vf_emp_recibos_ventas.codigo_tipo_documento, dbo.vf_emp_recibos_ventas.serie, dbo.vf_emp_recibos_ventas.fecha_factura, 
                      dbo.vf_emp_recibos_ventas.numero_factura, dbo.vf_emp_recibos_ventas.situacion, dbo.vf_emp_recibos_ventas.subcuenta, dbo.vf_emp_recibos_ventas.importe, 
                      dbo.vf_emp_recibos_ventas.codigo_tercero, dbo.vf_emp_recibos_ventas.importe_pendiente, dbo.vf_emp_recibos_ventas.adjuntos, 
                      dbo.vf_emp_recibos_ventas.observaciones, dbo.vf_emp_recibos_ventas.clave_entidad, dbo.vf_emp_recibos_ventas.clave_sucursal, 
                      dbo.vf_emp_recibos_ventas.digito_control, dbo.vf_emp_recibos_ventas.cuenta_corriente, dbo.vf_emp_recibos_ventas.numero_vto, 
                      dbo.vf_emp_recibos_ventas.sys_oid, dbo.vf_emp_recibos_ventas.numero_remesa, dbo.vf_emp_recibos_ventas.fecha_vto, 
                      dbo.vf_emp_recibos_ventas.codigo_banco, dbo.vf_emp_recibos_ventas.fecha_libramiento, dbo.vf_emp_recibos_ventas.documento_pago, 
                      dbo.vf_emp_recibos_ventas.importe_pagado, dbo.vf_emp_recibos_ventas.fecha_pago, dbo.vf_emp_recibos_ventas.codigo_tipo_efecto, 
                      dbo.vf_emp_recibos_ventas.su_factura, dbo.vf_emp_recibos_ventas.empresa_origen, dbo.vf_emp_recibos_ventas.provisional, 
                      dbo.vf_emp_clientes.codigo AS codigo_cliente, dbo.vf_emp_clientes.nombre AS nombre_cliente, dbo.vf_emp_recibos_ventas.pdf_generado
FROM         dbo.vf_emp_recibos_ventas LEFT OUTER JOIN
                      dbo.vf_emp_clientes ON dbo.vf_emp_recibos_ventas.codigo_tercero = dbo.vf_emp_clientes.codigo_tercero

GO

