USE [vs_martinez]
GO

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
WITH ENCRYPTION AS
BEGIN

	DECLARE @empresa_destino dm_empresas
	
	SET NOCOUNT OFF

set @empresa_destino=(select empresa_contabilizar from emp_series where empresa=@empresa and codigo_tipo_documento=@codigo_tipo_documento and codigo=@serie and ejercicio=@ejercicio)

-- DELETE FROM emp_efectos WHERE empresa=@empresa AND ejercicio=@ejercicio AND codigo_tipo_documento=@codigo_tipo_documento AND serie=@serie AND numero_factura=@numero AND tipo = 'V'
INSERT INTO emp_efectos (empresa,numero,tipo,ejercicio,codigo_tipo_documento,serie,numero_factura,fecha_factura,situacion,su_factura,
	subcuenta,codigo_tercero,codigo_proveedor,importe,importe_pendiente,  numero_vto,fecha_vto,numero_remesa,fecha_libramiento,importe_pagado,documento_pago,codigo_tipo_efecto,empresa_origen)
SELECT @empresa_destino, RTRIM(vtos.numero) + '-' + ltrim(rtrim(str(vtos.numero_vto))),'C',fra.ejercicio,vtos.codigo_tipo_documento
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

GO
ALTER PROCEDURE [dbo].[vs_generar_asiento_pago_efecto] 
 @pSys_oid_efecto dm_oid
,@pfecha dm_fechas_hora
,@pcodigo_banco dm_codigos_c
,@importe dm_importes
,@pmetalico dm_logico
WITH ENCRYPTION AS
BEGIN

	declare @Empresa dm_empresas
	declare @ejercicio dm_ejercicios
	declare @codigo_tipo_apunte dm_codigos_c
	declare @codigo_concepto dm_codigos_c
	declare @patron dm_char_largo
	declare @sesion dm_entero
	declare @sys_timestamp dm_fechas_hora
	declare @nombre_proveedor dm_nombres
	declare @razon_social_proveedor dm_nombres
	declare @numero_factura dm_numero_doc
	declare @fecha_Factura dm_fechas_hora
	declare @numero_recibo dm_numero_doc
	declare @fecha dm_fechas_hora
	declare @apunte dm_entero
	declare @subcta_proveedor dm_subcuenta
	declare @subcta_banco dm_subcuenta
	declare @importe_metalico dm_importes
	declare @empresa_origen dm_empresas
	
	set @Sesion = @@SPID
	set @sys_timestamp = getdate()
	select  @empresa=empresa
			,@nombre_proveedor=nombre_proveedor
			,@razon_social_proveedor=razon_social_proveedor
			,@fecha_factura = fecha_factura
			,@numero_factura=numero_factura
			,@numero_recibo=numero
			,@subcta_proveedor=subcuenta			
			FROM  vv_recibos_compra
			WHERE sys_oid = @pSys_oid_efecto

	select @ejercicio = ejercicio from emp_ejercicios 
		where empresa=@empresa and fecha_apertura <= @pfecha and fecha_cierre>=@pfecha

	set @apunte = 1
	declare cursor_patron CURSOR FOR 
		select codigo_tipo_apunte,codigo_concepto,patron 
		  from emp_apuntes_patron as ap 
		   left join emp_asientos_patron as asto ON ap.empresa = asto.empresa and ap.codigo=asto.codigo 
		   inner join gen_empresas on gen_empresas.codigo = ap.empresa
		 where gen_empresas.matriz = 1 -- ap.empresa=@empresa 
		   and codigo_tipo_documento='RC' 
		
	OPEN cursor_patron
	FETCH NEXT FROM cursor_patron into @codigo_tipo_apunte,@codigo_concepto,@patron	
	WHILE @@FETCH_STATUS = 0
		BEGIN
		 SET @patron = REPLACE(@patron,'[nombre_proveedor]',RTRIM(@nombre_proveedor))
		 SET @patron = REPLACE(@patron,'[razon_social_proveedor]',RTRIM(@razon_social_proveedor))
		 SET @patron = REPLACE(@patron,'[numero_factura]',RTRIM(@numero_factura))
		 SET @patron = REPLACE(@patron,'[fecha_factura]',RTRIM(@fecha_factura))
		 SET @patron = REPLACE(@patron,'[numero_recibo]',RTRIM(@numero_recibo))
			IF @codigo_tipo_apunte = 'RC_BANCO' 			
					BEGIN
						set @subcta_banco = (select subcuenta from eje_bancos_subcuenta where empresa = @Empresa and ejercicio = @ejercicio and codigo_banco = @pcodigo_banco)
						INSERT INTO tmp_apuntes_traspaso
						 (apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,fecha,codigo_concepto,descripcion,subcuenta,importe_debe,importe_haber,serie_documento,numero_documento)
						 values (@apunte,@Empresa,@Ejercicio,@sys_timestamp,@sesion,'RC',@pSys_oid_efecto,@pFecha,@codigo_concepto,@patron,@subcta_banco,0,@importe,'',@numero_recibo)
						set @apunte = @apunte + 1	  
					END
			ELSE
				IF @codigo_tipo_apunte = 'RC_PROVEED' 
				BEGIN
					if @pmetalico = 1 
						set @importe_metalico = @importe 
					else	
						set @importe_metalico = 0						
					INSERT INTO tmp_apuntes_traspaso
						 (apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,fecha,codigo_concepto,descripcion,subcuenta,importe_debe,importe_haber,serie_documento,numero_documento,importe_metalico)
						 values (@apunte,@Empresa,@Ejercicio,@sys_timestamp,@sesion,'RC',@pSys_oid_efecto,@pFecha,@codigo_concepto,@patron,@subcta_proveedor,@importe,0,'',@numero_recibo,@importe_metalico)
					
					set @apunte = @apunte + 1
				END
			FETCH NEXT FROM cursor_patron into @codigo_tipo_apunte,@codigo_concepto,@patron	  
	end 
	
	IF @apunte > 1
		UPDATE emp_efectos SET situacion='PAG',
			fecha_pago=@pfecha,
			importe_pagado = ISNULL(importe_pagado,0) + @importe,
			importe_pendiente = ISNULL(importe,0) - (ISNULL(importe_pagado,0) + @importe),
			codigo_banco=@pcodigo_banco 
		WHERE sys_oid=@pSys_oid_efecto
	ELSE
		RAISERROR('NO SE GENERO NINGÚN APUNTE',16,1)		
	CLOSE cursor_patron
	DEALLOCATE cursor_patron
