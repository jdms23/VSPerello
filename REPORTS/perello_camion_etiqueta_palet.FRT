   �   @                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ORIENTATION=1
PAPERSIZE=9
COLOR=2
                         Arial                                                         sys_oid                                                       oApp.oEmpresa.logo_empresa                                    7"COOPERATIVA VALENCIANAUNI�N PROTECTORA DEEL PERELL�"       "@I"                                                          Arial                                                         "Palet Picking"                                               Arial                                                         DATE()                                                        "@YL"                                                         Arial                                                         "FECHA ORDEN:"                                                Arial                                                         TTOD(FECHA)                                                   "@D"                                                          Arial                                                         
"N� PALET"                                                    Arial                                                         NUMERO_PALET                                                  "999"                                                         Arial                                                         	"CLIENTE"                                                     Arial                                                         NOMBRE_CLIENTE                                                Arial                                                         CODIGO_CLIENTE                                                "99999"                                                       Arial                                                         
"N� Cajas"                                                    Arial                                                         "Caja"                                                        Arial                                                         
"Kgs/Caja"                                                    Arial                                                         "Total"                                                       Arial                                                         
"Variedad"                                                    Arial                                                         	"Destino"                                                     Arial                                                         NUMERO_CAJAS                                                  "999"                                                         Arial                                                         DESCRIPCION_TIPO_CAJA                                         Arial                                                         KILOS_ENVASE                                                  "999.99"                                                      Arial                                                         KILOS_ENVASE * NUMERO_CAJAS                                   "999.99"                                                      Arial                                                         DESCRIPCION_ARTICULO                                          Arial                                                         DESCRIPCION_DESTINO                                           Arial                                                         NUMERO_CAJAS                                                  "999"                                                         Arial                                                         "TOTAL BULTOS"                                                Arial                                                         '"TODOS LOS PRODUCTOS SON ORIGEN ESPA�A"                       Arial                                                         "EMPRESA LOGISTICA"                                           Arial                                                         DESCRIPCION_AGENCIA                                           Arial                                                         �_screen.oBarCode.BarcodeImage( "(00)" + ALLTRIM(sscc), ,[lAddCheckDigit = .F.,nBarcodeType = 159, nFactor = 3, nImageHeight = 150, nRatio = 4])                                               	"CAMION:"                                                     Arial                                                         *NVL(TRANSFORM(CODIGO_CAMION), "SIN ENVIO")                    Arial                                                         Arial                                                         Arial                                                         Arial                                                         Arial                                                         Arial                                                         Arial                                                         Arial                                                         Arial                                                         Arial                                                         Arial                                                         Arial                                                         dataenvironment                                               }Top = 81
Left = 38
Width = 733
Height = 478
Visible = .F.
TabStop = .F.
DataSource = .NULL.
Name = "Dataenvironment"
                                                                /PROCEDURE BeforeOpenTables
LOCAL lcAlias, lcSSCC, lcSQL

lcAlias = ALIAS()

SCAN 
	IF EMPTY(NVL(sscc,"")) THEN 	
		&&Hay que volverlo a recoger por las dos pasadas...			
		TEXT TO lcSQL TEXTMERGE NOSHOW 
			SELECT sscc
			  FROM eje_montaje_palets 
			 WHERE sys_oid = <<sys_oid>>
		ENDTEXT 
		
		lcSSCC = oApp.SBD.Dame_Valor(lcSQL) 
		IF EMPTY(NVL(lcSSCC, "")) THEN 	
			lcSSCC = oApp.proximo_numero_serie("", "", "SSCC", .F., .T.)	
			lcSSCC = oApp.ean_dc(Alltrim(lcSSCC))
			
			replace sscc WITH lcSSCC 
			
			TEXT TO lcSQL TEXTMERGE NOSHOW 
				UPDATE eje_montaje_palets SET sscc = '<<lcSSCC>>', 
					impreso = 1
				 WHERE sys_oid = <<sys_oid>>
			ENDTEXT 	
		ELSE 
			TEXT TO lcSQL TEXTMERGE NOSHOW 
				UPDATE eje_montaje_palets SET impreso = 1
				 WHERE sys_oid = <<sys_oid>>
			ENDTEXT 	
		ENDIF 
	ELSE 
		TEXT TO lcSQL TEXTMERGE NOSHOW 
			UPDATE eje_montaje_palets SET impreso = 1
			 WHERE sys_oid = <<sys_oid>>
		ENDTEXT 	
	ENDIF 
	
	oApp.SBD.ExecSelect(lcSQL)	
	
ENDSCAN 

SELECT(lcAlias)
GO TOP 

ENDPROC
              ����    �  �                        q   %   4      �  %   N          �  U  � ��  � � � T�  �C�� ~��� %�CC� �  ҡ��
�
 M(� `�� � 			SELECT sscc�# � 			  FROM eje_montaje_palets �% � 			 WHERE sys_oid = <<sys_oid>>� � T� �C � � � � �� %�CC� �  ҡ����  T� �C�  �  � SSCC-a� � �� T� �CC� �� � �� >� ��� ��
 M(� `��= �7 				UPDATE eje_montaje_palets SET sscc = '<<lcSSCC>>', � � 					impreso = 1�& �  				 WHERE sys_oid = <<sys_oid>>� � ��
 M(� `��3 �- 				UPDATE eje_montaje_palets SET impreso = 1�& �  				 WHERE sys_oid = <<sys_oid>>� � � �w�
 M(� `��2 �, 			UPDATE eje_montaje_palets SET impreso = 1�% � 			 WHERE sys_oid = <<sys_oid>>� � � ��C � � � �	 �� �
 F��  �� #)� U
  LCALIAS LCSSCC LCSQL SSCC OAPP SBD
 DAME_VALOR PROXIMO_NUMERO_SERIE EAN_DC
 EXECSELECT BeforeOpenTables,     ��1 � � � A� A1QA �Aa� � �aaA � � 1aA A � � !QA A BB � Q 2                       $      )   �                           �9 �NU�NU<��;     	   2     L9 �7    	  