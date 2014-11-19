use vs_martinez
GO 

ALTER TABLE pda_pedido_c ADD generado dm_logico DEFAULT 0
GO 

ALTER TABLE dbo.pda_pedido_c ADD CONSTRAINT
	DF_pda_pedido_c_sys_timestamp DEFAULT getdate() FOR sys_timestamp
GO

UPDATE pda_pedido_c set generado = 1 

