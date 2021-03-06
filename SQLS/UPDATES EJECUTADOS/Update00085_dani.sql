USE [vs_martinez]
GO
/****** Object:  StoredProcedure [dbo].[vs_emitir_efectos_compra]    Script Date: 02/17/2012 09:45:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[vs_emitir_efectos_compra]
	   @empresa dm_empresas
      ,@ejercicio dm_ejercicios
      ,@codigo_tipo_documento dm_codigos_c
      ,@serie dm_codigos_c
      ,@numero dm_numero_doc
AS
BEGIN

	DECLARE @empresa_destino dm_empresas
	
	SET NOCOUNT OFF

set @empresa_destino=(select empresa_contabilizar from emp_series where empresa=@empresa and codigo_tipo_documento=@codigo_tipo_documento and codigo=@serie and ejercicio=@ejercicio)

-- DELETE FROM emp_efectos WHERE empresa=@empresa AND ejercicio=@ejercicio AND codigo_tipo_documento=@codigo_tipo_documento AND serie=@serie AND numero_factura=@numero AND tipo = 'V'
INSERT INTO emp_efectos (empresa,numero,tipo,ejercicio,codigo_tipo_documento,serie,numero_factura,fecha_factura,situacion,su_factura,
	subcuenta,codigo_tercero,codigo_proveedor,importe,importe_pendiente,  numero_vto,fecha_vto,numero_remesa,fecha_libramiento,importe_pagado,documento_pago,codigo_tipo_efecto,empresa_origen)
SELECT @empresa_destino, RTRIM(vtos.serie)+'/'+rtrim(vtos.ejercicio)+'/'+RTRIM(vtos.numero) + '-' + ltrim(rtrim(str(vtos.numero_vto))),'C',vtos.ejercicio,vtos.codigo_tipo_documento
		  ,vtos.serie,vtos.numero,fra.su_fecha_factura,'CA',fra.su_factura,
	ctas.subcuenta, fra.codigo_tercero,fra.codigo_proveedor,vtos.importe,vtos.importe,vtos.numero_vto, vtos.fecha_vto,'' docpago,FRA.fecha,0,NULL,FP.codigo_tipo_efecto,@empresa
	FROM eje_compra_vtos as vtos 
	INNER JOIN vv_compra_c_factura as fra ON fra.empresa = vtos.empresa AND fra.ejercicio = vtos.ejercicio AND fra.codigo_tipo_documento = vtos.codigo_tipo_documento
		  AND fra.serie = vtos.SERIE AND fra.numero = vtos.numero
	LEFT JOIN eje_proveedores_cond_compra_cuentas as ctas ON ctas.empresa = fra.empresa AND ctas.ejercicio = fra.ejercicio 
		  AND ctas.codigo_proveedor = fra.codigo_proveedor AND ctas.codigo_tipo_cond_compra = fra.codigo_tipo_cond_compra
	LEFT JOIN dbo.emp_formas_pago AS FP ON fra.empresa = FP.empresa AND fra.codigo_forma_pago = FP.codigo		
	where vtos.empresa=@empresa and vtos.ejercicio=@ejercicio and vtos.codigo_tipo_documento=@codigo_tipo_documento and vtos.serie=@serie and vtos.numero=@numero
END