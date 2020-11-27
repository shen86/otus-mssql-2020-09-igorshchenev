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
	ID SMALLINT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_Countries_ID PRIMARY KEY,
	CountryName NVARCHAR(128) NOT NULL,
	CountryCode NCHAR(3) NOT NULL,
	CONSTRAINT UQ_Countries_CountryName UNIQUE (CountryName),
	CONSTRAINT UQ_Countries_CountryCode UNIQUE (CountryCode)
);

--Indexes for Countries
CREATE INDEX IX_Countries_CountryName ON Countries (CountryName);



--Employees
CREATE TABLE Employees
(
	ID INT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_Employees_ID PRIMARY KEY,
	NameF NVARCHAR(64) NOT NULL,
	NameI NVARCHAR(64) NOT NULL,
	NameO NVARCHAR(64) NULL,
	BirthDate DATE NOT NULL,
	SexID TINYINT NOT NULL,
	NationID SMALLINT NOT NULL,
	AddressEmp NVARCHAR(512) NOT NULL,
	DocumentEmp NVARCHAR(512) NOT NULL,
	NumTab NVARCHAR(16) NOT NULL,
	HireDate DATE NOT NULL,
	DismissDate DATE NOT NULL,
	LoginEmp NVARCHAR(16) NOT NULL,
	EmailEmp NVARCHAR(32) NOT NULL,
	PhoneEmp NVARCHAR(16) NOT NULL,
	ManagerID INT NULL,
	CONSTRAINT FK_Employees_SexID FOREIGN KEY (SexID) REFERENCES Sexes(ID),
	CONSTRAINT FK_Employees_NationID FOREIGN KEY (NationID) REFERENCES Countries(ID),
	CONSTRAINT UQ_Employees_DocumentEmp UNIQUE (DocumentEmp),
	CONSTRAINT UQ_Employees_NumTab UNIQUE (NumTab),
	CONSTRAINT DF_Employees_DismissDate DEFAULT ('9999-12-31') FOR DismissDate,
	CONSTRAINT UQ_Employees_LoginEmp UNIQUE (LoginEmp),
	CONSTRAINT UQ_Employees_EmailEmp UNIQUE (EmailEmp),
	CONSTRAINT UQ_Employees_PhoneEmp UNIQUE (PhoneEmp),
	CONSTRAINT FK_Employees_ManagerID FOREIGN KEY (ManagerID) REFERENCES Employees(ID)
);

--Indexes for Employees
CREATE INDEX IX_Employees_NameF ON Employees (NameF);
CREATE INDEX IX_Employees_NameI ON Employees (NameI);
CREATE INDEX IX_Employees_NameO ON Employees (NameO);
CREATE INDEX IX_Employees_BirthDate ON Employees (BirthDate);
CREATE INDEX IX_Employees_SexID ON Employees (SexID);
CREATE INDEX IX_Employees_NationID ON Employees (NationID);
CREATE INDEX IX_Employees_AddressEmp ON Employees (AddressEmp);
CREATE INDEX IX_Employees_NumTab ON Employees (NumTab);
CREATE INDEX IX_Employees_HireDate ON Employees (HireDate);
CREATE INDEX IX_Employees_DismissDate ON Employees (DismissDate);
CREATE INDEX IX_Employees_LoginEmp ON Employees (LoginEmp);
CREATE INDEX IX_Employees_EmailEmp ON Employees (EmailEmp);
CREATE INDEX IX_Employees_PhoneEmp ON Employees (PhoneEmp);



--Departments
CREATE TABLE Departments
(
	ID INT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_Departments_ID PRIMARY KEY,
	DepartmentName NVARCHAR(64) NOT NULL,
	StartDate DATE NOT NULL,
	EndDate DATE NOT NULL,
	ManagerID INT NOT NULL,
	CONSTRAINT DF_Departments_EndDate DEFAULT ('9999-12-31') FOR EndDate,
	CONSTRAINT FK_Departments_ManagerID FOREIGN KEY (ManagerID) REFERENCES Employees(ID)
);

--Indexes for Departments
CREATE INDEX IX_Departments_DepartmentName ON Departments (DepartmentName);
CREATE INDEX IX_Departments_StartDate ON Departments (StartDate);
CREATE INDEX IX_Departments_EndDate ON Departments (EndDate);



--Jobs
CREATE TABLE Jobs
(
	ID INT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_Jobs_ID PRIMARY KEY,
	JobName NVARCHAR(32) NOT NULL,
	StartDate DATE NOT NULL,
	EndDate DATE NOT NULL,
	MinSalary DECIMAL(11,2) NOT NULL,
	MaxSalary DECIMAL(11,2) NOT NULL,
	CONSTRAINT DF_Jobs_EndDate DEFAULT ('9999-12-31') FOR EndDate
);

--Indexes for Jobs
CREATE INDEX IX_Jobs_JobName ON Jobs (JobName);
CREATE INDEX IX_Jobs_StartDate ON Jobs (StartDate);
CREATE INDEX IX_Jobs_EndDate ON Jobs (EndDate);



--Appointments
CREATE TABLE Appointments
(
	ID INT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_Jobs_ID PRIMARY KEY,
	EmpID INT NOT NULL,
	StartDate DATE NOT NULL,
	EndDate DATE NOT NULL,
	DepID INT NOT NULL,
	JobID INT NOT NULL,
	RateEmp DECIMAL(3,2) NOT NULL,
	SalaryEmp DECIMAL(11,2) NOT NULL,
	CONSTRAINT FK_Appointments_EmpID FOREIGN KEY (EmpID) REFERENCES Employees(ID),
	CONSTRAINT DF_Appointments_EndDate DEFAULT ('9999-12-31') FOR EndDate,
	CONSTRAINT FK_Appointments_DepID FOREIGN KEY (DepID) REFERENCES Departments(ID),
	CONSTRAINT FK_Appointments_JobID FOREIGN KEY (JobID) REFERENCES Jobs(ID),
	CONSTRAINT DF_Appointments_RateEmp DEFAULT 1 FOR RateEmp
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
	NationID SMALLINT NULL,
	AddressClient NVARCHAR(512) NULL,
	DocumentClient NVARCHAR(512) NOT NULL,
	PhoneClient NVARCHAR(16) NOT NULL,
	Discount DECIMAL(4,2) NOT NULL,
	Comment NVARCHAR(2048) NULL,
	CONSTRAINT FK_Clients_SexID FOREIGN KEY (SexID) REFERENCES Sexes(ID),
	CONSTRAINT FK_Clients_NationID FOREIGN KEY (NationID) REFERENCES Countries(ID),
	CONSTRAINT UQ_Clients_DocumentClient UNIQUE (DocumentClient),
	CONSTRAINT DF_Clients_Discount DEFAULT 0 FOR Discount
);

--Indexes for Clients
CREATE INDEX IX_Clients_NameF ON Clients (NameF);
CREATE INDEX IX_Clients_NameI ON Clients (NameI);
CREATE INDEX IX_Clients_NameO ON Clients (NameO);
CREATE INDEX IX_Clients_BirthDate ON Clients (BirthDate);
CREATE INDEX IX_Clients_SexID ON Clients (SexID);
CREATE INDEX IX_Clients_NationID ON Clients (NationID);
CREATE INDEX IX_Clients_AddressClient ON Clients (AddressClient);
CREATE INDEX IX_Clients_Discount ON Clients (Discount);



--Sales