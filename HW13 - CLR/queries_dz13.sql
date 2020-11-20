--1
/*
Хотелось бы конечно попробовать все пункты, но на это катастрофически не хватает времени
Поэтому был выбран 1 вариант
*/

--Скрипт из урока

-- Включаем CLR
exec sp_configure 'show advanced options', 1;
GO
reconfigure;
GO

exec sp_configure 'clr enabled', 1;
exec sp_configure 'clr strict security', 0 
GO

-- clr strict security 
-- 1 (Enabled): заставляет Database Engine игнорировать сведения PERMISSION_SET о сборках 
-- и всегда интерпретировать их как UNSAFE. По умолчанию, начиная с SQL Server 2017.

reconfigure;
GO

-- Для возможности создания сборок с EXTERNAL_ACCESS или UNSAFE
ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;




--Далее выполняем скрипт SQLSharp_SETUP

--Скрипт выполнял следующим образом

/*

EXEC SP_ChangeDBOwner 'sa'; --делал так потому что была ошибка

Msg 50000, Level 16, State 1, Line 2521 Line 203, Msg 50000:  The Security ID (SID) of the database owner ([owner_sid] field) for [WideWorldImporters] in [master].[sys].[databases]:.......

Воспользовался советами

https://sqlsharp.com/faq/#q28
https://stackoverflow.com/questions/12389656/the-database-owner-sid-recorded-in-the-master-database-differs-from-the-database

ALTER DATABASE [master] SET TRUSTWORTHY ON;
GO

скрипт в котором менял наименование бызы на - USE [WideWorldImporters]; (общий скрипт приложил к дз)

ALTER DATABASE [master] SET TRUSTWORTHY OFF;
GO

*/




--Далее пробуем

create or alter function user_CubeRoot (@FNumber float)
returns float
as external name [SQL#].[MATH].CubeRoot;
go

select SQL#.Math_CubeRoot(27); --3

select dbo.user_CubeRoot(27); --3




create or alter function user_StringEndsWith (@FString nvarchar(max), @FSearch nvarchar(4000), @FOption int)
returns bit
as external name [SQL#].[STRING].EndsWith;
go

select SQL#.String_EndsWith('Hello!!!','!',1); --1

select dbo.user_StringEndsWith('Hello!!!','!',1); --1




create or alter function user_UnixTime (@FNumber float)
returns datetime
as external name [SQL#].[DATE].FromUNIXTime;
go

select SQL#.Date_FromUNIXTime(1); --1970-01-01 00:00:01.000

select dbo.user_UnixTime(2); --1970-01-01 00:00:02.000