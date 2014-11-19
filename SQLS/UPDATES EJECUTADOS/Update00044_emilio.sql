USE vs_martinez
GO

/****** Object:  Table [dbo].[emp_grupos_clientes]    Script Date: 01/25/2012 10:26:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[emp_grupos_articulos](
	[empresa] [dbo].[dm_empresas] NOT NULL,
	[codigo] [dbo].[dm_codigos_c] NOT NULL,
	[descripcion] [dbo].[dm_nombres] NULL,
	[sys_logs] [dbo].[dm_memo] NULL,
	[sys_borrado] [dbo].[dm_logico] NULL,
	[sys_timestamp] [dbo].[dm_fechas_hora] NULL,
	[sys_oid] [dbo].[dm_oid] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_emp_grupos_articulos] PRIMARY KEY CLUSTERED 
(
	[empresa] ASC,
	[codigo] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[emp_grupos_articulos]  WITH NOCHECK ADD  CONSTRAINT [FK_emp_grupos_articulos_gen_empresas] FOREIGN KEY([empresa])
REFERENCES [dbo].[gen_empresas] ([codigo])
GO

ALTER TABLE [dbo].[emp_grupos_articulos] CHECK CONSTRAINT [FK_emp_grupos_articulos_gen_empresas]
GO

ALTER TABLE [dbo].[emp_grupos_articulos] ADD  CONSTRAINT [DF_emp_grupos_articulos_sys_timestamp]  DEFAULT (getdate()) FOR [sys_timestamp]
GO


