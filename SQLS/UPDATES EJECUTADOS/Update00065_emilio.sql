USE vs_martinez
GO

/****** Object:  Table [dbo].[emp_articulos]    Script Date: 02/01/2012 17:38:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[gen_mart_articulos_taribat](
	[codigo] [dbo].[dm_codigo_articulo] NOT NULL,
	[descripcion] [char](100) NULL,
	[sys_logs] [dbo].[dm_memo] NULL,
	[sys_borrado] [dbo].[dm_logico] NULL,
	[sys_timestamp] [dbo].[dm_fechas_hora] NULL,
	[sys_oid] [dbo].[dm_oid] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [pk_gen_mart_articulos_taribat] PRIMARY KEY CLUSTERED 
(
	[sys_oid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[gen_mart_articulos_taribat] ADD  CONSTRAINT [DF_gen_mart_articulos_taribat_sys_timestamp]  DEFAULT (getdate()) FOR [sys_timestamp]
GO
