--1
/*
Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

--1_1 Наверное самый простой вариант

select
	ap.PersonID,
	ap.FullName
from
	Application.People ap
where
	ap.IsSalesperson = 1
	and ap.PersonID not in (select
								si.SalespersonPersonID
							from
								Sales.Invoices si
							where
								si.InvoiceDate = '2015-07-04');


--1_2 И второй вариант с CTE наверное тоже самый простой

;with AP_CTE (PersonID, FullName)
as
(
select
	ap.PersonID,
	ap.FullName
from
	Application.People ap
where
	ap.IsSalesperson = 1
)
select
	AP_CTE.*
from
	AP_CTE
where
	AP_CTE.PersonID not in (select
								si.SalespersonPersonID
							from
								Sales.Invoices si
							where
								si.InvoiceDate = '2015-07-04');




--2
/*
Выберите товары с минимальной ценой (подзапросом). 
Сделайте два варианта подзапроса. Вывести: ИД товара, наименование товара, цена.
*/

--2_1 минимальная цена

select
	wsi.StockItemID,
	wsi.StockItemName
from
	Warehouse.StockItems wsi
where
	wsi.UnitPrice = (select
						 min(wwssii.UnitPrice)
					 from Warehouse.StockItems wwssii);


--2_2 топ 1

select
	wsi.StockItemID,
	wsi.StockItemName
from
	Warehouse.StockItems wsi
where
	wsi.UnitPrice = (select
						 top 1 wwssii.UnitPrice
					 from Warehouse.StockItems wwssii
					 order by wwssii.UnitPrice);




--3
/*
Выберите информацию по клиентам, которые перевели компании пять максимальных платежей из 
Sales.CustomerTransactions. Представьте несколько способов (в том числе с CTE).
*/

--3_1 топ 5 максимальных переводов

select
	sc.CustomerID,
	sc.CustomerName
from
	Sales.Customers sc
where
	sc.CustomerID in (select
						  top 5 sct.CustomerID
					  from
						  Sales.CustomerTransactions sct
					  order by sct.TransactionAmount desc);


--3_2 - закидываем их в CTE

;with MaxCustTran (CustomerID)
as
(
select
	top 5 sct.CustomerID
from
	Sales.CustomerTransactions sct
order by sct.TransactionAmount desc
)
select
	sc.CustomerID,
	sc.CustomerName
from
	Sales.Customers sc
where
	sc.CustomerID in (select
						  *
					  from
						  MaxCustTran);




--4
/*
Выберите города (ид и название), в которые были доставлены товары, входящие в тройку самых дорогих товаров, 
а также имя сотрудника, который осуществлял упаковку заказов (PackedByPersonID)
*/

--4_1

select
	distinct
	ac.CityID,
	ac.CityName,
	ap.FullName
from
	Application.Cities ac
		join Sales.Customers sc on sc.DeliveryCityID = ac.CityID
		join Sales.Invoices si on si.CustomerID = sc.CustomerID
		join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
		join Application.People ap on ap.PersonID = si.PackedByPersonID
where
	sil.StockItemID in (select
							top 3 wwssii.StockItemID
						from Warehouse.StockItems wwssii
						order by wwssii.UnitPrice desc);


--4_2 запихнул в CTE только подзапрос

;with MaxUnitPrice (StockItemId)
as
(
select
	top 3 wwssii.StockItemID
from Warehouse.StockItems wwssii
order by wwssii.UnitPrice desc
)
select
	distinct
	ac.CityID,
	ac.CityName,
	ap.FullName
from
	Application.Cities ac
		join Sales.Customers sc on sc.DeliveryCityID = ac.CityID
		join Sales.Invoices si on si.CustomerID = sc.CustomerID
		join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
		join Application.People ap on ap.PersonID = si.PackedByPersonID
where
	sil.StockItemID in (select
							*
						from
							MaxUnitPrice);




--5
/*
Объясните, что делает и оптимизируйте запрос:

SELECT
Invoices.InvoiceID,
Invoices.InvoiceDate,
(SELECT People.FullName
FROM Application.People
WHERE People.PersonID = Invoices.SalespersonPersonID
) AS SalesPersonName,
SalesTotals.TotalSumm AS TotalSummByInvoice,
(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
FROM Sales.OrderLines
WHERE OrderLines.OrderId = (SELECT Orders.OrderId
FROM Sales.Orders
WHERE Orders.PickingCompletedWhen IS NOT NULL
AND Orders.OrderId = Invoices.OrderId)
) AS TotalSummForPickedItems
FROM Sales.Invoices
JOIN
(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
FROM Sales.InvoiceLines
GROUP BY InvoiceId
HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

Можно двигаться как в сторону улучшения читабельности запроса, 
так и в сторону упрощения плана\ускорения. 
Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
Напишите ваши рассуждения по поводу оптимизации.
*/

--Запрос выводит информацию о счете
--ID, дата, кто продал, сумма продаваемого в счете и сумма заказа (если он укомплетован)
--Фильтруется по сумме проданного больше 27000
--Сортируется от наибольшей продажи

--Первое, что приходит в голову, это блок InvoicesLines отправить в CTE

