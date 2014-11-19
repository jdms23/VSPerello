*!*	SELECT c.oid, n.nspname, c.relname, n2.nspname, c2.relname, cons.conname
*!*	FROM pg_class c 
*!*	 JOIN pg_namespace n ON n.oid = c.relnamespace
*!*	 LEFT OUTER JOIN pg_constraint cons ON cons.conrelid = c.oid
*!*	 LEFT OUTER JOIN pg_class c2 ON cons.confrelid = c2.oid
*!*	 LEFT OUTER JOIN pg_namespace n2 ON n2.oid = c2.relnamespace
*!*	WHERE c.relkind = 'r' 
*!*	 AND n.nspname IN ('public') -- any other schemas in here
*!*	 AND (cons.contype = 'f' OR cons.contype IS NULL);