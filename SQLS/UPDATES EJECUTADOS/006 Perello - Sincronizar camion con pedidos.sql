USE [vs_perello]
GO

/****** Object:  View [dbo].[vf_eje_camiones_palets_cajas]    Script Date: 30/03/2015 10:31:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vf_eje_camiones_palets_cajas] AS 
SELECT CP.empresa, CP.ejercicio, CP.fecha, CP.codigo_camion, CP.linea, CP.numero_palet, CP.sys_oid, 
	MP.codigo_cliente, MP.nombre_cliente, MP.codigo_agencia, MP.descripcion_agencia, MP.codigo_destino, MP.descripcion_destino,
	MP.cargado, MP.palet_completo, MP.impreso, MP.sscc, MP.sys_oid as sys_oid_palet,
	MPC.codigo_articulo, MPC.descripcion_articulo, MPC.codigo_calidad, MPC.descripcion_calidad, 
	MPC.codigo_confeccion, MPC.descripcion_confeccion, MPC.numero_cajas, MPC.precio
  FROM eje_camiones_palets as CP 
	LEFT OUTER JOIN vf_eje_montaje_palets AS MP ON MP.empresa = CP.empresa
		AND MP.ejercicio = CP.ejercicio
		AND MP.fecha = CP.fecha
		AND MP.numero_palet = CP.numero_palet
	LEFT OUTER JOIN vf_eje_montaje_palets_cajas AS MPC ON MPC.empresa = MP.empresa
		AND MPC.ejercicio = MP.ejercicio
		AND MPC.fecha = MP.fecha
		AND MPC.numero_palet = MP.numero_palet


GO

ALTER VIEW [dbo].[vf_emp_articulos_confecciones] AS 
SELECT AC.empresa, AC.codigo_articulo, AC.codigo_confeccion, AC.codigo_tipo_caja, AC.descripcion, AC.codigo_ean, 
	AC.descripcion_edi, AC.predeterminada, AC.activa, AC.sys_oid, TC.descripcion as descripcion_caja, AC.activo_entradas, AC.activo_ventas, AC.activo_produccion
  FROM emp_articulos_confecciones AS AC 
	LEFT OUTER JOIN emp_tipos_caja AS TC ON TC.empresa = AC.empresa
		AND TC.codigo = AC.codigo_tipo_caja

GO


ALTER TRIGGER [dbo].[vf_eje_montaje_palets_cajas_bu]
   ON  [dbo].[vf_eje_montaje_palets_cajas]
   INSTEAD OF UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for trigger here
	UPDATE eje_montaje_palets_cajas SET codigo_articulo = inserted.codigo_articulo,
		codigo_calidad = inserted.codigo_calidad,
		codigo_confeccion = inserted.codigo_confeccion,
		numero_cajas = inserted.numero_cajas,
		precio = inserted.precio
	 FROM eje_montaje_palets_cajas
		INNER JOIN inserted ON inserted.sys_oid_caja = eje_montaje_palets_cajas.sys_oid
		
END

ALTER TABLE [dbo].[eje_montaje_palets_cajas]  WITH NOCHECK ADD  CONSTRAINT [FK_eje_montaje_palets_cajas_eje_venta_l] FOREIGN KEY([sys_oid_linea_pedido])
REFERENCES [dbo].[eje_venta_l] ([sys_oid])
ON UPDATE CASCADE 
ON DELETE SET NULL 
GO

ALTER TABLE [dbo].[eje_montaje_palets_cajas] CHECK CONSTRAINT [FK_eje_montaje_palets_cajas_eje_venta_l]
GO

alter table eje_montaje_palets add sincronizado dm_logico
go 

alter table eje_montaje_palets add fecha_ultima_sincronizacion dm_fechas_hora
go 

CREATE PROCEDURE [dbo].[vs_sincronizar_palet]
	@pempresa dm_empresas,
	@pejercicio dm_ejercicios,
	@pfecha dm_fechas_hora,
	@pnumero_palet dm_entero,
	@pUsuario dm_codigos_c
AS
BEGIN
	DECLARE @error varchar(max) = ''
	DECLARE @numero_palet dm_entero
	DECLARE @linea_palet dm_entero
	DECLARE @codigo_cliente dm_codigos_n
	DECLARE @codigo_destino dm_codigos_c
	DECLARE @codigo_agencia dm_codigos_c	
	DECLARE @codigo_articulo dm_codigo_articulo
	DECLARE @codigo_calidad dm_codigos_c
	DECLARE @codigo_confeccion dm_codigos_c
	DECLARE @numero_cajas dm_entero
	DECLARE @precio dm_precios
	DECLARE @sys_oid_linea_pedido dm_oid

	DECLARE @serie_pedido dm_codigos_c
	DECLARE @numero_pedido dm_numero_doc
	DECLARE @linea_pedido dm_entero


	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION 
	
		DECLARE cursor_palets CURSOR LOCAL FOR 
			SELECT MP.numero_palet, MP.codigo_cliente, MP.codigo_destino, MP.codigo_agencia, MPC.linea,
				MPC.codigo_articulo, MPC.codigo_calidad, MPC.codigo_confeccion, MPC.numero_cajas, MPC.precio, MPC.sys_oid_linea_pedido
			  FROM eje_montaje_palets AS MP 
				INNER JOIN eje_montaje_palets_cajas AS MPC ON MPC.empresa = MP.empresa
					AND MPC.ejercicio = MP.ejercicio
					AND MPC.fecha = MP.fecha
					AND MPC.numero_palet = MP.numero_palet
			 WHERE MP.empresa=@pempresa 
			   AND MP.ejercicio = @pejercicio
			   AND MP.fecha = @pfecha
			   AND MP.numero_palet = @pnumero_palet

		OPEN cursor_palets
		FETCH NEXT FROM cursor_palets INTO @numero_palet, @codigo_cliente, @codigo_destino, @codigo_agencia,@linea_palet,
			@codigo_articulo, @codigo_calidad, @codigo_confeccion, @numero_cajas, @precio, @sys_oid_linea_pedido
		WHILE @@FETCH_STATUS = 0
		BEGIN

			IF @sys_oid_linea_pedido IS NULL 
			BEGIN
				/*No tiene asignada la linea del pedido y hay que asignarla*/				
				SELECT TOP 1 @serie_pedido=C.serie, @numero_pedido=C.numero, @linea_pedido = L.linea
				  FROM vv_venta_c_pedido AS C					
					INNER JOIN vv_venta_l_pedido AS L ON L.empresa = C.empresa 
						AND L.ejercicio = C.ejercicio
						AND L.codigo_tipo_documento = C.codigo_tipo_documento
						AND L.serie = C.serie
						AND L.numero = C.numero
				 WHERE C.empresa = @pempresa
				   AND C.ejercicio = @pejercicio
				   AND C.codigo_tipo_documento = 'PV'
				   AND C.fecha = @pfecha
				   AND C.codigo_cliente = @codigo_cliente
				   AND L.codigo_Articulo = @codigo_articulo
				   AND L.codigo_calidad = @codigo_calidad
				   AND L.codigo_confeccion = @codigo_confeccion
				   AND L.precio = @precio

				IF @@ROWCOUNT = 0 
				BEGIN
					
					SELECT TOP 1 @serie_pedido=C.serie, @numero_pedido=C.numero 
					  FROM vv_venta_c_pedido AS C					
					 WHERE C.empresa = @pempresa
					   AND C.ejercicio = @pejercicio
					   AND C.codigo_tipo_documento = 'PV'
					   AND C.fecha = @pfecha
					   AND C.codigo_cliente = @codigo_cliente
					   
					IF @@ROWCOUNT = 0 
					BEGIN	
						SET @error = 'CREANDO PEDIDO AUTOMATICO'

						SELECT TOP 1 @serie_pedido = codigo
						  FROM emp_series
						 WHERE empresa = @pempresa
						   AND ejercicio = @pejercicio
						   AND codigo_tipo_documento = 'PV'
						   AND predeterminada = 1

						IF @@ROWCOUNT = 0
							RAISERROR('NO ENCUENTRO LA SERIE PREDETERMINADA DE PEDIDOS.', 16, 1)					

						EXEC vs_proximo_numero_serie @pempresa, @pEjercicio, 'PV', @serie_pedido , @pFecha, 1, @numero_pedido OUTPUT
			
						INSERT INTO vv_venta_c_pedido (
									[empresa],[ejercicio],[codigo_tipo_documento],[serie],[numero],[codigo_tipo_cond_venta],[fecha],[situacion]
									,[codigo_tercero],[codigo_cliente],[nombre_cliente],[razon_social_cliente],[nif_cliente],[domicilio_cliente]
									,[codigo_postal_cliente],[poblacion_cliente],[provincia_cliente],[codigo_forma_pago],[codigo_tabla_iva]
									,[codigo_representante],[dto_comercial],[dto_financiero],[numero_copias],[adjuntos],[codigo_pais_cliente]
									,[referencia],[codigo_divisa],[cambio_divisa],[codigo_tarifa],[identificador_dir_envio],[alias_dir_envio]
									,[nombre_dir_envio],[domicilio_dir_envio],[sucursal_dir_envio],[codigo_postal_dir_envio],[poblacion_dir_envio]
									,[provincia_dir_envio],[codigo_pais_dir_envio],[telefono_dir_envio],[movil_dir_envio],[email_dir_envio]
									,[fax_dir_envio],[aplicar_en_totales_portes],[importe_portes]
									,[cargo_financiero],[realizado_por],[codigo_agencia],aplicar_cargo_financiero,codigo_centro_venta
									,codigo_destino, observaciones_internas)
						SELECT TOP 1 @pempresa, @pejercicio, 'PV', @serie_pedido, @numero_pedido,'1', @pfecha, 'N',
							C.codigo_tercero, @codigo_cliente, C.nombre, C.razon_social, C.nif, C.domicilio,
							C.codigo_postal, C.poblacion, C.provincia, C.codigo_forma_pago, C.codigo_tabla_iva, 
							C.codigo_representante, C.descuento_comercial, C.descuento_financiero, 1, NULL, C.codigo_pais,
							NULL, (CASE WHEN D.codigo IS NULL THEN 'EUR' ELSE D.codigo END), (CASE WHEN D.codigo IS NULL THEN 1.0 ELSE D.ultimo_cambio END), C.codigo_tarifa, NULL, NULL, 
							C.nombre, C.domicilio, NULL, C.codigo_postal, C.poblacion, 
							C.provincia, C.codigo_pais, C.telefono, C.movil, C.email, C.fax, 0, 0,
							0, @pUsuario, @codigo_agencia, 0, '1',
							@codigo_destino, 'SICRONIZADO DESDE MONTAJE CAMION'
						  FROM vf_emp_clientes_completo AS C
							LEFT OUTER JOIN gen_divisas AS D ON D.codigo = C.codigo_divisa
						 WHERE C.empresa = @pEmpresa
						   AND C.codigo = @codigo_cliente
				
						IF @@ROWCOUNT = 0 
							RAISERROR('NO SE CREO LA CABECERA DEL PEDIDO AUTOMATICO', 16, 1)

						SET @linea_pedido = 1
					END
					ELSE 
					BEGIN
						SELECT @linea_pedido = MAX(linea)
						  FROM vv_venta_l_pedido 
						 WHERE empresa = @pempresa
						   AND ejercicio = @pejercicio
						   AND codigo_tipo_documento = 'PV'
						   AND serie = @serie_pedido
						   AND numero = @numero_pedido

						SET @linea_pedido = ISNULL(@linea_pedido, 0) + 1
					END	
					
					INSERT INTO vv_venta_l_pedido (empresa,ejercicio,codigo_tipo_documento,serie,numero,linea,codigo_almacen,codigo_articulo,descripcion,
						precio, unidades, unidades_anuladas, unidades_servidas, unidades_pendientes, dto1, dto2, codigo_tipo_iva, observaciones_internas,
						subcuenta_ventas, envases, codigo_envase, kilos_envase, kilos_sueltos, codigo_periodo, codigo_calidad, codigo_confeccion)
					SELECT TOP 1 @pempresa, @pejercicio, 'PV', @serie_pedido, @numero_pedido, @linea_pedido, '1', @codigo_articulo, A.descripcion, 
						@precio, (ISNULL(@numero_cajas,0) * ISNULL(C.peso,0)), 0, 0, (ISNULL(@numero_cajas,0) * ISNULL(C.peso,0)), 0, 0, A.codigo_tipo_iva, 'SINCRONIZADO DESDE MONTAJE CAMION',
						A.subcuenta_ventas, @numero_cajas, A.codigo_tipo_caja, ISNULL(C.peso, 0),0, CONVERT(char(10), datepart(week, @pfecha)), @codigo_calidad, @codigo_confeccion
					  FROM vf_emp_articulos_completo AS A
						LEFT OUTER JOIN emp_tipos_caja AS C ON C.empresa = A.empresa
							AND C.codigo = A.codigo_tipo_caja
					 WHERE A.empresa = @pempresa
					   AND A.ejercicio = @pejercicio
					   AND A.codigo = @codigo_articulo	

					EXEC vs_calcular_total_venta @pEmpresa, @pejercicio, 'PV', @serie_pedido, @numero_pedido

				END
				ELSE
				BEGIN
					/*Ya existe una linea del mismo articulo, calidad, confeccion y precio*/
					UPDATE eje_venta_l SET envases = envases + @numero_cajas
					 WHERE empresa = @pempresa 
					   AND ejercicio = @pejercicio
					   AND codigo_tipo_documento = 'PV'
					   AND serie = @serie_pedido
					   AND numero = @numero_pedido
					   AND linea = @linea_pedido
					
					EXEC vs_calcular_total_venta @pEmpresa, @pejercicio, 'PV', @serie_pedido, @numero_pedido

				END
				
				/* Actualizamos el sys_oid_linea_pedido */
				UPDATE eje_montaje_palets_cajas SET 
					sys_oid_linea_pedido = (SELECT sys_oid 
												FROM vv_venta_l_pedido
												WHERE empresa = @pempresa
												AND ejercicio = @pejercicio
												AND codigo_tipo_documento = 'PV'
												AND serie = @serie_pedido
												AND numero = @numero_pedido
												AND linea = @linea_pedido)
					WHERE empresa = @pempresa
					  AND ejercicio = @pejercicio
					  AND fecha = @pfecha
					  AND numero_palet = @numero_palet
					  AND linea = @linea_palet

			END
			ELSE 
			BEGIN
				/*Ya tiene asignada la linea del pedido y hay que actualizarla*/
				UPDATE eje_venta_l SET @serie_pedido = serie, 
					@numero_pedido = numero, 
					envases = (SELECT SUM(numero_cajas)
								 FROM eje_montaje_palets_cajas
								WHERE sys_oid_linea_pedido = @sys_oid_linea_pedido),
					precio = @precio
				 WHERE sys_oid = @sys_oid_linea_pedido

				EXEC vs_calcular_total_venta @pEmpresa, @pejercicio, 'PV', @serie_pedido, @numero_pedido

			END

			FETCH NEXT FROM cursor_palets INTO @numero_palet, @codigo_cliente, @codigo_destino, @codigo_agencia, @linea_palet,
				@codigo_articulo, @codigo_calidad, @codigo_confeccion, @numero_cajas, @precio, @sys_oid_linea_pedido

		END

		CLOSE cursor_palets
		DEALLOCATE cursor_palets

		UPDATE eje_montaje_palets SET sincronizado = 1, 
			fecha_ultima_sincronizacion = GETDATE()
		WHERE empresa = @pempresa
		  AND ejercicio = @pejercicio
		  AND fecha = @pfecha
		  AND numero_palet = @pnumero_palet

		COMMIT 

	END TRY 

	/****CONTROL DE ERRORES *****/
	BEGIN CATCH
		set @Error = 'ERROR AL EJECUTAR PROCEDIMIENTO (' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + @error + CHAR(13) + CHAR(10) + ERROR_MESSAGE()
		ROLLBACK
		RAISERROR(@Error,16,1)
	END CATCH

