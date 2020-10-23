--1
/*
Напишите запрос с временной таблицей и перепишите его с табличной переменной. Сравните планы.
В качестве запроса с временной таблицей и табличной переменной можно взять свой запрос или следующий запрос:
Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года (в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки)
Выведите id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом
Пример
Дата продажи Нарастающий итог по месяцу
2015-01-29 4801725.31
2015-01-30 4801725.31
2015-01-31 4801725.31
2015-02-01 9626342.98
2015-02-02 9626342.98
2015-02-03 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

--Долго мучился с нарастающим итогом

select
	si.InvoiceID,
	sc.CustomerName,
	si.InvoiceDate,
	sct.TransactionAmount,
	(select
		sum(sctp.TransactionAmount)
	from
		sales.Invoices sip
			join sales.CustomerTransactions sctp on sctp.InvoiceID = sip.InvoiceID
	where
		sip.InvoiceDate between '2015-01-01' and EOMONTH(si.InvoiceDate)) as NarostItogMonth
from
	Sales.Invoices si
		join Sales.Customers sc on sc.CustomerID = si.CustomerID
		join Sales.CustomerTransactions sct on sct.InvoiceID = si.InvoiceID
where
	si.InvoiceDate >= '2015-01-01'
order by si.InvoiceDate, si.InvoiceID;

--теперь делаем по заданию

drop table if exists #Invice2015_1

;with cte1 as
(
select
	si.InvoiceID,
	sc.CustomerName,
	si.InvoiceDate,
	sct.TransactionAmount,
	(select
		sum(sctp.TransactionAmount)
	from
		sales.Invoices sip
			join sales.CustomerTransactions sctp on sctp.InvoiceID = sip.InvoiceID
	where
		sip.InvoiceDate between '2015-01-01' and EOMONTH(si.InvoiceDate)) as NarostItogMonth
from
	Sales.Invoices si
		join Sales.Customers sc on sc.CustomerID = si.CustomerID
		join Sales.CustomerTransactions sct on sct.InvoiceID = si.InvoiceID
where
	si.InvoiceDate >= '2015-01-01'
)
select * into #Invice2015_1 from cte1
select * from #Invice2015_1 order by InvoiceID;




declare @Invoice2015_2 table
(
	InvoiceID int not null,
	CustomerName nvarchar(100) not null,
	InvoiceDate date not null,
	TransactionAmount decimal(18, 2) not null,
	SumAscItog float not null
)
;with cte2 as
(
select
	si.InvoiceID,
	sc.CustomerName,
	si.InvoiceDate,
	sct.TransactionAmount,
	(select
		sum(sctp.TransactionAmount)
	from
		sales.Invoices sip
			join sales.CustomerTransactions sctp on sctp.InvoiceID = sip.InvoiceID
	where
		sip.InvoiceDate between '2015-01-01' and EOMONTH(si.InvoiceDate)) as NarostItogMonth
from
	Sales.Invoices si
		join Sales.Customers sc on sc.CustomerID = si.CustomerID
		join Sales.CustomerTransactions sct on sct.InvoiceID = si.InvoiceID
where
	si.InvoiceDate >= '2015-01-01'
)
insert into @Invoice2015_2 select * from cte2
select * from @Invoice2015_2 order by InvoiceID;

--По стоимости запросы получились одинаково




--2
/*
Если вы брали предложенный выше запрос, то сделайте расчет суммы нарастающим итогом с помощью оконной функции.
Сравните 2 варианта запроса - через windows function и без них. Написать какой быстрее выполняется, сравнить по set statistics time on;
*/

select
	si.InvoiceID,
	sc.CustomerName,
	si.InvoiceDate,
	sct.TransactionAmount,
	sum(sct.TransactionAmount) over (order by year(si.InvoiceDate), month(si.InvoiceDate)) as NarostItogMonth
from
	Sales.Invoices si
		join Sales.Customers sc on sc.CustomerID = si.CustomerID
		join Sales.CustomerTransactions sct on sct.InvoiceID = si.InvoiceID
where
	si.InvoiceDate >= '2015-01-01'
