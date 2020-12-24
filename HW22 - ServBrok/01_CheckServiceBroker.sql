--Проверим работу сервис брокер

use master;
go

select name, is_broker_enabled from sys.databases;

/*
name					is_broker_enabled
-----------------------------------------
master					0
tempdb					1
model					0
msdb					1
WideWorldImporters		0
AdventureWorks2017		0
WideWorldImportersDW	0
*/

--Видим, что SB на базе WWI отключен

--Попробуем включить

use master;
go

alter database WideWorldImporters set enable_broker;

--Commands completed successfully.

--Далее доделаем 2 скрипта

ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;

ALTER AUTHORIZATION    
   ON DATABASE::WideWorldImporters TO [sa];

--Проверим

use master;
go

select name, is_broker_enabled from sys.databases;

/*
name					is_broker_enabled
-----------------------------------------
master					0
tempdb					1
model					0
msdb					1
WideWorldImporters		1
AdventureWorks2017		0
WideWorldImportersDW	0
*/