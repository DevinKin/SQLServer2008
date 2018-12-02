-- Ä£Ê½Ãû
SELECT e.NationalIDNumber, p.FirstName, p.LastName, City
	FROM HumanResources.Employee e
	INNER JOIN Person.Person p 
		ON p.BusinessEntityID = e.BusinessEntityID
	INNER JOIN Person.BusinessEntityAddress a
		ON p.BusinessEntityID = a.BusinessEntityID
	INNER JOIN Person.Address pa 
		ON pa.AddressID = a.AddressID; 


CREATE DATABASE Accounting
	ON (NAME = 'Accounting',
		FILENAME = 'E:\Learning\DataBase\SQLServer2012\db\AccountingData.mdf',
		SIZE = 10,
		MAXSIZE = 50,
		FILEGROWTH = 5)
	LOG ON
		(NAME = 'AccountingLog',
		 FILENAME = 'E:\Learning\DataBase\SQLServer2012\db\AccountingLog.ldf',
		 SIZE = 5MB,
		 MAXSIZE = 25MB,
		 FILEGROWTH = 5MB);
GO;

EXEC sp_helpdb 'Accounting';

USE Accounting;
CREATE TABLE Customers
(
	CustomerNo		INT		IDENTITY		NOT NULL,
	CustomerName	VARCHAR(30)				NOT NULL,
	Address1		VARCHAR(30)				NOT NULL,
	Address2		VARCHAR(30)				NOT NULL,
	City			VARCHAR(20)				NOT NULL,
	State			CHAR(2)					NOT NULL,
	Zip				VARCHAR(10)				NOT NULL,
	Contact			VARCHAR(25)				NOT NULL,
	Phone			CHAR(15)				NOT NULL,
	FedIDNo			VARCHAR(9)				NOT NULL,
	DateInSystem	DATE					NOT NULL
);

EXEC sp_help Customers;


CREATE TABLE Employees
(
	EmployeeID	INT	IDENTITY	NOT NULL,
	FirstName	VARCHAR(25)		NOT NULL,
	MiddleInitial	CHAR(1)		NULL,
	LastName	VARCHAR(25)		NOT NULL,
	Title		VARCHAR(25)		NOT NULL,
	SSN			VARCHAR(11)		NOT NULL,
	Salary		MONEY			NOT NULL,
	PriorSalary	MONEY			NOT NULL,
	LastRaise	AS Salary - PriorSalary,
	HireDate	DATE			NOT NULL,
	TerminationDate	DATE		NULL,
	ManagerEmpID	INT			NOT NULL,
	Department		VARCHAR(25)	NOT NULL
);

EXEC sp_help Employees;

ALTER DATABASE Accounting
	MODIFY FILE
	(NAME = Accounting,
	 SIZE = 100MB);


ALTER TABLE Employees
	ADD
		PreviousEmployer	VARCHAR(30)	NULL,
		DateOfBirth			DATE		NULL,
		LastRaiseDate		DATE		NOT NULL	DEFAULT '2018-01-01';

EXEC sp_help Employees;