order by si.InvoiceDate, si.InvoiceID;

--а теперь сравнение

set statistics time on;
go

select
	si.InvoiceID,
	sc.CustomerName,
	si.InvoiceDate,
	sct.TransactionAmount,
	sum(sct.TransactionAmount) over (order by year(si.InvoiceDate), month(si.InvoiceDate)) as NarostItogMonth
from
	Sales.Invoices si
		join Sales.Customers sc on sc.CustomerID = si.CustomerID
		join Sales.CustomerTransactions sct on sct.InvoiceID = si.InvoiceID
where
	si.InvoiceDate >= '2015-01-01'
order by si.InvoiceDate, si.InvoiceID;

set statistics time off;
go

/*
SQL Server parse and compile time: 
   CPU time = 109 ms, elapsed time = 161 ms.

(31440 rows affected)

 SQL Server Execution Times:
   CPU time = 828 ms,  elapsed time = 2435 ms.

Completion time: 2020-10-23T10:51:26.1086443+03:00
*/


set statistics time on;
go

select
	si.InvoiceID,
	sc.CustomerName,
	si.InvoiceDate,
	sct.TransactionAmount,
	(select
		sum(sctp.TransactionAmount)
	from
		sales.Invoices sip
			join sales.CustomerTransactions sctp on sctp.InvoiceID = sip.InvoiceID
	where
		sip.InvoiceDate between '2015-01-01' and EOMONTH(si.InvoiceDate)) as NarostItogMonth
from
	Sales.Invoices si
		join Sales.Customers sc on sc.CustomerID = si.CustomerID
		join Sales.CustomerTransactions sct on sct.InvoiceID = si.InvoiceID
where
	si.InvoiceDate >= '2015-01-01'
order by si.InvoiceDate, si.InvoiceID;

set statistics time off;
go

/*
SQL Server parse and compile time: 
   CPU time = 156 ms, elapsed time = 353 ms.

(31440 rows affected)

 SQL Server Execution Times:
   CPU time = 37703 ms,  elapsed time = 40004 ms.

Completion time: 2020-10-23T10:52:46.2301168+03:00
*/

--Если судить по SQL Server Execution Times: elapsed time
--то запрос с оконной функцией отработал быстрее примерно раз в 14-17
--(запускал с перерывами и в разные дни, привел просто 1 результат)




--3
/*
Вывести список 2х самых популярных продуктов (по кол-ву проданных) в каждом месяце 
за 2016й год (по 2 самых популярных продукта в каждом месяце)
*/

SELECT
	*
FROM
(
select
	ws.StockItemID,
	ws.StockItemName,
	year(si.InvoiceDate) as InvYear,
	month(si.InvoiceDate) as InvMonth,
	--sum(sil.Quantity) as SumOfQuan,
	row_number() over (partition by month(si.InvoiceDate) order by sum(sil.Quantity) desc) as Kolvo
from
	Sales.Invoices si
		join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
		join Warehouse.StockItems ws on ws.StockItemID = sil.StockItemID
where
	si.InvoiceDate >= '2016-01-01'
group by ws.StockItemID, ws.StockItemName, year(si.InvoiceDate), month(si.InvoiceDate)
--order by InvYear, InvMonth, SumOfQuan desc
) as InfoTable
WHERE
	InfoTable.Kolvo <= 2
ORDER BY InvMonth;




--4
/*
Функции одним запросом
Посчитайте по таблице товаров, в вывод также должен попасть ид товара, название, брэнд и цена
пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
посчитайте общее количество товаров и выведете полем в этом же запросе
посчитайте общее количество товаров в зависимости от первой буквы названия товара
отобразите следующий id товара исходя из того, что порядок отображения товаров по имени
предыдущий ид товара с тем же порядком отображения (по имени)
названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
сформируйте 30 групп товаров по полю вес товара на 1 шт
Для этой задачи НЕ нужно писать аналог без аналитических функций
*/

