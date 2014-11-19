use vs_martinez
go 

alter table emp_inventarios_c add piramidal dm_codigos_n, referencia dm_char_corto
go 

ALTER PROCEDURE [dbo].[vs_crea_regularizacion_stock]
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
DECLARE @pCodigoCliente dm_codigos_n

/***Doc. Destino***/
DECLARE @pEmpresa dm_empresas
DECLARE @pEjercicio dm_ejercicios
DECLARE @pSerie dm_codigos_c
DECLARE @pCodigo_tipo_documento dm_codigos_c
DECLARE @pFecha dm_fechas_hora
DECLARE	@pNumero dm_numero_doc
DECLARE @pNumeroDestino dm_numero_doc
DECLARE @pNumeroAux dm_numero_doc
DECLARE @pGrupo dm_char_corto
DECLARE @codigo_almacen dm_codigos_c
DECLARE @codigo_articulo dm_codigo_articulo
DECLARE @descripcion dm_char_largo
DECLARE @precio dm_precios
DECLARE @precio_e dm_precios
DECLARE @dto1 dm_porcentajes
DECLARE @dto2 dm_porcentajes
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
DECLARE @pSubcta_ventas dm_subcuenta
DECLARE @pobservaciones dm_memo
DECLARE @pobservaciones_internas dm_memo

DECLARE @pRiesgoMaximo dm_importes
DECLARE @pMargen dm_porcentajes
DECLARE @pRiesgoCliente dm_importes
DECLARE @dto_maximo dm_porcentajes
DECLARE @sys_oid_oferta dm_oid
DECLARE @bloquear_precios dm_logico
DECLARE @unidades_iniciales dm_stock 

