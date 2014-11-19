use vs_martinez
GO
ALTER TABLE eje_venta_l add sys_oid_origen dm_oid null
go
ALTER TABLE eje_compra_l add sys_oid_origen dm_oid null

go

ALTER TRIGGER [dbo].[eje_venta_l_bi]
   ON  [dbo].[eje_venta_l]
   INSTEAD OF INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @empresa dm_empresas
	DECLARE @ejercicio dm_ejercicios
	DECLARE @codigo_tipo_documento dm_codigos_c
	DECLARE @serie dm_codigos_C
	DECLARE @numero	dm_numero_doc
	DECLARE @linea dm_entero
	DECLARE @codigo_almacen dm_codigos_c
	DECLAre @CODIGO_aRTICULO dm_codigo_articulo
	DECLARE @descripcion dm_descripcion_articulo
	DECLARE @descripcion_idioma dm_char_largo
	DECLARE @unidades dm_unidades
	declare @precio dm_precios
	declare @precio_e dm_precios
	declare @codigo_tipo_iva dm_codigos_c
	declare @dto1 dm_porcentajes
	declare @dto2 dm_porcentajes
	declare @iva dm_porcentajes
	declare @re dm_porcentajes
    DECLARE @precio_coste dm_precios
    DECLARE @numero_serie dm_char_corto
    DECLARE @adjuntos dm_adjuntos
	DECLARE @codigo_ubicacion dm_char_corto
	declare @total_linea dm_importes
	DECLARE @linea_origen dm_entero
	DECLARE @linea_destino dm_entero
	DECLARE @subcta_ventas dm_subcuenta
	DECLARE @pobservaciones dm_memo
	DECLARE @pobservaciones_internas dm_memo
	DECLARE @dto_maximo dm_porcentajes
	declare @sys_oid_oferta dm_oid
	DECLARE @bloquear_precios dm_logico
	declare @sys_oid_origen dm_oid
		
	DECLARE INSERTADOS CURSOR LOCAL FOR 
				SELECT DISTINCT i.empresa,i.ejercicio,i.codigo_tipo_documento,i.serie,i.numero,i.linea,codigo_almacen
				,CODIGO_aRTICULO,descripcion,descripcion_idioma,ISNULL(unidades,0),ISNULL(precio,0.0),ISNULL(precio_e,0.0),codigo_tipo_iva,dto1,dto2
				,p.porcentaje_iva,p.porcentaje_re,ISNULL(precio_coste,0.0),numero_serie,i.adjuntos,codigo_ubicacion,linea_origen_ecotasa, linea_destino_ecotasa
				,subcuenta_ventas,i.observaciones,i.observaciones_internas,i.dto_maximo,i.sys_oid_oferta,i.bloquear_precios,i.sys_oid_origen
				FROM inserted AS i
				INNER JOIN eje_venta_c AS c ON c.empresa=i.empresa AND c.ejercicio=i.ejercicio
						AND c.codigo_tipo_documento=i.codigo_tipo_documento AND c.serie=i.serie AND c.numero=i.numero
				LEFT OUTER JOIN eje_iva_porcentajes AS p ON i.empresa = p.empresa 
						AND i.ejercicio = p.ejercicio AND c.codigo_tabla_iva = p.codigo_tabla AND i.codigo_tipo_iva = p.codigo_tipo
						AND p.tipo_iva = 'R'

	OPEN insertados
	
	FETCH NEXT FROM insertados INTO @empresa,@ejercicio,@codigo_tipo_documento,@serie,@numero,@linea,@codigo_almacen,@CODIGO_aRTICULO
				,@descripcion,@descripcion_idioma,@unidades,@precio,@precio_e,@codigo_tipo_iva,@dto1,@dto2,@iva
				,@re,@precio_coste,@numero_serie,@adjuntos,@codigo_ubicacion,@linea_origen,@linea_destino,@subcta_ventas
				,@pobservaciones,@pobservaciones_internas,@dto_maximo,@sys_oid_oferta,@bloquear_precios,@sys_oid_origen

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		SET @total_linea = round(ISNULL(@precio,0.0) * ISNULL(@unidades,0) * (1 - COALESCE(@dto1,0)/100) * (1-COALESCE(@dto2,0)/100),2)
		insert into eje_venta_l (
					empresa,ejercicio,codigo_tipo_documento,serie,numero,linea,codigo_almacen,CODIGO_aRTICULO
					,descripcion,descripcion_idioma,unidades,precio,precio_e,codigo_tipo_iva,dto1,dto2,iva
					,re,precio_coste,numero_serie,adjuntos,codigo_ubicacion,total_linea,linea_origen_ecotasa,linea_destino_ecotasa
					,subcuenta_ventas,observaciones,observaciones_internas,dto_maximo,sys_oid_oferta,bloquear_precios,sys_oid_origen
)
		values (@empresa,@ejercicio,@codigo_tipo_documento,@serie,@numero,@linea,@codigo_almacen,@CODIGO_aRTICULO
				,@descripcion,@descripcion_idioma,@unidades,@precio,@precio_e,@codigo_tipo_iva,@dto1,@dto2,@iva
				,@re,@precio_coste,@numero_serie,@adjuntos,@codigo_ubicacion,@total_linea,@linea_origen,@linea_destino
				,@subcta_ventas,@pobservaciones,@pobservaciones_internas,@dto_maximo,@sys_oid_oferta,@bloquear_precios,@sys_oid_origen
				)
		
	FETCH NEXT FROM insertados INTO @empresa,@ejercicio,@codigo_tipo_documento,@serie,@numero,@linea,@codigo_almacen,@CODIGO_aRTICULO
				,@descripcion,@descripcion_idioma,@unidades,@precio,@precio_e,@codigo_tipo_iva,@dto1,@dto2,@iva
				,@re,@precio_coste,@numero_serie,@adjuntos,@codigo_ubicacion,@linea_origen,@linea_destino,@subcta_ventas
				,@pobservaciones,@pobservaciones_internas,@dto_maximo,@sys_oid_oferta,@bloquear_precios,@sys_oid_origen

	END

	close insertados
	deallocate insertados
	SET NOCOUNT OFF;

END
go

