USE [vs_martinez]
GO

/****** Object:  Table [dbo].[emp_clientes_criterios_conjuntacion]    Script Date: 02/02/2012 12:22:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[emp_clientes_criterios_conjuntacion](
	[empresa] [dbo].[dm_empresas] NOT NULL,
	[codigo_cliente] [dbo].[dm_codigos_n] NOT NULL,
	[criterio_conjuntacion] [dbo].[dm_char_corto] NOT NULL,
	[sys_logs] [dbo].[dm_memo] NULL,
	[sys_borrado] [dbo].[dm_logico] NULL,
	[sys_timestamp] [dbo].[dm_fechas_hora] NULL,
	[sys_oid] [dbo].[dm_oid] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_emp_clientes_criterios_conjuntacion] PRIMARY KEY CLUSTERED 
(
	[empresa] ASC,
	[codigo_cliente] ASC,
	[criterio_conjuntacion] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[emp_clientes_criterios_conjuntacion]  WITH CHECK ADD  CONSTRAINT [FK_emp_clientes_criterios_conjuntacion_emp_clientes] FOREIGN KEY([empresa], [codigo_cliente])
REFERENCES [dbo].[emp_clientes] ([empresa], [codigo])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[emp_clientes_criterios_conjuntacion] CHECK CONSTRAINT [FK_emp_clientes_criterios_conjuntacion_emp_clientes]
GO

ALTER TABLE [dbo].[emp_clientes_criterios_conjuntacion] ADD  CONSTRAINT [DF_emp_clientes_criterios_conjuntacion_sys_borrado]  DEFAULT ((0)) FOR [sys_borrado]
GO

ALTER TABLE [dbo].[emp_clientes_criterios_conjuntacion] ADD  CONSTRAINT [DF_emp_clientes_criterios_conjuntacion_sys_timestamp]  DEFAULT (getdate()) FOR [sys_timestamp]
GO

/****** Object:  Index [UK_emp_clientes_criterios_conjuntacion]    Script Date: 02/02/2012 12:23:17 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UK_emp_clientes_criterios_conjuntacion] ON [dbo].[emp_clientes_criterios_conjuntacion] 
(
	[sys_oid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


