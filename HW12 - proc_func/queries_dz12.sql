--1
/*
Написать функцию возвращающую Клиента с наибольшей суммой покупки
*/

create or alter function user_GetCustomerWithMaxSumOfIvoice()
returns varchar(50)
begin

	declare @FCustomerName varchar(50);

	set @FCustomerName = '';

	with cte1 as
	(
	select
		sc.CustomerName,
		si.InvoiceID,
		sum(sil.Quantity * sil.UnitPrice) as MaxPokupka,
		row_number() over (order by sum(sil.Quantity * sil.UnitPrice) desc) as NumbOfMP
	from
		Sales.Customers sc
			join Sales.Invoices si on si.CustomerID = sc.CustomerID
			join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
	group by sc.CustomerName, si.InvoiceID
	)
	select @FCustomerName = CustomerName
	from cte1
	where NumbOfMP = 1;

	return @FCustomerName;

end;


select dbo.user_GetCustomerWithMaxSumOfIvoice();




--2
/*
Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

--решил без использования Sales.Customers, поскольку ссылка CustomerID есть в Sales.Invoices

create or alter procedure user_GetSumOfInvoiceByCustomer
	@PCustomerID int
as
begin
	
	set nocount on;

	with cte1 as
	(
	select
		si.InvoiceID,
		sum(sil.Quantity * sil.UnitPrice) as MaxPokupka,
		row_number() over (order by sum(sil.Quantity * sil.UnitPrice) desc) as NumbOfMP
	from
		Sales.Invoices si
			join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
	where
		si.CustomerID = @PCustomerID
	group by si.InvoiceID
	)
	select MaxPokupka from cte1 where NumbOfMP = 1;

	return;

end;


exec dbo.user_GetSumOfInvoiceByCustomer 533;




--3
/*
Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

--для примера решил сделать процедуру и функцию которая по ID клиента и дате
--показывает количество купленного товара до этой даты включительно

create or alter procedure user_proc_GetCountPosition
	@PCustomerID int, @PInvoiceDate date
as
begin
	
	set nocount on;

	select
		sum(sil.Quantity)
	from
		Sales.InvoiceLines sil
			join Sales.Invoices si on si.InvoiceID = sil.InvoiceID
	where
		si.CustomerID = @PCustomerID
		and si.InvoiceDate <= @PInvoiceDate;

	return;

end;

exec dbo.user_proc_GetCountPosition 105, '2014-06-01';



create or alter function user_func_GetCountPosition (@FCustomerID int, @FInvoiceDate date)
returns int
begin
	
	declare @FCountQuantity int;

	set @FCountQuantity = 0;

	select
		@FCountQuantity = sum(sil.Quantity)
	from
		Sales.InvoiceLines sil
			join Sales.Invoices si on si.InvoiceID = sil.InvoiceID
	where
		si.CustomerID = @FCustomerID
		and si.InvoiceDate <= @FInvoiceDate;

	return @FCountQuantity;

end;

select dbo.user_func_GetCountPosition(105, '2014-06-01');

--смотрим по set statistics

set statistics io, time on;
go

exec dbo.user_proc_GetCountPosition 105, '2014-06-01';

set statistics io, time off;
go

/*
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 5 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
Table 'InvoiceLines'. Scan count 2, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 157, lob physical reads 0, lob read-ahead reads 0.
Table 'InvoiceLines'. Segment reads 1, segment skipped 0.
Table 'Invoices'. Scan count 1, logical reads 312, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 16 ms,  elapsed time = 321 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

 SQL Server Execution Times:
   CPU time = 16 ms,  elapsed time = 328 ms.

Completion time: 2020-11-15T15:34:43.0858227+03:00

*/


set statistics io, time on;
go

select dbo.user_func_GetCountPosition(105, '2014-06-01');

set statistics io, time off;
go

/*
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 1 ms.

(1 row affected)

(1 row affected)

 SQL Server Execution Times:
   CPU time = 31 ms,  elapsed time = 21 ms.

Completion time: 2020-11-15T15:35:45.4070921+03:00

*/

--Информацию из статистики взял из первого запуска
--Позапускал несколько раз
--Удивила разница в планах запросов
--У процедуры он ветвящийся
--Функция выполняется быстрее, судя по времени




--4
/*
Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла.
*/

create or alter function user_tablefunc_GetInformForCustomer (@FCustomerID int)
returns table
as
return
(
select
	si.InvoiceID,
	sum(sil.Quantity) as SumOfQuant
from
	Sales.InvoiceLines sil
		join Sales.Invoices si on si.InvoiceID = sil.InvoiceID
where
	si.CustomerID = @FCustomerID
group by si.InvoiceID
);

select * from dbo.user_tablefunc_GetInformForCustomer(105);

select
	sc.CustomerName, utf.*
from
	Sales.Customers sc
	cross apply dbo.user_tablefunc_GetInformForCustomer(sc.CustomerID) utf
order by sc.CustomerName;




--5
/*
Во всех процедурах, в описании укажите для преподавателям какой уровень изоляции нужен и почему.
*/

/*
Все зависит от задачи, для чего использовать данные процедуры или функции

Если данные процедуры или функции использовать в оперативной отчетности,
то я бы выбрал уровень изоляции Read Uncommitted добавив в каждой таблице в блоках from приписку (nolock)
что позволит при выгрузке данных не мешать их обновлять, изменять, удалять.
Таким образом будем получать что-то в виде срезов данных на момент запуска

Если данные процедуры или функции использовать для редких отчетов (например топ-менеджменту необходим
дащборд по прошедщему дню по продажам), то я бы использовал уровень Serializable
чтобы получить самые актуальные данные после всех изменений в бд.
*/