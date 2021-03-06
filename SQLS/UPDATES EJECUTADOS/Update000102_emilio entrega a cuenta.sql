USE vs_martinez
GO
/****** Object:  StoredProcedure [dbo].[vs_calcular_total_venta]    Script Date: 02/29/2012 11:41:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 ALTER PROCEDURE [dbo].[vs_calcular_total_venta]
	@pempresa dm_empresas,
	@pejercicio dm_ejercicios,
	@pcodigo_tipo_documento dm_codigos_c,
	@pserie dm_codigos_c,
	@pnumero dm_numero_doc
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @codigo_tipo_iva dm_char_corto
	DECLARE @dto_comercial dm_porcentajes
	DECLARE @dto_financiero dm_porcentajes
	DECLARE @cuota_dto_comercial dm_importes
	DECLARE @cuota_dto_financiero dm_importes
	DECLARE @base_imponible dm_importes
	DECLARE @iva dm_porcentajes
	DECLARE @re dm_porcentajes
	DECLARE @cuota_iva dm_importes
	DECLARE @cuota_re dm_importes
	DECLARE @total_linea dm_importes
	DECLARE @importe_portes dm_importes
	DECLARE @aplicar_en_totales_portes dm_logico
	DECLARE @codigo_tipo_iva_portes dm_char_corto
	IF EXISTS(SELECT * FROM eje_venta_i WHERE @pempresa = empresa AND @pejercicio = ejercicio AND 
			@pcodigo_tipo_documento = codigo_tipo_documento AND @pserie = serie AND @pnumero = numero )
		DELETE eje_venta_i WHERE @pempresa = empresa AND @pejercicio = ejercicio AND 
			@pcodigo_tipo_documento = codigo_tipo_documento AND @pserie = serie AND @pnumero = numero
	DECLARE calcula CURSOR FOR
			SELECT l.codigo_tipo_iva, SUM(l.total_linea * ISNULL(c.dto_comercial,0)/100) AS cuota_dto_comercial, 
					  SUM(l.total_linea*ISNULL(c.dto_financiero,0)/100) AS cuota_dto_financiero, SUM(l.total_linea*ISNULL(l.iva, 0)/100) AS cuota_iva, 
					  SUM(l.total_linea*ISNULL(l.re,0)/100) AS cuota_re,SUM(l.total_linea) AS total_linea,ISNULL(iva,0),ISNULL(re,0)
					  ,ISNULL(c.importe_portes,0) AS importe_portes,c.aplicar_en_totales_portes,c.codigo_tipo_iva_portes
			FROM eje_venta_l AS l
			 INNER JOIN
					  eje_venta_c AS c ON l.empresa = c.empresa AND l.ejercicio = c.ejercicio AND l.codigo_tipo_documento = c.codigo_tipo_documento AND 
					  l.SERIE = c.serie AND l.numero = c.numero
			WHERE @pempresa=c.empresa AND @pejercicio=c.ejercicio AND @pcodigo_tipo_documento=c.codigo_tipo_documento AND @pserie=c.serie AND @pnumero = c.numero					  
			GROUP BY  l.codigo_tipo_iva,iva,re,c.aplicar_en_totales_portes,c.codigo_tipo_iva_portes, c.importe_portes
			
	OPEN calcula
	FETCH NEXT FROM calcula INTO @codigo_tipo_iva,@cuota_dto_comercial,@cuota_dto_financiero,@cuota_iva,@cuota_re
						,@total_linea,@iva,@re,@importe_portes,@aplicar_en_totales_portes,@codigo_tipo_iva_portes
							
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		--SET @cuota_dto_comercial = @total_linea * @dto_comercial / 100
		--SET @cuota_dto_financiero = @total_linea * @dto_financiero / 100
		SET @base_imponible = @total_linea - @cuota_dto_comercial - @cuota_dto_financiero
		SET @cuota_iva = @base_imponible * @iva / 100
		SET @cuota_re = @base_imponible * @re / 100

		IF @aplicar_en_totales_portes = 1 AND @codigo_tipo_iva_portes=@codigo_tipo_iva
		BEGIN		
			SET @base_imponible = @base_imponible + @importe_portes
			SET @cuota_iva = @base_imponible * ISNULL(@iva, 0)/100
			SET @cuota_re = @base_imponible * ISNULL(@re, 0)/100			
		END
		
		INSERT INTO eje_venta_i ( empresa,ejercicio,codigo_tipo_documento,serie,numero,codigo_tipo_iva,neto_lineas,
			cuota_dto_comercial,cuota_dto_financiero,base_imponible,iva,cuota_iva,re,cuota_re,total )
			VALUES (@pempresa,@pejercicio,@pcodigo_tipo_documento,@pserie,@pnumero,@codigo_tipo_iva,@total_linea,
			@cuota_dto_comercial,@cuota_dto_financiero,@base_imponible,@iva,@cuota_iva,@re,@cuota_re,@base_imponible + @cuota_iva + @cuota_re )

			IF EXISTS(
				SELECT DISTINCT vc.codigo_tipo_iva_portes, vc.aplicar_en_totales_portes, vc.numero, vi.codigo_tipo_iva, 
				vc.ejercicio FROM dbo.eje_venta_c AS vc
				LEFT OUTER JOIN
				eje_venta_i AS vi ON vc.empresa = vi.empresa AND vc.ejercicio = vi.ejercicio AND 
				vc.codigo_tipo_documento = vi.codigo_tipo_documento AND vc.serie = vi.serie AND 
				vc.numero = vi.numero AND vc.codigo_tipo_iva_portes = vi.codigo_tipo_iva
				WHERE (vc.aplicar_en_totales_portes = 1) AND (vi.codigo_tipo_iva IS NULL) AND 
				 @pempresa=vc.empresa AND @pejercicio=vc.ejercicio AND @pcodigo_tipo_documento=vc.codigo_tipo_documento AND
				  @pserie=vc.serie AND @pnumero = vc.numero			
			)
			
		INSERT INTO eje_venta_i (empresa,ejercicio,codigo_tipo_documento,serie,numero,codigo_tipo_iva,neto_lineas,iva,re
						,cuota_iva,cuota_re,base_imponible,total)
						SELECT DISTINCT vc.empresa, vc.ejercicio, vc.codigo_tipo_documento, vc.serie, vc.numero, 
									  vc.codigo_tipo_iva_portes, vc.importe_portes,ISNULL(IP.porcentaje_iva,0),ISNULL(IP.porcentaje_re,0)
									  ,vc.importe_portes * ISNULL(ip.porcentaje_iva, 0)/100,vc.importe_portes * ISNULL(ip.porcentaje_re, 0)/100
									  ,vc.importe_portes,total=vc.importe_portes+vc.importe_portes * ISNULL(ip.porcentaje_re, 0)/100+vc.importe_portes * ISNULL(ip.porcentaje_iva, 0)/100
						FROM  eje_venta_c AS vc INNER JOIN
								eje_iva_porcentajes AS IP ON vc.codigo_tipo_iva_portes = IP.codigo_tipo AND 
								vc.codigo_tabla_iva = IP.codigo_tabla AND vc.empresa = IP.empresa AND 
								vc.ejercicio = IP.ejercicio
						WHERE (vc.aplicar_en_totales_portes = 1) AND @pempresa=vc.empresa AND @pejercicio=vc.ejercicio
							 AND @pcodigo_tipo_documento=vc.codigo_tipo_documento AND @pserie=vc.serie AND @pnumero = vc.numero
		
		FETCH NEXT FROM calcula INTO @codigo_tipo_iva,@cuota_dto_comercial,@cuota_dto_financiero,@cuota_iva,@cuota_re
						,@total_linea,@iva,@re,@importe_portes,@aplicar_en_totales_portes,@codigo_tipo_iva_portes
	END
	
	EXEC vs_eje_venta_t @pEmpresa, @pEjercicio, @pCodigo_tipo_documento, @pSerie, @pNumero	
---	EXEC vs_calcular_vencimientos @pEmpresa, @pEjercicio, @pCodigo_tipo_documento, @pSerie, @pNumero	 			
END

go

create TRIGGER [dbo].[eje_mov_caja_ai]
   ON  [dbo].[eje_mov_caja]
   AFTER INSERT
AS 
BEGIN
	declare @codigo_tipo_mov dm_codigos_n
	DECLARE @empresa dm_empresas
	DECLARE @ejercicio dm_ejercicios
	DECLARE @codigo_tipo_documento dm_codigos_c
	DECLARE @serie dm_codigos_c
	DECLARE @numero dm_numero_doc
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	DECLARE insertados CURSOR LOCAL FOR
		SELECT codigo_tipo_mov,empresa, ejercicio, codigo_tipo_documento, serie, numero FROM inserted 
			
	
	OPEN insertados
	FETCH NEXT FROM insertados INTO @codigo_tipo_mov,@empresa, @ejercicio, @codigo_tipo_documento, @serie, @numero
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		if @codigo_tipo_mov >=1 and @codigo_tipo_mov <= 6
			exec vs_calcular_total_venta @empresa, @ejercicio, @codigo_tipo_documento, @serie, @numero
		
		FETCH NEXT FROM insertados INTO @codigo_tipo_mov,@empresa, @ejercicio, @codigo_tipo_documento, @serie, @numero
	END 
	
	CLOSE insertados
	DEALLOCATE insertados
	
END

go

CREATE TRIGGER [dbo].[eje_venta_entregas_ai]
   ON  [dbo].[eje_venta_entregas]
   AFTER INSERT
AS 
BEGIN
	DECLARE @empresa dm_empresas
	DECLARE @ejercicio dm_ejercicios
	DECLARE @codigo_tipo_documento dm_codigos_c
	DECLARE @serie dm_codigos_c
	DECLARE @numero dm_numero_doc
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	DECLARE insertados CURSOR LOCAL FOR
		SELECT empresa, ejercicio, codigo_tipo_documento, serie, numero FROM inserted 
			
	
	OPEN insertados
	FETCH NEXT FROM insertados INTO @empresa, @ejercicio, @codigo_tipo_documento, @serie, @numero
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		exec vs_calcular_total_venta @empresa, @ejercicio, @codigo_tipo_documento, @serie, @numero
		
		FETCH NEXT FROM insertados INTO @empresa, @ejercicio, @codigo_tipo_documento, @serie, @numero
	END 
	
	CLOSE insertados
	DEALLOCATE insertados
	
END
