use vs_martinez
go
alter table emp_articulos_grupos add subir_web dm_logico null default (1)

go
update emp_articulos_grupos set subir_web = 1
go
ALTER TABLE emp_familias DROP CONSTRAINT  [DF_emp_familias_subir_web]
go
ALTER TABLE [dbo].[emp_familias] ADD  CONSTRAINT [DF_emp_familias_subir_web]  DEFAULT ((1)) FOR [subir_web]
GO
update [emp_familias] set subir_web = 1
go
UPDATE emp_clientes set subir_web=1
go