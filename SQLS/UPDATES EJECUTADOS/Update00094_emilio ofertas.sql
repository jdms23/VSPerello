USE vsolution
GO
/****** Object:  StoredProcedure [dbo].[vs_calcular_total_venta]    Script Date: 02/22/2012 09:52:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[vs_comprobar_ofertas_venta]
	@pempresa dm_empresas,
	@pejercicio dm_ejercicios,
	@pcodigo_tipo_documento dm_codigos_c,
	@pserie dm_codigos_c,
	@pnumero dm_numero_doc
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @codigo_cliente dm_codigos_n
	DECLARE @fecha dm_fechas_hora
	DECLARE @numero_oferta dm_codigos_c
	DECLARE @tipo_oferta dm_entero_corto
	DECLARE @unidades_lote dm_unidades
	DECLARE @unidades_lineas dm_unidades
	/* BUSCAMOS OFERTAS CANDIDATAS PARA EL DOCUMENTO ACTUAL */
	select @codigo_cliente = codigo_cliente,@fecha=fecha from eje_venta_c 
		WHERE empresa = @pempresa AND ejercicio = @pejercicio AND codigo_tipo_documento = @pcodigo_tipo_documento AND @pserie = @pserie AND numero = @pnumero

	DECLARE ofertas_recorrer CURSOR FOR
	select emp_ofertas_c.numero,emp_ofertas_c.tipo,emp_ofertas_c.unidades_lote from emp_ofertas_c inner join emp_ofertas_l on emp_ofertas_c.empresa=emp_ofertas_l.empresa and emp_ofertas_c.numero=emp_ofertas_l.numero
		where emp_ofertas_c.empresa=@pempresa and desde_fecha <= @fecha and isnull(hasta_fecha,cast('31/12/2099' as date))>=@fecha and activa = 1 and tipo > 1
			and emp_ofertas_l.codigo_articulo IN (select eje_venta_l.codigo_Articulo from eje_venta_l where empresa = @pempresa AND ejercicio = @pejercicio AND codigo_tipo_documento = @pcodigo_tipo_documento AND @pserie = @pserie AND numero = @pnumero)
	OPEN ofertas_recorrer
	FETCH NEXT FROM ofertas_recorrer INTO @numero_oferta,@tipo_oferta,@unidades_lote					
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		SELECT @UNIDADES_LINEAS=SUM(unidades) from eje_venta_l where eje_venta_l.codigo_Articulo IN (select codigo_Articulo from emp_ofertas_l where empresa=@pempresa and numero=@numero_oferta)			
		select @unidades_lineas
		if @unidades_lineas >= @unidades_lote
			select codigo_articulo,sys_oid from eje_venta_l where eje_venta_l.codigo_Articulo IN (select codigo_Articulo from emp_ofertas_l where empresa=@pempresa and numero=@numero_oferta)			
		FETCH NEXT FROM ofertas_recorrer INTO @numero_oferta,@tipo_oferta,@unidades_lote							
	END
	CLOSE ofertas_recorrer
	DEALLOCATE ofertas_recorrer
END
