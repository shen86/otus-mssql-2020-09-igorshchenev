--1
/*
Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
Название клиента
МесяцГод Количество покупок

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys
имя клиента нужно поменять так чтобы осталось только уточнение
например исходное Tailspin Toys (Gasport, NY) - вы выводите в имени только Gasport,NY
дата должна иметь формат dd.mm.yyyy например 25.12.2019

Например, как должны выглядеть результаты:
InvoiceMonth Peeples Valley, AZ Medicine Lodge, KS Gasport, NY Sylvanite, MT Jessie, ND
01.01.2013 3 1 4 2 2
01.02.2013 7 3 4 2 1
*/

select * from
(
select
	convert(varchar, DATEFROMPARTS(year(si.InvoiceDate), month(si.InvoiceDate), 1), 104) as InvoiceMonth,
	substring(left(sc.CustomerName, len(sc.CustomerName) - 1), 16, len(sc.CustomerName)) as CustName,
	si.InvoiceID	
from
	Sales.Customers sc
		join Sales.Invoices si on si.CustomerID=sc.CustomerID
where
	sc.CustomerID between 2 and 6
) as InvoiceInfo
pivot
(
count(InvoiceID)
for CustName
in ([Sylvanite, MT], [Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Jessie, ND])
) as pvt
order by convert(datetime, InvoiceMonth, 104);




--2
/*
Для всех клиентов с именем, в котором есть Tailspin Toys
вывести все адреса, которые есть в таблице, в одной колонке

Пример результатов
CustomerName AddressLine
Tailspin Toys (Head Office) Shop 38
Tailspin Toys (Head Office) 1877 Mittal Road
Tailspin Toys (Head Office) PO Box 8975
Tailspin Toys (Head Office) Ribeiroville
.....
*/

select CustomerName, AddressCustomer from
(
select
	sc.CustomerName,
	sc.DeliveryAddressLine1,
	sc.DeliveryAddressLine2,
	sc.PostalAddressLine1,
	sc.PostalAddressLine2
from
	Sales.Customers sc
where
	sc.CustomerName like 'Tailspin Toys%'
) as AddrInfo
unpivot
(
AddressCustomer for column_addr in (DeliveryAddressLine1,DeliveryAddressLine2,PostalAddressLine1,PostalAddressLine2)
) as unpvt;




--3
/*
В таблице стран есть поля с кодом страны цифровым и буквенным
сделайте выборку ИД страны, название, код - чтобы в поле был либо цифровой либо буквенный код
Пример выдачи

CountryId CountryName Code
1 Afghanistan AFG
1 Afghanistan 4
3 Albania ALB
3 Albania 8
*/

select CountryID, CountryName, CodeCtr from
(
select
	ac.CountryID,
	ac.CountryName,
	ac.IsoAlpha3Code,
	cast(ac.IsoNumericCode as nvarchar(3)) as IsoNumericCodeChar
from
	Application.Countries ac
) as CountryInfo
unpivot
(
CodeCtr for column_code in (IsoAlpha3Code, IsoNumericCodeChar)
) as unpvt;




--4
/*
Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
*/

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




--5
/*
Code review (опционально). Запрос приложен в материалы Hometask_code_review.sql.
Что делает запрос?
Чем можно заменить CROSS APPLY - можно ли использовать другую стратегию выборки\запроса?
*/

SELECT T.FolderId,
		   T.FileVersionId,
		   T.FileId		
	FROM dbo.vwFolderHistoryRemove FHR
	CROSS APPLY (SELECT TOP 1 FileVersionId, FileId, FolderId, DirId
			FROM #FileVersions V
			WHERE RowNum = 1
				AND DirVersionId <= FHR.DirVersionId
			ORDER BY V.DirVersionId DESC) T 
	WHERE FHR.[FolderId] = T.FolderId
	AND FHR.DirId = T.DirId
	AND EXISTS (SELECT 1 FROM #FileVersions V WHERE V.DirVersionId <= FHR.DirVersionId)
	AND NOT EXISTS (
			SELECT 1
			FROM dbo.vwFileHistoryRemove DFHR
			WHERE DFHR.FileId = T.FileId
				AND DFHR.[FolderId] = T.FolderId
				AND DFHR.DirVersionId = FHR.DirVersionId
				AND NOT EXISTS (
					SELECT 1
					FROM dbo.vwFileHistoryRestore DFHRes
					WHERE DFHRes.[FolderId] = T.FolderId
						AND DFHRes.FileId = T.FileId
						AND DFHRes.PreviousFileVersionId = DFHR.FileVersionId
					)
			)

--Как улучшить данный запрос, сложно сказать
--Да и особых предположений по данному скрипту нет
--Но вынесу свое предположение
--что во временной таблице хранится какая-то рабочая ситуация (файлы и каталоги)
--и для каждого удаленного каталога проверятся наличие хотя бы одного файла/каталога
--которые не были удалены или восстановлены