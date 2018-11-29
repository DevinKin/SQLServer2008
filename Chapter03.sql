CREATE TABLE Stores (
	StoreCode char(4) NOT NULL PRIMARY KEY,
	Name VARCHAR(40) NOT NULL,
	Address VARCHAR(40) NULL,
	City VARCHAR(20) NOT NULL,
	State char(2) NOT NULL,
	Zip CHAR(5) NOT NULL
);

CREATE TABLE Sales (
	OrderNumber VARCHAR(20) NOT NULL PRIMARY KEY,
	StoreCode CHAR(4) NOT NULL FOREIGN KEY REFERENCES Stores(StoreCode),
	OrderDate date NOT NULL,
	Quantity int NOT NULL,
	Terms VARCHAR(12) NOT NULL,
	TitleID int NOT NULL
);

INSERT INTO Stores
VALUES('TEST', 'Test Store', '1234 Anywhere Street', 'Here', 'NY', '00319');


SELECT * FROM Stores;

INSERT INTO Stores(StoreCode, Name, City, State, Zip)
VALUES
('TST2', 'Test Store', 'Here', 'NY', '00319');

INSERT INTO Sales
(StoreCode, OrderNumber, OrderDate, Quantity, Terms, TitleID)
VALUES
('TST2','TESTORDER2','01/01/1999',10,'NET 30', 1234567),
('TST2','TESTORDER3','02/01/1999',10,'NET 30', 1234567);


/* This next statement is going to use code to
** change the "current" database to AdventureWorks.
** This makes certain, right in the code, that you are going
** to the correct database.
*/

USE AdventureWorks2017;

/* This next statement declares your working table.
** This particular table is actually a variable you are declaring
** on the fly.
*/
DECLARE @MyTable Table
(
	SalesOrderID	int,
	CustomerID		char(5)
)

/* Now that you have your table variable, you're ready
** to populate it with data from your SELECT statement.
** Note that you could just as easily insert the
** data into a permanent table (instead of a table variable).
*/
INSERT INTO @MyTable
	SELECT SalesOrderID, CustomerID
	FROM AdventureWorks2017.Sales.SalesOrderHeader
	WHERE SalesOrderID BETWEEN 44000 AND 44010;

-- Finally, make sure that the data was inserted like you think
SELECT *
FROM @MyTable;


-- Update
SELECT *
FROM Stores
WHERE StoreCode = 'TEST';

UPDATE Stores
SET City = 'There'
WHERE StoreCode = 'TEST';

UPDATE Stores
SET Name = Name + '-' + StoreCode;


-- Delete
DELETE Stores
WHERE StoreCode = 'TEST';


-- test1
SELECT *
FROM AdventureWorks2017.Production.Product;

-- test2
SELECT *
FROM AdventureWorks2017.Production.Product
WHERE ProductSubcategoryID IS NULL;

-- test3
SELECT	TOP 10 *
FROM AdventureWorks2017.Production.Location;

INSERT INTO AdventureWorks2017.Production.Location(Name, CostRate, Availability, ModifiedDate)
values('King Oliver', 12.31, 22.31, GETDATE());

SELECT *
FROM
AdventureWorks2017.Production.Location
WHERE Name = 'King Oliver';

DELETE FROM AdventureWorks2017.Production.Location
WHERE Name='King Oliver';