END

GO 

CREATE PROCEDURE [dbo].[vs_sincronizar_camion]
	@pempresa dm_empresas,
	@pejercicio dm_ejercicios,
	@pfecha dm_fechas_hora,
	@pcodigo_camion dm_entero,
	@pUsuario dm_codigos_c
AS
BEGIN
	DECLARE @error varchar(max)
	DECLARE @numero_palet dm_entero
	DECLARE @linea_palet dm_entero
	DECLARE @codigo_cliente dm_codigos_n
	DECLARE @codigo_destino dm_codigos_c
	DECLARE @codigo_agencia dm_codigos_c	
	DECLARE @codigo_articulo dm_codigo_articulo
	DECLARE @codigo_calidad dm_codigos_c
	DECLARE @codigo_confeccion dm_codigos_c
	DECLARE @numero_cajas dm_entero
	DECLARE @precio dm_precios
	DECLARE @sys_oid_linea_pedido dm_oid

	DECLARE @serie_pedido dm_codigos_c
	DECLARE @numero_pedido dm_numero_doc
	DECLARE @linea_pedido dm_entero


	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION 
	
		DECLARE cursor_palets_camion CURSOR LOCAL FOR 
			SELECT CP.numero_palet, MP.codigo_cliente, MP.codigo_destino, MP.codigo_agencia, MPC.linea,
				MPC.codigo_articulo, MPC.codigo_calidad, MPC.codigo_confeccion, MPC.numero_cajas, MPC.precio, MPC.sys_oid_linea_pedido
			  FROM eje_camiones_palets AS CP
				INNER JOIN eje_montaje_palets AS MP ON CP.empresa = MP.empresa
					AND CP.ejercicio = MP.ejercicio
					AND CP.fecha = MP.fecha
					AND CP.numero_palet = MP.numero_palet
				INNER JOIN eje_montaje_palets_cajas AS MPC ON MPC.empresa = MP.empresa
					AND MPC.ejercicio = MP.ejercicio
					AND MPC.fecha = MP.fecha
					AND MPC.numero_palet = MP.numero_palet
			 WHERE CP.empresa=@pempresa 
			   AND CP.ejercicio = @pejercicio
			   AND CP.fecha = @pfecha
			   AND CP.codigo_camion = @pcodigo_camion
			 ORDER BY CP.linea

		OPEN cursor_palets_camion
		FETCH NEXT FROM cursor_palets_camion INTO @numero_palet, @codigo_cliente, @codigo_destino, @codigo_agencia,@linea_palet,
			@codigo_articulo, @codigo_calidad, @codigo_confeccion, @numero_cajas, @precio, @sys_oid_linea_pedido
		WHILE @@FETCH_STATUS = 0
		BEGIN

			IF @sys_oid_linea_pedido IS NULL 
			BEGIN
				/*No tiene asignada la linea del pedido y hay que asignarla*/				
				SELECT TOP 1 @serie_pedido=C.serie, @numero_pedido=C.numero, @linea_pedido = L.linea
				  FROM vv_venta_c_pedido AS C					
					INNER JOIN vv_venta_l_pedido AS L ON L.empresa = C.empresa 
						AND L.ejercicio = C.ejercicio
						AND L.codigo_tipo_documento = C.codigo_tipo_documento
						AND L.serie = C.serie
						AND L.numero = C.numero
				 WHERE C.empresa = @pempresa
				   AND C.ejercicio = @pejercicio
				   AND C.codigo_tipo_documento = 'PV'
				   AND C.fecha = @pfecha
				   AND C.codigo_cliente = @codigo_cliente
				   AND L.codigo_Articulo = @codigo_articulo
				   AND L.codigo_calidad = @codigo_calidad
				   AND L.codigo_confeccion = @codigo_confeccion
				   AND L.precio = @precio

				IF @@ROWCOUNT = 0 
				BEGIN
					
					SELECT TOP 1 @serie_pedido=C.serie, @numero_pedido=C.numero 
					  FROM vv_venta_c_pedido AS C					
					 WHERE C.empresa = @pempresa
					   AND C.ejercicio = @pejercicio
					   AND C.codigo_tipo_documento = 'PV'
					   AND C.fecha = @pfecha
					   AND C.codigo_cliente = @codigo_cliente
					   
					IF @@ROWCOUNT = 0 
					BEGIN	
						SET @error = 'CREANDO PEDIDO AUTOMATICO'

						SELECT TOP 1 @serie_pedido = codigo
						  FROM emp_series
						 WHERE empresa = @pempresa
						   AND ejercicio = @pejercicio
						   AND codigo_tipo_documento = 'PV'
						   AND predeterminada = 1

						IF @@ROWCOUNT = 0
							RAISERROR('NO ENCUENTRO LA SERIE PREDETERMINADA DE PEDIDOS.', 16, 1)					

						EXEC vs_proximo_numero_serie @pempresa, @pEjercicio, 'PV', @serie_pedido , @pFecha, 1, @numero_pedido OUTPUT
			
						INSERT INTO vv_venta_c_pedido (
									[empresa],[ejercicio],[codigo_tipo_documento],[serie],[numero],[codigo_tipo_cond_venta],[fecha],[situacion]
									,[codigo_tercero],[codigo_cliente],[nombre_cliente],[razon_social_cliente],[nif_cliente],[domicilio_cliente]
									,[codigo_postal_cliente],[poblacion_cliente],[provincia_cliente],[codigo_forma_pago],[codigo_tabla_iva]
									,[codigo_representante],[dto_comercial],[dto_financiero],[numero_copias],[adjuntos],[codigo_pais_cliente]
									,[referencia],[codigo_divisa],[cambio_divisa],[codigo_tarifa],[identificador_dir_envio],[alias_dir_envio]
									,[nombre_dir_envio],[domicilio_dir_envio],[sucursal_dir_envio],[codigo_postal_dir_envio],[poblacion_dir_envio]
									,[provincia_dir_envio],[codigo_pais_dir_envio],[telefono_dir_envio],[movil_dir_envio],[email_dir_envio]
									,[fax_dir_envio],[aplicar_en_totales_portes],[importe_portes]
									,[cargo_financiero],[realizado_por],[codigo_agencia],aplicar_cargo_financiero,codigo_centro_venta
									,codigo_destino, observaciones_internas)
						SELECT TOP 1 @pempresa, @pejercicio, 'PV', @serie_pedido, @numero_pedido,'1', @pfecha, 'N',
							C.codigo_tercero, @codigo_cliente, C.nombre, C.razon_social, C.nif, C.domicilio,
							C.codigo_postal, C.poblacion, C.provincia, C.codigo_forma_pago, C.codigo_tabla_iva, 
							C.codigo_representante, C.descuento_comercial, C.descuento_financiero, 1, NULL, C.codigo_pais,
							NULL, (CASE WHEN D.codigo IS NULL THEN 'EUR' ELSE D.codigo END), (CASE WHEN D.codigo IS NULL THEN 1.0 ELSE D.ultimo_cambio END), C.codigo_tarifa, NULL, NULL, 
							C.nombre, C.domicilio, NULL, C.codigo_postal, C.poblacion, 
							C.provincia, C.codigo_pais, C.telefono, C.movil, C.email, C.fax, 0, 0,
							0, @pUsuario, @codigo_agencia, 0, '1',
							@codigo_destino, 'SICRONIZADO DESDE MONTAJE CAMION'
						  FROM vf_emp_clientes_completo AS C
							LEFT OUTER JOIN gen_divisas AS D ON D.codigo = C.codigo_divisa
						 WHERE C.empresa = @pEmpresa
						   AND C.codigo = @codigo_cliente
				
						IF @@ROWCOUNT = 0 
							RAISERROR('NO SE CREO LA CABECERA DEL PEDIDO AUTOMATICO', 16, 1)

						SET @linea_pedido = 1
					END
					ELSE 
					BEGIN
						SELECT @linea_pedido = MAX(linea)
						  FROM vv_venta_l_pedido 
						 WHERE empresa = @pempresa
						   AND ejercicio = @pejercicio
						   AND codigo_tipo_documento = 'PV'
						   AND serie = @serie_pedido
						   AND numero = @numero_pedido

						SET @linea_pedido = ISNULL(@linea_pedido, 0) + 1
					END	
					
					INSERT INTO vv_venta_l_pedido (empresa,ejercicio,codigo_tipo_documento,serie,numero,linea,codigo_almacen,codigo_articulo,descripcion,
						precio, unidades, unidades_anuladas, unidades_servidas, unidades_pendientes, dto1, dto2, codigo_tipo_iva, observaciones_internas,
						subcuenta_ventas, envases, codigo_envase, kilos_envase, kilos_sueltos, codigo_periodo, codigo_calidad, codigo_confeccion)
					SELECT TOP 1 @pempresa, @pejercicio, 'PV', @serie_pedido, @numero_pedido, @linea_pedido, '1', @codigo_articulo, A.descripcion, 
						@precio, (ISNULL(@numero_cajas,0) * ISNULL(C.peso,0)), 0, 0, (ISNULL(@numero_cajas,0) * ISNULL(C.peso,0)), 0, 0, A.codigo_tipo_iva, 'SINCRONIZADO DESDE MONTAJE CAMION',
						A.subcuenta_ventas, @numero_cajas, A.codigo_tipo_caja, ISNULL(C.peso, 0),0, CONVERT(char(10), datepart(week, @pfecha)), @codigo_calidad, @codigo_confeccion
					  FROM vf_emp_articulos_completo AS A
						LEFT OUTER JOIN emp_tipos_caja AS C ON C.empresa = A.empresa
							AND C.codigo = A.codigo_tipo_caja
					 WHERE A.empresa = @pempresa
					   AND A.ejercicio = @pejercicio
					   AND A.codigo = @codigo_articulo	

					 EXEC vs_calcular_total_venta @pEmpresa, @pejercicio, 'PV', @serie_pedido, @numero_pedido

				END
				ELSE
				BEGIN
					/*Ya existe una linea del mismo articulo, calidad, confeccion y precio*/
					UPDATE eje_venta_l SET envases = envases + @numero_cajas
					 WHERE empresa = @pempresa 
					   AND ejercicio = @pejercicio
					   AND codigo_tipo_documento = 'PV'
					   AND serie = @serie_pedido
					   AND numero = @numero_pedido
					   AND linea = @linea_pedido

					EXEC vs_calcular_total_venta @pEmpresa, @pejercicio, 'PV', @serie_pedido, @numero_pedido

				END
				
				/* Actualizamos el sys_oid_linea_pedido */
				UPDATE eje_montaje_palets_cajas SET 
					sys_oid_linea_pedido = (SELECT sys_oid 
												FROM vv_venta_l_pedido
												WHERE empresa = @pempresa
												AND ejercicio = @pejercicio
												AND codigo_tipo_documento = 'PV'
												AND serie = @serie_pedido
												AND numero = @numero_pedido
												AND linea = @linea_pedido)
					WHERE empresa = @pempresa
					AND ejercicio = @pejercicio
					AND fecha = @pfecha
					AND numero_palet = @numero_palet
					AND linea = @linea_palet

			END
			ELSE 
			BEGIN
				/*Ya tiene asignada la linea del pedido y hay que actualizarla*/
				UPDATE eje_venta_l SET @serie_pedido = serie, 
					@numero_pedido = numero, 
					envases = (SELECT SUM(numero_cajas)
								 FROM eje_montaje_palets_cajas
								WHERE sys_oid_linea_pedido = @sys_oid_linea_pedido),
					precio = @precio
				 WHERE sys_oid = @sys_oid_linea_pedido

				EXEC vs_calcular_total_venta @pEmpresa, @pejercicio, 'PV', @serie_pedido, @numero_pedido

			END

			FETCH NEXT FROM cursor_palets_camion INTO @numero_palet, @codigo_cliente, @codigo_destino, @codigo_agencia, @linea_palet,
				@codigo_articulo, @codigo_calidad, @codigo_confeccion, @numero_cajas, @precio, @sys_oid_linea_pedido

		END

		CLOSE cursor_palets_camion
		DEALLOCATE cursor_palets_camion

		UPDATE eje_montaje_palets SET sincronizado = 1, 
			fecha_ultima_sincronizacion = GETDATE()
		  FROM eje_montaje_palets 
			INNER JOIN eje_camiones_palets ON eje_camiones_palets.empresa = eje_montaje_palets.empresa
				AND eje_camiones_palets.ejercicio = eje_montaje_palets.ejercicio
				AND eje_camiones_palets.fecha = eje_montaje_palets.fecha
				AND eje_camiones_palets.numero_palet = eje_montaje_palets.numero_palet
		WHERE eje_camiones_palets.empresa = @pempresa
		  AND eje_camiones_palets.ejercicio = @pejercicio
		  AND eje_camiones_palets.fecha = @pfecha
		  AND eje_camiones_palets.codigo_camion = @pcodigo_camion

		COMMIT 

	END TRY 

	/****CONTROL DE ERRORES *****/
	BEGIN CATCH
		set @Error = 'ERROR AL EJECUTAR PROCEDIMIENTO (' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + @error + CHAR(13) + CHAR(10) + ERROR_MESSAGE()
		ROLLBACK
		RAISERROR(@Error,16,1)
	END CATCH

