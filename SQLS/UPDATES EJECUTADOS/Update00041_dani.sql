USE [vs_martinez]
GO
/****** Object:  StoredProcedure [dbo].[vs_deshacer_albaranes]    Script Date: 01/24/2012 17:02:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[vs_deshacer_albaranes]
	@pSys_oid_cabecera dm_oid,
	@pUsuario dm_codigos_c
WITH ENCRYPTION AS
BEGIN
SET NOCOUNT OFF;

/******** Doc. Origen *************/
DECLARE @pSys_oid_origen dm_oid
DECLARE @pSys_oid_origen_cabecera dm_oid
DECLARE @pEmpresa_origen dm_empresas
DECLARE @pEjercicio_origen dm_ejercicios
DECLARE @pCodigo_tipo_documento_origen dm_codigos_c
DECLARE @pSerie_origen dm_codigos_c
DECLARE @pNumero_origen dm_numero_doc
DECLARE @pFecha_origen dm_fechas_hora

/******** Doc. Destino **********/
DECLARE @pSys_oid_destino dm_oid
DECLARE @pEmpresa_destino dm_empresas
DECLARE @pEjercicio_destino dm_ejercicios
DECLARE @pCodigo_tipo_documento_destino dm_codigos_c
DECLARE @pSerie_destino dm_codigos_c
DECLARE @pNumero_destino dm_numero_doc
DECLARE @pFecha_destino dm_fechas_hora

/*************** Otras  *****************/
DECLARE @pUnidades_a_servir dm_unidades
DECLARE @pError varchar(4000)
DECLARE @pSys_oid dm_oid


SELECT @pEmpresa_destino=empresa,@pEjercicio_destino=ejercicio,@pSerie_destino=serie,@pNumero_destino=numero
		,@pCodigo_tipo_documento_destino=codigo_tipo_documento,@pFecha_destino=fecha
		FROM vv_venta_c_alba
		WHERE sys_oid =	@pSys_oid_cabecera

IF NOT EXISTS( SELECT oid_documento_destino, numero_documento_origen, sys_oid
				FROM  dbo.gen_nav_documentos AS ND 
				WHERE (ND.oid_documento_destino = @pSys_oid_cabecera)
			)
BEGIN
	DELETE vv_venta_c_alba WHERE empresa = @pEmpresa_destino 
							  AND ejercicio = @pEjercicio_destino
							  AND codigo_tipo_documento = @pCodigo_Tipo_Documento_destino
							  AND SERIE = @pSerie_destino
							  AND numero = @pNumero_destino
	EXEC vs_insertar_hueco_serie @pEmpresa_destino,@pEjercicio_destino,@pCodigo_Tipo_Documento_destino,@pSerie_destino,@pNumero_destino,@pFecha_destino
	RETURN						  
END

BEGIN TRY
BEGIN TRANSACTION 
/*
DECLARE alba CURSOR FOR 
SELECT ND.sys_oid, SD.unidades_a_servir,SD.sys_oid_origen,SD.sys_oid_destino,ND.oid_documento_origen
		,SD.empresa,SD.ejercicio,SD.Codigo_tipo_documento,SD.Serie,SD.Numero
FROM dbo.gen_nav_documentos AS ND
				 INNER JOIN
				      dbo.vv_venta_c_alba AS VC ON ND.oid_documento_destino = VC.sys_oid
				 INNER JOIN
                      dbo.vv_venta_l_alba AS VL ON VC.empresa = VL.empresa AND VC.ejercicio = VL.ejercicio AND VC.codigo_tipo_documento = VL.codigo_tipo_documento AND 
                      VC.serie = VL.SERIE AND VC.numero = VL.numero 
                 INNER JOIN
                      dbo.tmp_servir_documento AS SD ON VL.sys_oid = SD.sys_oid_destino
WHERE (ND.oid_documento_destino = @pSys_oid_cabecera) AND (SD.generada = 1)
*/
DECLARE alba CURSOR LOCAL FOR 
SELECT ND.sys_oid, SD.unidades_a_servir,SD.sys_oid_origen,SD.sys_oid_destino,ND.oid_documento_origen
		,SD.empresa,SD.ejercicio,SD.Codigo_tipo_documento,SD.Serie,SD.Numero
