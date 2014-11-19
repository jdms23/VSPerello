USE vs_martinez
GO 

/*
UPDATE ppal SET contrapartida = sctaprov.subcuenta
  FROM eje_apuntes as ppal
	INNER JOIN eje_apuntes as sctaprov on ppal.empresa = sctaprov.empresa
		and ppal.ejercicio = sctaprov.ejercicio
		and ppal.diario = sctaprov.diario
		and ppal.asiento = sctaprov.asiento
		and LEFT(sctaprov.subcuenta,3) in ('400','410','572','520')
 WHERE left(ppal.subcuenta,3) = '472' and ppal.contrapartida is null

SELECT ppal.*, sctaprov.subcuenta, eje_cuentas.nif, eje_cuentas.descripcion
  FROM eje_apuntes as ppal
	INNER JOIN eje_apuntes as sctaprov on ppal.empresa = sctaprov.empresa
		and ppal.ejercicio = sctaprov.ejercicio
		and ppal.diario = sctaprov.diario
		and ppal.asiento = sctaprov.asiento
		and LEFT(sctaprov.subcuenta,3) in ('400','410','572','520')
	INNER JOIN eje_cuentas ON eje_cuentas.empresa = sctaprov.empresa
		and eje_cuentas.ejercicio = sctaprov.ejercicio
		and eje_cuentas.codigo = sctaprov.subcuenta
 WHERE left(ppal.subcuenta,3) = '472' and ppal.contrapartida is null
update eje_apuntes set nif = vf_emp_proveedores.nif,
	razon_social = vf_emp_proveedores.razon_social

 */

DECLARE @sys_oid dm_oid
declare @contrapartida dm_subcuenta
declare @razon_social dm_nombres
declare @nif dm_nif

DECLARE crs cursor local for
	SELECT sys_oid, contrapartida
	  FROM eje_apuntes 
	 WHERE LEFT(subcuenta, 3) = '472' and isnull(nif, '') = ''
	 
OPEN crs
FETCH NEXT FROM crs INTO @sys_oid, @contrapartida
WHILE @@FETCH_STATUS = 0
BEGIN 
  SELECT @razon_social=razon_social, @nif=nif 
    FROM vf_emp_proveedores
   WHERE exists (select * from eje_proveedores_cond_compra_cuentas where eje_proveedores_cond_compra_cuentas.empresa = vf_emp_proveedores.empresa
					and eje_proveedores_cond_compra_cuentas.codigo_proveedor = vf_emp_proveedores.codigo
					and eje_proveedores_cond_compra_cuentas.subcuenta = @contrapartida)
  IF @@ROWCOUNT > 0 
	UPDATE eje_apuntes set razon_social = @razon_social, nif = @nif
	 where sys_oid = @sys_oid
  ELSE
	PRINT 'NO ENCUENTRO  ' + @CONTRAPARTIDA
  FETCH NEXT FROM crs INTO @sys_oid, @contrapartida
END
close crs
deallocate crs
