DECLARE @representantes as varchar(max)

set @representantes = ''
select @representantes = @representantes + ',[' + ltrim(str(codigo)) + ']' FROM emp_representantes

select @representantes
