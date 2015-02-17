/* Hay que ejecutar cada consulta de forma separada. Paso a Paso */

/*1. Añado un UDDT temporal con la nueva definición */ 
exec sp_addtype 'dm_cambios_divisas_perello', 'numeric(14,6)', NULL 

/*2. Construyo los comando de ALTER TABLE para cambiar el tipo de datos a todas las tablas - 
     Corta y pega el resultado y ejecutalo en una consulta */
select 'alter table dbo.' + TABLE_NAME + 
       ' alter column ' + COLUMN_NAME + ' dm_cambios_divisas_perello' 
from INFORMATION_SCHEMA.COLUMNS 
	INNER JOIN sys.objects ON sys.objects.object_id = OBJECT_ID(INFORMATION_SCHEMA.COLUMNS.TABLE_NAME)
where DOMAIN_NAME = 'dm_cambios_divisas' 
  and type = 'U'  
/*3.  Volver a crear las vistas en las que está involucrado */
select TABLE_NAME, COLUMN_NAME, DOMAIN_NAME
from INFORMATION_SCHEMA.COLUMNS 
	INNER JOIN sys.objects ON sys.objects.object_id = OBJECT_ID(INFORMATION_SCHEMA.COLUMNS.TABLE_NAME)
where DOMAIN_NAME = 'dm_cambios_divisas' 
  and type = 'V'
ORDER BY TABLE_NAME    

/*4. Borra el Antiguo UDDT */ 
exec sp_droptype 'dm_cambios_divisas'

/*5. Renombra el temporal para que se llame igual. */ 
exec sp_rename 'dm_cambios_divisas_perello', 'dm_cambios_divisas', 'USERDATATYPE'

/***Localizar tablas y vistas que utilizan el tipo de datos***/
/*
select sys.objects.object_id, sys.objects.type, INFORMATION_SCHEMA.COLUMNS.*
from INFORMATION_SCHEMA.COLUMNS 
	INNER JOIN sys.objects ON sys.objects.object_id = OBJECT_ID(INFORMATION_SCHEMA.COLUMNS.TABLE_NAME)
where DOMAIN_NAME = 'dm_cambios_divisas' 
  and type IN ('U','V')
ORDER BY TABLE_NAME   
*/
