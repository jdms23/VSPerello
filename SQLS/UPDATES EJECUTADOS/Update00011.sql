/*
USE vs_martinez
GO 

ALTER TABLE EMP_PRECIOS_CLIENTES DROP COLUMN CODIGO_TARIFA
ALTER TABLE EMP_PRECIOS_CLIENTES ADD identificador_dir_envio DM_ENTERO_CORTO

GO 

ALTER VIEW [dbo].[vv_precios_clientes]
WITH ENCRYPTION AS
SELECT     dbo.emp_precios_clientes.empresa, dbo.emp_precios_clientes.codigo, dbo.emp_precios_clientes.tipo, dbo.emp_precios_clientes.codigo_grupo, 
                      dbo.emp_precios_clientes.codigo_cliente, dbo.emp_precios_clientes.codigo_articulo, dbo.emp_precios_clientes.codigo_familia, dbo.emp_precios_clientes.precio, 
                      dbo.emp_precios_clientes.dto1, dbo.emp_precios_clientes.dto2, dbo.emp_precios_clientes.precio_neto, dbo.emp_precios_clientes.desde_unidades, 
                      dbo.emp_precios_clientes.hasta_unidades, dbo.emp_precios_clientes.sys_oid, dbo.emp_terceros.razon_social AS razon_social_cliente, 
                      dbo.emp_grupos_clientes.descripcion AS descripcion_grupo, dbo.emp_articulos.descripcion AS descripcion_articulo, 
                      dbo.emp_familias.descripcion AS descripcion_familia, dbo.emp_precios_clientes.identificador_dir_envio
FROM         dbo.emp_precios_clientes LEFT OUTER JOIN
                      dbo.emp_familias ON dbo.emp_precios_clientes.codigo_familia = dbo.emp_familias.codigo AND 
                      dbo.emp_precios_clientes.empresa = dbo.emp_familias.empresa LEFT OUTER JOIN
                      dbo.emp_articulos ON dbo.emp_precios_clientes.empresa = dbo.emp_articulos.empresa AND 
                      dbo.emp_precios_clientes.codigo_articulo = dbo.emp_articulos.codigo LEFT OUTER JOIN
                      dbo.emp_grupos_clientes ON dbo.emp_precios_clientes.empresa = dbo.emp_grupos_clientes.empresa AND 
                      dbo.emp_precios_clientes.codigo_grupo = dbo.emp_grupos_clientes.codigo LEFT OUTER JOIN
                      dbo.emp_terceros INNER JOIN
                      dbo.emp_clientes ON dbo.emp_terceros.empresa = dbo.emp_clientes.empresa AND dbo.emp_terceros.codigo = dbo.emp_clientes.codigo_tercero ON 
                      dbo.emp_precios_clientes.empresa = dbo.emp_clientes.empresa AND dbo.emp_precios_clientes.codigo_cliente = dbo.emp_clientes.codigo

GO

ALTER TRIGGER [dbo].[vv_precios_clientes_bi]
   ON  [dbo].[vv_precios_clientes]
WITH ENCRYPTION INSTEAD OF INSERT 
AS 
BEGIN
	SET NOCOUNT ON
	DECLARE @pCodigo dm_char_corto
	DECLARE @pEmpresa dm_empresas
	SET @pEmpresa = (SELECT empresa FROM inserted)
	EXEC vs_proximo_numero_serie @pEmpresa, '', '', 'PRECIOSCLI', null, 1, @pCodigo OUTPUT
	INSERT INTO emp_precios_clientes ( [empresa],[codigo],[tipo],[codigo_grupo],[codigo_cliente],[codigo_articulo],[codigo_familia],
		[precio],[dto1],[dto2],[precio_neto],[desde_unidades],[hasta_unidades],identificador_dir_envio )
		 --SELECT [empresa],ISNULL([codigo],CONVERT(int,@pCodigo)),[tipo],[codigo_grupo],[codigo_cliente],[codigo_articulo],[codigo_familia],
		 SELECT [empresa],CONVERT(int,@pCodigo),[tipo],[codigo_grupo],[codigo_cliente],[codigo_articulo],[codigo_familia],
		[precio],[dto1],[dto2],[precio_neto],[desde_unidades],[hasta_unidades],identificador_dir_envio 
		 FROM inserted

END

GO

ALTER TRIGGER [dbo].[vv_precios_clientes_bu] 
   ON  [dbo].[vv_precios_clientes]
WITH ENCRYPTION INSTEAD OF UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	UPDATE emp_precios_clientes SET 
		tipo=i.tipo,
		codigo_grupo=i.codigo_grupo,
		codigo_cliente=i.codigo_cliente,
		codigo_articulo=i.codigo_articulo,
		[codigo_familia]=i.codigo_familia,
		[precio]=i.precio
		,[dto1]=i.dto1
		,[dto2]=i.dto2
		,[precio_neto]=i.precio_neto
		,[desde_unidades]=i.[desde_unidades]
		,[hasta_unidades]=i.hasta_unidades
		,IDENTIFICADOR_DIR_ENVIO = i.identificador_dir_envio
	 FROM emp_precios_clientes AS C INNER JOIN inserted AS I on c.sys_oid = i.sys_oid
END

GO 

ALTER TABLE EMP_REPRESENTANTES ADD es_de_calle DM_LOGICO DEFAULT(0)
GO 

UPDATE EMP_REPRESENTANTES SET ES_DE_CALLE = 0
GO 

ALTER TRIGGER [dbo].[emp_representantes_au]
   ON  [dbo].[emp_representantes]
WITH ENCRYPTION  AFTER UPDATE
AS 
BEGIN
	DECLARE @codigo_empresa dm_empresas
	DECLARE @codigo dm_codigos_n
	DECLARE @codigo_tercero dm_codigos_c

	SET NOCOUNT ON;
	
	IF UPDATE(codigo_tercero)
	BEGIN

		DECLARE Borrados CURSOR LOCAL FOR 
		 SELECT empresa,codigo,codigo_tercero 
		   FROM deleted
		
		OPEN Borrados
		
		FETCH NEXT FROM Borrados INTO @codigo_empresa,@codigo,@codigo_tercero
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			IF (SELECT COUNT(*) 
			  FROM emp_representantes
			 where Empresa = @codigo_empresa 
			   and codigo_tercero = @codigo_tercero 
			   AND codigo <> @codigo) = 0
				update emp_terceros set es_representante = 0 
				 where empresa = @codigo_empresa and codigo = @codigo_tercero								
			
			FETCH NEXT FROM Borrados INTO @codigo_empresa,@codigo,@codigo_tercero
		END
		close borrados
		deallocate borrados
		
		UPDATE emp_terceros set es_representante = 1 
		  FROM emp_terceros
			INNER JOIN inserted ON inserted.empresa = emp_terceros.empresa 
				AND inserted.codigo_tercero = emp_terceros.codigo						
	END	
END

GO 

ALTER VIEW [dbo].[vf_emp_representantes]
WITH ENCRYPTION AS
SELECT     emp_representantes.empresa, emp_representantes.codigo_tercero, emp_representantes.codigo, emp_representantes.activo, emp_representantes.observaciones, 
			emp_representantes.adjuntos, emp_representantes.fecha_creacion, emp_representantes.fecha_modificacion, dbo.emp_terceros.nombre, 
            dbo.emp_terceros.razon_social, dbo.emp_terceros.nif, dbo.emp_terceros.domicilio, dbo.emp_terceros.codigo_postal, dbo.emp_terceros.poblacion, 
            dbo.emp_terceros.provincia, dbo.emp_terceros.telefono, dbo.emp_terceros.movil, dbo.emp_terceros.fax, dbo.emp_terceros.email, dbo.emp_terceros.web, 
            dbo.emp_terceros.sys_oid AS sys_oid_terceros, emp_representantes.sys_oid, emp_representantes.antiguedad, emp_representantes.irpf, emp_representantes.es_de_calle
FROM         emp_representantes 
	INNER JOIN dbo.emp_terceros ON emp_representantes.empresa = dbo.emp_terceros.empresa 
		AND emp_representantes.codigo_tercero = dbo.emp_terceros.codigo

GO


ALTER TRIGGER [dbo].[vf_emp_representantes_bi] 
   ON  [dbo].[vf_emp_representantes]
WITH ENCRYPTION INSTEAD OF INSERT
AS 
BEGIN
	DECLARE @sys_oid dm_oid
	DECLARE @codigo_tercero dm_codigos_n
	DECLARE @Codigo dm_char_corto
 	DECLARE @Empresa dm_empresas

	SET NOCOUNT ON;
	
	DECLARE Insertados CURSOR LOCAL FOR 
		SELECT sys_oid, empresa, codigo_tercero FROM inserted
		
	OPEN Insertados
	FETCH NEXT FROM Insertados INTO @sys_oid, @empresa, @codigo_tercero
	WHILE (@@FETCH_STATUS = 0)
	BEGIN		
		IF ISNULL(@codigo_tercero,0) = 0
		BEGIN
			EXEC vs_proximo_numero_serie @empresa, '', '', 'TERCEROS', null, 1, @Codigo OUTPUT
				
			INSERT INTO emp_terceros ( empresa, codigo, nombre,razon_social,nif,domicilio,codigo_postal,poblacion,provincia,telefono,
						movil, fax, email,web) 
				SELECT empresa,CONVERT(int,@Codigo),nombre,razon_social,nif,domicilio,codigo_postal,poblacion,provincia,telefono,
				   	   movil, fax, email,web 
				  FROM inserted 
				 WHERE sys_oid = @sys_oid
			  
			INSERT INTO emp_representantes (empresa, codigo_tercero, codigo, activo, observaciones, adjuntos, fecha_creacion, fecha_modificacion, antiguedad, irpf, es_de_calle) 
			 SELECT empresa, CONVERT(int,@Codigo), codigo, activo, observaciones, adjuntos, fecha_creacion, fecha_modificacion, antiguedad, irpf, es_de_calle 
			   FROM inserted
			  WHERE sys_oid = @sys_oid				
		END
		ELSE	
		BEGIN
			UPDATE emp_terceros SET 
				nombre=i.nombre, 
				razon_social = i.razon_social, 
				nif=i.nif, 
				domicilio=i.domicilio, 
				codigo_postal=i.codigo_postal,
				poblacion=i.poblacion, 
				provincia=i.provincia, 
				telefono=i.telefono, 
				movil=i.movil, 
				fax =i.fax, 
				email=i.email, 
				web=i.web
			  FROM emp_terceros AS T 
				INNER JOIN inserted AS i ON T.sys_oid = i.sys_oid_terceros
			 WHERE i.sys_oid = @sys_oid

			INSERT INTO emp_representantes (empresa, codigo_tercero, codigo, activo, observaciones, adjuntos, fecha_creacion, fecha_modificacion, antiguedad, irpf, es_de_calle) 
				SELECT empresa, codigo_tercero, codigo, activo, observaciones, adjuntos, fecha_creacion, fecha_modificacion, antiguedad, irpf, es_de_calle 
				FROM inserted
			   WHERE sys_oid = @sys_oid
		END
		
		FETCH NEXT FROM Insertados INTO @sys_oid, @empresa, @codigo_tercero
	END 		
		
END

GO 

ALTER TRIGGER [dbo].[vf_emp_representantes_bu] 
   ON  [dbo].[vf_emp_representantes]
WITH ENCRYPTION  INSTEAD OF UPDATE
AS 
BEGIN
	SET NOCOUNT ON
	UPDATE emp_representantes SET 
		empresa=i.empresa,
		codigo_tercero=i.codigo_tercero,
		codigo=i.codigo,
		activo=i.activo,
		observaciones=i.observaciones,
		adjuntos=i.adjuntos,
		fecha_creacion=i.fecha_creacion,
		fecha_modificacion=i.fecha_modificacion,
		antiguedad=i.antiguedad,
		irpf=i.irpf,
		es_de_calle=i.es_de_calle
	FROM emp_representantes AS C 
		INNER JOIN inserted AS I on c.sys_oid = i.sys_oid
		
	UPDATE emp_terceros SET 
		nombre=i.nombre, 
		razon_social = i.razon_social, 
		nif=i.nif, 
		domicilio=i.domicilio, 
		codigo_postal=i.codigo_postal,
		poblacion=i.poblacion, 
		provincia=i.provincia, 
		telefono=i.telefono, 
		movil=i.movil, 
		fax =i.fax, 
		email=i.email, 
		web=i.web
	FROM emp_terceros AS t
		INNER JOIN inserted as i ON t.sys_oid = i.sys_oid_terceros
END

GO 

ALTER TRIGGER [dbo].[eje_venta_c_bi]
   ON  [dbo].[eje_venta_c]
WITH ENCRYPTION  INSTEAD OF INSERT
AS 
BEGIN
	DECLARE @codigo_tipo_documento dm_codigos_c
	SET NOCOUNT ON;
	
	SET @codigo_tipo_documento = (SELECT TOP 1 codigo_tipo_documento FROM inserted)
	IF  @codigo_tipo_documento <> 'TV'  
		INSERT INTO eje_venta_c (
				empresa,ejercicio,codigo_tipo_documento,serie,codigo_tipo_cond_venta,numero,fecha,situacion,codigo_tercero
				,codigo_cliente,nombre_cliente,razon_social_cliente,nif_cliente,domicilio_cliente,codigo_postal_cliente
				,poblacion_cliente,provincia_cliente,codigo_forma_pago,codigo_Tabla_iva,codigo_representante,dto_comercial
				,dto_financiero,numero_copias,observaciones,observaciones_internas,adjuntos,codigo_pais_cliente,referencia
				,codigo_divisa,cambio_divisa,codigo_tarifa,identificador_dir_envio,alias_dir_envio,nombre_dir_envio,domicilio_dir_envio
				,sucursal_dir_envio,codigo_postal_dir_envio,poblacion_dir_envio,provincia_dir_envio,codigo_pais_dir_envio
				,telefono_dir_envio,movil_dir_envio,email_dir_envio,fax_dir_envio,codigo_portes,codigo_tipo_iva_portes,aplicar_en_totales_portes
				,importe_portes,cargo_financiero,realizado_por,codigo_agencia,periodo,piramidal,aplicar_cargo_financiero
				,codigo_centro_venta,criterio_conjuntacion,aplicar_cargo_financiero_dias,compensar_abono
				,identificador_banco, nombre_banco, domicilio_banco, sucursal_banco, codigo_postal_banco, poblacion_banco
			,provincia_banco, iban_code_banco, swift_code_banco, clave_entidad_banco, clave_sucursal_banco, digito_control_banco
			, cuenta_corriente_banco)
		 SELECT empresa,ejercicio,codigo_tipo_documento,serie,codigo_tipo_cond_venta,numero,fecha,situacion,codigo_tercero
				,codigo_cliente,nombre_cliente,razon_social_cliente,nif_cliente,domicilio_cliente,codigo_postal_cliente
				,poblacion_cliente,provincia_cliente,codigo_forma_pago,codigo_Tabla_iva,codigo_representante,dto_comercial
				,dto_financiero,numero_copias,observaciones,observaciones_internas,adjuntos,codigo_pais_cliente,referencia
				,codigo_divisa,cambio_divisa,codigo_tarifa,identificador_dir_envio,alias_dir_envio,nombre_dir_envio,domicilio_dir_envio
				,sucursal_dir_envio,codigo_postal_dir_envio,poblacion_dir_envio,provincia_dir_envio,codigo_pais_dir_envio,telefono_dir_envio
				,movil_dir_envio,email_dir_envio,fax_dir_envio,codigo_portes,codigo_tipo_iva_portes,aplicar_en_totales_portes
				,importe_portes,cargo_financiero,realizado_por,codigo_agencia
				  ,(SELECT PR.periodo
					FROM eje_periodos AS PR WHERE i.empresa = pr.empresa AND i.ejercicio = PR.ejercicio AND 
					i.fecha between pr.desde_fecha and pr.hasta_fecha AND PR.tipo LIKE '%G%')
					,piramidal,aplicar_cargo_financiero,codigo_centro_venta,criterio_conjuntacion,aplicar_cargo_financiero_dias,compensar_abono
					,identificador_banco, nombre_banco, domicilio_banco, sucursal_banco, codigo_postal_banco, poblacion_banco
			,provincia_banco, iban_code_banco, swift_code_banco, clave_entidad_banco, clave_sucursal_banco, digito_control_banco
			, cuenta_corriente_banco
		  			FROM inserted AS i
	ELSE
		
		/***Dejamos el identificador dir envio para poder buscar por la piramidal 
			Aunque eliminamos el resto de campos porque es un ticket ***/
		
		INSERT INTO eje_venta_c (
				empresa,ejercicio,codigo_tipo_documento,serie,codigo_tipo_cond_venta,numero,fecha,situacion,codigo_tercero
				,codigo_cliente,nombre_cliente,razon_social_cliente,nif_cliente,domicilio_cliente,codigo_postal_cliente
				,poblacion_cliente,provincia_cliente,codigo_forma_pago,codigo_Tabla_iva,codigo_representante,dto_comercial
				,dto_financiero,numero_copias,observaciones,observaciones_internas,adjuntos,codigo_pais_cliente,referencia
				,codigo_divisa,cambio_divisa,codigo_tarifa,identificador_dir_envio,alias_dir_envio,nombre_dir_envio,domicilio_dir_envio
				,sucursal_dir_envio,codigo_postal_dir_envio,poblacion_dir_envio,provincia_dir_envio,codigo_pais_dir_envio
				,telefono_dir_envio,movil_dir_envio,email_dir_envio,fax_dir_envio,codigo_portes,codigo_tipo_iva_portes,aplicar_en_totales_portes
				,importe_portes,cargo_financiero,realizado_por,codigo_agencia,periodo,piramidal,aplicar_cargo_financiero,codigo_centro_venta,criterio_conjuntacion
				,aplicar_cargo_financiero_dias,compensar_abono
				,identificador_banco, nombre_banco, domicilio_banco, sucursal_banco, codigo_postal_banco, poblacion_banco
			,provincia_banco, iban_code_banco, swift_code_banco, clave_entidad_banco, clave_sucursal_banco, digito_control_banco
			, cuenta_corriente_banco
				)				
		 SELECT i.empresa,i.ejercicio,i.codigo_tipo_documento,i.serie,i.codigo_tipo_cond_venta,i.numero,i.fecha,i.situacion,C.codigo_tercero
				,C.codigo,C.nombre,C.razon_social,C.nif,C.domicilio,C.codigo_postal
				,C.poblacion,C.provincia,i.codigo_forma_pago,i.codigo_Tabla_iva,i.codigo_representante,i.dto_comercial
				,i.dto_financiero,i.numero_copias,i.observaciones,i.observaciones_internas,i.adjuntos,C.codigo_pais,i.referencia
				,i.codigo_divisa,i.cambio_divisa,i.codigo_tarifa,i.identificador_dir_envio,'',c.nombre,C.domicilio
				,'',c.codigo_postal,C.poblacion,C.provincia,C.codigo_pais,''
				,'','','',i.codigo_portes,i.codigo_tipo_iva_portes,i.aplicar_en_totales_portes
				,i.importe_portes,i.cargo_financiero,i.realizado_por,i.codigo_agencia
				  ,(SELECT PR.periodo
					FROM eje_periodos AS PR WHERE i.empresa = pr.empresa AND i.ejercicio = PR.ejercicio AND 
					i.fecha between pr.desde_fecha and pr.hasta_fecha AND PR.tipo LIKE '%G%')
					,i.codigo_cliente,aplicar_cargo_financiero,codigo_centro_venta,i.criterio_conjuntacion,i.aplicar_cargo_financiero_dias,i.compensar_abono
					,identificador_banco, nombre_banco, domicilio_banco, sucursal_banco, codigo_postal_banco, poblacion_banco
			,provincia_banco, iban_code_banco, swift_code_banco, clave_entidad_banco, clave_sucursal_banco, digito_control_banco
			, cuenta_corriente_banco
		  			FROM inserted AS i 
		  				INNER JOIN gen_empresas AS E ON e.codigo = i.empresa
		  					INNER JOIN vf_emp_clientes AS C ON C.empresa = E.codigo AND C.codigo = E.codigo_clientes_tickets		
