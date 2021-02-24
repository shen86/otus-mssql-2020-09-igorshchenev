--Go to our DB
USE CarShowroom;
GO



--Insert some data

--Sexes
INSERT INTO Sexes
VALUES
('Male'),
('Female'),
('Other');


--Countries
INSERT INTO Countries
VALUES
('Russia', 'RUS'),
('Germany', 'DEU'),
('Japan', 'JPN');


--Employees
INSERT INTO Employees
VALUES
('Ivanov', 'Ivan', 'Ivanovich', '1971-01-01', 1, 1, 'Adres1', 'Pasport1',
'RU0000100001', '2020-01-01', default, 'IIvanov', 'IIvanov@company.com', '10-01', null),
('Sidorova', 'Svetlana', 'Sergeevna', '1982-06-30', 2, 1, 'Adres2', 'Pasport2',
'RU0000100002', '2020-03-11', default, 'SSidorova', 'SSidorova@company.com', '12-03', 1),
('Pereprodazhnikov', 'Stepan', 'Arkadievich', '1990-11-25', 1, 1, 'Adres3', 'Pasport3', 
'RU0000100003', '2020-10-21', default, 'SPereprodazhniko', 'SPereprodazhniko@company.com', '12-10', 2);


--Departments
INSERT INTO Departments
VALUES
('Direction', '1900-01-01', default, 1),
('Sales department', '1900-01-01', default, 2);


--Jobs
INSERT INTO Jobs
VALUES
('Director', '1900-01-01', default, 500000, 900000),
('Manager', '1900-01-01', default, 100000, 300000),
('Seller', '1900-01-01', default, 70000, 170000);


--Appointments
INSERT INTO Appointments
VALUES
(1, '2020-01-01', default, 1, 1, default, 750000),
(2, '2020-03-11', default, 2, 2, default, 150000),
(3, '2020-10-21', default, 2, 3, default, 85000);


--Clients
INSERT INTO Clients
VALUES
('Petrov', 'Petr', 'Petrovich', '2001-02-28', 1, 1, null, 'DocClient1', '+79999999999', null, null);


--Category
INSERT INTO Category
VALUES
('Uslugi', 'CarServices', 'Uslugi for clients'),
('Zapchasti', 'CarParts', 'Raznie zapchasti'),
('Auto', 'Cars', 'Avtomobili');


--CarServices
INSERT INTO CarServices
VALUES
(1, 'Mountung of car wheels', 4000, 'Shinomontag'),
(1, 'Storage of car wheels', 6000, 'Hranenie rezini');


--Color
INSERT INTO Color
VALUES
('Red'),
('Green');


--Firm
INSERT INTO Firm
VALUES
('VAZ', 'Adres111', 1, 'Zhiguli');


--CarParts
INSERT INTO CarParts
VALUES
(2, 'Bamper', null, null, 1, null, 1, 1000, null, null);


--CarBody
INSERT INTO CarBody
VALUES
('Sedan', 4, null),
('Cabriolet', 2, null);


--DriveType
INSERT INTO DriveType
VALUES
('Front-wheel drive', 'Peredniy privod'),
('Full-wheel drive', 'Polniy privod');


--Transmission
INSERT INTO Transmission
VALUES
('Automat', null),
('Manual', null);


--Cars
INSERT INTO Cars
VALUES
(3, 'Lada XRAY', '5TDZA22C74S187196', 1, 2020, null, null, 1, null, 1, 1, 1, 2, 1000000, null);


--Sales
INSERT INTO Sales
VALUES
('2021-AUTO-0001', 3, 1, getdate(), 'Prodal avto');


--SalesLines
INSERT INTO SalesLines
VALUES
(1, 3, 1, 1, 1000000, null, 1000000, 'FIRST SALE'),
(1, 2, 1, 1, 1000, null, 1000, null);