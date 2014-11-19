
use vs_martinez
go 

ALTER TABLE emp_clientes_cond_venta ADD agrupar_por_dir_envio dm_logico DEFAULT(0);
go 

UPDATE emp_clientes_cond_venta SET agrupar_por_dir_envio = 0
go 

ALTER VIEW [dbo].[vv_albaranes_pendientes_facturar] with encryption
AS
SELECT     dbo.vv_venta_c_alba.sys_oid, dbo.vv_venta_c_alba.empresa, dbo.vv_venta_c_alba.ejercicio, dbo.vv_venta_c_alba.periodo, 
                      dbo.vv_venta_c_alba.codigo_tipo_documento, dbo.vv_venta_c_alba.serie, dbo.vv_venta_c_alba.numero, dbo.vv_venta_c_alba.codigo_tipo_cond_venta, 
                      dbo.vv_venta_c_alba.fecha, dbo.vv_venta_c_alba.situacion, dbo.vv_venta_c_alba.codigo_cliente, dbo.vv_venta_c_alba.razon_social_cliente, 
                      dbo.vv_venta_c_alba.nif_cliente, dbo.vv_venta_c_alba.codigo_forma_pago, dbo.vv_venta_c_alba.codigo_tabla_iva, dbo.vv_venta_c_alba.codigo_representante, 
                      dbo.vv_venta_c_alba.dto_comercial, dbo.vv_venta_c_alba.dto_financiero, dbo.vv_venta_c_alba.identificador_dir_envio, dbo.vv_venta_c_alba.total, 
                      dbo.vv_venta_c_alba.base_imponible, dbo.vv_venta_c_alba.cuota_iva, dbo.emp_clientes_cond_venta.no_agrupar_albaranes, 
                      dbo.emp_clientes_cond_venta.facturacion_mensual, dbo.emp_clientes_cond_venta.agrupar_por_dir_envio, dbo.emp_clientes_cond_venta.serie_facturas, 
                      dbo.emp_clientes.codigo_grupo,dbo.emp_grupos_clientes.descripcion AS descripcion_grupo, dbo.emp_series.descripcion AS descripcion_serie, 
                      dbo.vv_venta_c_alba.criterio_conjuntacion,dbo.vv_venta_c_alba.cargo_financiero, dbo.emp_series.empresa_contabilizar, 
                      dbo.emp_tipos_facturacion.descripcion AS tipo_facturacion
FROM         dbo.vv_venta_c_alba INNER JOIN
                      dbo.emp_clientes ON dbo.vv_venta_c_alba.empresa = dbo.emp_clientes.empresa AND 
                      dbo.vv_venta_c_alba.codigo_cliente = dbo.emp_clientes.codigo LEFT OUTER JOIN
                      dbo.emp_series ON dbo.vv_venta_c_alba.codigo_tipo_documento = dbo.emp_series.codigo_tipo_documento AND 
                      dbo.vv_venta_c_alba.empresa = dbo.emp_series.empresa AND dbo.vv_venta_c_alba.ejercicio = dbo.emp_series.ejercicio AND 
                      dbo.vv_venta_c_alba.serie = dbo.emp_series.codigo LEFT OUTER JOIN
                      dbo.emp_tipos_facturacion ON dbo.emp_clientes.codigo_tipo_facturacion = dbo.emp_tipos_facturacion.codigo AND 
                      dbo.emp_clientes.empresa = dbo.emp_tipos_facturacion.empresa LEFT OUTER JOIN
                      dbo.emp_clientes_cond_venta ON dbo.vv_venta_c_alba.empresa = dbo.emp_clientes_cond_venta.empresa AND 
                      dbo.vv_venta_c_alba.codigo_cliente = dbo.emp_clientes_cond_venta.codigo_cliente AND 
                      dbo.vv_venta_c_alba.codigo_tipo_cond_venta = dbo.emp_clientes_cond_venta.codigo_tipo_cond_venta LEFT OUTER JOIN
                      dbo.emp_grupos_clientes ON dbo.emp_clientes.empresa = dbo.emp_grupos_clientes.empresa AND 
                      dbo.emp_clientes.codigo_grupo = dbo.emp_grupos_clientes.codigo
WHERE (dbo.vv_venta_c_alba.situacion = 'N' OR dbo.vv_venta_c_alba.situacion = 'IMP') 
	AND (dbo.vv_venta_c_alba.albaran_retenido IS NULL OR dbo.vv_venta_c_alba.albaran_retenido = 0)
	
