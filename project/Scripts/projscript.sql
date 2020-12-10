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

--Sexes
CREATE TABLE Sexes
(
	ID TINYINT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_Sexes_ID PRIMARY KEY,
	SexName NVARCHAR(16) NOT NULL,
	CONSTRAINT UQ_Sexes_SexName UNIQUE (SexName)
);



--Countries
CREATE TABLE Countries
(
	ID TINYINT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_Countries_ID PRIMARY KEY,
	CountryName NVARCHAR(128) NOT NULL,
	CountryCode NCHAR(3) NOT NULL,
	CONSTRAINT UQ_Countries_CountryName UNIQUE (CountryName),
	CONSTRAINT UQ_Countries_CountryCode UNIQUE (CountryCode)
);



--Employees
CREATE TABLE Employees
(
	ID INT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_Employees_ID PRIMARY KEY,
	NameF NVARCHAR(64) NOT NULL,
	NameI NVARCHAR(64) NOT NULL,
	NameO NVARCHAR(64) NULL,
	BirthDate DATE NOT NULL,
	SexID TINYINT NOT NULL,
	NationID TINYINT NOT NULL,
	AddressEmp NVARCHAR(512) NOT NULL,
	DocumentEmp NVARCHAR(512) NOT NULL,
	NumTab NVARCHAR(16) NOT NULL,
	HireDate DATE NOT NULL,
	DismissDate DATE NOT NULL CONSTRAINT DF_Employees_DismissDate DEFAULT ('9999-12-31'),
	LoginEmp NVARCHAR(16) NOT NULL,
	EmailEmp NVARCHAR(32) NOT NULL,
	PhoneEmp NVARCHAR(16) NOT NULL,
	ManagerID INT NULL,
	CONSTRAINT FK_Employees_SexID FOREIGN KEY (SexID) REFERENCES Sexes(ID),
	CONSTRAINT FK_Employees_NationID FOREIGN KEY (NationID) REFERENCES Countries(ID),
	CONSTRAINT UQ_Employees_DocumentEmp UNIQUE (DocumentEmp),
	CONSTRAINT UQ_Employees_NumTab UNIQUE (NumTab),
	CONSTRAINT UQ_Employees_LoginEmp UNIQUE (LoginEmp),
	CONSTRAINT UQ_Employees_EmailEmp UNIQUE (EmailEmp),
	CONSTRAINT UQ_Employees_PhoneEmp UNIQUE (PhoneEmp),
	CONSTRAINT FK_Employees_ManagerID FOREIGN KEY (ManagerID) REFERENCES Employees(ID)
);

--Indexes for Employees
CREATE INDEX IX_Employees_NameFIO ON Employees (NameF, NameI, NameO);
CREATE INDEX IX_Employees_BirthDate ON Employees (BirthDate);
CREATE INDEX IX_Employees_HireDate ON Employees (HireDate);
CREATE INDEX IX_Employees_DismissDate ON Employees (DismissDate);



--Departments
CREATE TABLE Departments
(
	ID SMALLINT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_Departments_ID PRIMARY KEY,
	DepartmentName NVARCHAR(64) NOT NULL,
	StartDate DATE NOT NULL,
	EndDate DATE NOT NULL CONSTRAINT DF_Departments_EndDate DEFAULT ('9999-12-31'),
	ManagerID INT NOT NULL,
	CONSTRAINT UQ_Departments_DepartmentName UNIQUE (DepartmentName),
	CONSTRAINT FK_Departments_ManagerID FOREIGN KEY (ManagerID) REFERENCES Employees(ID)
);



--Jobs
CREATE TABLE Jobs
(
	ID SMALLINT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_Jobs_ID PRIMARY KEY,
	JobName NVARCHAR(32) NOT NULL,
	StartDate DATE NOT NULL,
	EndDate DATE NOT NULL CONSTRAINT DF_Jobs_EndDate DEFAULT ('9999-12-31'),
	MinSalary DECIMAL(11,2) NOT NULL,
	MaxSalary DECIMAL(11,2) NOT NULL,
	CONSTRAINT UQ_Jobs_JobName UNIQUE (JobName)
);



--Appointments
CREATE TABLE Appointments
(
	ID INT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_Appointments_ID PRIMARY KEY,
	EmpID INT NOT NULL,
	StartDate DATE NOT NULL,
	EndDate DATE NOT NULL CONSTRAINT DF_Appointments_EndDate DEFAULT ('9999-12-31'),
	DepID SMALLINT NOT NULL,
	JobID SMALLINT NOT NULL,
	RateEmp DECIMAL(3,2) NOT NULL CONSTRAINT DF_Appointments_RateEmp DEFAULT 1,
	SalaryEmp DECIMAL(11,2) NOT NULL,
	CONSTRAINT FK_Appointments_EmpID FOREIGN KEY (EmpID) REFERENCES Employees(ID),
	CONSTRAINT FK_Appointments_DepID FOREIGN KEY (DepID) REFERENCES Departments(ID),
	CONSTRAINT FK_Appointments_JobID FOREIGN KEY (JobID) REFERENCES Jobs(ID)
);