;with SalesTotals (InvoiceID, TotalSumm)
as
(
SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
FROM Sales.InvoiceLines
GROUP BY InvoiceId
HAVING SUM(Quantity*UnitPrice) > 27000
)
SELECT
Invoices.InvoiceID,
Invoices.InvoiceDate,
(SELECT People.FullName
FROM Application.People
WHERE People.PersonID = Invoices.SalespersonPersonID
) AS SalesPersonName,
SalesTotals.TotalSumm AS TotalSummByInvoice,
(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
FROM Sales.OrderLines
WHERE OrderLines.OrderId = (SELECT Orders.OrderId
FROM Sales.Orders
WHERE Orders.PickingCompletedWhen IS NOT NULL
AND Orders.OrderId = Invoices.OrderId)
) AS TotalSummForPickedItems
FROM Sales.Invoices
JOIN
SalesTotals
ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC;

--Следующее, что приходит в голову - отправить в CTE OrderLines (Но мне кажется, 
--что это только для чтения хорошо)

;with SalesTotals (InvoiceID, TotalSumm)
as
(
SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
FROM Sales.InvoiceLines
GROUP BY InvoiceId
HAVING SUM(Quantity*UnitPrice) > 27000
),
SummOrderLines (OrderID, TotalSummForPickedItems)
as
(
SELECT OrderLines.OrderID, SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
FROM Sales.OrderLines
group by OrderLines.OrderID
)
SELECT
Invoices.InvoiceID,
Invoices.InvoiceDate,
(SELECT People.FullName
FROM Application.People
WHERE People.PersonID = Invoices.SalespersonPersonID
) AS SalesPersonName,
SalesTotals.TotalSumm AS TotalSummByInvoice,
(SELECT TotalSummForPickedItems
FROM SummOrderLines
WHERE SummOrderLines.OrderId = (SELECT Orders.OrderId
FROM Sales.Orders
WHERE Orders.PickingCompletedWhen IS NOT NULL
AND Orders.OrderId = Invoices.OrderId)
) AS TotalSummForPickedItems
FROM Sales.Invoices
JOIN
SalesTotals
ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC;

--Вместо этого я бы убрал подзапрос с fullname просто заджойнив таблицу 
--(только возникает вопрос, какой join использовать - inner or left)
--Скорее всего нужен left потому что не факт, что может быть значение fullname раз оно в подзапросе изначально
--Но это тоже скорее всего лучше для читабельности

;with SalesTotals (InvoiceID, TotalSumm)
as
(
SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
FROM Sales.InvoiceLines
GROUP BY InvoiceId
HAVING SUM(Quantity*UnitPrice) > 27000
)
SELECT
Invoices.InvoiceID,
Invoices.InvoiceDate,
People.FullName AS SalesPersonName,
SalesTotals.TotalSumm AS TotalSummByInvoice,
(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
FROM Sales.OrderLines
WHERE OrderLines.OrderId = (SELECT Orders.OrderId
FROM Sales.Orders
WHERE Orders.PickingCompletedWhen IS NOT NULL
AND Orders.OrderId = Invoices.OrderId)
) AS TotalSummForPickedItems
FROM Sales.Invoices
JOIN SalesTotals ON Invoices.InvoiceID = SalesTotals.InvoiceID
left join Application.People on People.PersonID = Invoices.SalespersonPersonID
ORDER BY TotalSumm DESC;

--Ну и еще один вариант - вынос подзапроса OrderLines в join (при этом появляется group by)
--и тоже возникает вопрос насчет left join sales.orders
--потому что в подзапросе по идее выпадет пустое значение, если будет не укомплектован
--скорее всего этот вариант тоже для читабельности

;with SalesTotals (InvoiceID, TotalSumm)
as
(
SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
FROM Sales.InvoiceLines
GROUP BY InvoiceId
HAVING SUM(Quantity*UnitPrice) > 27000
)
SELECT
Invoices.InvoiceID,
Invoices.InvoiceDate,
People.FullName AS SalesPersonName,
SalesTotals.TotalSumm AS TotalSummByInvoice,
SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) AS TotalSummForPickedItems
FROM Sales.Invoices
JOIN SalesTotals ON Invoices.InvoiceID = SalesTotals.InvoiceID
join Sales.Orders on Orders.OrderID = Invoices.OrderID and Orders.PickingCompletedWhen IS NOT NULL
join Sales.OrderLines on OrderLines.OrderID = Orders.OrderID
left join Application.People on People.PersonID = Invoices.SalespersonPersonID
group by Invoices.InvoiceID, InvoiceDate, People.FullName, SalesTotals.TotalSumm
ORDER BY TotalSumm DESC;

-- Больше никаких идей (хотя скорее всего решения есть и красивые)

--С планами запросов пока не знаком и со статистикой тоже. Надо больше об этом читать и углубляться




--6
/*
В материалах к вебинару есть файл HT_reviewBigCTE.sql - прочтите этот запрос и напишите, 
что он должен вернуть и в чем его смысл. Если есть идеи по улучшению запроса, то напишите их.
*/

--Наверное максимум что я могу сказать о данном запросе, это то, что:
--сравниваются файлы в рабочем и основном каталогах пользователя по определенным правилам 
--и подготавливаются для переноса/архива/удаления

--Может быть это неправильно, но мне кажется что это так

--Улучшения
--Если всегда в этом пункте определено правило 4 и не будет меняться, то
--на мой взгляд case тут лишний
/*
SELECT TOP 1
				1
		 where T.RuleType = 1
			and T.RuleCondition = 4
			and DF.Name like  case T.RuleCondition
							  when 4
							  then '%' + T.RuleItemFileMask + '%' --never will be indexed
							  when 3
							  then '%' + T.RuleItemFileMask --never will be indexed
							  when 2
							  then T.RuleItemFileMask + '%' --may be indexed
							 end
*/
--Да и вообще этот пункт может быть лишним в целом, поскольку следом идет сравнение по решулярному выражению
--которое может учитывать эти условия