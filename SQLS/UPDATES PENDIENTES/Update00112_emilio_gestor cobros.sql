USE vs_martinez
GO

/****** Object:  View [dbo].[vf_emp_recibos_ventas]    Script Date: 03/06/2012 17:24:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [dbo].[vf_emp_recibos_ventas]
AS
SELECT     emp_efectos.empresa, numero, tipo, ejercicio, codigo_tipo_documento, serie, fecha_factura, numero_factura, situacion, subcuenta, importe, emp_efectos.codigo_tercero, importe_pendiente, 
                      emp_efectos.adjuntos, emp_efectos.observaciones, clave_entidad, clave_sucursal, digito_control, cuenta_corriente, emp_efectos.sys_logs, emp_efectos.sys_borrado, emp_efectos.sys_timestamp, numero_vto, emp_efectos.sys_oid, 
                      numero_remesa, fecha_vto, codigo_banco, fecha_libramiento, documento_pago, importe_pagado, fecha_pago, codigo_tipo_efecto, su_factura, empresa_origen, 
                      provisional, emp_efectos.codigo_cliente, pdf_generado,gastos_financieros_dev,emp_clientes_cond_venta.codigo_representante,emp_clientes.codigo_gestor_cobros
FROM         dbo.emp_efectos
				left outer join dbo.emp_clientes on dbo.emp_clientes.empresa = dbo.emp_efectos.empresa_origen AND dbo.emp_clientes.codigo = dbo.emp_efectos.codigo_cliente
                   left outer join dbo.emp_clientes_cond_venta on dbo.emp_clientes_cond_venta.empresa = dbo.emp_efectos.empresa_origen 
						AND dbo.emp_clientes_cond_venta.codigo_cliente = dbo.emp_efectos.codigo_cliente and dbo.emp_clientes_cond_venta.predeterminada = 1
WHERE     (tipo = 'V')



GO


