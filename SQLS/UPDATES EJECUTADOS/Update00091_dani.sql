use vsolution
go 

/*
ALTER TABLE dbo.emp_orden_pago_l
	DROP COLUMN importe, fecha_vto, observaciones, adjuntos
GO

ALTER TABLE [dbo].[emp_orden_pago_l]  WITH NOCHECK ADD  CONSTRAINT [FK_emp_orden_pago_l_emp_efectos] FOREIGN KEY([empresa], [numero_efecto])
REFERENCES [dbo].[emp_efectos] ([empresa], [numero])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[emp_orden_pago_l] CHECK CONSTRAINT [FK_emp_orden_pago_l_emp_efectos]
GO

CREATE UNIQUE NONCLUSTERED INDEX [UK_emp_orden_pago_l] ON [dbo].[emp_orden_pago_l] 
(
	[sys_oid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

CREATE UNIQUE NONCLUSTERED INDEX [UK_emp_orden_pago_l_efectos] ON [dbo].[emp_orden_pago_l] 
(
	[empresa] ASC,
	[numero_efecto] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_emp_orden_pago_l_emp_orden_pago_c]') AND parent_object_id = OBJECT_ID(N'[dbo].[emp_orden_pago_l]'))
ALTER TABLE [dbo].[emp_orden_pago_l] DROP CONSTRAINT [FK_emp_orden_pago_l_emp_orden_pago_c]
GO

ALTER TABLE [dbo].[emp_orden_pago_l]  WITH NOCHECK ADD  CONSTRAINT [FK_emp_orden_pago_l_emp_orden_pago_c] FOREIGN KEY([empresa], [numero])
REFERENCES [dbo].[emp_orden_pago_c] ([empresa], [numero])
ON UPDATE CASCADE
ON DELETE CASCADE
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[emp_orden_pago_l] CHECK CONSTRAINT [FK_emp_orden_pago_l_emp_orden_pago_c]
GO

CREATE VIEW [dbo].[vf_emp_orden_pago_l]
with encryption AS
SELECT     dbo.emp_orden_pago_l.empresa, dbo.emp_orden_pago_l.numero, dbo.emp_orden_pago_l.numero_efecto, dbo.emp_efectos.fecha_vto, dbo.emp_efectos.su_factura, 
                      dbo.emp_efectos.fecha_factura, dbo.emp_efectos.importe_pendiente as importe, dbo.emp_efectos.situacion, dbo.emp_orden_pago_l.sys_oid
FROM         dbo.emp_orden_pago_l INNER JOIN
                      dbo.emp_efectos ON dbo.emp_orden_pago_l.empresa = dbo.emp_efectos.empresa AND dbo.emp_orden_pago_l.numero_efecto = dbo.emp_efectos.numero
WHERE     (dbo.emp_efectos.tipo = 'C')

GO

CREATE TRIGGER vf_emp_orden_pago_l_bi
   ON  dbo.vf_emp_orden_pago_l
WITH ENCRYPTION    INSTEAD OF INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for trigger here
	INSERT INTO emp_orden_pago_l (empresa,numero,numero_efecto)
		SELECT empresa,numero,numero_efecto
		  FROM inserted
	
END
GO

CREATE TRIGGER vf_emp_orden_pago_l_bu
   ON  vf_emp_orden_pago_l
with encryption   INSTEAD OF UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for trigger here
	UPDATE emp_orden_pago_l SET empresa = inserted.empresa,
		numero = inserted.numero,
		numero_efecto = inserted.numero_efecto
	 FROM emp_orden_pago_l 
		INNER JOIN inserted ON emp_orden_pago_l.sys_oid = inserted.sys_oid
		
END
GO

CREATE TRIGGER vf_emp_orden_pago_l_bd
   ON  vf_emp_orden_pago_l
with encryption    INSTEAD OF DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	DELETE emp_orden_pago_l 
	  FROM emp_orden_pago_l
		INNER JOIN deleted ON emp_orden_pago_l.sys_oid = deleted.sys_oid
END
GO

ALTER TABLE EMP_EFECTOS ADD numero_orden_pago dm_numero_doc

ALTER VIEW [dbo].[vf_emp_recibos_compras]  with encryption AS 
SELECT     empresa, numero, tipo, ejercicio, codigo_tipo_documento, serie, fecha_factura, numero_factura, situacion, subcuenta, importe, codigo_tercero, importe_pendiente, 
                      adjuntos, observaciones, clave_entidad, clave_sucursal, digito_control, cuenta_corriente, sys_logs, sys_borrado, sys_timestamp, numero_vto, sys_oid, 
                      numero_remesa, fecha_vto, codigo_banco, fecha_libramiento, documento_pago, importe_pagado, fecha_pago, codigo_tipo_efecto, su_factura, empresa_origen, 
                      provisional, codigo_proveedor, numero_orden_pago
FROM         dbo.emp_efectos
WHERE     (tipo = 'C')


CREATE TRIGGER emp_orden_pago_l_ai
   ON emp_orden_pago_l with encryption
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	UPDATE emp_efectos SET
		numero_orden_pago = l.numero
	  FROM emp_efectos AS E
		INNER JOIN emp_orden_pago_l AS L ON l.empresa = e.empresa 
			AND l.numero_efecto = e.numero
		INNER JOIN inserted AS I ON i.sys_oid = l.sys_oid
	
END
GO

CREATE TRIGGER emp_orden_pago_l_au
   ON emp_orden_pago_l with encryption 
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
    
	UPDATE emp_efectos SET
		numero_orden_pago = NULL
	  FROM emp_efectos AS E
		INNER JOIN emp_orden_pago_l AS L ON l.empresa = e.empresa 
			AND l.numero_efecto = e.numero
		INNER JOIN deleted AS d ON d.sys_oid = l.sys_oid
    
	UPDATE emp_efectos SET
		numero_orden_pago = l.numero
	  FROM emp_efectos AS E
		INNER JOIN emp_orden_pago_l AS L ON l.empresa = e.empresa 
			AND l.numero_efecto = e.numero
		INNER JOIN inserted AS I ON i.sys_oid = l.sys_oid
	
END
GO


CREATE TRIGGER emp_orden_pago_l_ad
   ON emp_orden_pago_l with encryption
   AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for trigger here
    
	UPDATE emp_efectos SET
		numero_orden_pago = NULL
	  FROM emp_efectos AS E
		INNER JOIN deleted AS d ON d.empresa= E.empresa
			and D.numero_efecto = E.numero
    	
END
GO


ALTER PROCEDURE [dbo].[vs_generar_asiento_orden_pago]
@pSys_oid_orden dm_oid
WITH ENCRYPTION
AS
BEGIN
begin try	
BEGIN TRANSACTION 

	declare @empresa dm_empresas
	declare @ejercicio dm_ejercicios
	declare @fecha dm_fechas_hora
	declare @fecha_bloqueo_ejercicio dm_fechas_hora
	declare @codigo_tipo_apunte dm_codigos_c
	declare @codigo_concepto dm_codigos_c
	declare @patron dm_char_largo
	declare @sesion dm_entero
	declare @sys_timestamp dm_fechas_hora
	declare @numero_efecto dm_numero_doc
	declare @numero_factura dm_numero_doc
	declare @numero_recibo dm_numero_doc
	declare @numero_orden dm_numero_doc
	declare @nombre_proveedor dm_nombres
	declare @razon_social_proveedor dm_nombres
	DECLARE @perror varchar(4000)
	declare @subcuenta_banco dm_subcuenta
	declare @documento_pago dm_char_corto
	declare @empresa_matriz dm_empresas 
	declare @fecha_vencimiento dm_fechas_hora
	declare @fecha_emision dm_fechas_hora
	declare @codigo_banco dm_codigos_c
	declare @importe_pendiente dm_importes
	declare @apunte dm_entero
	declare @subcuenta dm_subcuenta
	declare @subcuenta_efectos dm_subcuenta
	declare @sys_oid_efecto dm_oid
	declare @su_factura dm_char_corto
	declare @codigo_proveedor dm_codigos_n
	DECLARE @importe_total dm_importes
	
	select @empresa_matriz=codigo FROM gen_empresas WHERE matriz = 1
		
	select @Empresa=OP.empresa,@numero_orden=OP.numero,@fecha_vencimiento=OP.fecha_vto, @fecha_emision=OP.fecha_emision,
		@documento_pago=OP.documento_pago,@codigo_proveedor=op.codigo_proveedor,@nombre_proveedor=pr.nombre,
		@razon_social_proveedor=pr.razon_social,@codigo_banco=op.codigo_banco,@importe_total=op.importe,
		@codigo_concepto=op.codigo_concepto
	  from emp_orden_pago_c as OP
		left outer join vf_emp_proveedores as PR ON pr.empresa = @empresa_matriz 
			AND pr.codigo = op.codigo_proveedor
	   WHERE OP.sys_oid = @pSys_oid_orden
	 
	select @ejercicio = ejercicio,@fecha_bloqueo_ejercicio=fecha_bloqueo 
	  from emp_ejercicios 
	  where empresa=@empresa and fecha_apertura <= @fecha_emision and fecha_cierre>=@fecha_emision
	  
	  select @subcuenta_efectos=CTAS.subcuenta_efectos 
	    FROM eje_proveedores_cond_compra_cuentas AS CTAS
			INNER JOIN emp_proveedores_cond_compra AS CC ON CC.empresa = CTAS.empresa 
				AND CC.codigo_proveedor = CTAS.codigo_proveedor
				AND CC.predeterminada = 1
	   WHERE CTAS.empresa = @empresa_matriz 
	     AND CTAS.ejercicio = @ejercicio
	     AND CTAS.codigo_proveedor = @codigo_proveedor
	
		if ISNULL(@subcuenta_efectos,'') = '' 
			raiserror('No encuentro la subcuenta de efectos para este proveedor',16,1)
			
	  select @subcuenta_banco=subcuenta
	    FROM eje_bancos_subcuenta
	   WHERE empresa = @empresa_matriz
	     AND ejercicio = @ejercicio
	     AND codigo_banco = @codigo_banco
	     
		if ISNULL(@subcuenta_banco, '') = ''
			raiserror('No encuentro la subcuenta del banco indicado', 16,1)
				     
		set @Sesion = @@SPID
		set @sys_timestamp = getdate()

		DELETE tmp_apuntes_traspaso 
		where empresa=@empresa
		and sys_oid_origen = @psys_oid_orden 
		and codigo_tipo_documento_origen = 'OP'
		
		/*Asiento EMISION pagare*/
		select @codigo_tipo_apunte=codigo_tipo_apunte,@patron=ap.patron
		  from emp_apuntes_patron as ap 
			left join emp_asientos_patron as asto ON ap.empresa = asto.empresa and ap.codigo=asto.codigo 
		  where ap.empresa=@empresa_matriz 
		    and codigo_tipo_documento='OP' --Orden Pago Emision
		    and codigo_tipo_apunte='OP_EF_EMI'
					
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',ISNULL(RTRIM(@nombre_proveedor),''))
		SET @patron = REPLACE(@patron,'[razon_social_proveedor]',ISNULL(RTRIM(@razon_social_proveedor),''))
		SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(CONVERT(date, @fecha_vencimiento)))		    
		SET @patron = REPLACE(@patron,'[banco_pago]',ISNULL(RTRIM(@codigo_banco),''))		    
		SET @patron = REPLACE(@patron,'[numero_orden]',ISNULL(RTRIM(@numero_orden),''))
		SET @patron = REPLACE(@patron,'[documento_pago]',ISNULL(RTRIM(@documento_pago),''))
		
		declare cursor_recibos_orden cursor local for 
		select  dbo.emp_efectos.numero_factura,numero_efecto,emp_efectos.su_factura,
			emp_efectos.subcuenta,emp_efectos.importe_pendiente,emp_efectos.sys_oid
  		  FROM  emp_orden_pago_c
			INNER JOIN			
				dbo.emp_orden_pago_l ON emp_orden_pago_c.empresa=dbo.emp_orden_pago_l.empresa AND emp_orden_pago_c.numero=dbo.emp_orden_pago_l.numero
			INNER JOIN
			   dbo.emp_efectos ON dbo.emp_orden_pago_l.empresa = dbo.emp_efectos.empresa AND dbo.emp_orden_pago_l.numero_efecto = dbo.emp_efectos.numero
		 WHERE dbo.emp_orden_pago_c.sys_oid = @pSys_oid_orden
				
		SET @apunte = 0	
		OPEN cursor_recibos_orden
		FETCH NEXT FROM cursor_recibos_orden into @numero_factura, @numero_efecto,@su_factura, @subcuenta,@importe_pendiente,@sys_oid_efecto
		WHILE @@FETCH_STATUS = 0
		BEGIN			
			SET @patron = REPLACE(@patron,'[numero_factura]',ISNULL(RTRIM(@numero_factura),''))
			SET @patron = REPLACE(@patron,'[numero_efecto]',ISNULL(RTRIM(@numero_efecto),''))
			SET @patron = REPLACE(@patron,'[su_factura]',ISNULL(RTRIM(@su_factura),''))
			
			SET @apunte = @apunte + 1
			INSERT INTO tmp_apuntes_traspaso
				 (asiento, apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,
				 fecha,subcuenta,codigo_concepto,descripcion,importe_debe,importe_haber)
			  values (1, @apunte, @empresa, @Ejercicio ,@sys_timestamp,@sesion,'OP',@pSys_oid_orden,
						 @fecha_emision, @subcuenta, @codigo_concepto, @patron,@importe_pendiente,0)
									
			UPDATE emp_efectos SET situacion='FU'
			 WHERE sys_oid = @sys_oid_efecto

			FETCH NEXT FROM cursor_recibos_orden into @numero_factura, @numero_efecto,@su_factura, @subcuenta,@importe_pendiente,@sys_oid_efecto
					
		END  
				
		CLOSE cursor_recibos_orden
		DEALLOCATE cursor_recibos_orden

		select @codigo_tipo_apunte=codigo_tipo_apunte,@patron=ap.patron
		  from emp_apuntes_patron as ap 
			left join emp_asientos_patron as asto ON ap.empresa = asto.empresa and ap.codigo=asto.codigo 
		  where ap.empresa=@empresa_matriz 
		    and codigo_tipo_documento='OP' --Efecto fusionado
		    and codigo_tipo_apunte='OP_EF_EMIF'
		    
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',ISNULL(RTRIM(@nombre_proveedor),''))
		SET @patron = REPLACE(@patron,'[razon_social_proveedor]',ISNULL(RTRIM(@razon_social_proveedor),''))
		SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(CONVERT(date, @fecha_vencimiento)))		    
		SET @patron = REPLACE(@patron,'[banco_pago]',ISNULL(RTRIM(@codigo_banco),''))		    
		SET @patron = REPLACE(@patron,'[numero_orden]',ISNULL(RTRIM(@numero_orden),''))
		SET @patron = REPLACE(@patron,'[documento_pago]',ISNULL(RTRIM(@documento_pago),''))
		
		SET @apunte = @apunte + 1
		INSERT INTO tmp_apuntes_traspaso
			(asiento, apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,
				 fecha,subcuenta,codigo_concepto,descripcion,importe_debe,importe_haber)
		  values (1, @apunte, @empresa, @Ejercicio ,@sys_timestamp,@sesion,'OP',@pSys_oid_orden,
			 @fecha_emision, @subcuenta_efectos, @codigo_concepto, @patron, 0, @importe_total)
			 
		/*Asiento COBRO pagare*/
		
		select @codigo_tipo_apunte=codigo_tipo_apunte,@patron=ap.patron
		  from emp_apuntes_patron as ap 
			left join emp_asientos_patron as asto ON ap.empresa = asto.empresa and ap.codigo=asto.codigo 
		  where ap.empresa=@empresa_matriz 
		    and codigo_tipo_documento='OP' --Efecto fusionado
		    and codigo_tipo_apunte='OP_EFE_FUS'
		    
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',ISNULL(RTRIM(@nombre_proveedor),''))
		SET @patron = REPLACE(@patron,'[razon_social_proveedor]',ISNULL(RTRIM(@razon_social_proveedor),''))
		SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(CONVERT(date, @fecha_vencimiento)))		    
		SET @patron = REPLACE(@patron,'[banco_pago]',ISNULL(RTRIM(@codigo_banco),''))		    
		SET @patron = REPLACE(@patron,'[numero_orden]',ISNULL(RTRIM(@numero_orden),''))
		SET @patron = REPLACE(@patron,'[documento_pago]',ISNULL(RTRIM(@documento_pago),''))
		
		SET @apunte = 1
		INSERT INTO tmp_apuntes_traspaso
			(asiento, apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,
				 fecha,subcuenta,codigo_concepto,descripcion,importe_debe,importe_haber)
		  values (2, @apunte, @empresa, @Ejercicio ,@sys_timestamp,@sesion,'OP',@pSys_oid_orden,
			 @fecha_vencimiento, @subcuenta_efectos, @codigo_concepto, @patron, @importe_total, 0)

		select @codigo_tipo_apunte=codigo_tipo_apunte,@patron=ap.patron
		  from emp_apuntes_patron as ap 
			left join emp_asientos_patron as asto ON ap.empresa = asto.empresa and ap.codigo=asto.codigo 
		  where ap.empresa=@empresa_matriz 
		    and codigo_tipo_documento='OP' --Efecto fusionado
		    and codigo_tipo_apunte='OP_BANCO'
		    
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',ISNULL(RTRIM(@nombre_proveedor),''))
		SET @patron = REPLACE(@patron,'[razon_social_proveedor]',ISNULL(RTRIM(@razon_social_proveedor),''))
		SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(CONVERT(date, @fecha_vencimiento)))		    
		SET @patron = REPLACE(@patron,'[banco_pago]',ISNULL(RTRIM(@codigo_banco),''))		    
		SET @patron = REPLACE(@patron,'[numero_orden]',ISNULL(RTRIM(@numero_orden),''))
		SET @patron = REPLACE(@patron,'[documento_pago]',ISNULL(RTRIM(@documento_pago),''))
		
		SET @apunte = @apunte + 1
		INSERT INTO tmp_apuntes_traspaso
			(asiento, apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,
				 fecha,subcuenta,codigo_concepto,descripcion,importe_debe,importe_haber)
		  values (2, @apunte, @empresa, @Ejercicio ,@sys_timestamp,@sesion,'OP',@pSys_oid_orden,
			 @fecha_vencimiento, @subcuenta_banco, @codigo_concepto, @patron, 0, @importe_total)
			 	
		UPDATE emp_orden_pago_c 
			SET situacion='C' 
		 WHERE sys_oid=@pSys_oid_orden
		
		EXEC vs_traspasar_asiento 'OP',@pSys_oid_orden

		COMMIT 

