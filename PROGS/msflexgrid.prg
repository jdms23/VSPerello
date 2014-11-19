TESTDATALOC =HOME(2)+"Data\testdata.DBC"

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

    strCn =	[Provider=MSDataShape.1;Persist Security Info=False;]+;
      [Data Source="Data Provider = MSDASQL;]+;
      [DSN=Visual FoxPro Database;UID=;SourceDB=]+TESTDATALOC+[;]+;
      [SourceType=DBC;Exclusive=No;BackgroundFetch=Yes;Collate=Machine;Null=Yes;]+;
      [Deleted=Yes;";Data Provider=MSDASQL ]


    oRecordset = CreateObject("adodb.recordset")
    oConnection = CreateObject("adodb.connection")

    With oConnection
    .Provider = "MSDataShape"
    .ConnectionString = strCn
    .Open
  Endwith

  lcSel1 = [ select customer.cust_id, ]+;
    [   customer.Company,]+;
    [   orders.order_id,]+;
    [   orders.Order_date ]+;
    [ from customer ]+;
    [  inner join orders on customer.cust_id = orders.cust_id ]


  lcSel2 = [ select od.order_id, od.line_no, ]+;
    [   products.prod_name, ]+;
    [   products.no_in_unit as 'Packaging', ]+;
    [   od.unit_price, ]+;
    [   od.Quantity, ]+;
    [   od.unit_price * od.quantity as ExtendedPrice ]+;
    [ from orditems as od ]+;
    [  inner join products on od.product_id = products.product_id ]

  Do case
    Case tnSet = 1
      strShp = [SHAPE TABLE customer ]+;
        [  APPEND ( (SHAPE TABLE orders   ]+;
        [    APPEND (TABLE orditems RELATE order_id TO order_id)) ]+;
        [  RELATE cust_id TO cust_id ) ]
    Case tnSet = 2

      strShp = [SHAPE { select Company, cust_id from customer } ]+;
        [APPEND (( SHAPE { select distinct First_name, Last_name, a.emp_id + cust_id as "Emp_sel", cust_id  from employee a inner join orders b on a.emp_id = b.emp_id }  ]+;
        [APPEND (( SHAPE { select order_date, order_net, shipped_on, emp_id + cust_id as "Emp_sel",order_id from orders }  ]+;
        [APPEND ( { select order_id, line_no, prod_name from orditems inner join products on products.product_id = orditems.product_id } AS rsOrditems  ]+;
        [RELATE order_id TO order_id )) AS rsEmployee ]+;
        [RELATE emp_sel TO emp_sel )) AS rsOrders  ]+;
        [RELATE cust_id TO cust_id ) ]
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

  Endproc
  Procedure Set2.Click
    Thisform.LoadSet(2)
  Endproc
  Procedure Set3.Click
    Thisform.LoadSet(3)
  Endproc
  Procedure Set4.Click
    Thisform.LoadSet(4)
  Endproc
Enddefine