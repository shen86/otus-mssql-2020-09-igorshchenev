--1
/*
Все товары, в названии которых есть "urgent" или название начинается с "Animal". Вывести: ИД товара, наименование товара.
Таблицы: Warehouse.StockItems.
*/
select
	wsi.StockItemID,
	wsi.StockItemName
from
	Warehouse.StockItems wsi
where
	wsi.StockItemName like '%urgent%' or wsi.StockItemName like 'Animal%';



--2
/*
Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders). Сделать через JOIN, с подзапросом задание принято не будет. Вывести: ИД поставщика, наименование поставщика.
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
*/
select
	ps.SupplierID,
	ps.SupplierName
from
	Purchasing.Suppliers ps
		left join Purchasing.PurchaseOrders ppo on ps.SupplierID = ppo.SupplierID
where
	ppo.PurchaseOrderID is null;



--3
/*
Заказы (Orders) с ценой товара более 100$ либо количеством единиц товара более 20 штук и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа в формате ДД.ММ.ГГГГ
* название месяца, в котором была продажа
* номер квартала, к которому относится продажа
* треть года, к которой относится дата продажи (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой, пропустив первую 1000 и отобразив следующие 100 записей. Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).
Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/
select
	so.OrderID,
	convert(varchar, so.OrderDate, 104) as OrderDateDMY,
	datename(month, so.OrderDate) as Month_Name,
	datename(quarter, so.OrderDate) as Quarter_Name,
	case
		when month(so.OrderDate) between 1 and 4 then 1
		when month(so.OrderDate) between 5 and 8 then 2
		else 3
	end as ThirdOfYear,
	sc.CustomerName
from
	Sales.Orders so
		join Sales.Customers sc on sc.CustomerID = so.CustomerID
		join Sales.OrderLines sol on sol.OrderID = so.OrderID
where
	(sol.UnitPrice > 100 or sol.Quantity > 20) and so.PickingCompletedWhen is not null;


select
	so.OrderID,
	convert(varchar, so.OrderDate, 104) as OrderDateDMY,
	datename(month, so.OrderDate) as Month_Name,
	datename(quarter, so.OrderDate) as Quarter_Name,
	case
		when month(so.OrderDate) between 1 and 4 then 1
		when month(so.OrderDate) between 5 and 8 then 2
		else 3
	end as ThirdOfYear,
	sc.CustomerName
from
	Sales.Orders so
		join Sales.Customers sc on sc.CustomerID = so.CustomerID
		join Sales.OrderLines sol on sol.OrderID = so.OrderID
where
	(sol.UnitPrice > 100 or sol.Quantity > 20) and so.PickingCompletedWhen is not null
order by Quarter_Name, ThirdOfYear, so.OrderDate
offset 1000 rows fetch next 100 rows only;



--4
/*
Заказы поставщикам (Purchasing.Suppliers), которые были исполнены в январе 2014 года с доставкой Air Freight или Refrigerated Air Freight (DeliveryMethodName).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/
select
	adm.DeliveryMethodName,
	ppo.ExpectedDeliveryDate,
	ps.SupplierName,
	ap.FullName
from
	Purchasing.Suppliers ps
		join Purchasing.PurchaseOrders ppo on ppo.SupplierID = ps.SupplierID
		join Application.DeliveryMethods adm on adm.DeliveryMethodID = ppo.DeliveryMethodID
		join Application.People ap on ap.PersonID = ppo.ContactPersonID
where
	ppo.ExpectedDeliveryDate between '2014-01-01' and '2014-01-31'
	and adm.DeliveryMethodName in ('Air Freight', 'Refrigerated Air Freight');



--5
/*
Десять последних продаж (по дате) с именем клиента и именем сотрудника, который оформил заказ (SalespersonPerson).
*/
select top 10
	so.OrderDate,
	sc.CustomerName,
	ap.FullName
from
	Sales.Orders so
		join Sales.Customers sc on sc.CustomerID = so.CustomerID
		join Application.People ap on ap.PersonID = so.SalespersonPersonID
order by so.OrderDate desc;



--6
/*
Все ид и имена клиентов и их контактные телефоны, которые покупали товар Chocolate frogs 250g. Имя товара смотреть в Warehouse.StockItems.
*/
select
	sc.CustomerID,
	sc.CustomerName,
	sc.PhoneNumber
from
	Sales.Customers sc
		join Sales.Orders so on so.CustomerID = sc.CustomerID
		join Sales.OrderLines sol on sol.OrderID = so.OrderID
		join Warehouse.StockItems wsi on wsi.StockItemID = sol.StockItemID
where
	wsi.StockItemName = 'Chocolate frogs 250g';



--7
/*
Посчитать среднюю цену товара, общую сумму продажи по месяцам

Вывести:
* Год продажи
* Месяц продажи
* Средняя цена за месяц по всем товарам
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/
select
	year(si.InvoiceDate) as year_invoicedate,
	month(si.InvoiceDate) as month_invoicedate,
	avg(sil.UnitPrice) as avg_price,
	sum(sil.Quantity * sil.UnitPrice) as sum_price
from
	Sales.Invoices si
		join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
group by year(si.InvoiceDate), month(si.InvoiceDate)
order by year_invoicedate, month_invoicedate;



--8
/*
Отобразить все месяцы, где общая сумма продаж превысила 10 000

Вывести:
* Год продажи
* Месяц продажи
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/
select
	year(si.InvoiceDate) as year_invoicedate,
	month(si.InvoiceDate) as month_invoicedate,
	sum(sil.Quantity * sil.UnitPrice) as sum_price
from
	Sales.Invoices si
		join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
group by year(si.InvoiceDate), month(si.InvoiceDate)
having sum(sil.Quantity * sil.UnitPrice) > 10000
order by year_invoicedate, month_invoicedate;



--9
/*
Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц.
Группировка должна быть по году, месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/
select
	year(si.InvoiceDate) as year_invoicedate,
	month(si.InvoiceDate) as month_invoicedate,
	wsi.StockItemName,
	sum(sil.Quantity * sil.UnitPrice) as sum_price,
	min(si.InvoiceDate) as first_sales,
	sum(sil.Quantity) as sum_quantity
from
	Sales.Invoices si
		join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
		join Warehouse.StockItems wsi on wsi.StockItemID = sil.StockItemID
group by year(si.InvoiceDate), month(si.InvoiceDate), wsi.StockItemName
having sum(sil.Quantity) < 50
order by year_invoicedate, month_invoicedate;