END TRY
/****CONTROL DE ERRORES *****/
BEGIN CATCH
	set @pError = 'ERROR AL CONTABILIZAR la orden de pago (' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + ERROR_MESSAGE()
	ROLLBACK
	RAISERROR(@pError,16,1)
END CATCH

END


ALTER PROCEDURE [dbo].[vs_generar_asiento_orden_pago]
@pSys_oid_orden dm_oid
WITH ENCRYPTION
AS
BEGIN
begin try	
BEGIN TRANSACTION 

	declare @empresa dm_empresas
	declare @ejercicio dm_ejercicios
	declare @fecha dm_fechas_hora
	declare @fecha_bloqueo_ejercicio dm_fechas_hora
	declare @codigo_tipo_apunte dm_codigos_c
	declare @codigo_concepto dm_codigos_c
	declare @patron dm_char_largo
	declare @sesion dm_entero
	declare @sys_timestamp dm_fechas_hora
	declare @numero_efecto dm_numero_doc
	declare @numero_factura dm_numero_doc
	declare @numero_recibo dm_numero_doc
	declare @numero_orden dm_numero_doc
	declare @nombre_proveedor dm_nombres
	declare @razon_social_proveedor dm_nombres
	DECLARE @perror varchar(4000)
	declare @subcuenta_banco dm_subcuenta
	declare @documento_pago dm_char_corto
	declare @empresa_matriz dm_empresas 
	declare @fecha_vencimiento dm_fechas_hora
	declare @fecha_emision dm_fechas_hora
	declare @codigo_banco dm_codigos_c
	declare @importe_pendiente dm_importes
	declare @apunte dm_entero
	declare @subcuenta dm_subcuenta
	declare @subcuenta_efectos dm_subcuenta
	declare @sys_oid_efecto dm_oid
	declare @su_factura dm_char_corto
	declare @codigo_proveedor dm_codigos_n
	DECLARE @importe_total dm_importes
	
	select @empresa_matriz=codigo FROM gen_empresas WHERE matriz = 1
		
	select @Empresa=OP.empresa,@numero_orden=OP.numero,@fecha_vencimiento=OP.fecha_vto, @fecha_emision=OP.fecha_emision,
		@documento_pago=OP.documento_pago,@codigo_proveedor=op.codigo_proveedor,@nombre_proveedor=pr.nombre,
		@razon_social_proveedor=pr.razon_social,@codigo_banco=op.codigo_banco,@importe_total=op.importe,
		@codigo_concepto=op.codigo_concepto
	  from emp_orden_pago_c as OP
		left outer join vf_emp_proveedores as PR ON pr.empresa = @empresa_matriz 
			AND pr.codigo = op.codigo_proveedor
	   WHERE OP.sys_oid = @pSys_oid_orden
	 
	select @ejercicio = ejercicio,@fecha_bloqueo_ejercicio=fecha_bloqueo 
	  from emp_ejercicios 
	  where empresa=@empresa and fecha_apertura <= @fecha_emision and fecha_cierre>=@fecha_emision
	  
	  select @subcuenta_efectos=CTAS.subcuenta_efectos 
	    FROM eje_proveedores_cond_compra_cuentas AS CTAS
			INNER JOIN emp_proveedores_cond_compra AS CC ON CC.empresa = CTAS.empresa 
				AND CC.codigo_proveedor = CTAS.codigo_proveedor
				AND CC.predeterminada = 1
	   WHERE CTAS.empresa = @empresa_matriz 
	     AND CTAS.ejercicio = @ejercicio
	     AND CTAS.codigo_proveedor = @codigo_proveedor
	
		if ISNULL(@subcuenta_efectos,'') = '' 
			raiserror('No encuentro la subcuenta de efectos para este proveedor',16,1)
			
	  select @subcuenta_banco=subcuenta
	    FROM eje_bancos_subcuenta
	   WHERE empresa = @empresa_matriz
	     AND ejercicio = @ejercicio
	     AND codigo_banco = @codigo_banco
	     
		if ISNULL(@subcuenta_banco, '') = ''
			raiserror('No encuentro la subcuenta del banco indicado', 16,1)
				     
		set @Sesion = @@SPID
		set @sys_timestamp = getdate()

		DELETE tmp_apuntes_traspaso 
		where empresa=@empresa
		and sys_oid_origen = @psys_oid_orden 
		and codigo_tipo_documento_origen = 'OP'
		
		/*Asiento EMISION pagare*/
		select @codigo_tipo_apunte=codigo_tipo_apunte,@patron=ap.patron
		  from emp_apuntes_patron as ap 
			left join emp_asientos_patron as asto ON ap.empresa = asto.empresa and ap.codigo=asto.codigo 
		  where ap.empresa=@empresa_matriz 
		    and codigo_tipo_documento='OP' --Orden Pago Emision
		    and codigo_tipo_apunte='OP_EF_EMI'
					
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',ISNULL(RTRIM(@nombre_proveedor),''))
		SET @patron = REPLACE(@patron,'[razon_social_proveedor]',ISNULL(RTRIM(@razon_social_proveedor),''))
		SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(CONVERT(date, @fecha_vencimiento)))		    
		SET @patron = REPLACE(@patron,'[banco_pago]',ISNULL(RTRIM(@codigo_banco),''))		    
		SET @patron = REPLACE(@patron,'[numero_orden]',ISNULL(RTRIM(@numero_orden),''))
		SET @patron = REPLACE(@patron,'[documento_pago]',ISNULL(RTRIM(@documento_pago),''))
		
		declare cursor_recibos_orden cursor local for 
		select  dbo.emp_efectos.numero_factura,numero_efecto,emp_efectos.su_factura,
			emp_efectos.subcuenta,emp_efectos.importe_pendiente,emp_efectos.sys_oid
  		  FROM  emp_orden_pago_c
			INNER JOIN			
				dbo.emp_orden_pago_l ON emp_orden_pago_c.empresa=dbo.emp_orden_pago_l.empresa AND emp_orden_pago_c.numero=dbo.emp_orden_pago_l.numero
			INNER JOIN
			   dbo.emp_efectos ON dbo.emp_orden_pago_l.empresa = dbo.emp_efectos.empresa AND dbo.emp_orden_pago_l.numero_efecto = dbo.emp_efectos.numero
		 WHERE dbo.emp_orden_pago_c.sys_oid = @pSys_oid_orden
				
		SET @apunte = 0	
		OPEN cursor_recibos_orden
		FETCH NEXT FROM cursor_recibos_orden into @numero_factura, @numero_efecto,@su_factura, @subcuenta,@importe_pendiente,@sys_oid_efecto
		WHILE @@FETCH_STATUS = 0
		BEGIN			
			SET @patron = REPLACE(@patron,'[numero_factura]',ISNULL(RTRIM(@numero_factura),''))
			SET @patron = REPLACE(@patron,'[numero_efecto]',ISNULL(RTRIM(@numero_efecto),''))
			SET @patron = REPLACE(@patron,'[su_factura]',ISNULL(RTRIM(@su_factura),''))
			
			SET @apunte = @apunte + 1
			INSERT INTO tmp_apuntes_traspaso
				 (asiento, apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,
				 fecha,subcuenta,codigo_concepto,descripcion,importe_debe,importe_haber)
			  values (1, @apunte, @empresa, @Ejercicio ,@sys_timestamp,@sesion,'OP',@pSys_oid_orden,
						 @fecha_emision, @subcuenta, @codigo_concepto, @patron,@importe_pendiente,0)
									
			UPDATE emp_efectos SET situacion='FU'
			 WHERE sys_oid = @sys_oid_efecto

			FETCH NEXT FROM cursor_recibos_orden into @numero_factura, @numero_efecto,@su_factura, @subcuenta,@importe_pendiente,@sys_oid_efecto
					
		END  
				
		CLOSE cursor_recibos_orden
		DEALLOCATE cursor_recibos_orden

		select @codigo_tipo_apunte=codigo_tipo_apunte,@patron=ap.patron
		  from emp_apuntes_patron as ap 
			left join emp_asientos_patron as asto ON ap.empresa = asto.empresa and ap.codigo=asto.codigo 
		  where ap.empresa=@empresa_matriz 
		    and codigo_tipo_documento='OP' --Efecto fusionado
		    and codigo_tipo_apunte='OP_EF_EMIF'
		    
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',ISNULL(RTRIM(@nombre_proveedor),''))
		SET @patron = REPLACE(@patron,'[razon_social_proveedor]',ISNULL(RTRIM(@razon_social_proveedor),''))
		SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(CONVERT(date, @fecha_vencimiento)))		    
		SET @patron = REPLACE(@patron,'[banco_pago]',ISNULL(RTRIM(@codigo_banco),''))		    
		SET @patron = REPLACE(@patron,'[numero_orden]',ISNULL(RTRIM(@numero_orden),''))
		SET @patron = REPLACE(@patron,'[documento_pago]',ISNULL(RTRIM(@documento_pago),''))
		
		SET @apunte = @apunte + 1
		INSERT INTO tmp_apuntes_traspaso
			(asiento, apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,
				 fecha,subcuenta,codigo_concepto,descripcion,importe_debe,importe_haber)
		  values (1, @apunte, @empresa, @Ejercicio ,@sys_timestamp,@sesion,'OP',@pSys_oid_orden,
			 @fecha_emision, @subcuenta_efectos, @codigo_concepto, @patron, 0, @importe_total)
			 
		/*Asiento COBRO pagare*/
		
		select @codigo_tipo_apunte=codigo_tipo_apunte,@patron=ap.patron
		  from emp_apuntes_patron as ap 
			left join emp_asientos_patron as asto ON ap.empresa = asto.empresa and ap.codigo=asto.codigo 
		  where ap.empresa=@empresa_matriz 
		    and codigo_tipo_documento='OP' --Efecto fusionado
		    and codigo_tipo_apunte='OP_EFE_FUS'
		    
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',ISNULL(RTRIM(@nombre_proveedor),''))
		SET @patron = REPLACE(@patron,'[razon_social_proveedor]',ISNULL(RTRIM(@razon_social_proveedor),''))
		SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(CONVERT(date, @fecha_vencimiento)))		    
		SET @patron = REPLACE(@patron,'[banco_pago]',ISNULL(RTRIM(@codigo_banco),''))		    
		SET @patron = REPLACE(@patron,'[numero_orden]',ISNULL(RTRIM(@numero_orden),''))
		SET @patron = REPLACE(@patron,'[documento_pago]',ISNULL(RTRIM(@documento_pago),''))
		
		SET @apunte = 1
		INSERT INTO tmp_apuntes_traspaso
			(asiento, apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,
				 fecha,subcuenta,codigo_concepto,descripcion,importe_debe,importe_haber)
		  values (2, @apunte, @empresa, @Ejercicio ,@sys_timestamp,@sesion,'OP',@pSys_oid_orden,
			 @fecha_emision, @subcuenta_efectos, @codigo_concepto, @patron, @importe_total, 0)

		select @codigo_tipo_apunte=codigo_tipo_apunte,@patron=ap.patron
		  from emp_apuntes_patron as ap 
			left join emp_asientos_patron as asto ON ap.empresa = asto.empresa and ap.codigo=asto.codigo 
		  where ap.empresa=@empresa_matriz 
		    and codigo_tipo_documento='OP' --Efecto fusionado
		    and codigo_tipo_apunte='OP_BANCO'
		    
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',ISNULL(RTRIM(@nombre_proveedor),''))
		SET @patron = REPLACE(@patron,'[razon_social_proveedor]',ISNULL(RTRIM(@razon_social_proveedor),''))
		SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(CONVERT(date, @fecha_vencimiento)))		    
		SET @patron = REPLACE(@patron,'[banco_pago]',ISNULL(RTRIM(@codigo_banco),''))		    
		SET @patron = REPLACE(@patron,'[numero_orden]',ISNULL(RTRIM(@numero_orden),''))
		SET @patron = REPLACE(@patron,'[documento_pago]',ISNULL(RTRIM(@documento_pago),''))
		
		SET @apunte = @apunte + 1
		INSERT INTO tmp_apuntes_traspaso
			(asiento, apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,
				 fecha,subcuenta,codigo_concepto,descripcion,importe_debe,importe_haber)
		  values (2, @apunte, @empresa, @Ejercicio ,@sys_timestamp,@sesion,'OP',@pSys_oid_orden,
			 @fecha_emision, @subcuenta_banco, @codigo_concepto, @patron, 0, @importe_total)
			 	
		UPDATE emp_orden_pago_c 
			SET situacion='C' 
		 WHERE sys_oid=@pSys_oid_orden
		
		EXEC vs_traspasar_asiento 'OP',@pSys_oid_orden

		COMMIT 

