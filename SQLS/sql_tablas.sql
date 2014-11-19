SELECT pg_class.oid, pg_class.relname, relkind, pg_namespace.nspname 
  FROM PG_CLASS 
  inner join pg_namespace on pg_namespace.oid = pg_class.relnamespace
WHERE pg_namespace.nspname = 'public' 
  AND (relkind = 'r' or relkind = 'v');