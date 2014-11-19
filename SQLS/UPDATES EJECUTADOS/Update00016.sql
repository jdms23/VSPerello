/**** 17/01/2012 *****/

USE vs_martinez
GO

/****** Object:  Table [dbo].[emp_fusion_efectos_c]    Script Date: 01/17/2012 12:55:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[emp_fusion_efectos_c](
	[empresa] [dbo].[dm_empresas] NOT NULL,
	[numero] [dbo].[dm_numero_doc] NOT NULL,
	[fecha] [dbo].[dm_fechas_hora] NULL,
	[codigo_cliente] [dbo].[dm_codigos_n] NULL,
	[fecha_emision] [dbo].[dm_fechas_hora] NULL,
	[fecha_vto] [dbo].[dm_fechas_hora] NULL,
	[situacion] [dbo].[dm_char_muy_corto] NULL,
	[numero_efectos] [dbo].[dm_entero_corto] NULL,
	[importe] [dbo].[dm_importes] NULL,
	[fecha_fusion] [dbo].[dm_fechas_hora] NULL,
	[fecha_contabilizada] [dbo].[dm_fechas_hora] NULL,
	[observaciones] [dbo].[dm_memo] NULL,
	[adjuntos] [dbo].[dm_adjuntos] NULL,
	[sys_logs] [dbo].[dm_memo] NULL,
	[sys_borrado] [dbo].[dm_logico] NULL,
	[sys_timestamp] [dbo].[dm_fechas_hora] NULL,
	[sys_oid] [dbo].[dm_oid] IDENTITY(1,1) NOT NULL,
	[codigo_tercero] [dbo].[dm_codigos_n] NULL,
 CONSTRAINT [PK_emp_fusion_efectos_c] PRIMARY KEY CLUSTERED 
(
	[empresa] ASC,
	[numero] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[emp_fusion_efectos_c]  WITH NOCHECK ADD  CONSTRAINT [FK_emp_fusion_efectos_c_gen_empresas] FOREIGN KEY([empresa])
REFERENCES [dbo].[gen_empresas] ([codigo])
GO

ALTER TABLE [dbo].[emp_fusion_efectos_c] CHECK CONSTRAINT [FK_emp_fusion_efectos_c_gen_empresas]
GO

ALTER TABLE [dbo].[emp_fusion_efectos_c] ADD  CONSTRAINT [DF_emp_fusion_efectos_c_sys_timestamp]  DEFAULT (getdate()) FOR [sys_timestamp]
GO


CREATE TABLE [dbo].[emp_fusion_efectos_l](
	[empresa] [dbo].[dm_empresas] NOT NULL,
	[numero] [dbo].[dm_numero_doc] NOT NULL,
	[numero_efecto] [dbo].[dm_numero_doc] NOT NULL,
	[importe] [dbo].[dm_importes] NULL,
	[fecha_vto] [dbo].[dm_fechas_hora] NULL,
	[observaciones] [dbo].[dm_memo] NULL,
	[adjuntos] [dbo].[dm_adjuntos] NULL,
	[sys_logs] [dbo].[dm_memo] NULL,
	[sys_borrado] [dbo].[dm_logico] NULL,
	[sys_timestamp] [dbo].[dm_fechas_hora] NULL,
	[sys_oid] [dbo].[dm_oid] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_emp_fusion_efectos_l] PRIMARY KEY CLUSTERED 
(
	[empresa] ASC,
	[numero] ASC,
	[numero_efecto] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[emp_fusion_efectos_l]  WITH NOCHECK ADD  CONSTRAINT [FK_emp_fusion_efectos_l_emp_fusion_efectos_c] FOREIGN KEY([empresa], [numero])
REFERENCES [dbo].[emp_fusion_efectos_c] ([empresa], [numero])
ON DELETE CASCADE
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[emp_fusion_efectos_l] CHECK CONSTRAINT [FK_emp_fusion_efectos_l_emp_fusion_efectos_c]
GO

ALTER TABLE [dbo].[emp_fusion_efectos_l] ADD  CONSTRAINT [DF_emp_fusion_efectos_l_sys_timestamp]  DEFAULT (getdate()) FOR [sys_timestamp]
GO