END TRY
/****CONTROL DE ERRORES *****/
BEGIN CATCH
	set @pError = 'ERROR AL CONTABILIZAR la orden de pago (' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + ERROR_MESSAGE()
	ROLLBACK
	RAISERROR(@pError,16,1)
END CATCH

END


ALTER PROCEDURE [dbo].[vs_generar_asiento_orden_pago]
@pSys_oid_orden dm_oid
WITH ENCRYPTION
AS
BEGIN
begin try	
BEGIN TRANSACTION 

	declare @empresa dm_empresas
	declare @ejercicio dm_ejercicios
	declare @fecha dm_fechas_hora
	declare @fecha_bloqueo_ejercicio dm_fechas_hora
	declare @codigo_tipo_apunte dm_codigos_c
	declare @codigo_concepto dm_codigos_c
	declare @patron dm_char_largo
	declare @sesion dm_entero
	declare @sys_timestamp dm_fechas_hora
	declare @numero_efecto dm_numero_doc
	declare @numero_factura dm_numero_doc
	declare @numero_recibo dm_numero_doc
	declare @numero_orden dm_numero_doc
	declare @nombre_proveedor dm_nombres
	declare @razon_social_proveedor dm_nombres
	DECLARE @perror varchar(4000)
	declare @subcuenta_banco dm_subcuenta
	declare @documento_pago dm_char_corto
	declare @empresa_matriz dm_empresas 
	declare @fecha_vencimiento dm_fechas_hora
	declare @fecha_emision dm_fechas_hora
	declare @codigo_banco dm_codigos_c
	declare @importe_pendiente dm_importes
	declare @apunte dm_entero
	declare @subcuenta dm_subcuenta
	declare @subcuenta_efectos dm_subcuenta
	declare @sys_oid_efecto dm_oid
	declare @su_factura dm_char_corto
	declare @codigo_proveedor dm_codigos_n
	DECLARE @importe_total dm_importes
	
	select @empresa_matriz=codigo FROM gen_empresas WHERE matriz = 1
		
	select @Empresa=OP.empresa,@numero_orden=OP.numero,@fecha_vencimiento=OP.fecha_vto, @fecha_emision=OP.fecha_emision,
		@documento_pago=OP.documento_pago,@codigo_proveedor=op.codigo_proveedor,@nombre_proveedor=pr.nombre,
		@razon_social_proveedor=pr.razon_social,@codigo_banco=op.codigo_banco,@importe_total=op.importe,
		@codigo_concepto=op.codigo_concepto
	  from emp_orden_pago_c as OP
		left outer join vf_emp_proveedores as PR ON pr.empresa = @empresa_matriz 
			AND pr.codigo = op.codigo_proveedor
	   WHERE OP.sys_oid = @pSys_oid_orden
	 
	select @ejercicio = ejercicio,@fecha_bloqueo_ejercicio=fecha_bloqueo 
	  from emp_ejercicios 
	  where empresa=@empresa and fecha_apertura <= @fecha_emision and fecha_cierre>=@fecha_emision
	  
	  select @subcuenta_efectos=CTAS.subcuenta_efectos 
	    FROM eje_proveedores_cond_compra_cuentas AS CTAS
			INNER JOIN emp_proveedores_cond_compra AS CC ON CC.empresa = CTAS.empresa 
				AND CC.codigo_proveedor = CTAS.codigo_proveedor
				AND CC.predeterminada = 1
	   WHERE CTAS.empresa = @empresa_matriz 
	     AND CTAS.ejercicio = @ejercicio
	     AND CTAS.codigo_proveedor = @codigo_proveedor
	
		if ISNULL(@subcuenta_efectos,'') = '' 
			raiserror('No encuentro la subcuenta de efectos para este proveedor',16,1)
			
	  select @subcuenta_banco=subcuenta
	    FROM eje_bancos_subcuenta
	   WHERE empresa = @empresa_matriz
	     AND ejercicio = @ejercicio
	     AND codigo_banco = @codigo_banco
	     
		if ISNULL(@subcuenta_banco, '') = ''
			raiserror('No encuentro la subcuenta del banco indicado', 16,1)
				     
		set @Sesion = @@SPID
		set @sys_timestamp = getdate()

		DELETE tmp_apuntes_traspaso 
		where empresa=@empresa
		and sys_oid_origen = @psys_oid_orden 
		and codigo_tipo_documento_origen = 'OP'
		
		/*Asiento EMISION pagare*/
		select @codigo_tipo_apunte=codigo_tipo_apunte,@patron=ap.patron
		  from emp_apuntes_patron as ap 
			left join emp_asientos_patron as asto ON ap.empresa = asto.empresa and ap.codigo=asto.codigo 
		  where ap.empresa=@empresa_matriz 
		    and codigo_tipo_documento='OP' --Orden Pago Emision
		    and codigo_tipo_apunte='OP_EF_EMI'
					
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',ISNULL(RTRIM(@nombre_proveedor),''))
		SET @patron = REPLACE(@patron,'[razon_social_proveedor]',ISNULL(RTRIM(@razon_social_proveedor),''))
		SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(CONVERT(date, @fecha_vencimiento)))		    
		SET @patron = REPLACE(@patron,'[banco_pago]',ISNULL(RTRIM(@codigo_banco),''))		    
		SET @patron = REPLACE(@patron,'[numero_orden]',ISNULL(RTRIM(@numero_orden),''))
		SET @patron = REPLACE(@patron,'[documento_pago]',ISNULL(RTRIM(@documento_pago),''))
		
		declare cursor_recibos_orden cursor local for 
		select  dbo.emp_efectos.numero_factura,numero_efecto,emp_efectos.su_factura,
			emp_efectos.subcuenta,emp_efectos.importe_pendiente,emp_efectos.sys_oid
  		  FROM  emp_orden_pago_c
			INNER JOIN			
				dbo.emp_orden_pago_l ON emp_orden_pago_c.empresa=dbo.emp_orden_pago_l.empresa AND emp_orden_pago_c.numero=dbo.emp_orden_pago_l.numero
			INNER JOIN
			   dbo.emp_efectos ON dbo.emp_orden_pago_l.empresa = dbo.emp_efectos.empresa AND dbo.emp_orden_pago_l.numero_efecto = dbo.emp_efectos.numero
		 WHERE dbo.emp_orden_pago_c.sys_oid = @pSys_oid_orden
				
		SET @apunte = 0	
		OPEN cursor_recibos_orden
		FETCH NEXT FROM cursor_recibos_orden into @numero_factura, @numero_efecto,@su_factura, @subcuenta,@importe_pendiente,@sys_oid_efecto
		WHILE @@FETCH_STATUS = 0
		BEGIN			
			SET @patron = REPLACE(@patron,'[numero_factura]',ISNULL(RTRIM(@numero_factura),''))
			SET @patron = REPLACE(@patron,'[numero_efecto]',ISNULL(RTRIM(@numero_efecto),''))
			SET @patron = REPLACE(@patron,'[su_factura]',ISNULL(RTRIM(@su_factura),''))
			
			SET @apunte = @apunte + 1
			INSERT INTO tmp_apuntes_traspaso
				 (asiento, apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,
				 fecha,subcuenta,codigo_concepto,descripcion,importe_debe,importe_haber)
			  values (1, @apunte, @empresa, @Ejercicio ,@sys_timestamp,@sesion,'OP',@pSys_oid_orden,
						 @fecha_emision, @subcuenta, @codigo_concepto, @patron,@importe_pendiente,0)
									
			UPDATE emp_efectos SET situacion='FU'
			 WHERE sys_oid = @sys_oid_efecto

			FETCH NEXT FROM cursor_recibos_orden into @numero_factura, @numero_efecto,@su_factura, @subcuenta,@importe_pendiente,@sys_oid_efecto
					
		END  
				
		CLOSE cursor_recibos_orden
		DEALLOCATE cursor_recibos_orden

		select @codigo_tipo_apunte=codigo_tipo_apunte,@patron=ap.patron
		  from emp_apuntes_patron as ap 
			left join emp_asientos_patron as asto ON ap.empresa = asto.empresa and ap.codigo=asto.codigo 
		  where ap.empresa=@empresa_matriz 
		    and codigo_tipo_documento='OP' --Efecto fusionado
		    and codigo_tipo_apunte='OP_EF_EMIF'
		    
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',ISNULL(RTRIM(@nombre_proveedor),''))
		SET @patron = REPLACE(@patron,'[razon_social_proveedor]',ISNULL(RTRIM(@razon_social_proveedor),''))
		SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(CONVERT(date, @fecha_vencimiento)))		    
		SET @patron = REPLACE(@patron,'[banco_pago]',ISNULL(RTRIM(@codigo_banco),''))		    
		SET @patron = REPLACE(@patron,'[numero_orden]',ISNULL(RTRIM(@numero_orden),''))
		SET @patron = REPLACE(@patron,'[documento_pago]',ISNULL(RTRIM(@documento_pago),''))
		
		SET @apunte = @apunte + 1
		INSERT INTO tmp_apuntes_traspaso
			(asiento, apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,
				 fecha,subcuenta,codigo_concepto,descripcion,importe_debe,importe_haber)
		  values (1, @apunte, @empresa, @Ejercicio ,@sys_timestamp,@sesion,'OP',@pSys_oid_orden,
			 @fecha_emision, @subcuenta_efectos, @codigo_concepto, @patron, 0, @importe_total)
			 
		/*Asiento COBRO pagare*/
		
		select @codigo_tipo_apunte=codigo_tipo_apunte,@patron=ap.patron
		  from emp_apuntes_patron as ap 
			left join emp_asientos_patron as asto ON ap.empresa = asto.empresa and ap.codigo=asto.codigo 
		  where ap.empresa=@empresa_matriz 
		    and codigo_tipo_documento='OP' --Efecto fusionado
		    and codigo_tipo_apunte='OP_EFE_FUS'
		    
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',ISNULL(RTRIM(@nombre_proveedor),''))
		SET @patron = REPLACE(@patron,'[razon_social_proveedor]',ISNULL(RTRIM(@razon_social_proveedor),''))
		SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(CONVERT(date, @fecha_vencimiento)))		    
		SET @patron = REPLACE(@patron,'[banco_pago]',ISNULL(RTRIM(@codigo_banco),''))		    
		SET @patron = REPLACE(@patron,'[numero_orden]',ISNULL(RTRIM(@numero_orden),''))
		SET @patron = REPLACE(@patron,'[documento_pago]',ISNULL(RTRIM(@documento_pago),''))
		
		SET @apunte = 1
		INSERT INTO tmp_apuntes_traspaso
			(asiento, apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,
				 fecha,subcuenta,codigo_concepto,descripcion,importe_debe,importe_haber)
		  values (2, @apunte, @empresa, @Ejercicio ,@sys_timestamp,@sesion,'OP',@pSys_oid_orden,
			 @fecha_emision, @subcuenta_efectos, @codigo_concepto, @patron, @importe_total, 0)

		select @codigo_tipo_apunte=codigo_tipo_apunte,@patron=ap.patron
		  from emp_apuntes_patron as ap 
			left join emp_asientos_patron as asto ON ap.empresa = asto.empresa and ap.codigo=asto.codigo 
		  where ap.empresa=@empresa_matriz 
		    and codigo_tipo_documento='OP' --Efecto fusionado
		    and codigo_tipo_apunte='OP_BANCO'
		    
		SET @patron = REPLACE(@patron,'[nombre_proveedor]',ISNULL(RTRIM(@nombre_proveedor),''))
		SET @patron = REPLACE(@patron,'[razon_social_proveedor]',ISNULL(RTRIM(@razon_social_proveedor),''))
		SET @patron = REPLACE(@patron,'[fecha_vencimiento]',RTRIM(CONVERT(date, @fecha_vencimiento)))		    
		SET @patron = REPLACE(@patron,'[banco_pago]',ISNULL(RTRIM(@codigo_banco),''))		    
		SET @patron = REPLACE(@patron,'[numero_orden]',ISNULL(RTRIM(@numero_orden),''))
		SET @patron = REPLACE(@patron,'[documento_pago]',ISNULL(RTRIM(@documento_pago),''))
		
		SET @apunte = @apunte + 1
		INSERT INTO tmp_apuntes_traspaso
			(asiento, apunte,empresa,ejercicio,sys_timestamp,sesion,codigo_tipo_documento_origen,sys_oid_origen,
				 fecha,subcuenta,codigo_concepto,descripcion,importe_debe,importe_haber)
		  values (2, @apunte, @empresa, @Ejercicio ,@sys_timestamp,@sesion,'OP',@pSys_oid_orden,
			 @fecha_emision, @subcuenta_banco, @codigo_concepto, @patron, 0, @importe_total)
			 	
		UPDATE emp_orden_pago_c 
			SET situacion='C' 
		 WHERE sys_oid=@pSys_oid_orden
		
		EXEC vs_traspasar_asiento 'OP',@pSys_oid_orden

		COMMIT 

