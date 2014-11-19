use vs_martinez
update sys_logs set registro = 'TIPO DOCUMENTO:' + codigo_tipo_documento + ' SERIE:'+ serie + 'NUMERO:' + numero + 'LINEA:' + convert(char(5),linea) + char(13) + RTRIM(sys_logs.registro) 
from sys_logs inner join eje_venta_l 
on sys_logs.sys_oid_tabla = eje_venta_l.sys_oid
where nombre_tabla='lticket_v' AND registro like '%cambio%' and not registro like '%NUMERO%'
