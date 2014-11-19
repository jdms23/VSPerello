USE [vsolution]
GO

/****** Object:  Table [dbo].[emp_cobro_docs_c]    Script Date: 02/09/2012 17:44:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[emp_cobro_docs_c](
	[empresa] [dbo].[dm_empresas] NOT NULL,
	[numero] [dbo].[dm_numero_doc] NOT NULL,
	[codigo_cliente] [dbo].[dm_codigos_n] NULL,
	[codigo_tercero] [dbo].[dm_codigos_n] NULL,	
	codigo_banco dm_codigos_c null,
	[fecha_cobro] [dbo].[dm_fechas_hora] NULL,
	[situacion] [dbo].[dm_char_muy_corto] NULL,
	[numero_docs] [dbo].[dm_entero_corto] NULL,
	[importe] [dbo].[dm_importes] NULL,
	[asiento_cobro] [dbo].dm_asiento null,
	[observaciones] [dbo].[dm_memo] NULL,
	[sys_logs] [dbo].[dm_memo] NULL,
	[sys_borrado] [dbo].[dm_logico] NULL,
	[sys_timestamp] [dbo].[dm_fechas_hora] NULL,
	[sys_oid] [dbo].[dm_oid] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_emp_cobro_docs_c] PRIMARY KEY CLUSTERED 
(
	[empresa] ASC,
	[numero] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[emp_cobro_docs_c]  WITH NOCHECK ADD  CONSTRAINT [FK_emp_cobro_docs_c_gen_empresas] FOREIGN KEY([empresa])
REFERENCES [dbo].[gen_empresas] ([codigo])
GO

ALTER TABLE [dbo].[emp_cobro_docs_c] CHECK CONSTRAINT [FK_emp_cobro_docs_c_gen_empresas]
GO

ALTER TABLE [dbo].[emp_cobro_docs_c] ADD  CONSTRAINT [DF_emp_cobro_docs_c_sys_timestamp]  DEFAULT (getdate()) FOR [sys_timestamp]
GO


CREATE TABLE [dbo].[emp_cobro_docs_l](
	[empresa] [dbo].[dm_empresas] NOT NULL,
	[numero] [dbo].[dm_numero_doc] NOT NULL,	
	empresa_doc dm_empresas NOT NULL,
	ejercicio_doc dm_ejercicios NOT NULL,
	codigo_tipo_documento dm_codigos_c NOT NULL,
	serie_doc dm_codigos_c NOT NULL,	
	[numero_doc] [dbo].[dm_numero_doc] NOT NULL,
	[importe] [dbo].[dm_importes] NULL,
	[observaciones] [dbo].[dm_memo] NULL,
	[adjuntos] [dbo].[dm_adjuntos] NULL,
	[sys_logs] [dbo].[dm_memo] NULL,
	[sys_borrado] [dbo].[dm_logico] NULL,
	[sys_timestamp] [dbo].[dm_fechas_hora] NULL,
	[sys_oid] [dbo].[dm_oid] IDENTITY(1,1) NOT NULL
 CONSTRAINT [PK_emp_cobro_docs_l] PRIMARY KEY CLUSTERED 
(
	[empresa] ASC,
	[numero] ASC,
	empresa_doc ASC,
	ejercicio_doc ASC,
	codigo_tipo_documento ASC,
	serie_doc ASC,	
	[numero_doc] ASC		
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[emp_cobro_docs_l]  WITH NOCHECK ADD  CONSTRAINT [FK_emp_cobro_docs_l_emp_cobro_docs_c] FOREIGN KEY([empresa], [numero])
REFERENCES [dbo].[emp_cobro_docs_c] ([empresa], [numero])
ON DELETE CASCADE
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[emp_cobro_docs_l] CHECK CONSTRAINT [FK_emp_cobro_docs_l_emp_cobro_docs_c]
GO

ALTER TABLE [dbo].[emp_cobro_docs_l] ADD  CONSTRAINT [DF_emp_cobro_docs_l_sys_timestamp]  DEFAULT (getdate()) FOR [sys_timestamp]
GO



