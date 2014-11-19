use vs_martinez
go

ALTER TABLE sys_usuarios add codigo_centro_venta_defecto dm_codigos_c null
go


ALTER TRIGGER [dbo].[sys_usuarios_bi]
   ON  [dbo].[sys_usuarios] with encryption
INSTEAD OF INSERT
AS
BEGIN

INSERT sys_usuarios ([usuario]
      ,[form_inicio]
      ,[ultima_empresa]
      ,[ultimo_ejercicio]
      ,[ultima_fecha_trabajo]
      ,[activo]
      ,[administrador]
      ,[anclar_tareas]
      ,[sys_log]
      ,[sys_borrado]
      ,[sys_timestamp]
      ,[alias]
      ,[passwd]
      ,minutos_max_inactividad
      ,cerrar_sesion_automaticamente
      ,empresa_asociada
      ,codigo_banco_efectivo
      ,codigo_banco_tarjeta
      ,codigo_centro_venta_defecto)
SELECT usuario 
      ,[form_inicio]
      ,[ultima_empresa]
      ,[ultimo_ejercicio]
      ,[ultima_fecha_trabajo]
      ,[activo]
      ,[administrador]
      ,[anclar_tareas]
      ,[sys_log]
      ,[sys_borrado]
      ,[sys_timestamp]
      ,[alias]
      ,ENCRYPTBYPASSPHRASE(RTRIM(LTRIM(i.usuario)),i.passwd)
      ,minutos_max_inactividad
      ,cerrar_sesion_automaticamente
      ,empresa_asociada
      ,codigo_banco_efectivo
      ,codigo_banco_tarjeta
      ,codigo_centro_venta_defecto
      
  FROM inserted AS i
END
go

ALTER TRIGGER [dbo].[sys_usuarios_bu]
   ON  [dbo].[sys_usuarios] with encryption
   INSTEAD OF UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	IF UPDATE(passwd)
		--Si actualizamos el passwd nos toca desencriptar y volver a encriptar
		UPDATE sys_usuarios SET 
			[usuario] = i.usuario
		  ,[passwd] = ENCRYPTBYPASSPHRASE(RTRIM(LTRIM(i.usuario)),i.passwd)
		  ,[form_inicio] = i.form_inicio
		  ,[ultima_empresa] = i.ultima_empresa
		  ,[ultimo_ejercicio] = i.ultimo_ejercicio
		  ,[ultima_fecha_trabajo] = i.ultima_fecha_trabajo
		  ,[activo] = i.activo
		  ,[administrador] = i.administrador
		  ,[anclar_tareas] = i.anclar_tareas
		  ,[sys_log] = i.sys_log
		  ,[sys_borrado] = i.sys_borrado
		  ,[sys_timestamp] = i.sys_timestamp
		  ,[alias] = i.alias
		  ,[minutos_max_inactividad] = i.minutos_max_inactividad
		  ,cerrar_sesion_automaticamente = i.cerrar_sesion_automaticamente
		  ,empresa_asociada = i.empresa_asociada
		  ,codigo_banco_efectivo = i.codigo_banco_efectivo
		  ,codigo_banco_tarjeta = i.codigo_banco_tarjeta
		  ,codigo_centro_venta_defecto = i.codigo_centro_venta_defecto
		 FROM sys_usuarios 
			INNER JOIN inserted AS i ON i.sys_oid = sys_usuarios.sys_oid
			INNER JOIN deleted AS e ON e.sys_oid = i.sys_oid
	ELSE
		--Si no actualizamos el passwd actualizamos el resto de campos unicamente...
		UPDATE sys_usuarios SET 
			[usuario] = i.usuario
		  ,[form_inicio] = i.form_inicio
		  ,[ultima_empresa] = i.ultima_empresa
		  ,[ultimo_ejercicio] = i.ultimo_ejercicio
		  ,[ultima_fecha_trabajo] = i.ultima_fecha_trabajo
		  ,[activo] = i.activo
		  ,[administrador] = i.administrador
		  ,[anclar_tareas] = i.anclar_tareas
		  ,[sys_log] = i.sys_log
		  ,[sys_borrado] = i.sys_borrado
		  ,[sys_timestamp] = i.sys_timestamp
		  ,[alias] = i.alias
		  ,[minutos_max_inactividad] = i.minutos_max_inactividad
		  ,cerrar_sesion_automaticamente = i.cerrar_sesion_automaticamente
		  ,empresa_asociada = i.empresa_asociada
		  ,codigo_banco_efectivo = i.codigo_banco_efectivo
		  ,codigo_banco_tarjeta = i.codigo_banco_tarjeta
		  ,codigo_centro_venta_defecto = i.codigo_centro_venta_defecto
		 FROM sys_usuarios 
			INNER JOIN inserted AS i ON i.sys_oid = sys_usuarios.sys_oid
			INNER JOIN deleted AS e ON e.sys_oid = i.sys_oid

END

go

ALTER TABLE pda_pedido_c add realizado_por dm_codigos_c null
go
ALTER TABLE pda_pedido_c add codigo_centro_venta dm_codigos_c null
go