ALTER TRIGGER [dbo].[eje_venta_l_bu]
   ON  [dbo].[eje_venta_l]
   INSTEAD OF UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	DECLARE @empresa dm_empresas
	DECLARE @ejercicio dm_ejercicios
	DECLARE @codigo_tipo_documento dm_codigos_c
	DECLARE @serie dm_codigos_C
	DECLARE @numero	dm_numero_doc
	DECLARE @linea dm_entero
	DECLARE @codigo_almacen dm_codigos_c
	DECLAre @CODIGO_aRTICULO dm_codigo_articulo
	DECLARE @descripcion dm_descripcion_articulo
	DECLARE @descripcion_idioma dm_char_largo
	DECLARE @unidades dm_unidades
	declare @precio dm_precios
	declare @precio_e dm_precios
	declare @codigo_tipo_iva dm_codigos_c
	declare @dto1 dm_porcentajes
	declare @dto2 dm_porcentajes
	declare @iva dm_porcentajes
	declare @re dm_porcentajes
    DECLARE @precio_coste dm_precios
    DECLARE @numero_serie dm_char_corto
    DECLARE @adjuntos dm_adjuntos
	DECLARE @codigo_ubicacion dm_char_corto
	declare @total_linea dm_importes
	DECLARE @linea_origen dm_entero
	DECLARE @linea_destino dm_entero
	DECLARE @subcta_ventas dm_subcuenta
	DECLARE @pobservaciones dm_memo
	DECLARE @pobservaciones_internas dm_memo	
	DECLARE @dto_maximo dm_porcentajes
	declare @sys_oid_oferta dm_oid
	declare @bloquear_precios dm_logico
	declare @sys_oid_origen dm_oid
		
	DECLARE INSERTADOS CURSOR LOCAL FOR 
			SELECT DISTINCT i.empresa,i.ejercicio,i.codigo_tipo_documento,i.serie,i.numero,i.linea,codigo_almacen
				,CODIGO_aRTICULO,descripcion,descripcion_idioma,ISNULL(unidades,0),ISNULL(precio,0.0),ISNULL(precio_e,0.0),codigo_tipo_iva,dto1,dto2
				,p.porcentaje_iva,p.porcentaje_re,ISNULL(precio_coste,0.0),numero_serie,i.adjuntos,codigo_ubicacion,linea_origen_ecotasa, linea_destino_ecotasa
				,i.subcuenta_ventas,i.observaciones,i.observaciones_internas,i.dto_maximo,i.sys_oid_oferta,i.bloquear_precios,i.sys_oid_origen
				FROM inserted AS i
				INNER JOIN eje_venta_c AS c ON c.empresa=i.empresa AND c.ejercicio=i.ejercicio
						AND c.codigo_tipo_documento=i.codigo_tipo_documento AND c.serie=i.serie AND c.numero=i.numero
				LEFT OUTER JOIN eje_iva_porcentajes AS p ON i.empresa = p.empresa 
						AND i.ejercicio = p.ejercicio AND c.codigo_tabla_iva = p.codigo_tabla 
						AND i.codigo_tipo_iva = p.codigo_tipo AND p.tipo_iva = 'R'
	OPEN insertados
	FETCH NEXT FROM insertados INTO @empresa,@ejercicio,@codigo_tipo_documento,@serie,@numero,@linea,@codigo_almacen,@CODIGO_aRTICULO
				,@descripcion,@descripcion_idioma,@unidades,@precio,@precio_e,@codigo_tipo_iva,@dto1,@dto2,@iva
				,@re,@precio_coste,@numero_serie,@adjuntos,@codigo_ubicacion,@linea_origen,@linea_destino,@subcta_ventas
				,@pobservaciones,@pobservaciones_internas,@dto_maximo,@sys_oid_oferta,@bloquear_precios,@sys_oid_origen

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		SET @total_linea = round(ISNULL(@precio,0.0) * ISNULL(@unidades,0) * (1 - COALESCE(@dto1,0)/100) * (1-COALESCE(@dto2,0)/100),2)
		
		UPDATE eje_venta_l SET
			empresa=@empresa,ejercicio=@ejercicio,codigo_tipo_documento=@codigo_tipo_documento,serie=@serie,numero=@numero
			,linea=@linea,codigo_almacen=@codigo_almacen,CODIGO_aRTICULO=@CODIGO_aRTICULO,descripcion=@descripcion
			,descripcion_idioma=@descripcion_idioma,unidades=@unidades,precio=@precio,precio_e=@precio_e,codigo_tipo_iva=@codigo_tipo_iva
			,dto1=@dto1,dto2=@dto2,iva=@iva,re=@re,precio_coste=@precio_coste,numero_serie=@numero_serie,adjuntos=@adjuntos
			,codigo_ubicacion=@codigo_ubicacion,total_linea=@total_linea,linea_origen_ecotasa=@linea_origen,linea_destino_ecotasa=@linea_destino
			,subcuenta_ventas=@subcta_ventas,observaciones=@pobservaciones,observaciones_internas=@pobservaciones_internas
			,dto_maximo=@dto_maximo,sys_oid_oferta=@sys_oid_oferta,bloquear_precios=@bloquear_precios,sys_oid_origen=@sys_oid_origen
		 where empresa=@empresa and ejercicio=@ejercicio and codigo_tipo_documento=@codigo_tipo_documento and serie=@serie and numero=@numero and linea=@linea
		
		FETCH NEXT FROM insertados INTO @empresa,@ejercicio,@codigo_tipo_documento,@serie,@numero,@linea,@codigo_almacen,@CODIGO_aRTICULO
				,@descripcion,@descripcion_idioma,@unidades,@precio,@precio_e,@codigo_tipo_iva,@dto1,@dto2,@iva
				,@re,@precio_coste,@numero_serie,@adjuntos,@codigo_ubicacion,@linea_origen,@linea_destino,@subcta_ventas
				,@pobservaciones,@pobservaciones_internas,@dto_maximo,@sys_oid_oferta,@bloquear_precios,@sys_oid_origen
	END

	close insertados
	deallocate insertados
	SET NOCOUNT OFF;

END
go


ALTER VIEW [dbo].[vv_venta_l_ticket]
AS
SELECT     empresa, ejercicio, codigo_tipo_documento, serie, numero, linea, codigo_almacen, codigo_Articulo, descripcion, descripcion_idioma, unidades, precio, precio_e, dto1, 
                      dto2, total_linea, precio_coste, numero_serie, codigo_tipo_iva, observaciones, observaciones_internas, adjuntos, sys_logs, sys_borrado, sys_timestamp, sys_oid, 
                      iva, re, codigo_ubicacion, linea_origen_ecotasa, linea_destino_ecotasa, subcuenta_ventas, dto_maximo, sys_oid_oferta, bloquear_precios,sys_oid_origen
FROM         dbo.eje_venta_l
WHERE     (codigo_tipo_documento = 'TV')

GO