END TRY
/****CONTROL DE ERRORES *****/
BEGIN CATCH
	set @pError = 'ERROR AL CONTABILIZAR la orden de pago (' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + ERROR_MESSAGE()
	ROLLBACK
	RAISERROR(@pError,16,1)
END CATCH

END


CREATE VIEW [dbo].[vr_emp_orden_pago] with encryption
AS
SELECT     dbo.emp_orden_pago_c.empresa, dbo.emp_orden_pago_c.numero, dbo.emp_orden_pago_c.fecha, dbo.emp_orden_pago_c.codigo_proveedor, 
                      dbo.emp_orden_pago_c.documento_pago, dbo.emp_orden_pago_c.fecha_emision, dbo.emp_orden_pago_c.fecha_vto, dbo.emp_orden_pago_c.codigo_banco, 
                      dbo.emp_orden_pago_c.numero_efectos, dbo.emp_orden_pago_c.importe, dbo.vf_emp_orden_pago_l.numero_efecto, 
                      dbo.vf_emp_orden_pago_l.fecha_vto AS fecha_vencimiento_efecto, dbo.vf_emp_orden_pago_l.su_factura, dbo.vf_emp_orden_pago_l.fecha_factura, 
                      dbo.vf_emp_orden_pago_l.importe AS importe_efecto, dbo.emp_bancos.alias AS nombre_banco,
                      dbo.vf_emp_proveedores.nombre AS nombre_proveedor, dbo.vf_emp_proveedores.domicilio AS domicilio_proveedor, 
                      dbo.vf_emp_proveedores.codigo_postal AS codigo_postal_proveedor, dbo.vf_emp_proveedores.poblacion AS poblacion_proveedor,
                      dbo.vf_emp_proveedores.provincia AS provincia_proveedor, dbo.emp_orden_pago_c.sys_oid