END

GO

ALTER VIEW [dbo].[vv_recibos_compra]  with encryption AS 
SELECT     dbo.emp_efectos.empresa, dbo.emp_efectos.numero, dbo.emp_efectos.tipo, dbo.emp_efectos.ejercicio, dbo.emp_efectos.codigo_tipo_documento, 
                      dbo.emp_efectos.serie, dbo.emp_efectos.numero_factura, dbo.emp_efectos.fecha_factura, dbo.emp_efectos.importe, dbo.emp_efectos.codigo_tercero, 
                      dbo.emp_efectos.numero_vto, dbo.emp_efectos.fecha_vto, dbo.vf_emp_proveedores.nombre as nombre_proveedor, dbo.vf_emp_proveedores.razon_social as razon_social_proveedor, 
                      dbo.emp_efectos.codigo_proveedor, dbo.vf_emp_proveedores.nif as nif_proveedor, emp_formas_pago.descripcion as descripcion_forma_pago, 
                      dbo.emp_efectos.fecha_libramiento, dbo.vf_emp_proveedores.domicilio as domicilio_proveedor, dbo.vf_emp_proveedores.codigo_postal as codigo_postal_proveedor, 
                      dbo.vf_emp_proveedores.poblacion as poblacion_proveedor, dbo.vf_emp_proveedores.provincia as provincia_proveedor, dbo.emp_efectos.sys_oid, 
                      dbo.gen_empresas.nombre AS nombre_empresa, dbo.gen_empresas.nif AS nif_empresa, dbo.gen_empresas.domicilio AS domicilio_empresa, 
                      dbo.gen_empresas.codigo_postal AS codigo_postal_empresa, dbo.gen_empresas.poblacion AS poblacion_empresa, 
                      dbo.gen_empresas.provincia AS codigo_provincia_empresa, dbo.gen_empresas.telefono AS telefono_empresa, dbo.gen_empresas.fax AS fax_empresa, 
                      dbo.gen_empresas.email AS email_empresa, dbo.gen_provincias.nombre AS provincia_empresa, dbo.emp_efectos.situacion, dbo.emp_efectos.numero_remesa, 
                      dbo.emp_efectos.codigo_banco, dbo.emp_efectos.importe_pagado, dbo.emp_efectos.documento_pago, dbo.emp_efectos.fecha_pago, 
                      dbo.emp_efectos.importe_pendiente, dbo.emp_efectos.subcuenta, dbo.emp_efectos.codigo_tipo_efecto, dbo.gen_tipos_efectos.remesable
FROM         dbo.emp_efectos LEFT OUTER JOIN
                      dbo.gen_tipos_efectos ON dbo.emp_efectos.codigo_tipo_efecto = dbo.gen_tipos_efectos.codigo LEFT OUTER JOIN
                      dbo.gen_empresas ON dbo.emp_efectos.empresa = dbo.gen_empresas.codigo LEFT OUTER JOIN
                      dbo.vf_emp_proveedores ON dbo.emp_efectos.empresa_origen = dbo.vf_emp_proveedores.empresa AND 
                      dbo.emp_efectos.codigo_proveedor= dbo.vf_emp_proveedores.codigo LEFT OUTER JOIN
                      dbo.gen_provincias ON dbo.gen_empresas.provincia = dbo.gen_provincias.codigo LEFT OUTER JOIN
                      eje_compra_c ON eje_compra_c.empresa = emp_efectos.empresa_origen and eje_compra_c.ejercicio = emp_efectos.ejercicio 
                      AND eje_compra_c.codigo_tipo_documento = emp_efectos.codigo_tipo_documento and eje_compra_c.serie = emp_efectos.serie
                      and eje_compra_c.numero = emp_efectos.numero_factura left outer join
                      emp_formas_pago ON emp_formas_pago.empresa = eje_compra_c.empresa and emp_formas_pago.codigo = eje_compra_c.codigo_forma_pago
WHERE     (dbo.emp_efectos.tipo = 'C')

GO
