USE [vs_martinez]
GO
/****** Object:  StoredProcedure [dbo].[vs_crea_alb_compra]    Script Date: 02/02/2012 17:13:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[vs_crea_alb_compra]
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
DECLARE	@pNumero dm_numero_doc
DECLARE @pNumeroAux dm_numero_doc
DECLARE @pNumeroDestino dm_numero_doc
DECLARE @pGrupo dm_char_corto
DECLARE @codigo_almacen dm_codigos_c
DECLARE @codigo_articulo dm_codigo_articulo
DECLARE @descripcion dm_char_largo
DECLARE @precio dm_precios
DECLARE @precio_e dm_precios
DECLARE @dto1 dm_porcentajes
DECLARE @dto2 dm_porcentajes
DECLARE @dto3 dm_porcentajes
DECLARE @dto4 dm_porcentajes
DECLARE @tipo_descuento dm_char_muy_corto
DECLARE @total_linea dm_importes 
DECLARE @precio_coste dm_precios
DECLARE @numero_serie dm_char_corto
DECLARE @codigo_tipo_iva dm_codigos_c
DECLARE @adjuntos dm_adjuntos
DECLARE @codigo_ubicacion dm_codigos_c
DECLARE @unidades_a_servir dm_unidades
DECLARE @unidades_a_anular dm_unidades
DECLARE @pSys_oid dm_oid
DECLARE @pContador dm_entero_corto 
DECLARE @pSys_Oid_Tmp dm_oid
DECLARE @pSys_oid_destino dm_oid
DECLARE @pFechaCreacion dm_fechas_hora
DECLARE @pError varchar(4000)=''
DECLARE @pSys_oid_C_Destino dm_oid

DECLARE @pCodigoEcotasa dm_codigo_articulo = NULL
DECLARE @pEcotasa dm_entero_corto
DECLARE @pSubcta_compras dm_subcuenta
DECLARE @pcodigo_centro_compra dm_codigos_c
DECLARE @pobservaciones dm_memo
DECLARE @pobservaciones_internas dm_memo
DECLARE @psys_oid_pedido_venta dm_oid
DECLARE @pSu_Referencia dm_codigo_articulo

BEGIN TRY
BEGIN TRANSACTION 
	/******************  CURSOR DE GRUPOS   **********************/
	DECLARE grupos CURSOR LOCAL FOR 
		SELECT DISTINCT grupo FROM tmp_recibir_documento
		 WHERE sys_timestamp = @pTimeStamp
		   AND sesion = @pSesion 
		   AND generada = 0

	OPEN grupos
	FETCH NEXT FROM grupos INTO @pGrupo
	WHILE @@FETCH_STATUS=0
	BEGIN
	/******************  CURSOR DE ALBARANES   **********************/
	
	
		IF EXISTS (SELECT DISTINCT c.situacion 
				FROM dbo.tmp_recibir_documento AS S 
				INNER JOIN dbo.eje_compra_c AS C ON S.empresa = C.empresa AND S.ejercicio = C.ejercicio AND S.codigo_tipo_documento = C.codigo_tipo_documento 
				AND S.SERIE = C.serie AND S.numero = C.numero
				WHERE s.sys_timestamp = @pTimeStamp
			  AND s.sesion=@pSesion 
			  AND s.grupo = @pGrupo and s.generada = 0 AND C.situacion!='N')
				RAISERROR('YA SE HA GENERADO UN ALBARAN DEL PEDIDO',16,1)

		set @pError = 'ERROR GENERANDO LA CABECERA DEL ALBARAN' + CHAR(13) + CHAR(10)
		DECLARE alba CURSOR FOR 
			SELECT s.empresa, s.ejercicio, s.codigo_tipo_documento, s.serie, s.numero, c.fecha, 
				S.empresa_destino,S.ejercicio_destino,S.codigo_tipo_documento_destino,S.serie_destino,S.numero_destino, 
				  S.codigo_almacen, S.codigo_articulo, S.descripcion, S.unidades_a_servir, S.unidades_a_anular, S.precio
				  ,L.precio_e, L.precio_coste, S.dto1, S.dto2, S.dto3, S.dto4, L.tipo_descuento, L.numero_serie, S.codigo_tipo_iva, L.adjuntos
				  , S.codigo_ubicacion,S.sys_oid_origen,S.fecha_destino, s.sys_oid, c.sys_oid,L.subcuenta_compras
				  ,L.observaciones,L.observaciones_internas,L.sys_oid_pedido_venta,S.su_referencia
				FROM dbo.tmp_recibir_documento AS S 
				INNER JOIN dbo.vv_compra_l_pedido AS L ON S.sys_oid_origen = L.sys_oid 
				INNER JOIN dbo.eje_compra_c AS C ON L.empresa = C.empresa AND L.ejercicio = C.ejercicio AND L.codigo_tipo_documento = C.codigo_tipo_documento 
					AND L.SERIE = C.serie AND L.numero = C.numero
			WHERE s.sys_timestamp = @pTimeStamp
			  AND s.sesion=@pSesion 
			  AND s.grupo = @pGrupo
			  AND s.generada = 0

		OPEN alba 
		FETCH NEXT FROM alba INTO @pEmpresaOrigen, @pEjercicioOrigen, @pCodigoTipoDocumentoOrigen,@pSerieOrigen,@pNumeroOrigen,@pFechaOrigen
		,@pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumero,@codigo_almacen,@codigo_articulo,@descripcion,@unidades_a_servir
		,@unidades_a_anular,@precio,@precio_e,@precio_coste,@dto1,@dto2,@dto3,@dto4,@tipo_descuento, @numero_serie,@codigo_tipo_iva,@adjuntos,@codigo_ubicacion
		,@pSys_oid,@pFecha,@pSys_Oid_Tmp,@pOidOrigen,@pSubcta_compras,@pobservaciones,@pobservaciones_internas,@psys_oid_pedido_venta,@pSu_Referencia
	
		IF @pNumero IS NULL 
		BEGIN
			EXEC vs_proximo_numero_serie @pempresa, @pEjercicio, @pCodigo_tipo_documento, @pSerie,@pFecha, 1, @pNumeroDestino OUTPUT

			INSERT INTO vv_compra_c_alba (
									empresa, ejercicio, codigo_tipo_documento, serie,codigo_tipo_cond_compra, numero
									, fecha, situacion, codigo_tercero, codigo_proveedor, nombre_proveedor, razon_social_proveedor, nif_proveedor,domicilio_proveedor
									, codigo_postal_proveedor, poblacion_proveedor, provincia_proveedor, codigo_forma_pago, codigo_tabla_iva
									, dto_comercial, irpf, adjuntos,codigo_pais_proveedor,referencia, codigo_divisa, cambio_divisa,dto_financiero
									, periodo, cargo_financiero, realizado_por,codigo_portes, codigo_tipo_iva_portes, aplicar_en_totales_portes
									, importe_portes, codigo_agencia,codigo_almacen_envio, nombre_dir_envio, domicilio_dir_envio,codigo_postal_dir_envio, 
									poblacion_dir_envio, provincia_dir_envio,codigo_pais_dir_envio, telefono_dir_envio, movil_dir_envio, email_dir_envio,fax_dir_envio,
									su_pedido,su_fecha_pedido,su_albaran,su_fecha_albaran,codigo_centro_compra )
			SELECT    TOP (1) S.empresa_destino, S.ejercicio_destino, S.codigo_tipo_documento_destino, S.serie_destino,S.codigo_tipo_cond_compra_destino, @pNumeroDestino,  
                      S.fecha_destino, 'N', C.codigo_tercero, C.codigo_proveedor, C.nombre_proveedor, C.razon_social_proveedor, C.nif_proveedor, C.domicilio_proveedor, 
                      C.codigo_postal_proveedor, C.poblacion_proveedor, C.provincia_proveedor, C.codigo_forma_pago, C.codigo_tabla_iva
                      , C.dto_comercial, C.irpf, C.adjuntos, C.codigo_pais_proveedor, C.referencia, C.codigo_divisa, C.cambio_divisa, C.dto_financiero, C.periodo, C.cargo_financiero, 
                      @pUsuario, C.codigo_portes, C.codigo_tipo_iva_portes, C.aplicar_en_totales_portes, C.importe_portes, C.codigo_agencia,
                      C.codigo_almacen_envio, C.nombre_dir_envio, C.domicilio_dir_envio,C.codigo_postal_dir_envio, C.poblacion_dir_envio, 
					  C.provincia_dir_envio,C.codigo_pais_dir_envio, C.telefono_dir_envio, C.movil_dir_envio, C.email_dir_envio, C.fax_dir_envio,
					  C.su_pedido,C.su_fecha_pedido,S.su_numero_doc,S.su_fecha_doc,C.codigo_centro_compra
				FROM  dbo.tmp_recibir_documento AS S 
				INNER JOIN dbo.vv_compra_l_pedido AS l ON S.sys_oid_origen = L.sys_oid 
				INNER JOIN dbo.vv_compra_c_pedido AS C ON L.empresa = C.empresa AND L.ejercicio = C.ejercicio AND L.codigo_tipo_documento = C.codigo_tipo_documento 
					AND L.SERIE = C.serie AND L.numero = C.numero
			WHERE sesion=@pSesion 
			  AND grupo = @pGrupo 
			  AND generada = 0				
		END
		ELSE 
		BEGIN
			SET @pNumeroDestino = @pNumero
		END
		
		set @pSys_oid_C_Destino = (SELECT SYS_OID FROM eje_compra_c 
										WHERE empresa = @pEmpresa
										  AND ejercicio = @pEjercicio
										  AND codigo_tipo_documento = @pCodigo_tipo_documento
										  AND serie = @pSerie
										  AND numero = @pNumeroDestino)
			
		set @pContador = ISNULL((SELECT MAX(linea) FROM eje_compra_l WHERE empresa = @pEmpresa AND ejercicio = @pEjercicio AND codigo_tipo_documento = @pCodigo_tipo_documento
							AND serie = @pSerie AND numero = @pNumeroDestino),0)
		
		WHILE @@FETCH_STATUS=0
		BEGIN
			
			IF @unidades_a_servir <> 0 
			BEGIN		
				SET @pContador += 1
				set @pError = 'ERROR GENERANDO LA LINEA ' + RTRIM(STR(@pContador)) + ' DEL ALBARAN' + CHAR(13) + CHAR(10)  

				INSERT INTO vv_compra_l_alba (
					empresa, ejercicio, codigo_tipo_documento, serie, numero,linea, codigo_almacen, codigo_articulo, descripcion, 
					unidades, precio, precio_e, dto1, dto2, dto3, dto4, tipo_descuento, precio_coste,total_linea, numero_serie
					,codigo_tipo_iva,adjuntos, codigo_ubicacion,subcuenta_compras,observaciones,observaciones_internas,sys_oid_pedido_venta,su_referencia )
				 VALUES (
					 @pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumeroDestino,@pContador ,@codigo_almacen,@codigo_articulo,@descripcion
					,@unidades_a_servir,@precio,@precio_e,@dto1,@dto2,@dto3,@dto4,@tipo_descuento,@precio_coste,@total_linea, @numero_serie,@codigo_tipo_iva,@adjuntos,@codigo_ubicacion
					,@pSubcta_compras,@pobservaciones,@pobservaciones_internas,@psys_oid_pedido_venta,@pSu_Referencia )
					
			SELECT @pCodigoEcotasa=a1.codigo,@precio=A1.pvp,@descripcion=A1.descripcion,@codigo_tipo_iva=A1.codigo_tipo_iva
				 FROM emp_articulos AS A1 INNER JOIN emp_articulos AS A2 ON A1.codigo=A2.ecotasa
				 WHERE A2.codigo=@codigo_articulo AND A1.es_ecotasa=1
			
			IF @pCodigoEcotasa IS NOT NULL
				BEGIN
					SET @pContador += 1

					INSERT INTO vv_compra_l_alba (
					empresa, ejercicio, codigo_tipo_documento, serie, numero,linea, codigo_almacen, codigo_articulo, descripcion, 
					unidades, precio, precio_e, dto1, dto2, dto3, dto4, tipo_descuento, precio_coste,total_linea, numero_serie
					,codigo_tipo_iva,adjuntos, codigo_ubicacion,linea_origen_ecotasa,subcuenta_compras,observaciones,observaciones_internas
					,sys_oid_pedido_venta)
					VALUES (@pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumeroDestino,@pContador ,@codigo_almacen,@pCodigoEcotasa,@descripcion
					,@unidades_a_servir,@precio,0,0,0,0,0,@tipo_descuento,@precio,@total_linea, @numero_serie,@codigo_tipo_iva,@adjuntos,@codigo_ubicacion
					,@pContador-1,@pSubcta_compras,@pobservaciones,@pobservaciones_internas,@psys_oid_pedido_venta)
					SET @pCodigoEcotasa = NULL
					UPDATE vv_compra_l_alba SET linea_destino_ecotasa=@pContador WHERE codigo_articulo=@codigo_articulo AND empresa=@pEmpresa
					SET @pEcotasa = ( SELECT distinct v2.linea FROM vv_compra_l_pedido AS v1 INNER JOIN vv_compra_l_pedido AS v2
										ON v1.linea_destino_ecotasa=v2.linea AND v2.linea_origen_ecotasa=v1.linea AND v1.numero=v2.numero
										WHERE v1.sys_oid=@pSys_oid )
					UPDATE vv_compra_l_pedido SET 
					unidades_servidas=ISNULL(unidades_servidas,0) + isnull(@unidades_a_servir,0),
					unidades_anuladas=ISNULL(unidades_anuladas,0) + ISNULL(@unidades_a_anular,0),
					unidades_pendientes=ISNULL(unidades_pendientes,0)-(isnull(@unidades_a_servir,0)+isnull(@unidades_a_anular,0))
					WHERE vv_compra_l_pedido.numero=@pNumeroOrigen AND linea=@pEcotasa			  

				END							
					
				SET @pSys_oid_destino = (SELECT sys_oid 
										    FROM vv_compra_l_alba 
										    WHERE empresa = @pEmpresa 
										      AND ejercicio = @pEjercicio 
										      AND codigo_tipo_documento = @pCodigo_tipo_documento
										      AND SERIE = @pSerie
										      AND numero = @pNumeroDestino
										      AND linea = @pContador)
				
				SET @pFechaCreacion = GETDATE()
				
				EXEC vs_generar_documento @pCodigoTipoDocumentoOrigen, @pOidOrigen, @pNumeroOrigen, @pFechaOrigen, 
											@pCodigo_tipo_documento, @pSys_oid_C_Destino, @pNumeroDestino, @pFecha, 
											@pUsuario, @pFechaCreacion	
			END
			  
			UPDATE vv_compra_l_pedido SET 
				unidades_servidas=ISNULL(unidades_servidas,0) + isnull(@unidades_a_servir,0),
				unidades_anuladas=ISNULL(unidades_anuladas,0) + ISNULL(@unidades_a_anular,0),
				unidades_pendientes=ISNULL(unidades_pendientes,0)-(isnull(@unidades_a_servir,0)+isnull(@unidades_a_anular,0))
			 WHERE vv_compra_l_pedido.sys_oid=@pSys_oid
			
			IF NOT EXISTS (SELECT * FROM vv_compra_l_pedido 
							WHERE empresa = @pEmpresaOrigen 
							  AND ejercicio = @pEjercicioOrigen
							  AND codigo_tipo_documento = @pCodigoTipoDocumentoOrigen
							  AND SERIE = @pSerieOrigen
							  AND numero = @pNumeroOrigen
							  AND unidades_pendientes <> 0)
			BEGIN				  
				UPDATE vv_compra_c_pedido SET 
					situacion = 'S'
				WHERE empresa = @pEmpresaOrigen 
							  AND ejercicio = @pEjercicioOrigen
							  AND codigo_tipo_documento = @pCodigoTipoDocumentoOrigen
							  AND SERIE = @pSerieOrigen
							  AND numero = @pNumeroOrigen
			END
			 
			IF @unidades_a_servir <> 0 
				UPDATE tmp_recibir_documento SET 
					numero_destino = @pNumeroDestino,
					generada = 1,
					sys_oid_destino = @pSys_oid_destino
				WHERE sys_oid = @pSys_Oid_Tmp
		
			FETCH NEXT FROM alba INTO @pEmpresaOrigen, @pEjercicioOrigen, @pCodigoTipoDocumentoOrigen,@pSerieOrigen,@pNumeroOrigen
			,@pFechaOrigen, @pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumero,@codigo_almacen,@codigo_articulo
			,@descripcion,@unidades_a_servir,@unidades_a_anular,@precio,@precio_e,@precio_coste,@dto1,@dto2,@dto3,@dto4,@tipo_descuento,@numero_serie,@codigo_tipo_iva
			,@adjuntos,@codigo_ubicacion,@pSys_oid,@pFecha,@pSys_Oid_Tmp,@pOidOrigen,@pSubcta_compras,@pobservaciones,@pobservaciones_internas
			,@psys_oid_pedido_venta,@pSu_Referencia
		END
		
		 INSERT INTO eje_compra_entregas (empresa,ejercicio,codigo_tipo_documento,serie,numero,linea,fecha_entrega,entrega_a_cuenta,codigo_banco)
		  SELECT DISTINCT E1.empresa, E1.ejercicio, @pCodigo_tipo_documento,@pserie,@pNumeroDestino,E1.linea,E1.fecha_entrega,E1.entrega_a_cuenta,E1.codigo_banco
		  FROM dbo.eje_compra_entregas AS E1 
		  INNER JOIN dbo.tmp_recibir_documento AS T ON E1.empresa = T.empresa AND E1.ejercicio = T.ejercicio AND E1.codigo_tipo_documento = T.codigo_tipo_documento AND 
             E1.serie = T.serie AND E1.numero = T.numero WHERE T.generada=0

		  UPDATE E1 SET e1.sys_oid_destino = E0.sys_oid                        
				FROM eje_compra_entregas AS E1
					  INNER JOIN eje_compra_entregas AS E0 ON E1.sys_oid = E0.sys_oid_destino
				WHERE (E1.sys_oid_destino IS NULL)              
		
		set @pError = 'ERROR AL CALCULAR EL TOTAL DEL ALBARAN' + CHAR(13) + CHAR(10)  
		EXEC vs_calcular_total_compra @pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumeroDestino			
				
		CLOSE  alba
		DEALLOCATE alba

		/******************  CURSOR DE ALBARANES   **********************/
		FETCH NEXT FROM grupos INTO @pgrupo
	END
	/******************  CURSOR DE GRUPOS   **********************/
	CLOSE grupos
	DEALLOCATE grupos

	COMMIT
END TRY
/****CONTROL DE ERRORES *****/
BEGIN CATCH
	set @pError = 'ERROR AL GENERAR EL ALBARAN (' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + @pError + ERROR_MESSAGE()
	ROLLBACK
	RAISERROR(@pError,16,1)
END CATCH

END



