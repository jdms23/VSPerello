USE vs_alcaraz
GO
/****** Object:  StoredProcedure [dbo].[vs_comprobar_ofertas_venta]    Script Date: 02/28/2012 12:52:33 ******/
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
	declare @identificador_dir_envio dm_entero_corto
	DECLARE @fecha dm_fechas_hora
	declare @sys_oid_oferta dm_oid
	DECLARE @numero_oferta dm_codigos_c
	DECLARE @tipo_oferta dm_entero_corto
	DECLARE @unidades_lote dm_unidades
	DECLARE @unidades_lineas dm_unidades
	DECLARE @sin_exclusiones dm_logico
	DECLARE @excluir_ofertas dm_logico
	DECLARE @cliente_excluido dm_entero_corto
	

	/* primero quitamos las posibles ofertas */
	UPDATE eje_venta_l set sys_oid_oferta = null from eje_venta_l inner join emp_ofertas_c ON eje_venta_l.sys_oid_oferta = emp_ofertas_c.sys_oid
			where eje_venta_l.sys_oid_origen is null and emp_ofertas_c.tipo >= 1 and eje_venta_l.empresa = @pempresa AND ejercicio = @pejercicio AND codigo_tipo_documento = @pcodigo_tipo_documento AND serie = @pserie AND eje_venta_l.numero = @pnumero
		
	/* BUSCAMOS OFERTAS CANDIDATAS PARA EL DOCUMENTO ACTUAL */
	select @codigo_cliente = codigo_cliente,@identificador_dir_envio=identificador_dir_envio,@fecha=fecha from eje_venta_c 
		WHERE empresa = @pempresa AND ejercicio = @pejercicio AND codigo_tipo_documento = @pcodigo_tipo_documento AND serie = @pserie AND numero = @pnumero
	IF @codigo_cliente=2
		select @excluir_ofertas=excluir_ofertas from emp_clientes_direcciones where empresa=@pempresa and codigo_cliente=@codigo_cliente and identificador=@identificador_dir_envio
	else
		select @excluir_ofertas=excluir_ofertas from emp_clientes where empresa=@pempresa and codigo=@codigo_cliente
	

	DECLARE ofertas_recorrer CURSOR FOR
	select emp_ofertas_c.sys_oid,emp_ofertas_c.numero,emp_ofertas_c.tipo,emp_ofertas_c.unidades_lote,emp_ofertas_c.sin_exclusiones from emp_ofertas_c inner join emp_ofertas_l on emp_ofertas_c.empresa=emp_ofertas_l.empresa and emp_ofertas_c.numero=emp_ofertas_l.numero
		where emp_ofertas_c.empresa=@pempresa and desde_fecha <= @fecha and isnull(hasta_fecha,cast('31/12/2099' as date))>=@fecha and activa = 1 and tipo >= 1
			and emp_ofertas_l.codigo_articulo IN (select eje_venta_l.codigo_Articulo from eje_venta_l where empresa = @pempresa AND ejercicio = @pejercicio AND codigo_tipo_documento = @pcodigo_tipo_documento AND serie = @pserie AND numero = @pnumero)
	OPEN ofertas_recorrer
	FETCH NEXT FROM ofertas_recorrer INTO @sys_oid_oferta,@numero_oferta,@tipo_oferta,@unidades_lote,@sin_exclusiones	
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		select @cliente_excluido = COUNT(sys_oid) from emp_ofertas_clientes_excluidos where empresa=@pempresa and numero=@numero_oferta and codigo_cliente=@codigo_cliente
		if (ISNULL(@cliente_excluido,0)=0 and isnull(@excluir_ofertas,0)=0)or @sin_exclusiones=1 
		begin
			if @tipo_oferta = 1
			begin
				update eje_venta_l set precio=emp_ofertas_l.precio,dto1=emp_ofertas_l.dto,sys_oid_oferta=@sys_oid_oferta 
					from eje_venta_l inner join emp_ofertas_l on eje_venta_l.empresa = emp_ofertas_l.empresa and emp_ofertas_l.numero=@numero_oferta and eje_venta_l.codigo_Articulo=emp_ofertas_l.codigo_articulo
					where eje_venta_l.empresa = @pempresa AND eje_venta_l.ejercicio = @pejercicio AND eje_venta_l.codigo_tipo_documento = @pcodigo_tipo_documento AND eje_venta_l.serie = @pserie AND eje_venta_l.numero = @pnumero 
						and eje_venta_l.unidades >= isnull(emp_ofertas_l.desde_unidades,1) and eje_venta_l.unidades<=isnull(emp_ofertas_l.hasta_unidades,999999) and eje_venta_l.codigo_Articulo IN (select codigo_Articulo from emp_ofertas_l where empresa=@pempresa and numero=@numero_oferta)						
			end
		
		 
			if @tipo_oferta=2
			begin
				SELECT @UNIDADES_LINEAS=SUM(unidades) from eje_venta_l 
					where empresa = @pempresa AND ejercicio = @pejercicio AND codigo_tipo_documento = @pcodigo_tipo_documento AND serie = @pserie AND numero = @pnumero and
						eje_venta_l.codigo_Articulo IN (select codigo_Articulo from emp_ofertas_l where empresa=@pempresa and numero=@numero_oferta)			
					update eje_venta_l set precio=emp_articulos.pvp,dto1=emp_ofertas_dtos.dto,sys_oid_oferta=@sys_oid_oferta 
						from eje_venta_l inner join emp_ofertas_l on eje_venta_l.empresa = emp_ofertas_l.empresa and emp_ofertas_l.numero=@numero_oferta and eje_venta_l.codigo_Articulo=emp_ofertas_l.codigo_articulo
						inner join emp_ofertas_dtos on emp_ofertas_dtos.empresa=eje_venta_l.empresa and emp_ofertas_dtos.numero=@numero_oferta and emp_ofertas_dtos.desde_unidades<=@unidades_lineas and emp_ofertas_dtos.hasta_unidades>=@unidades_lineas
						inner join emp_articulos on emp_articulos.empresa=eje_venta_l.empresa and emp_articulos.codigo=eje_venta_l.codigo_articulo
						where eje_venta_l.dto1 < emp_ofertas_dtos.dto and eje_venta_l.empresa = @pempresa AND eje_venta_l.ejercicio = @pejercicio AND eje_venta_l.codigo_tipo_documento = @pcodigo_tipo_documento AND eje_venta_l.serie = @pserie AND eje_venta_l.numero = @pnumero 
							and eje_venta_l.codigo_Articulo IN (select codigo_Articulo from emp_ofertas_l where empresa=@pempresa and numero=@numero_oferta)			
			end
		
			if @tipo_oferta=3
			begin
				SELECT @UNIDADES_LINEAS=SUM(unidades) from eje_venta_l 
					where empresa = @pempresa AND ejercicio = @pejercicio AND codigo_tipo_documento = @pcodigo_tipo_documento AND serie = @pserie AND numero = @pnumero and
						eje_venta_l.codigo_Articulo IN (select codigo_Articulo from emp_ofertas_l where empresa=@pempresa and numero=@numero_oferta)			
				if @unidades_lineas >= @unidades_lote
					update eje_venta_l set precio=emp_ofertas_l.precio,dto1=emp_ofertas_l.dto,sys_oid_oferta=@sys_oid_oferta 
						from eje_venta_l inner join emp_ofertas_l on eje_venta_l.empresa = emp_ofertas_l.empresa and emp_ofertas_l.numero=@numero_oferta and eje_venta_l.codigo_Articulo=emp_ofertas_l.codigo_articulo
						where eje_venta_l.empresa = @pempresa AND eje_venta_l.ejercicio = @pejercicio AND eje_venta_l.codigo_tipo_documento = @pcodigo_tipo_documento AND eje_venta_l.serie = @pserie AND eje_venta_l.numero = @pnumero 
							and eje_venta_l.codigo_Articulo IN (select codigo_Articulo from emp_ofertas_l where empresa=@pempresa and numero=@numero_oferta)			
			end
			if @tipo_oferta = 4
			begin
				update eje_venta_l set precio=emp_ofertas_l.precio,dto1=emp_ofertas_l.dto,sys_oid_oferta=@sys_oid_oferta 
					from eje_venta_l inner join emp_ofertas_l on eje_venta_l.empresa = emp_ofertas_l.empresa and emp_ofertas_l.numero=@numero_oferta and eje_venta_l.codigo_Articulo=emp_ofertas_l.codigo_articulo
					where eje_venta_l.empresa = @pempresa AND eje_venta_l.ejercicio = @pejercicio AND eje_venta_l.codigo_tipo_documento = @pcodigo_tipo_documento AND eje_venta_l.serie = @pserie AND eje_venta_l.numero = @pnumero 
						and eje_venta_l.unidades%emp_ofertas_l.unidades_multiplo=0 and eje_venta_l.codigo_Articulo IN (select codigo_Articulo from emp_ofertas_l where empresa=@pempresa and numero=@numero_oferta)						
			end
		end
		FETCH NEXT FROM ofertas_recorrer INTO @sys_oid_oferta,@numero_oferta,@tipo_oferta,@unidades_lote,@sin_exclusiones							
	END
	CLOSE ofertas_recorrer
	DEALLOCATE ofertas_recorrer
END
