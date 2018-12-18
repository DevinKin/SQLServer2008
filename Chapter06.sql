USE Accounting;

-- CREATE PRIMARY KEY
ALTER TABLE Employees
	ADD CONSTRAINT PK_Employees
	PRIMARY KEY (EmployeeID);

CREATE TABLE Customers
(
	CustomerNo	INT		IDENTITY	NOT NULL PRIMARY KEY,
	CustomerName	VARCHAR(30)		NOT NULL,
	Address1		VARCHAR(30)		NOT NULL,
	Address2		VARCHAR(30)		NOT NULL,
	City			VARCHAR(20)		NOT NULL,
	State			CHAR(2)			NOT NULL,
	Zip				VARCHAR(10)		NOT NULL,
	Contact			VARCHAR(25)		NOT NULL,
	Phone			CHAR(15)		NOT NULL,
	FedIDNo			VARCHAR(9)		NOT NULL,
	DateInSystem	SMALLDATETIME	NOT NULL
);

CREATE TABLE Orders
(
	OrderID		INT		IDENTITY		NOT NULL	PRIMARY KEY,
	CustomerNo	INT		NOT NULL	FOREIGN KEY REFERENCES Customers(CustomerNo),
	OrderDate	DATE	NOT NULL,
	EmployeeID	INT		NOT NULL
);

EXEC sp_helpconstraint Orders;

ALTER TABLE Orders
	ADD CONSTRAINT FK_EmployeeCreatesOrder
	FOREIGN KEY(EmployeeID) REFERENCES Employees(EmployeeID);

EXEC sp_helpconstraint Orders;

INSERT INTO DBO.Employees(FirstName, LastName, Title, SSN, Salary, PriorSalary, HireDate, ManagerEmpID, Department)
	VALUES('Billy Bob', 'Boson', 'Head Cook & Bottle Washer', '123-45-6789', 100000, 80000, '1990-01-01', 1, 'Cooking and Bottling');

SELECT * FROM Employees;

ALTER TABLE Employees
	ADD CONSTRAINT FK_EmployeeHasManager
	FOREIGN KEY (ManagerEmpID) REFERENCES Employees(EmployeeID);

EXEC sp_helpconstraint Employees;

CREATE TABLE OrderDetails
(
	OrderID		INT			NOT NULL,
	PartNo		VARCHAR(10)	NOT NULL,
	Description	VARCHAR(25)	NOT NULL,
	UnitPrice	MONEY		NOT NULL,
	Qty			INT			NOT NULL,
	CONSTRAINT	PK_OrderDetails
		PRIMARY KEY(OrderID, PartNo),
	CONSTRAINT	FK_OrderConstainsDetails
		FOREIGN	KEY(OrderID)
			REFERENCES	Orders(OrderID)
			ON UPDATE NO ACTION
			ON DELETE CASCADE
);


INSERT INTO Customers
	VALUES('Billy Bob''s Shoes', '123 Main St.', ' ', 'Vancouver', 'WA', '98685', 'Billy Bob', '(360) 555-1234', '931234567', GETDATE());

SELECT * FROM Customers;

INSERT INTO Orders(CustomerNo, OrderDate, EmployeeID)
	VALUES(1, GETDATE(), 1);

INSERT INTO OrderDetails
	VALUES(1, '4X4525', 'This is a part', 25.00, 2);

SELECT * FROM Orders;

SELECT OrderID, PartNo FROM OrderDetails;

-- DELETE Order and see the CASCADE effect
DELETE Orders
WHERE OrderID = 1;


-- UNIQUE 约束
CREATE TABLE Shippers
(
	ShipperID	INT		IDENTITY	NOT NULL	PRIMARY KEY,
	ShipperName	VARCHAR(30)			NOT NULL,
	Address		VARCHAR(30)			NOT NULL,
	City		VARCHAR(25)			NOT NULL,
	State		CHAR(2)				NOT NULL,
	Zip			VARCHAR(10)			NOT NULL,
	PhoneNo		VARCHAR(14)			NOT NULL	UNIQUE
);

EXEC sp_helpconstraint Shippers;

ALTER TABLE Employees
	ADD CONSTRAINT AK_EmployeeSSN
	UNIQUE(SSN);

EXEC sp_helpconstraint Employees;

ALTER TABLE Customers
	ADD CONSTRAINT CN_CustomerDateInSystem
	CHECK
	(DateInSystem <= GETDATE());

EXEC sp_helpconstraint Customers;

-- 插入违反CHECK约束的记录
INSERT INTO Customers(CustomerName, Address1, Address2, City, State, Zip, Contact, Phone, FedIDNo, DateInSystem)
	VALUES
('Customer1', 'Address1', 'Add2', 'MyCity', 'NY', '55555',
'No Concat', '553-1212', '930984954', '12-31-2049');

-- 正常插入
INSERT INTO Customers(CustomerName, Address1, Address2, City, State, Zip, Contact, Phone, FedIDNo, DateInSystem)
	VALUES
('Customer1', 'Address1', 'Add2', 'MyCity', 'NY', '55555',
'No Concat', '553-1212', '930984954', GETDATE());

-- 创建表时指定DEFAULT约束
CREATE TABLE Shippers
(
	ShipperID	INT		IDENTITY	NOT NULL	PRIMARY KEY,
	ShipperName	VARCHAR(30)			NOT NULL,
	DateInSystem	SMALLDATETIME	NOT NULL	DEFAULT	GETDATE()
);

INSERT INTO Shippers(ShipperName)
	VALUES('United Parcel Service');

SELECT * FROM Shippers;


-- 在已存在的表中添加DEFAULT约束
ALTER TABLE Customers
	ADD CONSTRAINT CN_CustomerDefaultDateInSystem
		DEFAULT GETDATE() FOR DateInSystem;

EXEC sp_helpconstraint Customers;

ALTER TABLE Customers
	ADD CONSTRAINT CN_CustomerAddress
		DEFAULT 'UNKNOW' FOR Address1;

INSERT INTO Customers(CustomerName, Address1, Address2, City, State, Zip, Contact, Phone, FedIDNo, DateInSystem)
	VALUES('MyCust', '123 Anywhere', '', 'Reno', 'NV', 80808, 'Joe Bob', '555-1212', '931234567', GETDATE());

-- error, 已存在的数据不满足约束条件
ALTER TABLE Customers
	ADD CONSTRAINT CN_CustomerPhoneNo
	CHECK
	(Phone LIKE '([0-9][0-9][0-9]) [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');
	
ALTER TABLE Customers
	WITH NOCHECK
	ADD CONSTRAINT CN_CustomerPhoneNo
	CHECK
	(Phone LIKE '([0-9][0-9][0-9]) [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');

SELECT * FROM Customers;

EXEC sp_helpconstraint Customers;

INSERT INTO Customers(CustomerName, Address1, Address2, City, State, Zip, Contact, Phone, FedIDNo, DateInSystem)
	VALUES('MyCust', '123 Anywhere', '', 'Reno', 'NV', 80808, 'Joe Bob', '(800) 555-1212', '931234567', GETDATE());