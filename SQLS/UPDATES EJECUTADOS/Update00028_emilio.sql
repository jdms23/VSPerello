USE vs_martinez
GO
/****** Object:  StoredProcedure [dbo].[vs_traspasar_asiento]    Script Date: 01/18/2012 17:30:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[vs_traspasar_asiento]
 @pcodigo_tipo_documento dm_codigos_c,
 @psys_oid dm_entero
 
with encryption
AS
BEGIN
	 DECLARE @pAsiento dm_asiento=0
	 DECLARE @pEmpresa dm_empresas
	 DECLARE @pEjercicio dm_ejercicios
	 DECLARE @pDebe dm_importes
	 DECLARE @phaber dm_importes
	 DECLARE @pSys_oid_destino dm_oid
	 DECLARE @pFecha dm_fechas_hora
	 DECLARE @pFecha_creacion dm_fechas_hora
	 DECLARE @pUsuario VARCHAR(100)	 

	declare cursor_desglose_empresa CURSOR FOR 
		select distinct empresa,ejercicio from tmp_apuntes_traspaso WHERE codigo_tipo_documento_origen=@pcodigo_tipo_documento and sys_oid_origen=@psys_oid AND traspasado=0
	
	open cursor_desglose_empresa
	FETCH NEXT FROM cursor_desglose_empresa INTO @pempresa,@pejercicio
	WHILE @@FETCH_STATUS = 0
	BEGIN
		 SELECT @pDebe=SUM(isnull(importe_debe,0)),@phaber=SUM(isnull(importe_haber,0)) FROM tmp_apuntes_traspaso
		  WHERE codigo_tipo_documento_origen=@pcodigo_tipo_documento and sys_oid_origen=@psys_oid AND traspasado=0 and empresa=@pempresa

		 EXEC vs_proximo_numero_serie @pempresa,@pEjercicio, 'ASTO', 'ASIENTOS',NULL, 1, @pAsiento OUTPUT

		 INSERT INTO eje_asientos (empresa,ejercicio,asiento,fecha,tipo_asiento,diario,importe_debe,importe_haber,traspasado_de_gestion)
		 SELECT TOP(1) empresa,ejercicio,@pAsiento,fecha,'N',1,@pDebe,@phaber,1
		 FROM tmp_apuntes_traspaso WHERE codigo_tipo_documento_origen=@pcodigo_tipo_documento and sys_oid_origen=@psys_oid AND traspasado=0 and empresa=@pempresa
		 SET @pSys_oid_destino=IDENT_CURRENT('eje_asientos')
		 
		 INSERT INTO eje_apuntes (empresa,ejercicio,asiento,diario,fecha,tipo_asiento,apunte,subcuenta,importe_debe,importe_haber
						 ,descripcion,serie_documento,numero_documento,codigo_concepto,modelo_iva,modelo_347,base_imponible,iva,re,importe_metalico,contrapartida,traspasado_de_gestion,nif,razon_social)
		 SELECT empresa,ejercicio,@pAsiento,1,fecha,'N',apunte,subcuenta,importe_debe,importe_haber,descripcion,serie_documento
					,numero_documento,codigo_concepto,modelo_iva,modelo_347,base_imponible,iva,re,importe_metalico,contrapartida,1,NIF,razon_social
		 FROM tmp_apuntes_traspaso WHERE codigo_tipo_documento_origen=@pcodigo_tipo_documento and sys_oid_origen=@psys_oid AND traspasado=0 and empresa=@pempresa

		 SELECT @pFecha_creacion = sys_timestamp,@pFecha=fecha FROM eje_asientos WHERE sys_oid= @pSys_oid_destino
		 SELECT @pUsuario=usuario FROM sys_logins AS L,tmp_apuntes_traspaso AS t 
		 WHERE L.spid=t.sesion AND activa=1
		  AND spid=(SELECT sesion FROM tmp_apuntes_traspaso
		   WHERE codigo_tipo_documento_origen=@pcodigo_tipo_documento AND sys_oid=@psys_oid AND traspasado=0 and empresa=@pempresa)

		 UPDATE tmp_apuntes_traspaso SET traspasado=1,codigo_tipo_documento_destino='ASTO',sys_oid_destino=@pSys_oid_destino
		 WHERE codigo_tipo_documento_origen=@pcodigo_tipo_documento and sys_oid_origen=@psys_oid AND traspasado=0 and empresa=@pempresa

		 INSERT INTO gen_nav_documentos (tipo_documento_origen,oid_documento_origen,numero_documento_origen,fecha_documento_origen
						 ,tipo_documento_destino,numero_documento_destino,oid_documento_destino,fecha_documento_destino,usuario_creacion
						 ,fecha_creacion)
		SELECT TOP 1 codigo_tipo_documento_origen,sys_oid_origen,numero_documento,fecha,'ASTO',@pAsiento,@pSys_oid_destino
	 			 ,@pFecha,@pUsuario,@pFecha_creacion
				FROM tmp_apuntes_traspaso 
				WHERE codigo_tipo_documento_origen=@pcodigo_tipo_documento and sys_oid_origen=@psys_oid
				 AND sys_oid_destino=@pSys_oid_destino 
		
		
		FETCH NEXT FROM cursor_desglose_empresa INTO @pempresa,@pejercicio
	END	 
END