FROM tmp_servir_documento AS SD
	INNER JOIN vv_venta_c_pedido AS PV ON PV.empresa = SD.empresa
		AND PV.ejercicio = SD.ejercicio
		AND PV.codigo_tipo_documento = SD.codigo_tipo_documento
		AND PV.serie = SD.serie
		AND PV.numero = SD.numero
		INNER JOIN vv_venta_l_pedido AS PVL ON PVL.empresa = PV.empresa
		AND PVL.ejercicio = PV.ejercicio
		AND PVL.codigo_tipo_documento = PV.codigo_tipo_documento
		AND PVL.serie = PV.serie
		AND PVL.numero = PV.numero
	INNER JOIN vv_venta_c_alba AS AV ON AV.empresa = SD.empresa_destino
		AND AV.ejercicio = SD.ejercicio_destino
		AND AV.codigo_tipo_documento = SD.codigo_tipo_documento_destino
		AND AV.serie = SD.serie_destino
		AND AV.numero = SD.numero_destino
		INNER JOIN vv_venta_l_alba AS AVL ON AVL.empresa = AV.empresa
		AND AVL.ejercicio = AV.ejercicio
		AND AVL.codigo_tipo_documento = AV.codigo_tipo_documento
		AND AVL.serie = AV.serie
		AND AVL.numero = AV.numero
	INNER JOIN gen_nav_documentos AS ND ON nd.oid_documento_origen = pv.sys_oid 
		AND nd.oid_documento_destino = av.sys_oid	
WHERE sd.sys_oid_origen = pvl.sys_oid 
	AND sd.sys_oid_destino = avl.sys_oid
	AND SD.generada = 1
	AND ND.deshecho = 0
	AND ND.oid_documento_destino = @pSys_oid_cabecera
    
OPEN alba 
FETCH NEXT FROM alba INTO @pSys_oid,@pUnidades_a_servir,@pSys_oid_origen,@pSys_oid_destino,@pSys_oid_origen_cabecera
							,@pEmpresa_origen,@pEjercicio_origen,@pCodigo_tipo_documento_origen,@pSerie_origen,@pNumero_origen
							
	WHILE @@FETCH_STATUS=0
	BEGIN

		UPDATE vv_venta_l_pedido SET 
			unidades_pendientes += ISNULL(@pUnidades_a_servir,0),
			unidades_servidas -= ISNULL(@pUnidades_a_servir,0)
		WHERE vv_venta_l_pedido.sys_oid=@pSys_oid_origen

		UPDATE vv_venta_l_pedido SET 
			unidades_pendientes += ISNULL(@pUnidades_a_servir,0),
			unidades_servidas -= ISNULL(@pUnidades_a_servir,0)
		WHERE linea = ( SELECT v2.linea FROM vv_venta_l_pedido AS v1 INNER JOIN vv_venta_l_pedido AS v2
			ON v1.linea_destino_ecotasa=v2.linea AND v2.linea_origen_ecotasa=v1.linea AND v1.numero=v2.numero
			WHERE v1.sys_oid=@pSys_oid_origen )	AND empresa=@pEmpresa_origen AND ejercicio=@pEjercicio_origen
				 AND codigo_tipo_documento=@pCodigo_tipo_documento_origen AND serie=@pSerie_origen AND numero=@pNumero_origen	
			
		IF EXISTS (SELECT * FROM vv_venta_l_pedido 
						WHERE sys_oid=@pSys_oid_origen
						  AND unidades_pendientes <> 0)
			UPDATE vv_venta_c_pedido SET 
				situacion = 'N'
						WHERE sys_oid=@pSys_oid_origen_cabecera
			
			update eje_venta_entregas set sys_oid_destino=null where codigo_tipo_documento='PV' and sys_oid_destino=@pSys_oid_cabecera

			FETCH NEXT FROM alba INTO @pSys_oid,@pUnidades_a_servir,@pSys_oid_origen,@pSys_oid_destino,@pSys_oid_origen_cabecera
							,@pEmpresa_origen,@pEjercicio_origen,@pCodigo_tipo_documento_origen,@pSerie_origen,@pNumero_origen
	END
	
	EXEC vs_insertar_hueco_serie @pEmpresa_destino,@pEjercicio_destino,@pCodigo_Tipo_Documento_destino,@pSerie_destino,@pNumero_destino,@pFecha_destino
	
	UPDATE gen_nav_documentos SET deshecho = 1,usuario_deshacer=@pUsuario,fecha_deshacer = GETDATE() WHERE sys_oid=@pSys_oid
	
	DELETE vv_venta_c_alba WHERE empresa = @pEmpresa_destino 
							  AND ejercicio = @pEjercicio_destino
							  AND codigo_tipo_documento = @pCodigo_Tipo_Documento_destino
							  AND SERIE = @pSerie_destino
							  AND numero = @pNumero_destino
	
	CLOSE  alba
	DEALLOCATE alba

	COMMIT
END TRY
/****CONTROL DE ERRORES *****/
BEGIN CATCH
	set @pError = 'ERROR AL DESHACER EL ALBARAN (' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + ERROR_MESSAGE()
	ROLLBACK
	RAISERROR(@pError,16,1)
END CATCH	

END