ALTER VIEW [dbo].[vv_venta_l_alba]
AS
SELECT     dbo.eje_venta_l.empresa, dbo.eje_venta_l.ejercicio, dbo.eje_venta_l.codigo_tipo_documento, dbo.eje_venta_l.serie, dbo.eje_venta_l.numero, dbo.eje_venta_l.linea, 
                      dbo.eje_venta_l.codigo_almacen, dbo.eje_venta_l.codigo_Articulo, dbo.eje_venta_l.descripcion, dbo.eje_venta_l.descripcion_idioma, dbo.eje_venta_l.unidades, 
                      dbo.eje_venta_l.precio, dbo.eje_venta_l.precio_e, dbo.eje_venta_l.dto1, dbo.eje_venta_l.dto2, dbo.eje_venta_l.total_linea, dbo.eje_venta_l.precio_coste, 
                      dbo.eje_venta_l.numero_serie, dbo.eje_venta_l.codigo_tipo_iva, dbo.eje_venta_l.observaciones, dbo.eje_venta_l.observaciones_internas, dbo.eje_venta_l.adjuntos, 
                      dbo.eje_venta_l.sys_logs, dbo.eje_venta_l.sys_borrado, dbo.eje_venta_l.sys_timestamp, dbo.eje_venta_l.sys_oid, dbo.eje_venta_l.iva, dbo.eje_venta_l.re, 
                      dbo.eje_venta_l.codigo_ubicacion, dbo.eje_alba_l.numero_pedido, dbo.eje_alba_l.sys_oid AS sys_oid_alba, dbo.eje_venta_l.linea_origen_ecotasa, 
                      dbo.eje_venta_l.linea_destino_ecotasa, dbo.eje_venta_l.subcuenta_ventas, dbo.eje_venta_l.dto_maximo, dbo.eje_venta_l.bloquear_precios, 
                      dbo.eje_venta_l.sys_oid_oferta,dbo.eje_venta_l.sys_oid_origen
FROM         dbo.eje_venta_l INNER JOIN
                      dbo.eje_alba_l ON dbo.eje_venta_l.empresa = dbo.eje_alba_l.empresa AND dbo.eje_venta_l.ejercicio = dbo.eje_alba_l.ejercicio AND 
                      dbo.eje_venta_l.codigo_tipo_documento = dbo.eje_alba_l.codigo_tipo_documento AND dbo.eje_venta_l.serie = dbo.eje_alba_l.serie AND 
                      dbo.eje_venta_l.numero = dbo.eje_alba_l.numero AND dbo.eje_venta_l.linea = dbo.eje_alba_l.linea
WHERE     (dbo.eje_venta_l.codigo_tipo_documento = 'AV')

GO


ALTER TRIGGER [dbo].[vv_venta_l_alba_bi]
   ON  [dbo].[vv_venta_l_alba]
   INSTEAD OF INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO eje_venta_l (
			empresa, ejercicio, codigo_tipo_documento, SERIE, numero, linea,
			codigo_almacen, codigo_Articulo, descripcion, descripcion_idioma, unidades, 
			precio, precio_e, dto1, dto2, total_linea, precio_coste, 
			numero_serie, codigo_tipo_iva, observaciones, observaciones_internas, adjuntos, 
			iva, re,codigo_ubicacion,linea_origen_ecotasa,linea_destino_ecotasa,subcuenta_ventas,
			dto_maximo,sys_oid_oferta,bloquear_precios,sys_oid_origen )
		SELECT empresa, ejercicio, codigo_tipo_documento, SERIE, numero, linea,
			codigo_almacen, codigo_Articulo, descripcion, descripcion_idioma, unidades, 
			precio, precio_e, dto1, dto2, total_linea, precio_coste, 
			numero_serie, codigo_tipo_iva, observaciones, observaciones_internas, adjuntos, 
			iva, re,codigo_ubicacion,linea_origen_ecotasa,linea_destino_ecotasa,subcuenta_ventas,
			dto_maximo,sys_oid_oferta,bloquear_precios,sys_oid_origen
		FROM INSERTED

	INSERT INTO eje_alba_l (empresa,ejercicio,codigo_tipo_documento,SERIE,numero,linea,numero_pedido) SELECT empresa,ejercicio,codigo_tipo_documento,SERIE,numero,linea,numero_pedido FROM INSERTED

END

go

ALTER TRIGGER [dbo].[vv_venta_l_alba_bu]
   ON  [dbo].[vv_venta_l_alba]
   INSTEAD OF UPDATE
AS 
BEGIN

	SET NOCOUNT ON;
	
	UPDATE eje_venta_l set empresa=i.empresa,ejercicio=i.ejercicio,codigo_tipo_documento=i.codigo_tipo_documento,serie=i.serie
		,numero=i.numero,linea=i.linea,
		codigo_almacen=i.codigo_almacen, codigo_Articulo=i. codigo_Articulo, descripcion=i.descripcion
		, descripcion_idioma=i.descripcion_idioma, unidades=i.unidades,precio=i.precio, precio_e=i.precio_e, dto1=i.dto1, dto2=i.dto2
		, total_linea=i.total_linea, precio_coste=i.precio_coste,numero_serie=i.numero_serie, codigo_tipo_iva=i.codigo_tipo_iva
		, observaciones=i.observaciones, observaciones_internas=i.observaciones_internas, adjuntos=i.adjuntos,iva=i.iva,re=i.re
		,codigo_ubicacion=i.codigo_ubicacion,linea_origen_ecotasa = i.linea_origen_ecotasa,linea_destino_ecotasa=i.linea_destino_ecotasa
		,subcuenta_ventas=i.subcuenta_ventas,dto_maximo=i.dto_maximo,sys_oid_oferta=i.sys_oid_oferta,bloquear_precios=i.bloquear_precios,sys_oid_origen=i.sys_oid_origen
		FROM eje_venta_l
		 INNER JOIN inserted AS i ON eje_venta_l.sys_oid = i.sys_oid
		 INNER JOIN deleted ON i.sys_oid = deleted.sys_oid
		
	UPDATE eje_alba_l set numero_pedido=inserted.numero_pedido
		FROM eje_alba_l
		 INNER JOIN inserted ON eje_alba_l.sys_oid = inserted.sys_oid_alba
		 INNER JOIN deleted ON inserted.sys_oid_alba = deleted.sys_oid_alba
	
	SET NOCOUNT OFF

END

go


/****** Object:  StoredProcedure [dbo].[vs_crea_ticket]    Script Date: 02/28/2012 17:06:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[vs_crea_ticket]
	@pTimeStamp dm_fechas_hora,
	@pSesion dm_entero,
	@pUsuario dm_codigos_c
AS
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
DECLARE @pNumeroDestino dm_numero_doc
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

/******** PARA CLIENETES VARIOS ***********/
DECLARE @codigo_tercero dbo.dm_codigos_n 
DECLARE @codigo_cliente dbo.dm_codigos_n 
DECLARE @nombre_cliente dbo.dm_nombres 
DECLARE @razon_social_cliente dbo.dm_nombres 
DECLARE @nif_cliente dbo.dm_nif 
DECLARE @domicilio_cliente dbo.dm_domicilio 
DECLARE @codigo_postal_cliente dbo.dm_codigo_postal 
DECLARE @poblacion_cliente dbo.dm_poblacion 
DECLARE @provincia_cliente dbo.dm_provincia 

