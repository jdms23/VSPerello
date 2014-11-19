use vs_martinez
go 

select emp_efectos.sys_oid as id_recibo, emp_efectos.tipo as tipo_recibo, emp_efectos.empresa_origen, emp_efectos.empresa, numero, serie, numero_factura, situacion, importe, emp_efectos.codigo_tipo_efecto, gen_tipos_efectos.descripcion as descripcion_tipo_efecto, 
	emp_efectos.codigo_cliente, vf_emp_clientes.nombre as nombre_cliente, emp_clientes_cond_venta.codigo_forma_pago, emp_formas_pago.codigo_tipo_efecto as tipo_efecto_cliente, gen_tipos_efectos_fp.descripcion as descripcion_tipo_efecto_forma_pago
  from emp_efectos
	LEFT OUTER JOIN gen_tipos_efectos on gen_tipos_efectos.codigo = emp_efectos.codigo_tipo_efecto
	LEFT OUTER JOIN vf_emp_clientes on vf_emp_clientes.empresa = emp_efectos.empresa_origen AND vf_emp_clientes.codigo = emp_efectos.codigo_cliente
		LEFT OUTER JOIN emp_clientes_cond_venta ON emp_clientes_cond_venta.empresa = vf_emp_clientes.empresa and emp_clientes_cond_venta.codigo_cliente = vf_emp_clientes.codigo AND emp_clientes_cond_venta.codigo_tipo_cond_venta = '1'
		LEFT OUTER JOIN emp_formas_pago ON emp_formas_pago.empresa = emp_clientes_cond_venta.empresa and emp_formas_pago.codigo = emp_clientes_cond_venta.codigo_forma_pago
		LEFT OUTER JOIN gen_tipos_efectos as gen_tipos_efectos_fp on gen_tipos_efectos_fp.codigo = emp_formas_pago.codigo_tipo_efecto
	 where emp_efectos.clave_entidad = '0000'	
   and emp_efectos.tipo = 'V'
   order by codigo_cliente,situacion