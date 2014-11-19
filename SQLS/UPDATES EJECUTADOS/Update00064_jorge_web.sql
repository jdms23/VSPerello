USE [vs_martinez] 
GO

/****** Object:  Table [dbo].[web_tabla_borrados]    Script Date: 02/01/2012 12:40:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[web_tabla_borrados](
	[sys_oid] [dbo].[dm_oid] NOT NULL,
	[sys_oid_borrado] [dbo].[dm_oid] NULL,
	[nombre_tabla] [dbo].[dm_char_corto] NULL,
 CONSTRAINT [PK_web_tabla_borrados] PRIMARY KEY CLUSTERED 
(
	[sys_oid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


