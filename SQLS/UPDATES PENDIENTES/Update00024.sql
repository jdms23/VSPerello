USE vs_martinez
GO
ALTER TRIGGER [dbo].[vv_precios_proveedores_bi]
   ON  [dbo].[vv_precios_proveedores]
   INSTEAD OF INSERT
AS 
BEGIN
	SET NOCOUNT ON
	DECLARE @pCodigo dm_char_corto
	DECLARE @pEmpresa dm_empresas
	DECLARE @pSysOid dm_oid
	DECLARE @pCodigoOld dm_codigos_n
	
	DECLARE insertados CURSOR LOCAL FOR SELECT empresa,sys_oid,codigo,codigo FROM inserted
	OPEN insertados
	FETCH NEXT FROM insertados INTO @pEmpresa,@pSysOid,@pcodigo,@pCodigoOld
	WHILE @@FETCH_STATUS = 0
	BEGIN
	--SET @pEmpresa = (SELECT empresa FROM inserted)
	SET @pCodigo = NULL
	EXEC vs_proximo_numero_serie @pEmpresa, '', '', 'PRECIOSPRO', null, 1, @pCodigo OUTPUT
	INSERT INTO emp_precios_proveedores ( [empresa],[codigo],[tipo],[codigo_proveedor],[codigo_articulo],[codigo_familia],
		[precio],[dto1],[dto2],dto3,dto4,[precio_neto],unidades_embalaje,[desde_unidades],[hasta_unidades],[su_referencia],predeterminado,
		nombre_tarifa,desde_fecha,hasta_fecha)
		 SELECT [empresa],CONVERT(int,@pCodigo),[tipo],[codigo_proveedor],[codigo_articulo],[codigo_familia],
		[precio],[dto1],[dto2],dto3,dto4,[precio_neto],unidades_embalaje,[desde_unidades],[hasta_unidades],[su_referencia],predeterminado,
		nombre_tarifa,desde_fecha,hasta_fecha
		 FROM inserted WHERE empresa=@pEmpresa AND ISNULL(codigo,0) = CASE WHEN ISNULL(@pCodigoOld,0) = 0 THEN 0 ELSE @pCodigoOld END
	FETCH NEXT FROM insertados INTO @pEmpresa,@pSysOid,@pcodigo,@pCodigoOld
	END
	CLOSE insertados
	DEALLOCATE insertados
END