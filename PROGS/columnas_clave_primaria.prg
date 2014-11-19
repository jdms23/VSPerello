lcTabla = "sys_menus_gen"

TEXT TO lcSQL TEXTMERGE NOSHOW 
	SELECT               
	  pg_attribute.attname as colname, 
	  format_type(pg_attribute.atttypid, pg_attribute.atttypmod) as coltype
	FROM pg_index, pg_class, pg_attribute 
	WHERE 
	  pg_class.oid = '<<lcTabla>>'::regclass AND
	  indrelid = pg_class.oid AND
	  pg_attribute.attrelid = pg_class.oid AND 
	  pg_attribute.attnum = any(pg_index.indkey)
	  AND indisprimary
ENDTEXT 

_CLIPTEXT = LCSQL




