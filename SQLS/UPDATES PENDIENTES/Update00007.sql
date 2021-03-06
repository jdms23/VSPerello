USE vs_martinez
GO
ALTER TRIGGER [dbo].[eje_clientes_cond_venta_cuentas_bi]
   ON  [dbo].[eje_clientes_cond_venta_cuentas]
   INSTEAD OF INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	 DECLARE @rellenar INT
	 DECLARE @subcuenta dm_subcuenta
	 DECLARE @subcuenta_efectos dm_subcuenta
	 DECLARE @subcuenta_riesgo dm_subcuenta
	 DECLARE @subcuenta_impagados dm_subcuenta
	 DECLARE @descripcion dm_char_largo
	 DECLARE @razon_social dm_char_largo
	 DECLARE @nif dm_char_largo
	 DECLARE @codigo_cliente dm_codigos_n
	 DECLARE @sys_oid dm_oid
	 DECLARE @empresa dm_empresas
	 DECLARE @ejercicio dm_ejercicios
	 DECLARE @pCodigo_tipo_cond_venta dm_codigos_c
	 
	 DECLARE Insertados CURSOR LOCAL FOR 
	 SELECT digitos_subcuentas,i.subcuenta,i.subcuenta_efectos,i.subcuenta_riesgo,emp_terceros.razon_social,emp_terceros.nif
		  ,I.codigo_cliente,I.sys_oid,i.empresa,i.ejercicio,I.Codigo_tipo_cond_venta
	 FROM emp_ejercicios AS E INNER JOIN inserted AS I ON E.empresa=I.empresa AND E.ejercicio=I.ejercicio
	 INNER JOIN emp_clientes
			ON I.empresa=emp_clientes.empresa AND i.codigo_cliente=emp_clientes.codigo
	 INNER JOIN emp_terceros 
			ON i.empresa=emp_terceros.empresa AND emp_clientes.codigo_tercero=emp_terceros.codigo
	 /*
	 SELECT @rellenar=digitos_subcuentas,@subcuenta=i.subcuenta,@subcuenta_efectos=i.subcuenta_efectos
		  ,@subcuenta_riesgo=i.subcuenta_riesgo,@razon_social=emp_terceros.razon_social,@nif=emp_terceros.nif
		  ,@codigo_cliente=I.codigo_cliente
	  FROM emp_ejercicios AS E INNER JOIN inserted AS I ON E.empresa=I.empresa AND E.ejercicio=I.ejercicio
	 INNER JOIN emp_clientes
			ON I.empresa=emp_clientes.empresa AND i.codigo_cliente=emp_clientes.codigo
	 INNER JOIN emp_terceros 
			ON i.empresa=emp_terceros.empresa AND emp_clientes.codigo_tercero=emp_terceros.codigo
	*/
	 OPEN Insertados
	 FETCH NEXT FROM Insertados INTO @rellenar,@subcuenta,@subcuenta_efectos,@subcuenta_riesgo,@razon_social,@nif
		  ,@codigo_cliente,@sys_oid,@empresa,@ejercicio,@pCodigo_tipo_cond_venta
		WHILE @@FETCH_STATUS = 0
		BEGIN  
			 IF @subcuenta IS NULL
			  BEGIN
				  SET @subcuenta='4300' + REPLICATE('0',  @rellenar-4-LEN(RTRIM(LTRIM(STR(@codigo_cliente))) ))++ RTRIM(LTRIM(STR(@codigo_cliente)))
				  INSERT INTO eje_cuentas ( empresa,ejercicio,descripcion,digitos,nif,codigo ) 
				  SELECT DISTINCT i.empresa,i.ejercicio,@razon_social,@rellenar,@nif,@subcuenta
				  FROM inserted AS i
				  WHERE (i.empresa=@empresa AND i.codigo_cliente=@codigo_cliente AND i.ejercicio=@ejercicio 
				  AND i.Codigo_tipo_cond_venta=@pCodigo_tipo_cond_venta ) AND	
				    ( SELECT COUNT(*) FROM eje_cuentas WHERE empresa=@empresa AND ejercicio=@ejercicio AND codigo=@subcuenta) = 0
			  END
			 IF @subcuenta_efectos IS NULL
			  BEGIN
				  SET @subcuenta_efectos='4310' + REPLICATE('0',  @rellenar-4-LEN(RTRIM(LTRIM(STR(@codigo_cliente))) ))++ RTRIM(LTRIM(STR(@codigo_cliente)))
				  INSERT INTO eje_cuentas ( empresa,ejercicio,descripcion,digitos,nif,codigo ) 
				  SELECT DISTINCT i.empresa,i.ejercicio,@razon_social,@rellenar,@nif,@subcuenta_efectos
				  FROM inserted AS i
				  WHERE (i.empresa=@empresa AND i.codigo_cliente=@codigo_cliente AND i.ejercicio=@ejercicio 
				  AND i.Codigo_tipo_cond_venta=@pCodigo_tipo_cond_venta ) AND				  
				    ( SELECT COUNT(*) FROM eje_cuentas WHERE empresa=@empresa AND ejercicio=@ejercicio AND codigo=@subcuenta_efectos ) = 0
			  END
			  /*
			 IF @subcuenta_riesgo IS NULL
			  BEGIN
				  SET @subcuenta_riesgo='4311' + REPLICATE('0',  @rellenar-4-LEN(RTRIM(LTRIM(STR(@codigo_cliente))) )) + RTRIM(LTRIM(STR(@codigo_cliente)))
				  INSERT INTO eje_cuentas ( empresa,ejercicio,descripcion,digitos,nif,codigo ) 
				  SELECT DISTINCT i.empresa,i.ejercicio,@razon_social,@rellenar,@nif,@subcuenta_riesgo
				  FROM inserted AS i 
				   WHERE ( SELECT COUNT(*) FROM eje_cuentas WHERE empresa=i.empresa AND ejercicio=i.ejercicio AND codigo=@subcuenta_riesgo) = 0
			  END
		*/
			 IF @subcuenta_impagados IS NULL
			  BEGIN
				  SET @subcuenta_impagados='4315' + REPLICATE('0',  @rellenar-4-LEN(RTRIM(LTRIM(STR(@codigo_cliente))) )) + RTRIM(LTRIM(STR(@codigo_cliente)))
				  INSERT INTO eje_cuentas ( empresa,ejercicio,descripcion,digitos,nif,codigo ) 
				  SELECT DISTINCT i.empresa,i.ejercicio,@razon_social,@rellenar,@nif,@subcuenta_impagados
				  FROM inserted AS i
				  WHERE (i.empresa=@empresa AND i.codigo_cliente=@codigo_cliente AND i.ejercicio=@ejercicio 
				  AND i.Codigo_tipo_cond_venta=@pCodigo_tipo_cond_venta ) AND		
				  ( SELECT COUNT(*) FROM eje_cuentas WHERE empresa=@empresa AND ejercicio=@ejercicio AND codigo=@subcuenta_impagados) = 0
			  END
	  
	  INSERT INTO eje_clientes_cond_venta_cuentas (empresa,ejercicio,codigo_cliente,codigo_tipo_cond_venta,subcuenta,
	  subcuenta_efectos,subcuenta_riesgo,subcuenta_impagados)
	  SELECT empresa,ejercicio,codigo_cliente,codigo_tipo_cond_venta,@subcuenta,@subcuenta_efectos,@subcuenta_riesgo,@subcuenta_impagados
	   FROM inserted AS i
		  WHERE (i.empresa=@empresa AND i.codigo_cliente=@codigo_cliente AND i.ejercicio=@ejercicio 
		  AND i.Codigo_tipo_cond_venta=@pCodigo_tipo_cond_venta )
	 FETCH NEXT FROM Insertados INTO @rellenar,@subcuenta,@subcuenta_efectos,@subcuenta_riesgo,@razon_social,@nif
		  ,@codigo_cliente,@sys_oid,@empresa,@ejercicio,@pCodigo_tipo_cond_venta
	END
	CLOSE Insertados
	DEALLOCATE Insertados
END