END

GO 

ALTER VIEW [dbo].[vf_eje_montaje_palets] AS 
SELECT P.empresa, P.ejercicio, P.fecha, P.numero_palet, 
	P.codigo_cliente, CL.nombre as nombre_cliente,
	P.codigo_destino, D.descripcion as descripcion_destino,
	P.codigo_agencia, AG.descripcion as descripcion_agencia,
	P.numero_cajas, P.sscc, P.impreso, P.completo as palet_completo,
	P.cargado, P.completo, P.sincronizado, P.sys_oid as sys_oid
  FROM eje_montaje_palets AS P
	LEFT OUTER JOIN vf_emp_clientes AS CL ON CL.empresa = P.empresa 
		AND CL.codigo = P.codigo_cliente
	LEFT OUTER JOIN emp_destinos AS D ON D.empresa = P.empresa 
		AND D.codigo = P.codigo_destino
	LEFT OUTER JOIN emp_agencias AS AG ON AG.empresa = P.empresa 
		AND AG.codigo = P.codigo_agencia

GO 

ALTER VIEW [dbo].[vf_eje_camiones_palets] AS 
SELECT CP.empresa, CP.ejercicio, CP.fecha, CP.codigo_camion, CP.linea, CP.numero_palet, CP.sys_oid, 
	MP.codigo_cliente, MP.nombre_cliente, MP.codigo_agencia, MP.descripcion_agencia, MP.codigo_destino, MP.descripcion_destino,
	MP.numero_cajas, MP.cargado, MP.palet_completo, MP.impreso, MP.sincronizado, MP.sscc, MP.sys_oid as sys_oid_palet,
	(SELECT SUM(numero_cajas)
	   FROM eje_montaje_palets_cajas
	  WHERE empresa = MP.empresa
	    AND ejercicio = MP.ejercicio
		AND fecha = MP.fecha
		AND numero_palet = MP.numero_palet) AS numero_cajas_cargadas
  FROM eje_camiones_palets as CP 
	LEFT OUTER JOIN vf_eje_montaje_palets AS MP ON MP.empresa = CP.empresa
		AND MP.ejercicio = CP.ejercicio
		AND MP.fecha = CP.fecha
		AND MP.numero_palet = CP.numero_palet



GO