DECLARE @pCodigoEcotasa dm_codigo_articulo = NULL
DECLARE @pEcotasa dm_entero_corto
DECLARE @pSubcta_ventas dm_subcuenta
DECLARE @pobservaciones dm_memo
DECLARE @pobservaciones_internas dm_memo
DECLARE @dto_maximo dm_porcentajes
DECLARE @sys_oid_oferta dm_oid
DECLARE @bloquear_precios dm_logico

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
			RAISERROR('YA SE HA GENERADO UN TICKET DEL PEDIDO',16,1)
	
		set @pError = 'ERROR GENERANDO LA CABECERA DEL TICKET ' + CHAR(13) + CHAR(10)

	/******************  CURSOR DE TICKETS   **********************/
		DECLARE ticket CURSOR FOR 
			SELECT s.empresa, s.ejercicio, s.codigo_tipo_documento, s.serie, s.numero, c.fecha, S.empresa_destino
			, S.ejercicio_destino, S.codigo_tipo_documento_destino, S.serie_destino, S.numero_destino, 
				  S.codigo_almacen, S.codigo_articulo, S.descripcion, S.unidades_a_servir, S.unidades_a_anular, S.precio
				  ,L.precio_e, L.precio_coste, S.dto1, S.dto2, L.numero_serie, S.codigo_tipo_iva, L.adjuntos
				  ,S.codigo_ubicacion,S.sys_oid_origen,S.fecha_destino, s.sys_oid, c.sys_oid
				  ,CL.codigo_tercero,CL.codigo,T.nombre,T.razon_social,T.nif,T.domicilio,T.codigo_postal,T.poblacion,T.provincia
				  ,L.subcuenta_ventas,L.observaciones,L.observaciones_internas,L.dto_maximo,L.sys_oid_oferta,L.bloquear_precios 
			FROM dbo.tmp_servir_documento AS S 
				INNER JOIN dbo.vv_venta_l_pedido AS L ON S.sys_oid_origen = L.sys_oid 
				INNER JOIN dbo.eje_venta_c AS C ON L.empresa = C.empresa AND L.ejercicio = C.ejercicio AND L.codigo_tipo_documento = C.codigo_tipo_documento 
					AND L.SERIE = C.serie AND L.numero = C.numero
				LEFT JOIN emp_clientes AS CL ON C.codigo_cliente=CL.codigo
				LEFT JOIN emp_terceros AS T ON T.codigo = CL.codigo_tercero 
				INNER JOIN gen_empresas AS E ON E.codigo = S.empresa
			WHERE s.sys_timestamp = @pTimeStamp
			  AND s.sesion=@pSesion 
			  AND s.grupo = @pGrupo
			  AND s.generada = 0

		OPEN ticket 
				  
		FETCH NEXT FROM ticket INTO @pEmpresaOrigen, @pEjercicioOrigen, @pCodigoTipoDocumentoOrigen,@pSerieOrigen,@pNumeroOrigen
		,@pFechaOrigen, @pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumeroDestino,@codigo_almacen,@codigo_articulo,@descripcion
		,@unidades_a_servir,@unidades_a_anular,@precio,@precio_e,@precio_coste,@dto1,@dto2,@numero_serie,@codigo_tipo_iva,@adjuntos,@codigo_ubicacion
		,@pSys_oid,@pFecha,@pSys_Oid_Tmp,@pOidOrigen,@codigo_tercero,@codigo_cliente,@nombre_cliente,@razon_social_cliente,@nif_cliente,@domicilio_cliente,@codigo_postal_cliente
		,@poblacion_cliente,@provincia_cliente,@pSubcta_ventas,@pobservaciones,@pobservaciones_internas,@dto_maximo,@sys_oid_oferta,@bloquear_precios 
			
		IF @pNumero IS NULL 
		BEGIN
			EXEC vs_proximo_numero_serie @pEmpresa, @pEjercicio, @pCodigo_tipo_documento, @pSerie, @pFecha, 1, @pNumeroDestino OUTPUT

			SELECT @codigo_tercero=C.codigo_tercero,@codigo_cliente=C.codigo,@nombre_cliente=T.nombre,@razon_social_cliente=T.[razon_social]
					,@nif_cliente=T.nif,@domicilio_cliente=T.domicilio,@codigo_postal_cliente=T.codigo_postal,@poblacion_cliente=T.poblacion
					,@provincia_cliente=T.provincia
					FROM [emp_clientes] AS C
					INNER JOIN emp_terceros AS T ON t.codigo = C.codigo_tercero 
					INNER JOIN gen_empresas AS E ON E.codigo = @pEmpresa   
			 WHERE C.codigo = E.codigo_clientes_varios
  
			INSERT INTO eje_venta_c (
						[empresa],[ejercicio],[codigo_tipo_documento],[serie],[numero],[codigo_tipo_cond_venta],[fecha],[situacion]
						,[codigo_tercero],[codigo_cliente],[nombre_cliente],[razon_social_cliente],[nif_cliente],[domicilio_cliente]
						,[codigo_postal_cliente],[poblacion_cliente],[provincia_cliente],[codigo_forma_pago],[codigo_tabla_iva]
						,[codigo_representante],[dto_comercial],[dto_financiero],[numero_copias],[adjuntos],[codigo_pais_cliente]
						,[referencia],[codigo_divisa],[cambio_divisa],[codigo_tarifa],[identificador_dir_envio],[alias_dir_envio]
						,[nombre_dir_envio],[domicilio_dir_envio],[sucursal_dir_envio],[codigo_postal_dir_envio],[poblacion_dir_envio]
						,[provincia_dir_envio],[codigo_pais_dir_envio],[telefono_dir_envio],[movil_dir_envio],[email_dir_envio]
						,[fax_dir_envio],[codigo_portes],[codigo_tipo_iva_portes],[aplicar_en_totales_portes],[importe_portes]
						,[cargo_financiero],[realizado_por],[codigo_agencia],piramidal,aplicar_cargo_financiero,codigo_centro_venta
						,criterio_conjuntacion,aplicar_cargo_financiero_dias  )
			SELECT TOP (1) 
						S.empresa_destino,S.ejercicio_destino,S.codigo_tipo_documento_destino,S.serie_destino,@pNumeroDestino,S.codigo_tipo_cond_venta_destino,fecha_destino,'N'
						,@codigo_tercero, @codigo_cliente,@nombre_cliente,@razon_social_cliente,@nif_cliente,@domicilio_cliente
						,@codigo_postal_cliente,@poblacion_cliente,@provincia_cliente, C.codigo_forma_pago, C.codigo_tabla_iva, C.codigo_representante
						,C.dto_comercial, C.dto_financiero, C.numero_copias, C.adjuntos, C.codigo_pais_cliente,C.referencia, C.codigo_divisa
						, C.cambio_divisa, C.codigo_tarifa, C.identificador_dir_envio,C.alias_dir_envio, C.nombre_dir_envio, C.domicilio_dir_envio
						, C.sucursal_dir_envio,C.codigo_postal_dir_envio, C.poblacion_dir_envio, C.provincia_dir_envio, C.codigo_pais_dir_envio
						,C.telefono_dir_envio, C.movil_dir_envio, C.email_dir_envio, C.fax_dir_envio,C.codigo_portes, C.codigo_tipo_iva_portes
						, C.aplicar_en_totales_portes, C.importe_portes,C.cargo_financiero, @pUsuario, C.codigo_agencia,C.codigo_cliente
						, C.aplicar_cargo_financiero,C.codigo_centro_venta,C.criterio_conjuntacion,C.aplicar_cargo_financiero_dias
			FROM  dbo.tmp_servir_documento AS S 
				INNER JOIN dbo.vv_venta_l_pedido AS l ON S.sys_oid_origen = L.sys_oid 
				INNER JOIN dbo.vv_venta_c_pedido AS C ON L.empresa = C.empresa AND L.ejercicio = C.ejercicio AND L.codigo_tipo_documento = C.codigo_tipo_documento 
					AND L.SERIE = C.serie AND L.numero = C.numero
			WHERE sesion=@pSesion 
			  AND grupo = @pGrupo 
			  AND generada = 0				
		END
		ELSE 
		BEGIN
			SET @pNumeroDestino = @pNumero
		END		
		set @pSys_oid_C_Destino = (SELECT SYS_OID FROM eje_venta_c 
										WHERE empresa = @pEmpresa
										  AND ejercicio = @pEjercicio
										  AND codigo_tipo_documento = @pCodigo_tipo_documento
										  AND serie = @pSerie
										  AND numero = @pNumeroDestino)
			
		set @pContador = ISNULL((SELECT MAX(linea) FROM eje_venta_l WHERE empresa = @pEmpresa AND ejercicio = @pEjercicio AND codigo_tipo_documento = @pCodigo_tipo_documento
							AND serie = @pSerie AND numero = @pNumeroDestino),0)
		
		WHILE @@FETCH_STATUS=0
		BEGIN
			
			IF @unidades_a_servir <> 0 OR (ISNULL(@unidades_a_servir,0) = 0 AND ISNULL(@codigo_articulo,'') = '' AND ISNULL(@descripcion,'') <> '')
			BEGIN		
				SET @pContador += 1
				set @pError = 'ERROR GENERANDO LA LINEA ' + RTRIM(STR(@pContador)) + '  DEL TICKET ' + CHAR(13) + CHAR(10)  

				INSERT INTO eje_venta_l (empresa,ejercicio,codigo_tipo_documento,SERIE,Numero,codigo_almacen,codigo_articulo,descripcion,unidades
						,precio,precio_e,dto1,dto2,precio_coste,numero_serie,codigo_tipo_iva,adjuntos,codigo_ubicacion,linea,subcuenta_ventas
						,observaciones,observaciones_internas,dto_maximo,sys_oid_oferta,bloquear_precios,sys_oid_origen  )
				 VALUES (@pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumeroDestino,@codigo_almacen,@codigo_articulo,@descripcion,@unidades_a_servir
						,@precio,@precio_e,@dto1,@dto2,@precio_coste,@numero_serie,@codigo_tipo_iva,@adjuntos,@codigo_ubicacion,@pContador,@pSubcta_ventas
						,@pobservaciones,@pobservaciones_internas,@dto_maximo,@sys_oid_oferta,@bloquear_precios,@psys_oid )

				SELECT @pCodigoEcotasa=a1.codigo,@precio=A1.pvp,@descripcion=A1.descripcion,@codigo_tipo_iva=A1.codigo_tipo_iva,@bloquear_precios=A1.bloquear_precios
					 FROM emp_articulos AS A1 
						INNER JOIN emp_articulos AS A2 ON A1.empresa = A2.empresa AND A1.codigo=A2.ecotasa
					 WHERE A2.empresa = @pEmpresa 
					   AND A2.codigo=@codigo_articulo 
					   AND A1.es_ecotasa=1
				
				IF @pCodigoEcotasa IS NOT NULL
					BEGIN
						SET @pContador += 1
						INSERT INTO eje_venta_l (empresa,ejercicio,codigo_tipo_documento,SERIE,Numero,codigo_almacen,codigo_articulo,descripcion,unidades
								,precio,precio_e,dto1,dto2,precio_coste,numero_serie,codigo_tipo_iva,adjuntos,codigo_ubicacion,linea,linea_origen_ecotasa
								,subcuenta_ventas,observaciones,observaciones_internas,dto_maximo,sys_oid_oferta,bloquear_precios  )
						 VALUES (@pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumeroDestino,@codigo_almacen,@pCodigoEcotasa,@descripcion,@unidades_a_servir
								,@precio,@precio_e,0,0,@precio_coste,@numero_serie,@codigo_tipo_iva,@adjuntos,@codigo_ubicacion,@pContador,@pContador-1
								,@pSubcta_ventas,@pobservaciones,@pobservaciones_internas,@dto_maximo,NULL,@bloquear_precios)
						SET @pCodigoEcotasa = NULL
						  UPDATE eje_venta_l SET linea_destino_ecotasa=@pContador WHERE codigo_articulo=@codigo_articulo AND empresa=@pEmpresa
						  SET @pEcotasa = ( SELECT distinct v2.linea FROM vv_venta_l_pedido AS v1 INNER JOIN vv_venta_l_pedido AS v2
											ON v1.linea_destino_ecotasa=v2.linea AND v2.linea_origen_ecotasa=v1.linea AND v1.numero=v2.numero
											WHERE v1.sys_oid=@pSys_oid )
							UPDATE vv_venta_l_pedido SET 
								unidades_servidas=ISNULL(unidades_servidas,0) + isnull(@unidades_a_servir,0),
								unidades_anuladas=ISNULL(unidades_anuladas,0) + ISNULL(@unidades_a_anular,0),
								unidades_pendientes=ISNULL(unidades_pendientes,0)-(isnull(@unidades_a_servir,0)+isnull(@unidades_a_anular,0))
							 WHERE vv_venta_l_pedido.numero=@pNumeroOrigen AND linea=@pEcotasa					  
					
					
					END							
			
				SET @pSys_oid_destino = (SELECT sys_oid 
										    FROM eje_venta_l 
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
			  
			UPDATE vv_venta_l_pedido SET 
				unidades_servidas=ISNULL(unidades_servidas,0) + isnull(@unidades_a_servir,0),
				unidades_anuladas=ISNULL(unidades_anuladas,0) + ISNULL(@unidades_a_anular,0),
				unidades_pendientes=ISNULL(unidades_pendientes,0)-(isnull(@unidades_a_servir,0)+isnull(@unidades_a_anular,0))
			 WHERE vv_venta_l_pedido.sys_oid=@pSys_oid
			
			IF NOT EXISTS (SELECT * FROM vv_venta_l_pedido 
							WHERE empresa = @pEmpresaOrigen 
							  AND ejercicio = @pEjercicioOrigen
							  AND codigo_tipo_documento = @pCodigoTipoDocumentoOrigen
							  AND SERIE = @pSerieOrigen
							  AND numero = @pNumeroOrigen
							  AND unidades_pendientes <> 0)
			BEGIN				  
				UPDATE vv_venta_c_pedido SET 
					situacion = 'S'
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
		
			FETCH NEXT FROM ticket INTO @pEmpresaOrigen, @pEjercicioOrigen, @pCodigoTipoDocumentoOrigen,@pSerieOrigen,@pNumeroOrigen
			,@pFechaOrigen, @pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumero,@codigo_almacen,@codigo_articulo,@descripcion,@unidades_a_servir
			,@unidades_a_anular,@precio,@precio_e,@precio_coste,@dto1,@dto2,@numero_serie,@codigo_tipo_iva,@adjuntos,@codigo_ubicacion,@pSys_oid,@pFecha,@pSys_Oid_Tmp,@pOidOrigen
			,@codigo_tercero,@codigo_cliente,@nombre_cliente,@razon_social_cliente,@nif_cliente,@domicilio_cliente,@codigo_postal_cliente
			,@poblacion_cliente,@provincia_cliente,@pSubcta_ventas,@pobservaciones,@pobservaciones_internas,@dto_maximo,@sys_oid_oferta,@bloquear_precios 

		END

	 INSERT INTO eje_venta_entregas (empresa,ejercicio,codigo_tipo_documento,serie,numero,linea,fecha_entrega,entrega_a_cuenta,codigo_banco)
		  SELECT DISTINCT  @pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumeroDestino,E1.linea,E1.fecha_entrega,E1.entrega_a_cuenta,E1.codigo_banco
		  FROM dbo.eje_venta_entregas AS E1 
		  INNER JOIN dbo.tmp_servir_documento AS T ON E1.empresa = T.empresa AND E1.ejercicio = T.ejercicio AND E1.codigo_tipo_documento = T.codigo_tipo_documento AND 
             E1.serie = T.serie AND E1.numero = T.numero WHERE E1.sys_oid_destino IS NULL and t.sys_timestamp = @pTimeStamp
			  AND t.sesion=@pSesion 
			  AND t.grupo = @pGrupo		
		  if @@ROWCOUNT >0 
			  UPDATE eje_venta_entregas SET sys_oid_destino = @pSys_oid_C_Destino
					FROM eje_venta_entregas AS E1
						inner join dbo.tmp_servir_documento AS T ON E1.empresa = T.empresa AND E1.ejercicio = T.ejercicio AND E1.codigo_tipo_documento = T.codigo_tipo_documento AND 
				 E1.serie = T.serie AND E1.numero = T.numero WHERE E1.sys_oid_destino IS NULL and t.sys_timestamp = @pTimeStamp  AND t.sesion=@pSesion AND t.grupo = @pGrupo		 
 
		set @pError = 'ERROR AL CALCULAR EL TOTAL  DEL TICKET ' + CHAR(13) + CHAR(10)  
		EXEC vs_calcular_total_venta @pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumeroDestino			
		EXEC vs_calcular_vencimientos @pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumeroDestino			
		EXEC vs_generar_asiento_venta @pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumeroDestino			
		
				
		CLOSE  ticket
		DEALLOCATE ticket

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
	set @pError = 'ERROR AL GENERAR EL TICKET (' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + @pError +  ERROR_MESSAGE()
	ROLLBACK
	RAISERROR(@pError,16,1)
END CATCH

END

go

ALTER PROCEDURE [dbo].[vs_crea_albaranes]  
 @pTimeStamp dm_fechas_hora,  
 @pSesion dm_entero,  
 @pUsuario dm_codigos_c  
AS  
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
DECLARE @pNumero dm_numero_doc  
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
DECLARE @pcodigo_tercero dm_codigos_n
  
DECLARE @pCodigoEcotasa dm_codigo_articulo = NULL
DECLARE @pEcotasa dm_entero_corto
DECLARE @pSubcta_ventas dm_subcuenta
DECLARE @pobservaciones dm_memo
DECLARE @pobservaciones_internas dm_memo
DECLARE @dto_maximo dm_porcentajes
DECLARE @sys_oid_oferta dm_oid
DECLARE @bloquear_precios dm_logico

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
 
	set @pError = 'ERROR GENERANDO LA CABECERA DEL ALBARAN' + CHAR(13) + CHAR(10)
	
	IF EXISTS (SELECT DISTINCT C.situacion 
		FROM tmp_servir_documento AS S 
		INNER JOIN dbo.eje_venta_c AS C ON S.empresa = C.empresa AND S.ejercicio = C.ejercicio AND S.codigo_tipo_documento = C.codigo_tipo_documento 
		AND S.SERIE = C.serie AND S.numero = C.numero
		WHERE s.sys_timestamp = @pTimeStamp  
			AND s.sesion=@pSesion   
			AND s.grupo = @pGrupo 
			AND s.generada = 0 AND C.situacion!='N')
			
		RAISERROR('YA SE HA GENERADO UN ALBARAN DEL PEDIDO',16,1)
			
 /******************  CURSOR DE ALBARANES   **********************/  
  DECLARE alba CURSOR FOR   
   SELECT s.empresa, s.ejercicio, s.codigo_tipo_documento, s.serie, s.numero, c.fecha, S.empresa_destino, S.ejercicio_destino, S.codigo_tipo_documento_destino, S.serie_destino, S.numero_destino,   
      S.codigo_almacen, S.codigo_articulo, S.descripcion, S.unidades_a_servir, S.unidades_a_anular, S.precio  
      ,L.precio_e, L.precio_coste, S.dto1, S.dto2, L.numero_serie, S.codigo_tipo_iva, L.adjuntos  
      , S.codigo_ubicacion,S.sys_oid_origen,S.fecha_destino, s.sys_oid, c.sys_oid,c.codigo_tercero,L.subcuenta_ventas
      ,L.observaciones,L.observaciones_internas,L.dto_maximo,L.sys_oid_oferta,L.bloquear_precios
   FROM dbo.tmp_servir_documento AS S   
    INNER JOIN dbo.vv_venta_l_pedido AS L ON S.sys_oid_origen = L.sys_oid   
    INNER JOIN dbo.eje_venta_c AS C ON L.empresa = C.empresa AND L.ejercicio = C.ejercicio AND L.codigo_tipo_documento = C.codigo_tipo_documento   
     AND L.SERIE = C.serie AND L.numero = C.numero  
   WHERE s.sys_timestamp = @pTimeStamp  
     AND s.sesion=@pSesion   
     AND s.grupo = @pGrupo  
     AND s.generada = 0
  
  OPEN alba   
  FETCH NEXT FROM alba INTO @pEmpresaOrigen, @pEjercicioOrigen, @pCodigoTipoDocumentoOrigen,@pSerieOrigen,@pNumeroOrigen, @pFechaOrigen
  ,@pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumero,@codigo_almacen,@codigo_articulo,@descripcion,@unidades_a_servir
  ,@unidades_a_anular,@precio,@precio_e,@precio_coste,@dto1,@dto2,@numero_serie,@codigo_tipo_iva,@adjuntos,@codigo_ubicacion
  ,@pSys_oid,@pFecha,@pSys_Oid_Tmp,@pOidOrigen,@pcodigo_tercero,@pSubcta_ventas,@pobservaciones,@pobservaciones_internas
  ,@dto_maximo,@sys_oid_oferta,@bloquear_precios
   
  IF @pNumero IS NULL   
  BEGIN  
   EXEC vs_proximo_numero_serie @pempresa, @pEjercicio, @pCodigo_tipo_documento, @pSerie,@pFecha, 1, @pNumeroDestino OUTPUT  
     
   INSERT INTO vv_venta_c_alba (  
         [empresa],[ejercicio],[codigo_tipo_documento],[serie],[numero],[codigo_tipo_cond_venta],[fecha],[situacion]  
         ,[codigo_tercero],[codigo_cliente],[nombre_cliente],[razon_social_cliente],[nif_cliente],[domicilio_cliente]  
         ,[codigo_postal_cliente],[poblacion_cliente],[provincia_cliente],[codigo_forma_pago],[codigo_tabla_iva]  
         ,[codigo_representante],[dto_comercial],[dto_financiero],[numero_copias],[adjuntos],[codigo_pais_cliente]  
         ,[referencia],[codigo_divisa],[cambio_divisa],[codigo_tarifa],[identificador_dir_envio],[alias_dir_envio]  
         ,[nombre_dir_envio],[domicilio_dir_envio],[sucursal_dir_envio],[codigo_postal_dir_envio],[poblacion_dir_envio]  
         ,[provincia_dir_envio],[codigo_pais_dir_envio],[telefono_dir_envio],[movil_dir_envio],[email_dir_envio]  
         ,[fax_dir_envio],[codigo_portes],[codigo_tipo_iva_portes],[aplicar_en_totales_portes],[importe_portes]  
         ,[cargo_financiero],[realizado_por],[codigo_agencia],[su_pedido],aplicar_cargo_financiero,codigo_centro_venta
         ,criterio_conjuntacion,aplicar_cargo_financiero_dias,albaran_retenido,compensar_abono)  
   SELECT TOP (1)   
      S.empresa_destino,S.ejercicio_destino,S.codigo_tipo_documento_destino,S.serie_destino,@pNumeroDestino,S.codigo_tipo_cond_venta_destino,fecha_destino,'N'  
      ,C.codigo_tercero, C.codigo_cliente, C.nombre_cliente, C.razon_social_cliente,C.nif_cliente, C.domicilio_cliente  
      , C.codigo_postal_cliente, C.poblacion_cliente,C.provincia_cliente, C.codigo_forma_pago, C.codigo_tabla_iva, C.codigo_representante  
      ,C.dto_comercial, C.dto_financiero, C.numero_copias, C.adjuntos, C.codigo_pais_cliente,C.referencia, C.codigo_divisa  
      , C.cambio_divisa, C.codigo_tarifa, C.identificador_dir_envio,C.alias_dir_envio, C.nombre_dir_envio, C.domicilio_dir_envio  
      , C.sucursal_dir_envio,C.codigo_postal_dir_envio, C.poblacion_dir_envio, C.provincia_dir_envio, C.codigo_pais_dir_envio  
      ,C.telefono_dir_envio, C.movil_dir_envio, C.email_dir_envio, C.fax_dir_envio,C.codigo_portes, C.codigo_tipo_iva_portes  
      , C.aplicar_en_totales_portes, C.importe_portes,C.cargo_financiero, @pUsuario, C.codigo_agencia, C.su_pedido,C.aplicar_cargo_financiero,C.codigo_centro_venta
      ,C.criterio_conjuntacion,C.aplicar_cargo_financiero_dias,0,0
   FROM  dbo.tmp_servir_documento AS S   
    INNER JOIN dbo.vv_venta_l_pedido AS l ON S.sys_oid_origen = L.sys_oid   
    INNER JOIN dbo.vv_venta_c_pedido AS C ON L.empresa = C.empresa AND L.ejercicio = C.ejercicio AND L.codigo_tipo_documento = C.codigo_tipo_documento   
     AND L.SERIE = C.serie AND L.numero = C.numero  
   WHERE sesion=@pSesion   
     AND grupo = @pGrupo   
     AND generada = 0      
  END
ELSE 
BEGIN
	SET @pNumeroDestino = @pNumero
END
    
  set @pSys_oid_C_Destino = (SELECT SYS_OID FROM eje_venta_c   
          WHERE empresa = @pEmpresa  
            AND ejercicio = @pEjercicio  
            AND codigo_tipo_documento = @pCodigo_tipo_documento  
            AND serie = @pSerie  
            AND numero = @pNumeroDestino)  
     
  set @pContador = ISNULL((SELECT MAX(linea) FROM eje_venta_l WHERE empresa = @pEmpresa AND ejercicio = @pEjercicio AND codigo_tipo_documento = @pCodigo_tipo_documento  
       AND serie = @pSerie AND numero = @pNumeroDestino),0)  
    
  WHILE @@FETCH_STATUS=0  
  BEGIN  
     
   IF @unidades_a_servir <> 0 OR (ISNULL(@unidades_a_servir,0) = 0 AND ISNULL(@codigo_articulo,'') = '' AND ISNULL(@descripcion,'') <> '')
   BEGIN    
    SET @pContador += 1  

	set @pError = 'ERROR GENERANDO LA LINEA ' + RTRIM(STR(@pContador)) + ' DEL ALBARAN' + CHAR(13) + CHAR(10)  
	
    INSERT INTO vv_venta_l_alba (empresa,ejercicio,codigo_tipo_documento,SERIE,Numero,codigo_almacen,codigo_articulo,descripcion,unidades  
      ,precio,precio_e,dto1,dto2,precio_coste,numero_serie,codigo_tipo_iva,adjuntos,codigo_ubicacion,linea,subcuenta_ventas
      ,observaciones,observaciones_internas,dto_maximo,sys_oid_oferta,bloquear_precios,sys_oid_origen )  
     VALUES (@pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumeroDestino,@codigo_almacen,@codigo_articulo,@descripcion,@unidades_a_servir  
      ,@precio,@precio_e,@dto1,@dto2,@precio_coste,@numero_serie,@codigo_tipo_iva,@adjuntos,@codigo_ubicacion,@pContador,@pSubcta_ventas   
	  ,@pobservaciones,@pobservaciones_internas,@dto_maximo,@sys_oid_oferta,@bloquear_precios,@pSys_oid )
	  
	SELECT @pCodigoEcotasa=a1.codigo,@precio=a1.pvp,@descripcion=a1.descripcion,@codigo_tipo_iva=a1.codigo_tipo_iva,@bloquear_precios=A1.bloquear_precios
	  FROM emp_articulos AS a1 
		INNER JOIN emp_articulos AS a2 ON a1.codigo=a2.ecotasa
	 WHERE a2.empresa = @pEmpresa 
	   AND a2.codigo=@codigo_articulo 
	   AND a1.es_ecotasa=1 
				
	IF @pCodigoEcotasa IS NOT NULL
		BEGIN
			SET @pContador += 1
		  
			INSERT INTO vv_venta_l_alba (empresa,ejercicio,codigo_tipo_documento,SERIE,Numero,codigo_almacen,codigo_articulo,descripcion,unidades  
			,precio,precio_e,dto1,dto2,precio_coste,numero_serie,codigo_tipo_iva,adjuntos,codigo_ubicacion,linea,linea_origen_ecotasa
			,subcuenta_ventas,sys_oid_oferta,bloquear_precios)
			VALUES (@pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumeroDestino,@codigo_almacen,@pCodigoEcotasa,@descripcion,@unidades_a_servir  
			,@precio,@precio, 0, 0,@precio,'',@codigo_tipo_iva,@adjuntos,@codigo_ubicacion,@pContador
			,@pContador-1,@pSubcta_ventas,NULL,@bloquear_precios)

			SET @pCodigoEcotasa = NULL

			UPDATE vv_venta_l_alba SET linea_destino_ecotasa=@pContador WHERE codigo_articulo=@codigo_articulo AND empresa=@pEmpresa
			SET @pEcotasa = ( SELECT distinct v2.linea FROM vv_venta_l_pedido AS v1 INNER JOIN vv_venta_l_pedido AS v2
								ON v1.linea_destino_ecotasa=v2.linea AND v2.linea_origen_ecotasa=v1.linea AND v1.numero=v2.numero
								WHERE v1.sys_oid=@pSys_oid )
								
			UPDATE vv_venta_l_pedido SET 
			unidades_servidas=ISNULL(unidades_servidas,0) + isnull(@unidades_a_servir,0),
			unidades_anuladas=ISNULL(unidades_anuladas,0) + ISNULL(@unidades_a_anular,0),
			unidades_pendientes=ISNULL(unidades_pendientes,0)-(isnull(@unidades_a_servir,0)+isnull(@unidades_a_anular,0))
			WHERE vv_venta_l_pedido.numero=@pNumeroOrigen AND linea=@pEcotasa					  
		END


    SET @pSys_oid_destino = (SELECT sys_oid   
              FROM vv_venta_l_alba   
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
       
   UPDATE vv_venta_l_pedido SET   
    unidades_servidas=ISNULL(unidades_servidas,0) + isnull(@unidades_a_servir,0),  
    unidades_anuladas=ISNULL(unidades_anuladas,0) + ISNULL(@unidades_a_anular,0),  
    unidades_pendientes=ISNULL(unidades_pendientes,0)-(isnull(@unidades_a_servir,0)+isnull(@unidades_a_anular,0))  
    WHERE vv_venta_l_pedido.sys_oid=@pSys_oid  
     
   IF NOT EXISTS (SELECT * FROM vv_venta_l_pedido   
       WHERE empresa = @pEmpresaOrigen   
         AND ejercicio = @pEjercicioOrigen  
         AND codigo_tipo_documento = @pCodigoTipoDocumentoOrigen  
         AND SERIE = @pSerieOrigen  
         AND numero = @pNumeroOrigen  
         AND unidades_pendientes <> 0)  
   BEGIN        
    UPDATE vv_venta_c_pedido SET   
     situacion = 'S'  
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
    
	 FETCH NEXT FROM alba INTO @pEmpresaOrigen, @pEjercicioOrigen, @pCodigoTipoDocumentoOrigen,@pSerieOrigen,@pNumeroOrigen, @pFechaOrigen
	 ,@pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumero,@codigo_almacen,@codigo_articulo,@descripcion,@unidades_a_servir
	 ,@unidades_a_anular,@precio,@precio_e,@precio_coste,@dto1,@dto2,@numero_serie,@codigo_tipo_iva,@adjuntos,@codigo_ubicacion
	 ,@pSys_oid,@pFecha,@pSys_Oid_Tmp,@pOidOrigen,@pcodigo_tercero,@pSubcta_ventas,@pobservaciones,@pobservaciones_internas
	 ,@dto_maximo,@sys_oid_oferta,@bloquear_precios 
 END
 
 	 INSERT INTO eje_venta_entregas (empresa,ejercicio,codigo_tipo_documento,serie,numero,linea,fecha_entrega,entrega_a_cuenta,codigo_banco)
		  SELECT DISTINCT E1.empresa, E1.ejercicio, @pCodigo_tipo_documento,@pserie,@pNumeroDestino,E1.linea,E1.fecha_entrega,E1.entrega_a_cuenta,E1.codigo_banco
		  FROM dbo.eje_venta_entregas AS E1 
		  INNER JOIN dbo.tmp_servir_documento AS T ON E1.empresa = T.empresa AND E1.ejercicio = T.ejercicio AND E1.codigo_tipo_documento = T.codigo_tipo_documento AND 
             E1.serie = T.serie AND E1.numero = T.numero WHERE E1.sys_oid_destino IS NULL and t.sys_timestamp = @pTimeStamp
			  AND t.sesion=@pSesion 
			  AND t.grupo = @pGrupo		
		  
		  UPDATE E1 SET e1.sys_oid_destino = @pSys_oid_C_Destino
				FROM eje_venta_entregas AS E1
					inner join dbo.tmp_servir_documento AS T ON E1.empresa = T.empresa AND E1.ejercicio = T.ejercicio AND E1.codigo_tipo_documento = T.codigo_tipo_documento AND 
             E1.serie = T.serie AND E1.numero = T.numero WHERE E1.sys_oid_destino IS NULL  
  set @pError = 'ERROR AL CALCULAR EL TOTAL DEL ALBARAN' + CHAR(13) + CHAR(10)  
  
  EXEC vs_calcular_total_venta @pEmpresa,@pEjercicio,@pCodigo_tipo_documento,@pSerie,@pNumeroDestino     
      
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
/*
exec vs_crea_albaranes '11/10/2011 13:28:39',143,'DANI'
*/  
END  

go