select
	ws.StockItemID,
	ws.StockItemName,
	ws.Brand,
	ws.UnitPrice,
	row_number() over (partition by substring(ws.StockItemName, 1, 1) order by ws.StockItemName) as Bukva,
	count(*) over () as Kolvo,
	count(*) over (partition by substring(ws.StockItemName, 1, 1)) as KolvoBukva,
	lead(ws.StockItemID) over (order by ws.StockItemName) as NextID,
	lag(ws.StockItemID) over (order by ws.StockItemName) as PrevID,
	lag(ws.StockItemName, 2, 'No items') over (order by ws.StockItemName) as Name2StrPrev,
	ntile(30) over (order by ws.TypicalWeightPerUnit) as GroupWeight
from
	Warehouse.StockItems ws;




--5
/*
По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал
В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки
*/

--полные имена могут быть абсолютно разные, поэтому оставил FULLNAME

SELECT
*
FROM
(
select
	si.SalespersonPersonID, --ap.PersonID,
	ap.FullName,
	sc.CustomerID,
	sc.CustomerName,
	si.InvoiceDate,
	sum(sil.Quantity*sil.UnitPrice) as SumOfInv,
	row_number() over (partition by si.SalespersonPersonID order by si.InvoiceDate desc) as LastDateOfInv
from
	Application.People ap
		join Sales.Invoices si on si.SalespersonPersonID = ap.PersonID
		join Sales.Customers sc on sc.CustomerID = si.CustomerID
		join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
group by si.SalespersonPersonID, ap.FullName, sc.CustomerID, sc.CustomerName, si.InvoiceDate
) as TableOfLastInv
WHERE
	TableOfLastInv.LastDateOfInv = 1;




--6
/*
Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
*/

SELECT
	*
FROM
(
select
	sc.CustomerID,
	sc.CustomerName,
	sil.StockItemID,
	sil.UnitPrice,
	si.InvoiceDate,
	row_number() over (partition by sc.CustomerID order by sil.UnitPrice desc) as MaxPrice
from
	Sales.Customers sc
		join Sales.Invoices si on si.CustomerID = sc.CustomerID
		join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
) as TableOfMaxPrice
WHERE
	TableOfMaxPrice.MaxPrice <= 2;




--OPTIONAL

/*
Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
*/

--Это из прошлого ДЗ

select
	sc.CustomerID,
	sc.CustomerName,
	InvMaxPrice.*
from
	Sales.Customers sc
	cross apply (
		select
			top 2 sil.StockItemID, sil.UnitPrice, si.InvoiceDate
		from
			Sales.Invoices si
				join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
		where
			si.CustomerID = sc.CustomerID
		order by sil.UnitPrice desc) as InvMaxPrice;




/*
По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал
В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки
*/

select
	ap.PersonID,
	ap.FullName,
	InvDZ5.*
from
	Application.People ap
	cross apply (
		select top 1
			sc.CustomerID,
			sc.CustomerName,
			si.InvoiceDate,
			sum(sil.Quantity*sil.UnitPrice) as SumOfInv
		from
			Sales.Invoices si
				join Sales.Customers sc on sc.CustomerID = si.CustomerID
				join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
		where
			si.SalespersonPersonID = ap.PersonID
		group by sc.CustomerID, sc.CustomerName, si.InvoiceDate
		order by si.InvoiceDate desc) as InvDZ5;




/*
Вывести список 2х самых популярных продуктов (по кол-ву проданных) в каждом месяце 
за 2016й год (по 2 самых популярных продукта в каждом месяце)
*/

--Что-то пока нет мыслей совсем




--BONUS
/*
Напишите запрос, который выбирает 10 клиентов, которые сделали больше 30 заказов 
и последний заказ был не позднее апреля 2016.
*/

--Фразу - и последний заказ был не позднее апреля 2016 - понимаю как
--Последний заказ мог быть до мая месяца поэтому

select
	sc.CustomerID,
	sc.CustomerName,
	count(so.OrderID),
	max(so.OrderDate)
from
	Sales.Customers sc
		join Sales.Orders so on so.CustomerID = sc.CustomerID
group by sc.CustomerID, sc.CustomerName
having count(so.OrderID) > 30 and max(so.OrderDate) < '2016-05-01'
