/*
Делаем анализ базы данных из первого модуля, выбираем таблицу и делаем ее секционирование, с переносом
данных по секциям (партициям) - исходя из того, что таблица большая, пишем скрипты миграции в секционированную таблицу.
*/

USE WideWorldImporters;
GO

--Смотрим партиционированные таблицы

select
	distinct t.name
from
	sys.partitions p
		inner join sys.tables t on p.object_id = t.object_id
where
	p.partition_number <> 1;

/*
CustomerTransactions
SupplierTransactions
*/

--Поскольку на занятии рассматривали invoices и invoiceslines то выбрано Purchasing.PurchaseOrders

--создадим файловую группу
ALTER DATABASE [WideWorldImporters] ADD FILEGROUP [YearData]
GO

--добавим файл
ALTER DATABASE [WideWorldImporters] ADD FILE 
( NAME = N'Years', FILENAME = N'E:\DB\Yeardata.ndf' , 
SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [YearData]
GO

--создадим функцию и схему для партиционирования

CREATE PARTITION FUNCTION [fnYearPartition](DATE) AS RANGE RIGHT FOR VALUES
('20120101','20130101','20140101','20150101','20160101', '20170101', '20180101', '20190101', '20200101', '20210101');
GO

CREATE PARTITION SCHEME [schmYearPartition] AS PARTITION [fnYearPartition] 
ALL TO ([YearData])
GO


--Далее создадим табличку и индекс

CREATE TABLE [Purchasing].[PurchaseOrdersYears]
(
	[PurchaseOrderID] [int] NOT NULL,
	[SupplierID] [int] NOT NULL,
	[OrderDate] [date] NOT NULL,
	[DeliveryMethodID] [int] NOT NULL,
	[ContactPersonID] [int] NOT NULL,
	[ExpectedDeliveryDate] [date] NULL,
	[SupplierReference] [nvarchar](20) NULL,
	[IsOrderFinalized] [bit] NOT NULL,
	[Comments] [nvarchar](max) NULL,
	[InternalComments] [nvarchar](max) NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL
) ON [schmYearPartition]([OrderDate])
GO

ALTER TABLE [Purchasing].[PurchaseOrdersYears] ADD CONSTRAINT PK_Purchasing_PurchaseOrdersYears
PRIMARY KEY CLUSTERED  (OrderDate, PurchaseOrderID)
ON [schmYearPartition]([OrderDate]);


--Заполним нашу таблицу

INSERT INTO [Purchasing].[PurchaseOrdersYears]
           ([PurchaseOrderID]
           ,[SupplierID]
           ,[OrderDate]
           ,[DeliveryMethodID]
           ,[ContactPersonID]
           ,[ExpectedDeliveryDate]
           ,[SupplierReference]
           ,[IsOrderFinalized]
           ,[Comments]
           ,[InternalComments]
           ,[LastEditedBy]
           ,[LastEditedWhen])
SELECT [PurchaseOrderID]
      ,[SupplierID]
      ,[OrderDate]
      ,[DeliveryMethodID]
      ,[ContactPersonID]
      ,[ExpectedDeliveryDate]
      ,[SupplierReference]
      ,[IsOrderFinalized]
      ,[Comments]
      ,[InternalComments]
      ,[LastEditedBy]
      ,[LastEditedWhen]
  FROM [Purchasing].[PurchaseOrders]


--А теперь поселектим

SELECT  $PARTITION.fnYearPartition(OrderDate) AS Partition
		, COUNT(*) AS [COUNT]
		, MIN(OrderDate)
		, MAX(OrderDate) 
FROM [Purchasing].[PurchaseOrdersYears]
GROUP BY $PARTITION.fnYearPartition(OrderDate) 
ORDER BY Partition

/*
Partition	COUNT	(Отсутствует имя столбца)	(Отсутствует имя столбца)
3			605				2013-01-01				2013-12-31
4			604				2014-01-01				2014-12-31
5			610				2015-01-01				2015-12-31
6			255				2016-01-01				2016-05-31
*/

--Для проверки выгрузим оконнную из основной

select
	distinct year(OrderDate) as TestYear,
	count(*) over (partition by year(OrderDate))
from
	[Purchasing].[PurchaseOrders]
order by TestYear

/*
TestYear	(Отсутствует имя столбца)
2013				605
2014				604
2015				610
2016				255
*/