use vs_martinez
go 

alter table emp_clientes_direcciones add solo_tickets dm_logico default 0
go 

update emp_clientes_direcciones set solo_tickets = 0

