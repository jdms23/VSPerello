USE [vsolution]
GO

/****** Object:  Table [dbo].[emp_articulos_sinonimos]    Script Date: 02/08/2012 09:57:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[emp_articulos_sinonimos](
	[empresa] [dbo].[dm_empresas] NOT NULL,
	[codigo_articulo] [dbo].[dm_codigo_articulo] NOT NULL,
	[termino_sinonimo] [dbo].[dm_numero_doc] NOT NULL,
	[sys_logs] [dbo].[dm_memo] NULL,
	[sys_borrado] [dbo].[dm_logico] NULL,
	[sys_timestamp] [dbo].[dm_fechas_hora] NULL,
	[sys_oid] [dbo].[dm_oid] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_emp_articulos_sinonimos] PRIMARY KEY CLUSTERED 
(
	[empresa] ASC,
	[codigo_articulo] ASC,
	[termino_sinonimo] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[emp_articulos_sinonimos]  WITH NOCHECK ADD  CONSTRAINT [FK_emp_articulos_sinonimos_emp_articulos] FOREIGN KEY([empresa], [codigo_articulo])
REFERENCES [dbo].[emp_articulos] ([empresa], [codigo])
ON UPDATE CASCADE
ON DELETE CASCADE
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[emp_articulos_sinonimos] CHECK CONSTRAINT [FK_emp_articulos_sinonimos_emp_articulos]
GO

ALTER TABLE [dbo].[emp_articulos_sinonimos]  WITH NOCHECK ADD  CONSTRAINT [FK_emp_articulos_sinonimos_gen_terminos] FOREIGN KEY([termino_sinonimo])
REFERENCES [dbo].[gen_terminos] ([termino])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[emp_articulos_sinonimos] CHECK CONSTRAINT [FK_emp_articulos_sinonimos_gen_terminos]
GO

ALTER TABLE [dbo].[emp_articulos_sinonimos]  WITH NOCHECK ADD  CONSTRAINT [FK_emp_articulos_sinonimos_gen_empresas] FOREIGN KEY([empresa])
REFERENCES [dbo].[gen_empresas] ([codigo])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[emp_articulos_sinonimos] CHECK CONSTRAINT [FK_emp_articulos_sinonimos_gen_empresas]
GO

ALTER TABLE [dbo].[emp_articulos_sinonimos] ADD  CONSTRAINT [DF_emp_articulos_sinonimos_stock_sys_timestamp]  DEFAULT (getdate()) FOR [sys_timestamp]
GO


