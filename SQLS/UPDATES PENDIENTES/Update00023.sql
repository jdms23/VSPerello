USE vs_martinez
GO
ALTER TRIGGER [dbo].[vv_precios_clientes_bi]
   ON  [dbo].[vv_precios_clientes]
   INSTEAD OF INSERT
AS 
BEGIN
	SET NOCOUNT OFF;
	DECLARE @pCodigo dm_char_corto
	DECLARE @pEmpresa dm_empresas
	DECLARE @pSysOid dm_oid
	DECLARE @pCodigoOld dm_oid
	DECLARE insertados CURSOR LOCAL FOR SELECT empresa,sys_oid,codigo,codigo FROM inserted
	OPEN insertados
	FETCH NEXT FROM insertados INTO @pEmpresa,@pSysOid,@pcodigo,@pCodigoOld
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
	IF @pCodigo IS NULL EXEC vs_proximo_numero_serie @pEmpresa, '', '', 'PRECIOSCLI', null, 1, @pCodigo OUTPUT
	INSERT INTO emp_precios_clientes ( [empresa],[codigo],[tipo],[codigo_grupo],[codigo_cliente],[codigo_articulo],[codigo_familia],/*[codigo_tarifa],*/
		[precio],[dto1],[dto2],[precio_neto],[desde_unidades],[hasta_unidades] )
		 --SELECT [empresa],ISNULL([codigo],CONVERT(int,@pCodigo)),[tipo],[codigo_grupo],[codigo_cliente],[codigo_articulo],[codigo_familia],
		 SELECT [empresa],CONVERT(int,@pCodigo),[tipo],[codigo_grupo],[codigo_cliente],[codigo_articulo],[codigo_familia],/*[codigo_tarifa],*/
		[precio],[dto1],[dto2],[precio_neto],[desde_unidades],[hasta_unidades] 
		FROM inserted WHERE empresa=@pEmpresa AND ISNULL(codigo,0) = CASE WHEN ISNULL(@pCodigoOld,0) = 0 THEN 0 ELSE @pCodigoOld END
	FETCH NEXT FROM insertados INTO @pEmpresa,@pSysOid,@pcodigo,@pCodigoOld
	END
	CLOSE insertados
	DEALLOCATE insertados
END