--Indexes for Appointments
CREATE INDEX IX_Appointments_StartDate ON Appointments (StartDate);
CREATE INDEX IX_Appointments_EndDate ON Appointments (EndDate);
CREATE INDEX IX_Appointments_SalaryEmp ON Appointments (SalaryEmp);



--Clients
CREATE TABLE Clients
(
	ID INT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_Clients_ID PRIMARY KEY,
	NameF NVARCHAR(64) NOT NULL,
	NameI NVARCHAR(64) NOT NULL,
	NameO NVARCHAR(64) NULL,
	BirthDate DATE NOT NULL,
	SexID TINYINT NULL,
	NationID TINYINT NULL,
	AddressClient NVARCHAR(512) NULL,
	DocClient NVARCHAR(512) NOT NULL,
	PhoneClient NVARCHAR(16) NOT NULL,
	Discount DECIMAL(4,2) NULL,
	Comment NVARCHAR(2048) NULL,
	CONSTRAINT FK_Clients_SexID FOREIGN KEY (SexID) REFERENCES Sexes(ID),
	CONSTRAINT FK_Clients_NationID FOREIGN KEY (NationID) REFERENCES Countries(ID),
	CONSTRAINT UQ_Clients_DocClient UNIQUE (DocClient),
	CONSTRAINT UQ_Clients_PhoneClient UNIQUE (PhoneClient)
);

--Indexes for Clients
CREATE INDEX IX_Clients_NameFIO ON Clients (NameF, NameI, NameO);
CREATE INDEX IX_Clients_BirthDate ON Clients (BirthDate);



--Sales
CREATE TABLE Sales
(
	ID INT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_Sales_ID PRIMARY KEY,
	NumSal NVARCHAR(32) NOT NULL,
	EmpID INT NOT NULL,
	ClientID INT NOT NULL,
	DateSal DATETIME2 NOT NULL,
	Discount DECIMAL(4,2) NULL,
	Comment NVARCHAR(2048) NULL,
	CONSTRAINT UQ_Sales_NumSal UNIQUE (NumSal),
	CONSTRAINT FK_Sales_EmpID FOREIGN KEY (EmpID) REFERENCES Employees(ID),
	CONSTRAINT FK_Sales_ClientID FOREIGN KEY (ClientID) REFERENCES Clients(ID)
);

--Indexes for Sales
CREATE INDEX IX_Sales_NumSal ON Sales (NumSal);
CREATE INDEX IX_Sales_DateSal ON Sales (DateSal);



--Categoyry
CREATE TABLE Category
(
	ID TINYINT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_Category_ID PRIMARY KEY,
	NameCat NVARCHAR(64) NOT NULL,
	TableCat NVARCHAR(32) NOT NULL,
	Comment NVARCHAR(2048) NULL,
	CONSTRAINT UQ_Category_NameCat UNIQUE (NameCat),
	CONSTRAINT UQ_Category_TableCat UNIQUE (TableCat)
);



--SalesLines
CREATE TABLE SalesLines
(
	ID INT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_SalesLines_ID PRIMARY KEY,
	SalesID INT NOT NULL,
	CategoryID TINYINT NOT NULL,
	PositionID INT NOT NULL,
	Quantity INT NOT NULL,
	SumSal DECIMAL(11,2) NOT NULL,
	Discount DECIMAL(4,2) NULL,
	SumSalItog DECIMAL(11,2) NOT NULL,
	Comment NVARCHAR(2048) NULL,
	CONSTRAINT FK_SalesLines_SalesID FOREIGN KEY (SalesID) REFERENCES Sales(ID),
	CONSTRAINT FK_SalesLines_CategoryID FOREIGN KEY (CategoryID) REFERENCES Category(ID)
);

--Indexes for SalesLines



--CarServices
CREATE TABLE CarServices
(
	ID INT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_CarServices_ID PRIMARY KEY,
	CategoryID TINYINT NOT NULL,
	ServiceName NVARCHAR(64) NOT NULL,
	Price DECIMAL(11,2) NOT NULL,
	Comment NVARCHAR(2048) NULL,
	CONSTRAINT FK_CarServices_CategoryID FOREIGN KEY (CategoryID) REFERENCES Category(ID),
	CONSTRAINT UQ_CarServices_ServiceName UNIQUE (ServiceName)
);



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