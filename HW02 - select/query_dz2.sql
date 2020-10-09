--1
select
	wsi.StockItemID,
	wsi.StockItemName
from
	Warehouse.StockItems wsi
where
	wsi.StockItemName like '%urgent%' or wsi.StockItemName like 'Animal%';



--2
select
	ps.SupplierID,
	ps.SupplierName
from
	Purchasing.Suppliers ps
		left join Purchasing.PurchaseOrders ppo on ps.SupplierID = ppo.SupplierID
where
	ppo.PurchaseOrderID is null;



--3
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
select
	year(si.InvoiceDate) as year_invoicedate,
	month(si.InvoiceDate) as month_invoicedate,
	avg(sil.ExtendedPrice) as avg_price,
	sum(sil.ExtendedPrice) as sum_price
from
	Sales.Invoices si
		join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
group by year(si.InvoiceDate), month(si.InvoiceDate)
order by year_invoicedate, month_invoicedate;



--8
select
	year(si.InvoiceDate) as year_invoicedate,
	month(si.InvoiceDate) as month_invoicedate,
	sum(sil.ExtendedPrice) as sum_price
from
	Sales.Invoices si
		join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
group by year(si.InvoiceDate), month(si.InvoiceDate)
having sum(sil.ExtendedPrice) > 10000
order by year_invoicedate, month_invoicedate;



--9
select
	year(si.InvoiceDate) as year_invoicedate,
	month(si.InvoiceDate) as month_invoicedate,
	wsi.StockItemName,
	sum(sil.ExtendedPrice) as sum_price,
	min(si.InvoiceDate) as first_sales,
	sum(sil.Quantity) as sum_quantity
from
	Sales.Invoices si
		join Sales.InvoiceLines sil on sil.InvoiceID = si.InvoiceID
		join Warehouse.StockItems wsi on wsi.StockItemID = sil.StockItemID
group by year(si.InvoiceDate), month(si.InvoiceDate), wsi.StockItemName
having sum(sil.Quantity) < 50
order by year_invoicedate, month_invoicedate;