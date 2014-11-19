oForm = createobject('myForm')
oForm.Show
Read events

Define CLASS myform AS form
  Top = 0
  Left = 0
  Height = 450
  Width = 750
  DoCreate = .T.
  Caption = "Form1"
  Name = "Form1"

  Add OBJECT command1 as commandbutton with ;
    Autosize = .t., ;
    Top = 0, ;
    Left = 0, ;
    Name = "Set1", ;
    Caption = 'Sample 1'

  Add OBJECT command2 as commandbutton with ;
    Autosize = .t., ;
    Top = 0, ;
    Left = 0, ;
    Name = "Set2", ;
    Caption = 'Sample 2'

  Add OBJECT command3 as commandbutton with ;
    Autosize = .t., ;
    Top = 0, ;
    Left = 0, ;
    Name = "Set3", ;
    Caption = 'Sample 3'

  Add OBJECT command4 as commandbutton with ;
    Autosize = .t., ;
    Top = 0, ;
    Left = 0, ;
    Name = "Set4", ;
    Caption = 'Sample 4'

  Add OBJECT hflex AS olecontrol WITH ;
    Top = 0, ;
    Left = 0, ;
    Height = 420, ;
    Width = 750, ;
    Name = "Hflex", ;
    OleClass = 'MSHierarchicalFlexGridLib.MSHFlexGrid'

  Procedure LoadSet
    Lparameters tnSet
    Local oRecordset,oConnection, strCn, strShp

    strCn =	"FILEDSN=" + GETFILE("DSN") &&&./VSolution.dsn"


    oRecordset = CreateObject("adodb.recordset")
    oConnection = CreateObject("adodb.connection")

    With oConnection
    	.Provider = "MSDataShape"
    	.ConnectionString = strCn
    	.Open
  	Endwith

  Do case
    Case tnSet = 1
      strShp = [SHAPE {SELECT empresa, codigo,  descripcion FROM emp_almacenes } ]+;
        [ APPEND ({SELECT empresa, codigo_almacen, codigo_articulo, stock_minimo, stock_maximo FROM emp_almacenes_articulos_stock } ]+;
        [  RELATE empresa TO empresa, codigo TO codigo_almacen) ]

    Case tnSet = 2
      strShp = [SHAPE {SELECT codigo, nombre FROM vf_emp_clientes WHERE EXISTS (SELECT * FROM vv_venta_c_alba WHERE codigo_cliente = vf_emp_clientes.codigo)} ]+;
        [ APPEND ({SELECT numero, fecha, codigo_cliente FROM vv_venta_c_alba} ]+;
        [  RELATE codigo TO codigo_cliente) ]

    Case tnSet = 3

      strShp = [ SHAPE  {SELECT cust_id, company FROM customer} ]+;
        [APPEND ({SELECT cust_id, order_id, order_date, order_net ]+;
        [         FROM orders ]+;
        [         WHERE order_date < {1/1/1996} AND cust_id = ?} ]+;
        [         RELATE cust_id TO PARAMETER 0) AS rsOldOrders, ]+;
        [       ({SELECT cust_id, order_id, order_date, order_net ]+;
        [         FROM orders ]+;
        [         WHERE order_date >= {1/1/1996}} ]+;
        [         RELATE cust_id TO cust_id) AS rsRecentOrders ]

    Case tnSet = 4
      strShp = [  SHAPE ]+;
        [(SHAPE {]+lcSel1+[ } as rs1 ]+;
        [	APPEND  ({]+lcSel2+[ } AS rsDetails RELATE order_id TO order_id),  ]+;
        [ SUM(rsDetails.ExtendedPrice) AS OrderTotal, ANY(rsDetails.order_id)) AS rsOrders ]+;
        [COMPUTE  rsOrders, ]+;
        [SUM(rsOrders.OrderTotal) AS CustTotal, ]+;
        [ANY(rsOrders.Company) AS Cmpny	]+;
        [   BY cust_id ]

  Endcase
  With oRecordset
    .ActiveConnection = oConnection
    .Source = strShp
    .Open
  Endwith

  With this.hflex
    .Datasource = oRecordset
    .Mergecells = 3
    .GridColorBand(1) = rgb(255,0,0)
    .GridColorBand(2) = rgb(0,0,255)
    .GridColorBand(3) = rgb(0,255,0)
    .ColWidth(0,0) = 300
    .ColWIdth(1,0) = 600
    .CollapseAll
  Endwith
Endproc

  Procedure Init
    With this
      .Set2.Left = .Set1.Left + .Set1.Width + 5
      .Set3.Left = .Set2.Left + .Set2.Width + 5
      .Set4.Left = .Set3.Left + .Set3.Width + 5
      .hflex.Top = .Set1.Top + .Set1.Height + 5
      .hflex.Height = .Height - (.hflex.Top + 5)
      .hflex.Left = 5
      .hflex.Width = .Width - 10
      .LoadSet(1)
    Endwith
  Endproc

  Procedure QueryUnLoad
    Clear events
  Endproc

  Procedure Set1.Click
    Thisform.LoadSet(1)
  ENDPROC
  
  Procedure Set2.Click
    Thisform.LoadSet(2)
  Endproc
  
  Procedure Set3.Click
    Thisform.LoadSet(3)
  Endproc
  
  Procedure Set4.Click
    Thisform.LoadSet(4)
  ENDPROC
  
Enddefine