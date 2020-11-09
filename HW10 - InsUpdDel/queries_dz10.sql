--1
/*
Довставлять в базу 5 записей используя insert в таблицу Customers или Suppliers
*/

insert into Purchasing.Suppliers
(
SupplierName,
SupplierCategoryID,
PrimaryContactPersonID,
AlternateContactPersonID,
DeliveryCityID,
PostalCityID,
PaymentDays,
PhoneNumber,
FaxNumber,
WebsiteURL,
DeliveryAddressLine1,
DeliveryPostalCode,
PostalAddressLine1,
PostalPostalCode,
LastEditedBy
)
values
(
'Aa Aa',
2,
3260,
3259,
38180,
38180,
28,
'(111) 111-1111',
'(111) 111-1112',
'https://aaaa.org',
'DAL 1',
'11111',
'PAL 1',
'11111',
1
), --1
(
'Bb Bb',
3,
3258,
3257,
38179,
38179,
28,
'(222) 222-2222',
'(222) 222-2223',
'https://bbbb.org',
'DAL 2',
'22222',
'PAL 2',
'22222',
1
), --2
(
'Cc Cc',
4,
3256,
3255,
38178,
38178,
28,
'(333) 333-3333',
'(333) 333-3334',
'https://cccc.org',
'DAL 3',
'33333',
'PAL 3',
'33333',
1
), --3
(
'Dd Dd',
5,
3254,
3253,
38177,
38177,
28,
'(444) 444-4444',
'(444) 444-4445',
'https://dddd.org',
'DAL 4',
'44444',
'PAL 4',
'44444',
1
), --4
(
'Ee Ee',
6,
3252,
3251,
38176,
38176,
28,
'(555) 555-5555',
'(555) 555-5556',
'https://eeee.org',
'DAL 5',
'55555',
'PAL 5',
'55555',
1
) --5
;




--2
/*
удалите 1 запись из Customers, которая была вами добавлена
*/

delete from Purchasing.Suppliers where SupplierName = 'Cc Cc';




--3
/*
изменить одну запись, из добавленных через UPDATE
*/

update Purchasing.Suppliers
set DeliveryMethodID = 10
where SupplierName = 'Aa Aa';




--4
/*
Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

select * into Purchasing.Suppliers4 from Purchasing.Suppliers where 1 = 2;

insert into Purchasing.Suppliers4
(
SupplierID,
SupplierName,
SupplierCategoryID,
PrimaryContactPersonID,
AlternateContactPersonID,
DeliveryCityID,
PostalCityID,
PaymentDays,
PhoneNumber,
FaxNumber,
WebsiteURL,
DeliveryAddressLine1,
DeliveryPostalCode,
PostalAddressLine1,
PostalPostalCode,
LastEditedBy,
ValidFrom,
ValidTo
)
values
(
1,
'Ee Ee',
6,
3251,
3250,
38175,
38175,
28,
'(555) 555-5557',
'(555) 555-5558',
'https://eeee1.org',
'DAL 51',
'55555',
'PAL 51',
'55555',
1,
getdate(),
getdate()+10
), --5
(
2,
'Ff Ff',
7,
3249,
3248,
38173,
38173,
28,
'(666) 666-6666',
'(666) 666-6667',
'https://ffff.org',
'DAL 6',
'66666',
'PAL 6',
'66666',
1,
getdate(),
getdate()+11
) --6
;

merge Purchasing.Suppliers as t_target
using Purchasing.Suppliers4 as t_source
on (t_target.SupplierName = t_source.SupplierName)
when matched then --update
	update set
	SupplierName = t_source.SupplierName,
	SupplierCategoryID = t_source.SupplierCategoryID,
	PrimaryContactPersonID = t_source.PrimaryContactPersonID,
	AlternateContactPersonID = t_source.AlternateContactPersonID,
	DeliveryCityID = t_source.DeliveryCityID,
	PostalCityID = t_source.PostalCityID,
	PaymentDays = t_source.PaymentDays,
	PhoneNumber = t_source.PhoneNumber,
	FaxNumber = t_source.FaxNumber,
	WebsiteURL = t_source.WebsiteURL,
	DeliveryAddressLine1 = t_source.DeliveryAddressLine1,
	DeliveryPostalCode = t_source.DeliveryPostalCode,
	PostalAddressLine1 = t_source.PostalAddressLine1,
	PostalPostalCode = t_source.PostalPostalCode,
	LastEditedBy = t_source.LastEditedBy
when not matched then --insert
	insert
	(
	SupplierName,
	SupplierCategoryID,
	PrimaryContactPersonID,
	AlternateContactPersonID,
	DeliveryCityID,
	PostalCityID,
	PaymentDays,
	PhoneNumber,
	FaxNumber,
	WebsiteURL,
	DeliveryAddressLine1,
	DeliveryPostalCode,
	PostalAddressLine1,
	PostalPostalCode,
	LastEditedBy
	)
	values
	(
	t_source.SupplierName,
	t_source.SupplierCategoryID,
	t_source.PrimaryContactPersonID,
	t_source.AlternateContactPersonID,
	t_source.DeliveryCityID,
	t_source.PostalCityID,
	t_source.PaymentDays,
	t_source.PhoneNumber,
	t_source.FaxNumber,
	t_source.WebsiteURL,
	t_source.DeliveryAddressLine1,
	t_source.DeliveryPostalCode,
	t_source.PostalAddressLine1,
	t_source.PostalPostalCode,
	t_source.LastEditedBy
	)
;




--5
/*
Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

EXEC sp_configure 'show advanced options', 1;
GO


RECONFIGURE;
GO


EXEC sp_configure 'xp_cmdshell', 1;
GO


RECONFIGURE;
GO


SELECT @@SERVERNAME;


exec master..xp_cmdshell 'bcp "[WideWorldImporters].Purchasing.Suppliers" out  "C:\Temp\PurcSuppBulk.txt" -T -w -t"--IGOR--" -S DESKTOP-1LNI38F\SQL2017';


select * into Purchasing.Suppliers5 from Purchasing.Suppliers where 1 = 2;


bulk insert [WideWorldImporters].Purchasing.Suppliers5
from "C:\Temp\PurcSuppBulk.txt"
with
(
BATCHSIZE = 1000,
DATAFILETYPE = 'widechar',
FIELDTERMINATOR = '--IGOR--',
ROWTERMINATOR ='\n',
KEEPNULLS,
TABLOCK
);