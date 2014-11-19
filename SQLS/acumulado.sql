CREATE TABLE #apuntes (importe_debe dm_importes, importe_haber dm_importes, saldo dm_importes, acum dm_importes) 

DECLARE @Acumulado dm_importes, @Debe dm_importes, @Haber dm_importes, @Saldo

INSERT INTO #apuntes 
	SELECT importe_debe, importe_haber, importe_debe - importe_haber, 0 
	  FROM eje_apuntes WHERE subcuenta = '7000000000'
	   
DECLARE rt_cursor CURSOR 
 FOR UPDATE
 SELECT importe_debe, importe_haber, saldo
   FROM @apuntes

 OPEN rt_cursor 

 FETCH NEXT FROM rt_cursor INTO @importe_debe, @importe_haber, @Saldo

 WHILE @@FETCH_STATUS = 0 
  BEGIN
   SET @Acumulado = @Acumulado + @Saldo 
   
   INSERT #Sales VALUES (@DayCount,@Sales,@RunningTotal) INSERTAR # valores de las ventas (@ DayCount, ventas @, @ TotalAcumulado) 
   FETCH NEXT FROM rt_cursor INTO @DayCount,@Sales FETCH NEXT DE rt_cursor INTO @ DayCount, ventas @ 
  END END 

 CLOSE rt_cursor Rt_cursor CERRAR 
 DEALLOCATE rt_cursor DEALLOCATE rt_cursor 

 SELECT * FROM #Sales ORDER BY DayCount SELECT * FROM # ORDEN ventas por DayCount 

 DROP TABLE #Sales DROP TABLE # Sales 