oApp = CREATEOBJECT("aplicacion")
lo = oApp.SBD.add_cursor("", "vf_articulos")
lo.lista_campos_clave = "sys_oid"
lo.actualizable = .T.
lo.Rellenar_cursor()
lo.Select()
BROWSE



