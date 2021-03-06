USE [vs_martinez]
GO
/****** Object:  StoredProcedure [dbo].[vs_facturar_albaranes]    Script Date: 01/26/2012 18:46:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[vs_facturar_albaranes]
	@pTimeStamp dm_fechas_hora,
	@pSesion dm_entero,
	@pUsuario dm_codigos_c
WITH ENCRYPTION AS
BEGIN
SET NOCOUNT ON;
/***Para guardar el documento origen ***/
DECLARE @pEmpresaOrigen dm_empresas
DECLARE @pEjercicioOrigen dm_ejercicios
DECLARE @pCodigoTipoDocumentoOrigen dm_codigos_c
DECLARE @pSerieOrigen dm_codigos_c
DECLARE @pNumeroOrigen dm_numero_doc
DECLARE @pFechaOrigen dm_fechas_hora
DECLARE @pOidOrigen dm_oid

/***Doc. Destino***/
DECLARE @pEmpresa dm_empresas
DECLARE @pEjercicio dm_ejercicios
DECLARE @pSerie dm_codigos_c
DECLARE @pCodigo_tipo_documento dm_codigos_c
DECLARE @pFecha dm_fechas_hora
DECLARE @pFechaDevengo dm_fechas_hora
DECLARE	@pNumero dm_numero_doc
DECLARE @pGrupo dm_char_largo
DECLARE @pSys_oid dm_oid
DECLARE @pContador dm_entero_corto 
DECLARE @pSys_Oid_Tmp dm_oid
DECLARE @pSys_oid_destino dm_oid
DECLARE @pFechaCreacion dm_fechas_hora
DECLARE @pError varchar(4000)
DECLARE @pSys_oid_C_Destino dm_oid
DECLARE @pCodigo_Portes dm_codigos_c
DECLARE @pCodigo_Tipo_IVA_Portes dm_codigos_c
DECLARE @pAplicar_en_Totales_Portes dm_logico
DECLARE @pImporte_Portes dm_importes 

