USE [vs_martinez]
GO
/****** Object:  Trigger [dbo].[eje_proveedores_cond_compra_cuentas_bi]    Script Date: 02/17/2012 13:13:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[eje_proveedores_cond_compra_cuentas_bi]
   ON  [dbo].[eje_proveedores_cond_compra_cuentas]
WITH ENCRYPTION  INSTEAD OF INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	 DECLARE @rellenar INT
	 DECLARE @subcuenta dm_subcuenta
	 DECLARE @subcuenta_efectos dm_subcuenta
	 DECLARE @subcuenta_compras dm_subcuenta
	 DECLARE @razon_social dm_char_largo
	 DECLARE @nif dm_char_largo
	 DECLARE @codigo_proveedor dm_codigos_n
	 DECLARE @acreedor dm_logico
	 DECLARE @numero_ceros int
	 DECLARE @ERROR VARCHAR(4000)
	 DECLARE @sys_oid dm_oid
	 DECLARE @empresa dm_empresas
	 DECLARE @ejercicio dm_ejercicios
	 DECLARE @pCodigo_tipo_cond_compra dm_codigos_c
	 DECLARE @cNumero dm_char_corto	 
	 
	 DECLARE Insertados CURSOR LOCAL FOR 
	 SELECT E.digitos_subcuentas,i.subcuenta,i.subcuenta_efectos,i.subcuenta_compras,emp_terceros.razon_social,emp_terceros.nif
		  ,I.codigo_proveedor,emp_proveedores.acreedor,I.sys_oid,I.empresa,I.ejercicio,I.Codigo_tipo_cond_compra
		  FROM emp_ejercicios AS E 
			INNER JOIN inserted AS I ON E.empresa=I.empresa AND E.ejercicio=I.ejercicio
			INNER JOIN emp_proveedores	ON I.empresa=emp_proveedores.empresa AND i.codigo_proveedor=emp_proveedores.codigo
			INNER JOIN emp_terceros ON i.empresa=emp_terceros.empresa AND emp_proveedores.codigo_tercero=emp_terceros.codigo
	OPEN Insertados
	FETCH NEXT FROM Insertados INTO @rellenar,@subcuenta,@subcuenta_efectos,@subcuenta_compras,@razon_social,@nif
		  ,@codigo_proveedor,@acreedor,@sys_oid,@empresa,@ejercicio,@pCodigo_tipo_cond_compra
	WHILE @@FETCH_STATUS = 0
	BEGIN  		  

		 set @cNumero = RIGHT(RTRIM(LTRIM(STR(@codigo_proveedor))),5)
		 set @numero_ceros = @rellenar-4-LEN(@cNumero)
		 		
		 IF ISNULL(@subcuenta,'') = '' AND @numero_ceros >=0 AND @cNumero <> ''
		  BEGIN
			  SET @subcuenta= CASE @acreedor
									 WHEN 1 THEN '4100'
									 ELSE '4000'
							  END
			  + REPLICATE('0', @numero_ceros)+@cNumero
			  
			  IF NOT EXISTS(SELECT codigo FROM eje_cuentas WHERE empresa=@empresa AND ejercicio=@ejercicio AND codigo=@subcuenta)			  
				  INSERT INTO eje_cuentas (empresa,ejercicio,descripcion,digitos,nif,codigo) 
					VALUES(@empresa, @ejercicio, @razon_social, @rellenar, @nif, @subcuenta)
		  END
		 IF isnull(@subcuenta_efectos,'') = '' AND @numero_ceros >=0 AND @cNumero <> ''
		  BEGIN
			  SET @subcuenta_efectos= CASE @acreedor
											   WHEN 1 THEN '4110'
											   ELSE '4010'
											  END
			  + REPLICATE('0', @numero_ceros)+ @cNumero
			  
			  IF NOT EXISTS(SELECT codigo FROM eje_cuentas WHERE empresa=@empresa AND ejercicio=@ejercicio AND codigo=@subcuenta_efectos)			  
				  INSERT INTO eje_cuentas (empresa,ejercicio,descripcion,digitos,nif,codigo) 
					VALUES(@empresa, @ejercicio, @razon_social, @rellenar, @nif, @subcuenta_efectos)
		  END
		  
		  INSERT INTO eje_proveedores_cond_compra_cuentas (empresa,ejercicio,codigo_proveedor,codigo_tipo_cond_compra,subcuenta,subcuenta_efectos,subcuenta_compras)
			VALUES (@empresa, @ejercicio, @codigo_proveedor, @pCodigo_tipo_cond_compra, @subcuenta, @subcuenta_efectos, @subcuenta_compras)
			
		FETCH NEXT FROM Insertados INTO @rellenar,@subcuenta,@subcuenta_efectos,@subcuenta_compras,@razon_social,@nif
			  ,@codigo_proveedor,@acreedor,@sys_oid,@empresa,@ejercicio,@pCodigo_tipo_cond_compra	   
	END	   
	CLOSE Insertados
	DEALLOCATE Insertados
END