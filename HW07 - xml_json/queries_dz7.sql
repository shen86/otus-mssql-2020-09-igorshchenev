--1
/*
В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice

Опционально - если вы знакомы с insert, update, merge, то загрузить эти данные в таблицу Warehouse.StockItems.
Существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName).
*/

declare @x xml
set @x = 
(
	select
		*
	from
		openrowset (bulk 'C:\Temp\StockItems-188-f89807.xml', single_blob) as d
)

--select @x

declare @dochandle int
exec sp_xml_preparedocument @dochandle output, @x


select * from openxml(@dochandle, N'/StockItems/Item')
with
(
StockItemName nvarchar(100) '@Name',
SupplierID int 'SupplierID',
UnitPackageID int 'Package/UnitPackageID',
OuterPackageID int 'Package/OuterPackageID',
QuantityPerOuter int 'Package/QuantityPerOuter',
TypicalWeightPerUnit decimal(18,3) 'Package/TypicalWeightPerUnit',
LeadTimeDays int 'LeadTimeDays',
IsChillerStock bit 'IsChillerStock',
TaxRate decimal(18,3) 'TaxRate',
UnitPrice decimal(18,2) 'UnitPrice'
)

exec sp_xml_removedocument @dochandle;




--2
/*
Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml

Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML.
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/

select top 15
	ws.StockItemName as [@Name],
	ws.SupplierID as [SupplierID],
	ws.UnitPackageID as [Package/UnitPackageID],
	ws.OuterPackageID as [Package/OuterPackageID],
	ws.QuantityPerOuter as [Package/QuantityPerOuter],
	ws.TypicalWeightPerUnit as [Package/TypicalWeightPerUnit],
	ws.LeadTimeDays as [LeadTimeDays],
	ws.IsChillerStock as [IsChillerStock],
	ws.TaxRate as [TaxRate],
	ws.UnitPrice as [UnitPrice]
from Warehouse.StockItems ws
for xml path('Item'), root('StockItems');




--3
/*
В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

select
	ws.StockItemID,
	ws.StockItemName,
	json_value(ws.CustomFields, '$.CountryOfManufacture') as CountryOfManufacture,
	isnull(json_value(ws.CustomFields, '$.Tags[0]'), '') as FirstTags
from
	Warehouse.StockItems ws;




--4
/*
Найти в StockItems строки, где есть тэг "Vintage".
Вывести:
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%'
*/

select
	ws.StockItemID,
	ws.StockItemName,
	catbl.[key],
	catbl.value
from
	Warehouse.StockItems ws
	cross apply openjson(ws.CustomFields, '$.Tags') as catbl
where
	catbl.value = 'Vintage';

--option
--Попробовал с cross apply

select
	ws.StockItemID,
	ws.StockItemName,
	catbl.value,
	string_agg(catgs.value, ', ')
from
	Warehouse.StockItems ws
	cross apply openjson(ws.CustomFields, '$.Tags') as catbl
	cross apply openjson(json_query(ws.CustomFields, '$.Tags')) as catgs
where
	catbl.value = 'Vintage'
group by ws.StockItemID, ws.StockItemName, catbl.value;