use vsolution
GO
alter table gen_empresas add codigo_forma_pago_efectivo dm_codigos_c null
go
alter table gen_empresas add codigo_forma_pago_tarjeta dm_codigos_c null
go
update gen_empresas set codigo_forma_pago_efectivo='00',codigo_forma_pago_tarjeta='TV'
GO

ALTER PROCEDURE [dbo].[vs_eje_venta_t]
	@empresa [dbo].[dm_empresas],
	@ejercicio [dbo].[dm_ejercicios],
	@codigo_tipo_documento [dbo].[dm_codigos_c],
	@serie [dbo].[dm_codigos_c],
	@numero dm_numero_doc
 AS
BEGIN

	SET NOCOUNT ON;
	declare @numero_abono dm_numero_doc
	declare @serie_abono dm_codigos_c
	DECLARE @base_imponible dm_importes	
	DECLARE @neto_lineas dm_importes
	DECLARE @iva dm_porcentajes
	DECLARE @cuota_iva dm_importes
	DECLARE @re dm_porcentajes
	DECLARE @cuota_re dm_importes
	DECLARE @numero_linea dm_entero
	DECLARE @dto_comercial dm_porcentajes
	DECLARE @dto_financiero dm_porcentajes
	declare @cuota_dto_comercial dm_importes
	declare @cuota_dto_financiero dm_importes
	declare @total dm_importes
	declare @cargo_financiero dm_importes
	declare @lcUpdate varchar(1000)
	declare @entrega_a_cuenta dm_importes
	declare @importe_compensado dm_importes
	declare @importe_ya_compensado dm_importes	
	declare @abonos_compensados dm_char_corto
	declare @importe_abonado dm_importes
	declare @fecha_entrega dm_fechas_hora
	declare @fecha_vto dm_fechas_hora
	DECLARE @importe dm_importes
	declare @aplicar_cargo_financiero dm_logico
	DECLARE @perror varchar(4000)
	DECLARE @compensar_abono dm_logico
	declare @codigo_cliente dm_codigos_n
	declare @pte_compensar dm_importes
	declare @total_factura dm_importes
	declare @sys_oid_abono dm_oid
	declare @empresa_contabilizar dm_empresas
	declare @empresa_abono dm_empresas
	declare @ejercicio_abono dm_ejercicios 
	declare @codigo_tipo_documento_abono dm_codigos_c
	declare @serie_abono_compensacion dm_codigos_c
	declare @numero_abono_compensacion dm_numero_doc
	DECLARE @irpf dm_porcentajes
	DECLARE @codigo_forma_pago_efectivo dm_codigos_c
	DECLARE @codigo_forma_pago_tarjeta dm_codigos_c
	
	SET @numero_linea = 1

