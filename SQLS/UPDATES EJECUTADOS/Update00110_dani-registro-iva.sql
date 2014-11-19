use vs_alcaraz
go 

alter table tmp_apuntes_traspaso drop column numero_factura_iva
go 

ALTER TABLE tmp_apuntes_traspaso add numero_documento_iva dm_char_corto
go 