END

GO 

CREATE VIEW [dbo].[vf_venta_lineas_movimientos]
WITH ENCRYPTION AS
SELECT     dbo.eje_venta_c.empresa, dbo.eje_venta_c.ejercicio, dbo.eje_venta_c.codigo_tipo_documento, dbo.eje_venta_c.serie, dbo.eje_venta_c.numero, 
                      dbo.eje_venta_c.fecha, dbo.eje_venta_c.codigo_cliente, dbo.eje_venta_c.identificador_dir_envio, dbo.eje_venta_c.nombre_cliente, 
                      dbo.eje_venta_c.razon_social_cliente, dbo.eje_venta_c.nif_cliente, dbo.eje_venta_t.cuota_dto_comercial, dbo.eje_venta_t.cuota_dto_financiero, 
                      dbo.eje_venta_c.dto_comercial, dbo.eje_venta_c.dto_financiero, dbo.eje_venta_t.base_imponible, dbo.eje_venta_t.cuota_iva, dbo.eje_venta_t.cuota_re, 
                      dbo.eje_venta_t.neto_lineas, dbo.eje_venta_t.total, dbo.eje_venta_t.cuota_cargo_financiero, dbo.eje_venta_c.sys_oid, 
                      dbo.gen_tipos_documentos.descripcion AS tipo_documento, dbo.eje_venta_c.situacion, dbo.emp_formas_pago.descripcion AS descripcion_forma_pago, 
                      dbo.eje_venta_c.codigo_representante, CASE WHEN vf_emp_representantes.nombre IS NULL OR
                      LEN(vf_emp_representantes.nombre) = 0 THEN 'SIN REPRESENTANTE' ELSE vf_emp_representantes.nombre END AS nombre_representante, 
                      dbo.eje_venta_c.domicilio_cliente, dbo.eje_venta_c.poblacion_cliente, dbo.eje_venta_c.provincia_cliente, dbo.eje_venta_t.entrega_a_cuenta, 
                      dbo.eje_venta_t.fecha_entrega, ISNULL(dbo.emp_clientes.codigo_tercero, dbo.eje_venta_c.codigo_tercero) AS codigo_tercero, dbo.gen_tipos_documentos.pantalla_asociada, dbo.eje_venta_c.compensar_abono, 
                      dbo.eje_venta_t.importe_compensado, dbo.eje_venta_t.pendiente_compensar, dbo.eje_venta_t.abonos_compensados, dbo.eje_venta_c.codigo_tipo_cond_venta, 
                      dbo.emp_centros.descripcion AS centro_venta, dbo.emp_series.descripcion as descripcion_serie, dbo.eje_venta_c.codigo_forma_pago, 
                      CASE WHEN dbo.eje_venta_c.codigo_postal_cliente IS NULL THEN 'Sin CP' WHEN LEN(dbo.eje_venta_c.codigo_postal_cliente) 
                      = 0 THEN 'Sin CP' ELSE dbo.eje_venta_c.codigo_postal_cliente END AS codigo_postal_cliente, dbo.eje_venta_c.piramidal,
                      eje_venta_l.linea, eje_venta_l.codigo_almacen, eje_venta_l.codigo_Articulo, eje_venta_l.descripcion, dbo.emp_articulos.descripcion as descripcion_articulo, 
                      emp_articulos.codigo_familia, emp_familias.descripcion as descripcion_familia, eje_venta_l.unidades, eje_venta_l.precio, eje_venta_l.precio_e, eje_venta_l.precio_coste,
                      eje_venta_l.dto1, eje_venta_l.dto2, eje_venta_l.total_linea, eje_venta_l.observaciones, eje_venta_l.iva, eje_venta_l.re, eje_venta_l.codigo_tipo_iva, 
                      eje_venta_l.codigo_ubicacion, eje_venta_l.subcuenta_ventas
