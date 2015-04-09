/*

archivo de datos destinos.txt 
============================================================================
1           ;CENTRO-MADRID-ES CARREFOUR                                                 
2           ;SUR-SUR -ES CARREFOUR                                                      
3           ;NORTE-NORTE -ES CARREFOUR                                                  
4           ;CATALUÑA-CATALUÑA- ES CARREFOUR                                            
5           ;LEVANTE-LEVANTE                                                            

archivo de formato destinos.fmt
============================================================================
<?xml version="1.0"?>
<BCPFORMAT 
xmlns="http://schemas.microsoft.com/sqlserver/2004/bulkload/format" 
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <RECORD>
    <FIELD ID="1" xsi:type="CharTerm" TERMINATOR=";" 
      MAX_LENGTH="13"/> 
    <FIELD ID="2" xsi:type="CharTerm" TERMINATOR="\r\n" 
      MAX_LENGTH="75" COLLATION="SQL_Latin1_General_CP1_CI_AS"/>
  </RECORD>
  <ROW>
    <COLUMN SOURCE="1" NAME="ID" xsi:type="SQLVARYCHAR"/>
    <COLUMN SOURCE="2" NAME="DESCRIPCION" xsi:type="SQLVARYCHAR"/>
  </ROW>
</BCPFORMAT>

*/

INSERT INTO emp_destinos (empresa, codigo, descripcion)
SELECT 'E_000001J', ID, descripcion
  FROM  OPENROWSET(BULK  'D:\desarrollo\VSPerello_fuente\DOCS\DESTINOS.TXT',
      FORMATFILE='D:\desarrollo\VSPerello_fuente\DOCS\DESTINOS.FMT'     
      ) as t1 
 WHERE NOT ID IN ('6','7','8','9')

