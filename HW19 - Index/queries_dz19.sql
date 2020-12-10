--Прилагаю сюда часть скрипта на создание базы данных проекта
--Основной скрипт в каталоге project



--Go to master
USE master;
GO



--Drop DB if exists
IF DB_ID(N'CarShowroom') IS NOT NULL
DROP DATABASE CarShowroom;
GO



--Create DB
CREATE DATABASE CarShowroom
ON
(
	NAME = N'CarShowroom_dat',
	FILENAME = N'C:\DB\db_cs_dat.mdf',
	SIZE = 64,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 8
)
LOG ON
(
	NAME = N'CarShowroom_log',
	FILENAME = N'C:\DB\db_cs_log.ldf',
	SIZE = 8,
	MAXSIZE = 512,
	FILEGROWTH = 4
);
GO



--Go to our DB
USE CarShowroom;
GO



--Create tables



--А теперь делаем анализ на примере одной таблицы

--Countries
CREATE TABLE Countries
(
	ID TINYINT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_Countries_ID PRIMARY KEY,
	CountryName NVARCHAR(128) NOT NULL,
	CountryCode NCHAR(3) NOT NULL,
	CONSTRAINT UQ_Countries_CountryName UNIQUE (CountryName),
	CONSTRAINT UQ_Countries_CountryCode UNIQUE (CountryCode)
);

--Как видно, при создании таблицы мы создаем уникальные значения, что должно создать индекс

--Далее закинем немного данных

USE CarShowroom;
GO

insert into Countries (CountryName, CountryCode)
values ('Austria', 'AUT');
insert into Countries (CountryName, CountryCode)
values ('Australia', 'AUS');
insert into Countries (CountryName, CountryCode)
values ('Argentina', 'ARG');
insert into Countries (CountryName, CountryCode)
values ('Brazil', 'BRA');
insert into Countries (CountryName, CountryCode)
values ('Belgium', 'BEL');
insert into Countries (CountryName, CountryCode)
values ('Czech Republic', 'CZE');
insert into Countries (CountryName, CountryCode)
values ('Canada', 'CAN');


--И теперь поселектим с включенным планом запроса

select * from Countries;
--Получаем Clustered index scan PK_Countries_ID


select * from Countries where CountryName = 'Canada';
--Имеем Index seek UQ_Countries_CountryName и при этом получаем Key lookup по PK_Countries_ID и Nested loops

select * from Countries where CountryCode = 'CAN';
--Ситуация аналогична, но только фигурирует UQ_Countries_CountryCode

select CountryCode from Countries where CountryName = 'Canada';
select CountryName from Countries where CountryCode = 'CAN';
--Все равно имеем index seek вместе с key lookup и nested loops (удивило)



--Создадим индекс для наименования
CREATE INDEX IX_Countries_CountryName ON Countries (CountryName);
--и при запросе
select CountryCode from Countries where CountryName = 'Canada';
--получим ту же картину с key lookup и nested loops но только теперь будет IX_Countries_CountryName
--поэтому создание дополнительных таких индексов не нужно

--удалим его
drop index Countries.IX_Countries_CountryName;

--создадим составной индекс
CREATE INDEX IX_Countries_CountryNameCode ON Countries (CountryName, CountryCode);
--и теперь при запросе
select CountryCode from Countries where CountryName = 'Canada';
--у нас только index seek IX_Countries_CountryNameCode

--удалим и его
drop index Countries.IX_Countries_CountryNameCode;

--создадим покрывающий
create index IX_Countries_CountryNameINCLCode on Countries (CountryName) include (CountryCode);
--и при запросе
select CountryCode from Countries where CountryName = 'Canada';
--получим только index seek IX_Countries_CountryNameINCLCode

--удалим и его
drop index Countries.IX_Countries_CountryNameINCLCode;


--сделаем
select * from Countries where id = 7;
--и получим clustered index seek PK_Countries_ID

--при запросе
select id from Countries where CountryName = 'Canada';
--получим index seek UQ_Countries_CountryName


--Добавим таблицу
--Firm
CREATE TABLE Firm
(
	ID INT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_Firm_ID PRIMARY KEY,
	MakerName NVARCHAR(64) NOT NULL,
	AddressFirm NVARCHAR(512) NOT NULL,
	CountryID TINYINT NOT NULL,
	Comment NVARCHAR(2048) NULL,
	CONSTRAINT UQ_Firm_MakerName UNIQUE (MakerName),
	CONSTRAINT FK_Firm_CountryID FOREIGN KEY (CountryID) REFERENCES Countries(ID)
);

--и так же кинем чуть данных
insert into Firm (MakerName, AddressFirm, CountryID)
values ('AAA', 'Adr1', 1);
insert into Firm (MakerName, AddressFirm, CountryID)
values ('BBB', 'Adr2', 7);

--а далее сделаем запросы

select
	f.MakerName
from
	Firm f
		join Countries c on c.ID = f.CountryID
where
	c.CountryName = 'Canada';

--В этом случае видим
--clustered index scan PK_Firm_ID
--clustered index seek PK_Countries_ID
--Оба уходят в nested loops


select
	c.CountryName
from
	Countries c
		join Firm f on f.CountryID = c.ID
where
	f.MakerName = 'AAA';

--В этом случае видим
--index seek UQ_Firm_MakerName вместе с key lookup PK_Firm_ID уходящие в nested loops
--и второй nested loops в который приходят данные из верхнего описания и clustered index seek PK_Countries_ID