BEGIN TRY
BEGIN TRANSACTION 
	
	/******************  CURSOR DE GRUPOS   **********************/
	DECLARE grupos CURSOR LOCAL FOR 
		SELECT DISTINCT grupo FROM tmp_servir_documento
		 WHERE sys_timestamp = @pTimeStamp
		   AND sesion = @pSesion 
		   AND generada = 0
	
	OPEN grupos
	FETCH NEXT FROM grupos INTO @pGrupo
	WHILE @@FETCH_STATUS=0
	BEGIN
	
		IF EXISTS (SELECT DISTINCT C.situacion 
			FROM tmp_servir_documento AS S 
			INNER JOIN dbo.eje_venta_c AS C ON S.empresa = C.empresa AND S.ejercicio = C.ejercicio AND S.codigo_tipo_documento = C.codigo_tipo_documento 
			AND S.SERIE = C.serie AND S.numero = C.numero
			WHERE s.sys_timestamp = @pTimeStamp
			  AND s.sesion=@pSesion 
			  AND s.grupo = @pGrupo and s.generada = 0 AND C.situacion!='N')
			  
		RAISERROR('YA SE HA GENERADO UN PEDIDO DEL PRESUPUESTO',16,1)
	
	/******************  CURSOR DE PEDIDOS A GENERAR   **********************/
		set @pError = 'ERROR GENERANDO LA CABECERA DEL PEDIDO' + CHAR(13) + CHAR(10)

		DECLARE pedido CURSOR LOCAL FOR
			SELECT s.empresa, s.ejercicio, s.codigo_tipo_documento, s.serie, s.numero, c.fecha, S.empresa_destino, S.ejercicio_destino, S.codigo_tipo_documento_destino, S.serie_destino, S.numero_destino, 
				  S.codigo_almacen, S.codigo_articulo, S.descripcion, S.unidades_a_servir, S.unidades_a_anular, S.precio
				  ,L.precio_e, L.precio_coste, S.dto1, S.dto2, L.numero_serie, S.codigo_tipo_iva, L.adjuntos
				  , S.codigo_ubicacion,S.sys_oid_origen,S.fecha_destino, s.sys_oid, c.sys_oid,subcuenta_ventas
				  ,L.observaciones dm_memo,L.observaciones_internas,L.dto_maximo,L.sys_oid_oferta,L.bloquear_precios
			FROM dbo.tmp_servir_documento AS S 
				INNER JOIN dbo.vv_venta_l_presup AS L ON S.sys_oid_origen = L.sys_oid 
				INNER JOIN dbo.eje_venta_c AS C ON L.empresa = C.empresa AND L.ejercicio = C.ejercicio AND L.codigo_tipo_documento = C.codigo_tipo_documento 
					AND L.SERIE = C.serie AND L.numero = C.numero
			WHERE s.sys_timestamp = @pTimeStamp
			  AND s.sesion=@pSesion 
			  AND s.grupo = @pGrupo
			  AND s.generada = 0

		OPEN pedido 
		FETCH NEXT FROM pedido INTO @pEmpresaOrigen, @pEjercicioOrigen, @pCodigoTipoDocumentoOrigen,@pSerieOrigen,@pNumeroOrigen
		,@pFechaOrigen, @pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumero,@codigo_almacen,@codigo_articulo,@descripcion
		,@unidades_a_servir,@unidades_a_anular,@precio,@precio_e,@precio_coste,@dto1,@dto2,@numero_serie,@codigo_tipo_iva,@adjuntos
		,@codigo_ubicacion,@pSys_oid,@pFecha,@pSys_Oid_Tmp,@pOidOrigen,@pSubcta_ventas,@pobservaciones,@pobservaciones_internas
		,@dto_maximo,@sys_oid_oferta,@bloquear_precios
	
		IF @pNumero IS NULL 
		BEGIN
			set @pError = 'ERROR GENERANDO EL NUMERO DE SERIE ' + isnull(@pserie,'serie nula') + CHAR(13) + CHAR(10)
			
			EXEC vs_proximo_numero_serie @pempresa, NULL, 'GEN', @pSerie, @pFecha, 1, @pNumeroDestino OUTPUT
			
			INSERT INTO emp_inventarios_c([empresa],[numero],[descripcion],[fecha],[codigo_almacen],[situacion],
				[realizado_por],[regularizacion],piramidal,referencia)
     		SELECT TOP (1) 
						S.empresa_destino,@pNumeroDestino,'REGULARIZACION STOCK',
						fecha_destino,S.codigo_almacen,'N',@pUsuario, 1,C.codigo_cliente,
						RTRIM(@pSerieOrigen) + '/' + RTRIM(CONVERT(char, @pNumeroOrigen)) + '/' + LTRIM(RTRIM(CONVERT(char, C.codigo_cliente)))
			FROM  dbo.tmp_servir_documento AS S 
				INNER JOIN dbo.vv_venta_l_presup AS l ON S.sys_oid_origen = L.sys_oid 
				INNER JOIN dbo.vv_venta_c_presup AS C ON L.empresa = C.empresa AND L.ejercicio = C.ejercicio AND L.codigo_tipo_documento = C.codigo_tipo_documento 
					AND L.SERIE = C.serie AND L.numero = C.numero
			WHERE sesion=@pSesion 
			  AND grupo = @pGrupo 
			  AND generada = 0	
		END
		ELSE 
		BEGIN
			SET @pNumeroDestino = @pNumero
		END
		
		SELECT @pSys_oid_C_Destino=SYS_OID
		  FROM emp_inventarios_c 
		 WHERE empresa = @pEmpresa
		  AND numero = @pNumeroDestino

		set @pContador = ISNULL((SELECT MAX(linea) FROM emp_inventarios_l WHERE empresa = @pEmpresa AND numero = @pNumeroDestino),0)
		
		WHILE @@FETCH_STATUS=0
		BEGIN
			
			IF @unidades_a_servir <> 0 OR (ISNULL(@unidades_a_servir,0) = 0 AND ISNULL(@codigo_articulo,'') = '' AND ISNULL(@descripcion,'') <> '')
			BEGIN		
				SET @pContador += 1
								
				SELECT @unidades_iniciales = isnull(stock,0),@precio_coste=isnull(precio_medio_coste,0),@precio=isnull(precio_ultima_compra,0) 
				  FROM emp_existencias 
				 WHERE empresa = @pEmpresa
				   AND codigo_articulo = @codigo_articulo
				   AND codigo_almacen = @codigo_almacen				   
				   AND codigo_ubicacion = @codigo_ubicacion 
				   
				IF @unidades_iniciales < @unidades_a_servir 
				BEGIN
					set @pError = 'NO HAY SUFICIENTES UNIDADES PARA SERVIR LA LINEA ' + RTRIM(STR(@pContador)) + ' DEL PRESUPUESTO' + CHAR(13) + CHAR(10)     
					RAISERROR('',16,1)
				END
				
				set @pError = 'ERROR GENERANDO LA LINEA ' + RTRIM(STR(@pContador)) + ' DEL PEDIDO' + CHAR(13) + CHAR(10)     
				INSERT INTO emp_inventarios_l([empresa],[numero],[linea],[codigo_almacen],[codigo_ubicacion],[codigo_articulo],[unidades_iniciales]
					,[unidades_contadas],[precio_medio_coste],[precio_ultima_compra])
				VALUES (@pEmpresa,@pNumeroDestino,@pContador,@codigo_almacen,@codigo_ubicacion,@codigo_articulo,@unidades_iniciales,
					(@unidades_iniciales - @unidades_a_servir),@precio_coste,@precio)

				SELECT @pCodigoEcotasa=a1.codigo,@precio=a1.pvp,@descripcion=a1.descripcion,@codigo_tipo_iva=a1.codigo_tipo_iva,@bloquear_precios=A1.bloquear_precios
					FROM emp_articulos AS a1 INNER JOIN emp_articulos AS a2 ON a1.codigo=a2.ecotasa
					WHERE a2.codigo=@codigo_articulo AND a1.es_ecotasa=1 AND a1.empresa=@pEmpresa
					
				IF @pCodigoEcotasa IS NOT NULL
				BEGIN
						UPDATE vv_venta_l_presup SET 
							unidades_servidas=ISNULL(unidades_servidas,0) + isnull(@unidades_a_servir,0),
							unidades_anuladas=ISNULL(unidades_anuladas,0) + ISNULL(@unidades_a_anular,0),
							unidades_pendientes=ISNULL(unidades_pendientes,0)-(isnull(@unidades_a_servir,0)+isnull(@unidades_a_anular,0))
						 WHERE vv_venta_l_presup.numero=@pNumeroOrigen AND linea=@pEcotasa
				END

				SET @pSys_oid_destino = (SELECT sys_oid 
										    FROM emp_inventarios_l
										    WHERE empresa = @pEmpresa 
										      AND numero = @pNumeroDestino
										      AND linea = @pContador)				
										      
				SET @pFechaCreacion = GETDATE()
				
				EXEC vs_generar_documento @pCodigoTipoDocumentoOrigen, @pOidOrigen, @pNumeroOrigen, @pFechaOrigen, 
											@pCodigo_tipo_documento, @pSys_oid_C_Destino, @pNumeroDestino, @pFecha, 
											@pUsuario, @pFechaCreacion	
			END
			  
			UPDATE vv_venta_l_presup SET 
				unidades_servidas=ISNULL(unidades_servidas,0) + isnull(@unidades_a_servir,0),
				unidades_anuladas=ISNULL(unidades_anuladas,0) + ISNULL(@unidades_a_anular,0),
				unidades_pendientes=ISNULL(unidades_pendientes,0)-(isnull(@unidades_a_servir,0)+isnull(@unidades_a_anular,0))
			 WHERE vv_venta_l_presup.sys_oid=@pSys_oid
			
			IF NOT EXISTS (SELECT * FROM vv_venta_l_presup
							WHERE empresa = @pEmpresaOrigen 
							  AND ejercicio = @pEjercicioOrigen
							  AND codigo_tipo_documento = @pCodigoTipoDocumentoOrigen
							  AND SERIE = @pSerieOrigen
							  AND numero = @pNumeroOrigen
							  AND unidades_pendientes <> 0)
			BEGIN				  
				
				/*
				UPDATE vv_venta_c_presup SET 
					situacion = 'A'			--ACEPTADO
				WHERE empresa = @pEmpresaOrigen 
							  AND ejercicio = @pEjercicioOrigen
							  AND codigo_tipo_documento = @pCodigoTipoDocumentoOrigen
							  AND SERIE = @pSerieOrigen
							  AND numero = @pNumeroOrigen				
				*/
				DELETE vv_venta_c_presup							  
				WHERE empresa = @pEmpresaOrigen 
							  AND ejercicio = @pEjercicioOrigen
							  AND codigo_tipo_documento = @pCodigoTipoDocumentoOrigen
							  AND SERIE = @pSerieOrigen
							  AND numero = @pNumeroOrigen
				
			END
			 
			IF @unidades_a_servir <> 0 
				UPDATE tmp_servir_documento SET 
					numero_destino = @pNumeroDestino,
					generada = 1,
					sys_oid_destino = @pSys_oid_destino
				WHERE sys_oid = @pSys_Oid_Tmp
		
		  FETCH NEXT FROM pedido INTO @pEmpresaOrigen, @pEjercicioOrigen, @pCodigoTipoDocumentoOrigen,@pSerieOrigen,@pNumeroOrigen
		  ,@pFechaOrigen, @pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumero,@codigo_almacen,@codigo_articulo,@descripcion
		  ,@unidades_a_servir,@unidades_a_anular,@precio,@precio_e,@precio_coste,@dto1,@dto2,@numero_serie,@codigo_tipo_iva,@adjuntos
		  ,@codigo_ubicacion,@pSys_oid,@pFecha,@pSys_Oid_Tmp,@pOidOrigen,@pSubcta_ventas,@pobservaciones,@pobservaciones_internas
		  ,@dto_maximo,@sys_oid_oferta,@bloquear_precios
		END

		set @pError = 'ERROR AL CALCULAR EL TOTAL DEL PEDIDO' + CHAR(13) + CHAR(10)  				
		
		EXEC vs_actualizar_inventario @pSys_oid_C_Destino
		
		CLOSE  pedido
		DEALLOCATE pedido

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
	set @pError = 'ERROR AL GENERAR EL PEDIDO (' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + @pError + ERROR_MESSAGE()
	ROLLBACK
	RAISERROR(@pError,16,1)
END CATCH

END



