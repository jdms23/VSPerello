------------
-- GRAND TOTAL (all times), TOTAL (year), SUBTOTAL (month) mssql select query 
------------
-- Microsoft T-SQL derived table rpt generates the report - select from select 
-- The outer query does the final filtering and sorting
USE AdventureWorks;
SELECT * 
FROM
(
  SELECT YY=COALESCE(CONVERT(varchar,YEAR(OrderDate)),''), 
         MM=COALESCE(LEFT(CONVERT(varchar,OrderDate,111),7),''), 
              ORDERS = COUNT(*), 
              SALES = '$'+CONVERT(varchar,SUM(TotalDue),1),
          GRPMM = CASE WHEN
 GROUPING(LEFT(CONVERT(varchar,OrderDate,111),7)) = 0 
                       AND  GROUPING(YEAR(OrderDate)) = 1
                          THEN 'SUBTOTAL' ELSE '' END,  
          GRPYY= CASE WHEN GROUPING(YEAR(OrderDate)) = 0
AND  GROUPING(LEFT(CONVERT(varchar,OrderDate,111),7)) = 1 
                         THEN 'TOTAL' ELSE '' END, 
          GRPALL = CASE WHEN 
                   GROUPING(LEFT(CONVERT(varchar,OrderDate,111),7)) = 1
                        AND GROUPING(YEAR(OrderDate)) = 1 
                                  THEN 'GRAND TOTAL' ELSE '' END
  FROM Sales.SalesOrderHeader
  GROUP BY YEAR(OrderDate), LEFT(CONVERT(varchar,OrderDate,111),7) 
WITH CUBE
) 
rpt
WHERE 
       GRPMM != '' OR GRPYY !='' OR GRPALL !=''
ORDER BY 
            CASE WHEN GRPALL!= '' THEN 3
                 WHEN GRPYY != '' THEN 2
            ELSE 1 END, 
            YY, MM
GO

/* Partial results

YY    MM          ORDERS      SALES             GRPMM       GRPYY GRPALL
      2004/04     2127        $4,268,473.54     SUBTOTAL          
      2004/05     2386        $5,813,557.45     SUBTOTAL          
      2004/06     2374        $6,004,155.77     SUBTOTAL          
      2004/07     976         $56,178.92        SUBTOTAL          
2001              1379        $12,693,250.63                TOTAL 
2002              3692        $34,463,848.44                TOTAL 
2003              12443       $47,171,489.55                TOTAL 
2004              13950       $28,887,306.04                TOTAL 
                  31464       $123,215,894.65                     GRAND TOTAL
*/

------------
