--1
/*
Динамический PIVOT
Пишем динамический PIVOT.
По заданию из занятия “Операторы CROSS APPLY, PIVOT, CUBE”.
Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
Название клиента
МесяцГод Количество покупок

Нужно написать запрос, который будет генерировать результаты для всех клиентов.
Имя клиента указывать полностью из CustomerName.
Дата должна иметь формат dd.mm.yyyy например 25.12.2019
*/

declare
	@CustNameCol nvarchar(max),
	@sql nvarchar(max);

set @CustNameCol = (
select
	quotename(scd.CustomerName) + ',' as 'data()'
from
	Sales.Customers scd
/*where
	CustomerID between 2 and 6*/
for xml path('')
);

set @sql = N'
select * from
(
select
	convert(varchar, DATEFROMPARTS(year(si.InvoiceDate), month(si.InvoiceDate), 1), 104) as InvoiceMonth,
	sc.CustomerName as CustName,
	si.InvoiceID	
from
	Sales.Customers sc
		join Sales.Invoices si on si.CustomerID=sc.CustomerID
) as InvoiceInfo
pivot
(
count(InvoiceID)
for CustName
in (' + left(@CustNameCol,len(@CustNameCol) - 1) + ')
) as pvt
order by convert(datetime, InvoiceMonth, 104);';

--print @sql;

exec (@sql);