BEGIN TRY
 BEGIN TRANSACTION
	DELETE eje_venta_t 
	 WHERE empresa = @empresa 
	   AND ejercicio = @ejercicio
	   AND codigo_tipo_documento= @codigo_tipo_documento 
	   AND serie = @serie 
	   AND numero=@numero

	DECLARE cursor_vs_eje_venta_t CURSOR LOCAL FOR 
	 SELECT neto_lineas,cuota_dto_comercial,cuota_dto_financiero,base_imponible,iva,cuota_iva,re,cuota_re,total
				,eje_venta_c.cargo_financiero,aplicar_cargo_financiero,eje_venta_c.irpf
	   FROM eje_venta_i
	   INNER JOIN eje_venta_c 
	   ON dbo.eje_venta_i.empresa = dbo.eje_venta_c.empresa
	    AND dbo.eje_venta_i.ejercicio = dbo.eje_venta_c.ejercicio
	    AND dbo.eje_venta_i.codigo_tipo_documento = dbo.eje_venta_c.codigo_tipo_documento
	    AND dbo.eje_venta_i.serie = dbo.eje_venta_c.serie
	    AND dbo.eje_venta_i.numero = dbo.eje_venta_c.numero
	  WHERE eje_venta_i.empresa = @empresa  
	    AND	eje_venta_i.ejercicio = @ejercicio
	    AND	eje_venta_i.codigo_tipo_documento = @codigo_tipo_documento
	    AND	eje_venta_i.serie = @serie
	    AND	eje_venta_i.numero = @numero
	
	OPEN cursor_vs_eje_venta_t
	FETCH NEXT FROM cursor_vs_eje_venta_t INTO @neto_lineas,@cuota_dto_comercial,@cuota_dto_financiero,@base_imponible,@iva,@cuota_iva,@re,@cuota_re,@total,@cargo_financiero
						  ,@aplicar_cargo_financiero,@irpf
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		IF @numero_linea = 1 
			INSERT INTO eje_venta_t (empresa,ejercicio,codigo_tipo_documento,serie,numero,neto_lineas,cuota_dto_comercial,cuota_dto_financiero,base_imponible1,iva1,cuota_iva1,re1,cuota_re1,total,fecha_vto1,importe1) 
					VALUES (@empresa,@ejercicio,@codigo_tipo_documento,@serie,@numero,@neto_lineas,@cuota_dto_comercial,@cuota_dto_financiero,@base_imponible,@iva,@cuota_iva,@re,@cuota_re,@total,@fecha_vto,@importe)
		ELSE
		BEGIN
			SET @lcUpdate = 'UPDATE eje_venta_t SET ' +
				'neto_lineas = neto_lineas + ' + CAST(@neto_lineas AS varchar(20)) + ', ' + 
				'cuota_dto_comercial = cuota_dto_comercial + ' + CAST(@cuota_dto_comercial AS VARCHAR(20)) + ', ' +
				'cuota_dto_financiero = cuota_dto_financiero + ' + CAST(@cuota_dto_financiero AS VARCHAR(20)) + ', ' +
				'base_imponible' + cast(@numero_linea as varchar) + '=' + CAST(@base_imponible AS VARCHAR(20)) + ',' + 
				'iva' + cast(@numero_linea as varchar) + '=' + CAST(@iva AS VARCHAR(20)) + ',' + 
				'cuota_iva' + cast(@numero_linea as varchar) + '=' + CAST(@cuota_iva AS VARCHAR(20)) + ',' + 
				're'+ cast(@numero_linea as varchar) + '=' + CAST(@re AS VARCHAR(20)) + ',' + 
				'cuota_re'+ cast(@numero_linea as varchar) + '=' + CAST(@cuota_re AS VARCHAR(20)) + ',' +
				'total = total + ' + CAST(@total AS VARCHAR(20)) +
				' WHERE empresa = ''' + @empresa + ''' AND ejercicio = ''' + @ejercicio + ''' AND codigo_tipo_documento = ''' + @codigo_tipo_documento + ''' AND serie = ''' + @serie + ''' AND numero = ''' + @numero + ''''
			EXEC(@lcUPDATE)
		END
		FETCH NEXT FROM cursor_vs_eje_venta_t INTO @neto_lineas,@cuota_dto_comercial,@cuota_dto_financiero,@base_imponible,@iva,@cuota_iva,@re,@cuota_re,@total,@cargo_financiero
				,@aplicar_cargo_financiero,@irpf
		SET @numero_linea = @numero_linea + 1
	END
	
	CLOSE cursor_vs_eje_venta_t
	deallocate cursor_vs_eje_venta_t
	
	select @entrega_a_cuenta = ISNULL(SUM(isnull(entrega_a_cuenta,0)),0),@fecha_entrega=MAX(fecha_entrega) 
	 from eje_venta_entregas 
	 where empresa=@empresa 
	 and ejercicio = @ejercicio 
	 and codigo_tipo_documento=@codigo_tipo_documento 
	 and serie=@serie 
	 and numero=@numero	

	UPDATE eje_venta_t
		SET cuota_irpf=base_imponible * (ISNULL(@irpf,0)/100),entrega_a_cuenta =@entrega_a_cuenta,fecha_entrega=@fecha_Entrega,cuota_cargo_financiero=(base_imponible * ISNULL(@cargo_financiero,0)/100)
			,total = base_imponible + cuota_iva + cuota_re + (base_imponible * ISNULL(@cargo_financiero,0)/100) - (base_imponible * (ISNULL(@irpf,0)/100))
		WHERE empresa = @empresa  
			AND	ejercicio = @ejercicio
			AND	codigo_tipo_documento = @codigo_tipo_documento
			AND	serie = @serie
			AND	numero = @numero	
		
	if @codigo_tipo_documento = 'FV'
	BEGIN
		select @total_factura=isnull(total,0) from eje_venta_t where empresa=@empresa and ejercicio=@ejercicio 
			and codigo_tipo_documento=@codigo_tipo_documento and serie=@serie and numero=@numero
		if @total_factura < 0 AND (ABS(@total_factura) - ABS(@entrega_a_cuenta)) > 0.01
			update eje_venta_c set compensar_abono=C.compensar_abonos 
				from eje_venta_c as V inner join emp_clientes as C on C.empresa = V.empresa and C.codigo=V.codigo_cliente 
				where V.empresa=@empresa and V.ejercicio=@ejercicio and V.codigo_tipo_documento=@codigo_tipo_documento and V.serie=@serie and V.numero=@numero
		else
			update eje_venta_c set compensar_abono=0 
				where empresa=@empresa and ejercicio=@ejercicio and codigo_tipo_documento=@codigo_tipo_documento and serie=@serie and numero=@numero
	
		select @codigo_cliente=codigo_cliente,@compensar_abono=compensar_abono 
		  from eje_venta_c 
		 WHERE empresa = @empresa     
		   AND	ejercicio = @ejercicio    
		   AND	codigo_tipo_documento = @codigo_tipo_documento    
		   AND	serie = @serie    
		   AND	numero = @numero
		
		if @total_factura > 0 
		begin
			SELECT @empresa_contabilizar = isnull(empresa_contabilizar,empresa)
			  FROM emp_series
			 WHERE empresa = @empresa 
			 AND ejercicio = @ejercicio  
			 AND codigo_tipo_documento = @codigo_tipo_documento	
			 AND codigo = @serie 
			 
			DELETE eje_venta_compensar 
			 WHERE empresa = @empresa 
			 AND ejercicio = @ejercicio  
			 AND codigo_tipo_documento = @codigo_tipo_documento	
			 AND	serie = @serie 
			 AND	numero = @numero
		
			DECLARE cursor_abonos_pendientes cursor local for
				select eje_venta_c.sys_oid, eje_venta_c.empresa, eje_venta_c.ejercicio, eje_venta_c.codigo_tipo_documento,
					eje_venta_c.serie,eje_venta_c.numero,eje_venta_t.pendiente_compensar 
				from eje_venta_t 
					inner join eje_venta_c ON dbo.eje_venta_t.empresa = dbo.eje_venta_c.empresa
					AND dbo.eje_venta_t.ejercicio = dbo.eje_venta_c.ejercicio
					AND dbo.eje_venta_t.codigo_tipo_documento = dbo.eje_venta_c.codigo_tipo_documento
					AND dbo.eje_venta_t.serie = dbo.eje_venta_c.serie
					AND dbo.eje_venta_t.numero = dbo.eje_venta_c.numero 
					INNER JOIN emp_series ON emp_series.empresa = eje_venta_c.empresa 
					AND emp_series.ejercicio = eje_venta_c.ejercicio
					AND emp_series.codigo_tipo_documento = eje_venta_c.codigo_tipo_documento					
					AND emp_series.codigo = eje_venta_c.serie
				WHERE eje_venta_c.codigo_cliente = @codigo_cliente 
					and eje_venta_c.compensar_abono=1 
					AND eje_venta_c.empresa = @empresa  
					AND	eje_venta_c.codigo_tipo_documento = @codigo_tipo_documento					
					AND emp_series.empresa_contabilizar = @empresa_contabilizar and eje_venta_t.pendiente_compensar > 0
			
			SET @numero_linea = 1
			open cursor_abonos_pendientes
			FETCH NEXT FROM cursor_abonos_pendientes INTO @sys_oid_abono,@empresa_abono,@ejercicio_abono,@codigo_tipo_documento_abono,@serie_abono_compensacion,@numero_abono_compensacion,@pte_compensar
			WHILE (@@FETCH_STATUS = 0)
			BEGIN	 		
				if @total_factura >= @pte_compensar 
				begin
					insert into eje_venta_compensar (empresa,ejercicio,codigo_tipo_documento,serie,numero,linea,importe_compensado,sys_oid_abono) values
					(@empresa,@ejercicio,@codigo_tipo_documento,@serie,@numero,@numero_linea,@pte_compensar,@sys_oid_abono)				
				end
				ELSE
				begin
					insert into eje_venta_compensar (empresa,ejercicio,codigo_tipo_documento,serie,numero,linea,importe_compensado,sys_oid_abono) values
					(@empresa,@ejercicio,@codigo_tipo_documento,@serie,@numero,@numero_linea,@total_factura,@sys_oid_abono)				
				end
				exec vs_calcular_total_venta @empresa_abono,@ejercicio_abono,@codigo_tipo_documento_abono,@serie_abono_compensacion,@numero_abono_compensacion
				SET @numero_linea = @numero_linea + 1									
				FETCH NEXT FROM cursor_abonos_pendientes INTO @sys_oid_abono,@empresa_abono,@ejercicio_abono,@codigo_tipo_documento_abono,@serie_abono_compensacion,@numero_abono_compensacion,@pte_compensar
			END
			CLOSE cursor_abonos_pendientes
			deallocate cursor_abonos_pendientes		
		end 	
		
		select @importe_ya_compensado = isnull(SUM(importe_compensado),0) from eje_venta_compensar where sys_oid_abono = (select sys_oid from eje_venta_c where empresa=@empresa and ejercicio = @ejercicio and codigo_tipo_documento=@codigo_tipo_documento and serie=@serie and numero=@numero)
		set @importe_compensado=0
		set @abonos_compensados=''
		declare cursor_compensaciones cursor local for 
			select importe_compensado,serie_abono,numero_abono 
			from vf_compensaciones_abonos 
			where empresa=@empresa 
			and ejercicio = @ejercicio 
			and codigo_tipo_documento=@codigo_tipo_documento 
			and serie=@serie 
			and numero=@numero

		OPEN cursor_compensaciones
		FETCH NEXT FROM cursor_compensaciones INTO @importe_abonado,@serie_abono,@numero_abono
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			set @importe_compensado=@importe_compensado + @importe_abonado
			set @abonos_compensados = rtrim(@abonos_compensados) + ' ' + RTRIM(@serie_abono) + '-' + RTRIM(@numero_abono) 
			FETCH NEXT FROM cursor_compensaciones INTO @importe_abonado,@serie_abono,@numero_abono		
		END
		CLOSE cursor_compensaciones
		deallocate cursor_compensaciones
		
		
		UPDATE eje_venta_t
			SET importe_compensado=@importe_compensado,abonos_compensados=@abonos_compensados,cuota_cargo_financiero=(base_imponible * ISNULL(@cargo_financiero,0)/100)
				,total = base_imponible + cuota_iva + cuota_re + (base_imponible * ISNULL(@cargo_financiero,0)/100) - (base_imponible * (ISNULL(@irpf,0)/100)),
				pendiente_compensar=CASE
										WHEN (base_imponible + cuota_iva + cuota_re + round((base_imponible * ISNULL(@cargo_financiero,0)/100),2)- (base_imponible * (ISNULL(@irpf,0)/100)) >= 0) THEN 0
										WHEN @compensar_abono=1 and  (base_imponible + cuota_iva + cuota_re + round((base_imponible * ISNULL(@cargo_financiero,0)/100),2)- (base_imponible * (ISNULL(@irpf,0)/100)) < 0)
											THEN ((base_imponible + cuota_iva + cuota_re + (base_imponible * ISNULL(@cargo_financiero,0)/100)) - (base_imponible * (ISNULL(@irpf,0)/100)) + @importe_ya_compensado) * -1
											ELSE 0
										END															
			WHERE empresa = @empresa  
				AND	ejercicio = @ejercicio
				AND	codigo_tipo_documento = @codigo_tipo_documento
				AND	serie = @serie
				AND	numero = @numero
										
	END

	select @codigo_forma_pago_efectivo=codigo_forma_pago_efectivo,@codigo_forma_pago_tarjeta=codigo_forma_pago_tarjeta
	from gen_empresas where codigo=@empresa
	
	update eje_venta_c set codigo_forma_pago=case when B.es_visa=1 then @codigo_forma_pago_tarjeta else @codigo_forma_pago_efectivo END
	from eje_venta_c as C inner join eje_venta_t as T on c.empresa=t.empresa and c.ejercicio=t.ejercicio and
		c.codigo_tipo_documento=t.codigo_tipo_documento and c.serie=t.serie and c.numero=t.numero
		inner join eje_mov_caja as M on C.empresa=M.empresa and C.ejercicio = M.ejercicio and C.codigo_tipo_documento=M.codigo_tipo_documento and C.serie=M.serie and C.numero=M.numero 
		inner join emp_bancos as B on M.empresa = B.empresa and M.codigo_banco = B.codigo
	where c.empresa = @empresa  
			AND	c.ejercicio = @ejercicio AND c.codigo_tipo_documento = @codigo_tipo_documento AND c.serie = @serie
			AND	c.numero = @numero and isnull(t.total,0)-ISNULL(t.entrega_a_cuenta,0)=0 and ISNULL(t.entrega_a_cuenta,0)<>0 and B.tiene_tpv = 1
	
	COMMIT TRANSACTION
	END TRY
	
	BEGIN CATCH
		set @pError = 'ERROR AL CALCULAR TOTALES DE VENTA(' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + ERROR_MESSAGE()
	 	ROLLBACK
		RAISERROR(@pError,16,1)
	END CATCH

END

go
