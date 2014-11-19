USE vs_martinez
GO

/****** Object:  Table [dbo].[emp_articulos_grupos]    Script Date: 01/25/2012 10:28:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[emp_articulos_grupos](
	[empresa] [dbo].[dm_empresas] NOT NULL,
	[codigo_articulo] [dbo].[dm_codigo_articulo] NOT NULL,
	[codigo_grupo] [dbo].[dm_codigos_c] NOT NULL,
	[sys_logs] [dbo].[dm_memo] NULL,
	[sys_borrado] [dbo].[dm_logico] NULL,
	[sys_timestamp] [dbo].[dm_fechas_hora] NULL,
	[sys_oid] [dbo].[dm_oid] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_EMP_ARTICULOS_GRUPOS] PRIMARY KEY CLUSTERED 
(
	[empresa] ASC,
	[codigo_articulo] ASC,
	[codigo_grupo] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[emp_articulos_grupos]  WITH NOCHECK ADD  CONSTRAINT [FK_emp_articulos_grupos_emp_articulos] FOREIGN KEY([empresa], [codigo_articulo])
REFERENCES [dbo].[emp_articulos] ([empresa], [codigo])
ON UPDATE CASCADE
ON DELETE CASCADE
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[emp_articulos_grupos] CHECK CONSTRAINT [FK_emp_articulos_grupos_emp_articulos]
GO

ALTER TABLE [dbo].[emp_articulos_grupos]  WITH NOCHECK ADD  CONSTRAINT [FK_emp_articulos_grupos_emp_grupos_articulos] FOREIGN KEY([empresa], [codigo_grupo])
REFERENCES [dbo].[emp_grupos_articulos] ([empresa], [codigo])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[emp_articulos_grupos] CHECK CONSTRAINT [FK_emp_articulos_grupos_emp_grupos_articulos]
GO

ALTER TABLE [dbo].[emp_articulos_grupos]  WITH NOCHECK ADD  CONSTRAINT [FK_emp_articulos_grupos_gen_empresas] FOREIGN KEY([empresa])
REFERENCES [dbo].[gen_empresas] ([codigo])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[emp_articulos_grupos] CHECK CONSTRAINT [FK_emp_articulos_grupos_gen_empresas]
GO

ALTER TABLE [dbo].[emp_articulos_grupos] ADD  CONSTRAINT [DF_emp_articulos_grupos_stock_sys_timestamp]  DEFAULT (getdate()) FOR [sys_timestamp]
GO