FROM         dbo.vf_emp_orden_pago_l INNER JOIN
                      dbo.emp_orden_pago_c ON dbo.vf_emp_orden_pago_l.empresa = dbo.emp_orden_pago_c.empresa AND 
                      dbo.vf_emp_orden_pago_l.numero = dbo.emp_orden_pago_c.numero CROSS JOIN 
                      dbo.gen_empresas INNER JOIN
                      dbo.vf_emp_proveedores ON dbo.gen_empresas.codigo = vf_emp_proveedores.empresa AND 
                      dbo.emp_orden_pago_c.codigo_proveedor = dbo.vf_emp_proveedores.codigo  INNER JOIN
                      dbo.emp_bancos ON dbo.gen_empresas.codigo = dbo.emp_bancos.empresa AND 
                      dbo.emp_orden_pago_c.codigo_banco = dbo.emp_bancos.codigo
WHERE     (dbo.gen_empresas.matriz = 1)

GO

create PROCEDURE [dbo].[vs_descontabilizar_orden_pago]
	@pSys_oid dm_oid,
	@usuario dm_codigos_c      with encryption 
AS
BEGIN
	DECLARE @perror varchar(4000)
	SET NOCOUNT OFF
begin try	
	
	
	BEGIN TRANSACTION 
	UPDATE emp_efectos SET situacion = 'CA'
	  FROM emp_efectos AS E
		INNER JOIN emp_orden_pago_l AS L ON L.empresa = E.empresa 
			AND L.numero_efecto = E.numero
		INNER JOIN emp_orden_pago_c as C ON C.empresa = L.empresa
			and C.numero = L.numero
	  WHERE C.sys_oid = @pSys_oid
	    and E.tipo = 'C'
	    
	DELETE eje_asientos 
	  FROM eje_asientos 
		INNER JOIN gen_nav_documentos ON gen_nav_documentos.oid_documento_destino = eje_asientos.sys_oid
	 where gen_nav_documentos.tipo_documento_origen='OP' 
	   and gen_nav_documentos.oid_documento_origen = @pSys_oid
	   and gen_nav_documentos.deshecho=0
	
	UPDATE tmp_apuntes_traspaso SET traspasado=0,
		codigo_tipo_documento_destino=NULL,
		sys_oid_destino=NULL 
	 WHERE codigo_tipo_documento_origen='OP' 
	   and sys_oid_origen=@pSys_oid
	   AND traspasado=1
	   
	UPDATE emp_orden_pago_c set situacion='N' 
	 WHERE sys_oid = @pSys_oid
	 
	update gen_nav_documentos set deshecho=1,
		usuario_deshacer=@usuario,
		fecha_deshacer=getdate() 
	where tipo_documento_origen='OP' 
	  and oid_documento_origen = @pSys_oid 
	  and deshecho=0
	  
	COMMIT 
END TRY
/****CONTROL DE ERRORES *****/
BEGIN CATCH
	set @pError = 'ERROR AL DESCONTABILIZAR LA ORDEN DE PAGO (' + ERROR_PROCEDURE() + '):' + CHAR(13) + CHAR(10) + ERROR_MESSAGE()
	ROLLBACK
	RAISERROR(@pError,16,1)
END CATCH
END

*/
