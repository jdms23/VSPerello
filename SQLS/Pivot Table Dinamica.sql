DECLARE @empresas as varchar(max)
DECLARE @SQLPivotTabla varchar(max)

set @empresas = ''
select @empresas = @empresas + N',[' + rtrim(nombre) + N']' FROM gen_empresas
 
set @empresas = SUBSTRING(@empresas, 2, LEN(@empresas) - 1)

set @SQLPivotTabla = 'SELECT * FROM (SELECT empresa_contabilizar as empresa, nombre_representante, ISNULL(base_imponible, 0) AS total FROM vr_venta_cabecera WHERE codigo_tipo_documento IN (''AV'',''TV'')) AS TableOrigen PIVOT (SUM(total) FOR empresa IN ([SANEAMIENTO MARTINEZ, S.L.],[GRUP CST BATMAR, S.L.],[MACC, S.L.])) AS A'

execute(@SQLPivotTabla)