BEGIN TRY

	BEGIN TRANSACTION 
	/******************  CURSOR DE GRUPOS   **********************/
	DECLARE grupos CURSOR LOCAL FOR 
		SELECT grupo, max(fecha) 
		  FROM tmp_facturar_albaranes
		 WHERE sys_timestamp = @pTimeStamp
		   AND sesion = @pSesion 
		   AND generada = 0
		 GROUP BY grupo

	OPEN grupos
	FETCH NEXT FROM grupos INTO @pGrupo, @pFechaDevengo
	
	WHILE @@FETCH_STATUS=0
	BEGIN
	/*
		IF EXISTS (SELECT DISTINCT C.situacion 
			FROM tmp_facturar_albaranes AS S 
			INNER JOIN dbo.eje_venta_c AS C ON S.empresa = C.empresa AND S.ejercicio = C.ejercicio AND S.codigo_tipo_documento = C.codigo_tipo_documento 
			AND S.SERIE = C.serie AND S.numero = C.numero
			WHERE s.sys_timestamp = @pTimeStamp
			AND s.sesion=@pSesion 
			AND s.grupo = @pGrupo and s.generada = 0 AND C.situacion!='N')
			RAISERROR('YA SE HA GENERADO UNA FACTURA DEL ALBARAN',16,1)
			*/
	
	/******************  CURSOR DE FACTURAS   **********************/
		DECLARE facturas CURSOR LOCAL FOR 
		SELECT S.sys_oid_origen, C.empresa, C.ejercicio,C.codigo_tipo_documento, C.serie, C.Numero, C.Fecha, 
				C.[codigo_portes],C.[codigo_tipo_iva_portes],C.[aplicar_en_totales_portes],C.[importe_portes],
				S.empresa_destino, S.ejercicio_destino, S.codigo_tipo_documento_destino, S.serie_destino, S.fecha_destino, S.sys_oid
		  FROM dbo.tmp_facturar_albaranes AS S 
			INNER JOIN dbo.eje_venta_c AS C ON S.sys_oid_origen = C.sys_oid
  		 WHERE s.sys_timestamp = @pTimeStamp
			AND s.sesion=@pSesion 
			AND s.grupo = @pGrupo
			AND s.generada = 0
			AND c.situacion <> 'F'  /*Por si han facturado desde otra pantalla y lo teníamos en buffer*/

		OPEN facturas 
		FETCH NEXT FROM facturas INTO @pOidOrigen, @pEmpresaOrigen, @pEjercicioOrigen,@pCodigoTipoDocumentoOrigen, @pSerieOrigen,@pNumeroOrigen, @pFechaOrigen, 
			@pCodigo_Portes,@pCodigo_Tipo_IVA_Portes, @pAplicar_en_Totales_Portes, @pImporte_Portes, 
			@pEmpresa, @pEjercicio, @pCodigo_Tipo_Documento, @pSerie, @pFecha, @pSys_oid_tmp
	
		EXEC vs_proximo_numero_serie @pempresa, @pEjercicio, @pCodigo_Tipo_Documento, @pSerie,@pFecha, 1, @pNumero OUTPUT
		
		/***Creamos la cabecera del grupo***/
			
		INSERT INTO vv_venta_c_factura (
									[empresa],[ejercicio],[codigo_tipo_documento],[serie],[numero],[codigo_tipo_cond_venta],[fecha],[situacion]
									,[codigo_tercero],[codigo_cliente],[nombre_cliente],[razon_social_cliente],[nif_cliente],[domicilio_cliente]
									,[codigo_postal_cliente],[poblacion_cliente],[provincia_cliente],[codigo_forma_pago],[codigo_tabla_iva]
									,[codigo_representante],[dto_comercial],[dto_financiero],[numero_copias],[adjuntos],[codigo_pais_cliente]
									,[referencia],[codigo_divisa],[cambio_divisa],[codigo_tarifa],[identificador_dir_envio],[alias_dir_envio]
									,[nombre_dir_envio],[domicilio_dir_envio],[sucursal_dir_envio],[codigo_postal_dir_envio],[poblacion_dir_envio]
									,[provincia_dir_envio],[codigo_pais_dir_envio],[telefono_dir_envio],[movil_dir_envio],[email_dir_envio]
									,[fax_dir_envio],[identificador_dir_pago],[alias_dir_pago],[nombre_dir_pago],[domicilio_dir_pago],[sucursal_dir_pago],[codigo_postal_dir_pago],[poblacion_dir_pago]
									,[provincia_dir_pago],[codigo_pais_dir_pago],[telefono_dir_pago],[movil_dir_pago],[email_dir_pago],[fax_dir_pago],
									[cargo_financiero],[realizado_por],[codigo_agencia],[aplicar_cargo_financiero],aplicar_cargo_financiero_dias 
									,[codigo_centro_venta], fecha_devengo,identificador_banco,nombre_banco,domicilio_banco,sucursal_banco,codigo_postal_banco
									,poblacion_banco,provincia_banco,iban_code_banco,swift_code_banco,clave_entidad_banco,clave_sucursal_banco,digito_control_banco
									,cuenta_corriente_banco,criterio_conjuntacion)
			SELECT TOP (1) 
						@pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumero,S.codigo_tipo_cond_venta,@pFecha,'N'
						,C.codigo_tercero, C.codigo_cliente, C.nombre_cliente, C.razon_social_cliente,C.nif_cliente, C.domicilio_cliente
						, C.codigo_postal_cliente, C.poblacion_cliente,C.provincia_cliente, C.codigo_forma_pago, C.codigo_tabla_iva
						, C.codigo_representante,C.dto_comercial, C.dto_financiero, CV.numero_copias_factura, C.adjuntos, C.codigo_pais_cliente
						, C.referencia, C.codigo_divisa,C.cambio_divisa,C.codigo_tarifa,C.identificador_dir_envio,C.alias_dir_envio
						, C.nombre_dir_envio, C.domicilio_dir_envio, C.sucursal_dir_envio,C.codigo_postal_dir_envio, C.poblacion_dir_envio
						, C.provincia_dir_envio, C.codigo_pais_dir_envio,C.telefono_dir_envio, C.movil_dir_envio , C.email_dir_envio, C.fax_dir_envio,DP.identificador,DP.alias
						, ISNULL(DP.nombre,c.nombre_cliente), isnull(DP.domicilio,c.domicilio_cliente), DP.sucursal,isnull(DP.codigo_postal,c.codigo_postal_cliente), isnull(DP.poblacion,C.poblacion_cliente)
						, ISNULL(DP.provincia,C.provincia_cliente), isnull(DP.codigo_pais,c.codigo_pais_cliente),DP.telefono, DP.movil , DP.email
						, DP.fax, C.cargo_financiero, @pUsuario, C.codigo_agencia,C.aplicar_cargo_financiero, C.aplicar_cargo_financiero_dias
						, C.codigo_centro_venta, @pFechaDevengo, B.identificador,B.banco,B.domicilio,B.sucursal,B.codigo_postal
						, B.poblacion, B.provincia, B.iban_code, B.swift_code, B.clave_entidad, B.clave_sucursal, B.digito_control
						, B.cuenta_corriente, C.criterio_conjuntacion
				FROM  dbo.tmp_facturar_albaranes AS S 
					INNER JOIN dbo.vv_venta_c_alba AS C ON S.sys_oid_origen=C.sys_oid
					LEFT OUTER JOIN emp_clientes_direcciones as DP ON DP.empresa = C.empresa
						AND DP.codigo_cliente = C.codigo_cliente
						AND DP.codigo_tipo_direccion = 'PAG'
						AND DP.predeterminada = 1
					LEFT OUTER JOIN emp_terceros_bancos AS B ON B.empresa = C.empresa
						AND B.codigo_tercero = C.codigo_tercero 
						AND B.predeterminado = 1
					LEFT OUTER JOIN emp_clientes_cond_venta AS CV ON cv.empresa = c.empresa 
						AND cv.codigo_cliente = c.codigo_cliente
						AND cv.codigo_tipo_cond_venta = c.codigo_tipo_cond_venta
			   WHERE S.sesion=@pSesion 
				 AND S.grupo = @pGrupo 
				 AND S.generada = 0				
				 AND S.sys_oid_origen = @pOidOrigen
		
				
		set @pSys_oid_C_Destino = (SELECT SYS_OID FROM eje_venta_c 
										WHERE empresa = @pEmpresa
										  AND ejercicio = @pEjercicio
										  AND codigo_tipo_documento = @pCodigo_tipo_documento
										  AND serie = @pSerie
										  AND numero = @pNumero)
		
		set @pContador = 0 /*ISNULL((SELECT MAX(linea) FROM eje_venta_l WHERE empresa = @pEmpresa AND ejercicio = @pEjercicio AND codigo_tipo_documento = @pCodigo_tipo_documento
							AND serie = @pSerie AND numero = @pNumero),0) */
	

		WHILE @@FETCH_STATUS=0
		BEGIN
			
			SET @pContador += 1
			
			IF @pContador = 1		
			BEGIN	
				SELECT @pEmpresa as empresa,@pEjercicio as ejercicio,@pCodigo_tipo_documento as codigo_tipo_documento,@pSerie as serie,@pNumero as numero, IDENTITY(int,1,1) AS linea ,L.[codigo_almacen],L.[codigo_Articulo],L.[descripcion]
					,L.[descripcion_idioma],L.[unidades],L.[precio],L.[precio_e],L.[dto1],L.[dto2],L.[total_linea],L.[precio_coste],L.[numero_serie],L.[codigo_tipo_iva]
					,L.[observaciones],L.[observaciones_internas],L.[adjuntos],L.[iva],L.[re],L.[codigo_ubicacion],C.sys_oid as sys_oid_albaran
					,L.subcuenta_ventas,L.dto_maximo,l.sys_oid_oferta,L.bloquear_precios
				  INTO #tmp 
				  FROM vv_venta_l_alba AS L 
					INNER JOIN vv_venta_c_alba AS C ON C.empresa = L.empresa AND C.ejercicio = L.ejercicio AND C.codigo_tipo_documento = L.codigo_tipo_documento
							AND C.serie = L.SERIE AND C.numero = L.numero 
				  WHERE C.sys_oid = @pOidOrigen
			END	  
			ELSE
			BEGIN			
				INSERT INTO #tmp(
				[empresa],[ejercicio],[codigo_tipo_documento],[SERIE],[numero]
				,[codigo_almacen],[codigo_Articulo],[descripcion]
				,[descripcion_idioma],[unidades],[precio],[precio_e],[dto1],[dto2],[total_linea],[precio_coste],[numero_serie],[codigo_tipo_iva]
				,[observaciones],[observaciones_internas],[adjuntos],[iva],[re],[codigo_ubicacion],sys_oid_albaran,subcuenta_ventas,dto_maximo
				,sys_oid_oferta,bloquear_precios				
				)
				SELECT @pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumero,L.[codigo_almacen],L.[codigo_Articulo],L.[descripcion]
					,L.[descripcion_idioma],L.[unidades],L.[precio],L.[precio_e],L.[dto1],L.[dto2],L.[total_linea],L.[precio_coste],L.[numero_serie],L.[codigo_tipo_iva]
					,L.[observaciones],L.[observaciones_internas],L.[adjuntos],L.[iva],L.[re],L.[codigo_ubicacion],C.sys_oid
					,L.subcuenta_ventas,L.dto_maximo,l.sys_oid_oferta,l.bloquear_precios
				  FROM vv_venta_l_alba AS L 
					INNER JOIN vv_venta_c_alba AS C ON C.empresa = L.empresa AND C.ejercicio = L.ejercicio AND C.codigo_tipo_documento = L.codigo_tipo_documento
							AND C.serie = L.SERIE AND C.numero = L.numero 
				  WHERE C.sys_oid = @pOidOrigen
			  			
			/*SET @pSys_oid_destino = (SELECT sys_oid 
										FROM vv_venta_l_factura 
										WHERE empresa = @pEmpresa 
										  AND ejercicio = @pEjercicio 
										  AND codigo_tipo_documento = @pCodigo_tipo_documento
										  AND SERIE = @pSerie
										  AND numero = @pNumero
										  AND linea = @pContador)
			*/
		    END
		    		
		    /**Hay que ver como lo calculamos y si agrupamos...[codigo_portes],[codigo_tipo_iva_portes],[aplicar_en_totales_portes],[importe_portes] 
			   Al menos debería ir agrupado por tipo de via portes	**/
		    IF @pAplicar_en_Totales_Portes = 1 AND isnull(@pImporte_Portes,0) > 0 
		    BEGIN
				UPDATE vv_venta_c_factura SET 
						codigo_portes = @pCodigo_Portes,
						codigo_tipo_iva_portes = @pCodigo_Tipo_IVA_Portes,
						aplicar_en_totales_portes = 1,
						importe_portes = isnull(importe_portes,0) + isnull(@pImporte_Portes,0)
				 WHERE sys_oid = @pSys_oid_C_Destino
		    END 
			
			/***Navegacion de documentos***/		    
			SET @pFechaCreacion = GETDATE()
			EXEC vs_generar_documento @pCodigoTipoDocumentoOrigen, @pOidOrigen, @pNumeroOrigen, @pFechaOrigen, 
									@pCodigo_tipo_documento, @pSys_oid_C_Destino, @pNumero, @pFecha, 
									@pUsuario, @pFechaCreacion	

			/***Actualizamos documento origen****/
			UPDATE vv_venta_c_alba SET 
				SITUACION = 'F'		
			 WHERE sys_oid = @pOidOrigen
			 
			/***Actualizamos la tabla temporal***/ 
			UPDATE tmp_facturar_albaranes SET 
				generada = 1,
				usuario = @pUsuario,
				numero_destino = @pNumero,
				sys_oid_destino = @pSys_oid_C_Destino	
			 WHERE sys_oid = @pSys_Oid_Tmp												

			FETCH NEXT FROM facturas INTO @pOidOrigen, @pEmpresaOrigen, @pEjercicioOrigen,@pCodigoTipoDocumentoOrigen, @pSerieOrigen,@pNumeroOrigen, @pFechaOrigen, 
				@pCodigo_Portes,@pCodigo_Tipo_IVA_Portes, @pAplicar_en_Totales_Portes, @pImporte_Portes, 
				@pEmpresa, @pEjercicio, @pCodigo_Tipo_Documento, @pSerie, @pFecha, @pSys_oid_tmp
				
		END
				
		INSERT INTO vv_venta_l_factura ([empresa],[ejercicio],[codigo_tipo_documento],[SERIE],[numero],[linea]
				,[codigo_almacen],[codigo_Articulo],[descripcion]
				,[descripcion_idioma],[unidades],[precio],[precio_e],[dto1],[dto2],[total_linea],[precio_coste],[numero_serie],[codigo_tipo_iva]
				,[observaciones],[observaciones_internas],[adjuntos],[iva],[re],[codigo_ubicacion],SYS_OID_ALBARAN,subcuenta_ventas,dto_maximo
				,sys_oid_oferta,bloquear_precios)
			SELECT empresa, ejercicio, codigo_tipo_documento, serie, numero, linea, 
				codigo_almacen, codigo_articulo, descripcion, 
				descripcion_idioma, unidades,precio,precio_e,dto1,dto2,total_linea,precio_coste,numero_serie,codigo_tipo_iva,
				observaciones,observaciones_internas,adjuntos,iva,re,codigo_ubicacion,SYS_OID_ALBARAN,subcuenta_ventas,dto_maximo,
				sys_oid_oferta,bloquear_precios
			  FROM #tmp 
		
		DROP TABLE #tmp
		
		 INSERT INTO eje_venta_entregas (empresa,ejercicio,codigo_tipo_documento,serie,numero,linea,fecha_entrega,entrega_a_cuenta,codigo_banco)
		  SELECT DISTINCT E1.empresa, E1.ejercicio, @pCodigo_tipo_documento,@pserie,@pnumero,ROW_NUMBER() OVER (ORDER BY E1.sys_oid),E1.fecha_entrega,E1.entrega_a_cuenta,E1.codigo_banco
		  FROM dbo.eje_venta_entregas AS E1 
		  INNER JOIN dbo.tmp_facturar_albaranes AS T ON E1.empresa = T.empresa AND E1.ejercicio = T.ejercicio AND E1.codigo_tipo_documento = T.codigo_tipo_documento AND 
             E1.serie = T.serie AND E1.numero = T.numero WHERE T.sys_oid_destino = @psys_oid_c_destino and E1.sys_oid_destino IS NULL

		  UPDATE E1 SET e1.sys_oid_destino = @pSys_oid_C_Destino
				FROM eje_venta_entregas AS E1
					inner join dbo.tmp_facturar_albaranes AS T ON E1.empresa = T.empresa AND E1.ejercicio = T.ejercicio AND E1.codigo_tipo_documento = T.codigo_tipo_documento AND 
             E1.serie = T.serie AND E1.numero = T.numero WHERE T.sys_oid_destino = @psys_oid_c_destino and E1.sys_oid_destino IS NULL  
					  
		EXEC vs_calcular_total_venta @pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumero	
		EXEC vs_calcular_vencimientos @pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumero			
		EXEC vs_generar_asiento_venta @pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumero			
				
		CLOSE facturas
		DEALLOCATE facturas

		/******************  CURSOR DE ALBARANES   **********************/
		FETCH NEXT FROM grupos INTO @pgrupo, @pFechaDevengo
		
	END
	/******************  CURSOR DE GRUPOS   **********************/
	CLOSE grupos
	DEALLOCATE grupos

	COMMIT
END TRY


/****CONTROL DE ERRORES *****/
BEGIN CATCH
	set @pError = 'ERROR AL GENERAR LAS FACTURAS(' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + ERROR_MESSAGE()
	ROLLBACK
	RAISERROR(@pError,16,1)
END CATCH

END