FROM         dbo.eje_venta_c INNER JOIN
                      dbo.eje_venta_t ON dbo.eje_venta_c.empresa = dbo.eje_venta_t.empresa AND dbo.eje_venta_c.ejercicio = dbo.eje_venta_t.ejercicio AND 
                      dbo.eje_venta_c.codigo_tipo_documento = dbo.eje_venta_t.codigo_tipo_documento AND dbo.eje_venta_c.serie = dbo.eje_venta_t.serie AND 
                      dbo.eje_venta_c.numero = dbo.eje_venta_t.numero INNER JOIN
                      dbo.gen_tipos_documentos ON dbo.eje_venta_c.codigo_tipo_documento = dbo.gen_tipos_documentos.codigo INNER JOIN
                      dbo.emp_series ON dbo.eje_venta_c.empresa = dbo.emp_series.empresa AND dbo.eje_venta_c.ejercicio = dbo.emp_series.ejercicio AND 
                      dbo.eje_venta_c.serie = dbo.emp_series.codigo AND dbo.eje_venta_c.codigo_tipo_documento = dbo.emp_series.codigo_tipo_documento LEFT OUTER JOIN
                      dbo.emp_centros ON dbo.eje_venta_c.codigo_centro_venta = dbo.emp_centros.codigo AND dbo.eje_venta_c.empresa = dbo.emp_centros.empresa LEFT OUTER JOIN
                      dbo.emp_formas_pago ON dbo.eje_venta_c.empresa = dbo.emp_formas_pago.empresa AND 
                      dbo.eje_venta_c.codigo_forma_pago = dbo.emp_formas_pago.codigo LEFT OUTER JOIN
                      dbo.vf_emp_representantes ON dbo.eje_venta_c.empresa = dbo.vf_emp_representantes.empresa AND 
                      dbo.eje_venta_c.codigo_representante = dbo.vf_emp_representantes.codigo LEFT OUTER JOIN 
                      dbo.emp_clientes ON dbo.eje_venta_c.empresa = dbo.emp_clientes.empresa AND dbo.eje_venta_c.piramidal = dbo.emp_clientes.codigo LEFT OUTER JOIN 
                      dbo.eje_venta_l ON dbo.eje_venta_c.empresa = dbo.eje_venta_l.empresa AND dbo.eje_venta_c.ejercicio = dbo.eje_venta_l.ejercicio AND 
                      dbo.eje_venta_c.codigo_tipo_documento = dbo.eje_venta_l.codigo_tipo_documento AND dbo.eje_venta_c.serie = dbo.eje_venta_l.serie AND 
                      dbo.eje_venta_c.numero = dbo.eje_venta_l.numero LEFT OUTER JOIN 
                      dbo.emp_articulos ON dbo.eje_venta_l.empresa = dbo.emp_articulos.empresa AND dbo.eje_venta_l.codigo_Articulo = dbo.emp_articulos.codigo LEFT OUTER JOIN 
                      dbo.emp_familias ON dbo.emp_articulos.empresa = dbo.emp_familias.empresa AND dbo.emp_articulos.codigo_familia = dbo.emp_familias.codigo
                                            
GO

*/