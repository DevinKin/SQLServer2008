-- 使用返回单个值的SELECT语句的嵌套查询
SELECT DISTINCT sod.ProductID
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod
	ON soh.SalesOrderID = sod.SalesOrderID
WHERE OrderDate = (
	SELECT MIN(OrderDate) FROM Sales.SalesOrderHeader);

-- 使用返回多个值的子查询的嵌套查询
SELECT ProductID, Name
FROM Production.Product
WHERE ProductID IN (
	SELECT ProductID FROM Sales.SpecialOfferProduct);

SELECT DISTINCT pp.ProductID, Name
FROM Production.Product pp
JOIN Sales.SpecialOfferProduct ssop
	ON pp.ProductID = ssop.ProductID;


-- 使用嵌套的SELECT发现孤立的记录
SELECT Description
FROM Sales.SpecialOfferProduct ssop
RIGHT OUTER JOIN Sales.SpecialOffer sso
	ON ssop.SpecialOfferID = sso.SpecialOfferID
WHERE sso.SpecialOfferID != 1
	AND ssop.SpecialOfferID IS NULL;

SELECT Description
FROM Sales.SpecialOffer sso
WHERE sso.SpecialOfferID != 1
	AND sso.SpecialOfferID NOT IN (
	SELECT SpecialOfferID FROM Sales.SpecialOfferProduct);


-- 在WHERE子句中的关联子查询
USE AdventureWorks2017;

-- Get a list of customers and the date of their first order
SELECT soh.CustomerID, MIN(soh.OrderDate) AS OrderDate
INTO #MinOrderDates
FROM Sales.SalesOrderHeader soh
GROUP BY soh.CustomerID;

-- Do somthing additional with that information
SELECT soh.CustomerID, soh.SalesOrderID, soh.OrderDate
FROM Sales.SalesOrderHeader soh
JOIN #MinOrderDates t
	ON soh.CustomerID = t.CustomerID
	AND soh.OrderDate = t.OrderDate
ORDER BY soh.CustomerID;

SELECT soh1.CustomerID, soh1.SalesOrderID, soh1.OrderDate
FROM Sales.SalesOrderHeader soh1
WHERE soh1.OrderDate = (
	SELECT MIN(soh2.OrderDate)
	FROM Sales.SalesOrderHeader soh2
	WHERE soh2.CustomerID = soh1.CustomerID)
	ORDER BY CustomerID;

-- 在SELECT列表中的关联子查询
SELECT sc.AccountNumber,
	(SELECT MIN(OrderDate)
		FROM Sales.SalesOrderHeader soh
		WHERE soh.CustomerID = sc.CustomerID)
		AS OrderDate
FROM Sales.Customer sc;

SELECT COALESCE(NULL,1,NULL,'123');

SELECT sc.AccountNumber,
	ISNULL(CAST((SELECT MIN(OrderDate)
		FROM Sales.SalesOrderHeader soh
		WHERE soh.CustomerID = sc.CustomerID) AS varchar), 'NEVER ORDERED') AS OrderDate
FROM Sales.Customer sc;

-- 派生表
SELECT DISTINCT sc.AccountNumber, sst.Name
FROM Sales.Customer AS sc
JOIN Sales.SalesTerritory sst
	ON sc.TerritoryID = sst.TerritoryID
JOIN (
	SELECT CustomerID
	FROM Sales.SalesOrderHeader soh
	JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
	JOIN Production.Product pp
		ON sod.ProductID = pp.ProductID
	WHERE pp.Name = 'HL Mountain Rear Wheel') AS dt1
	ON sc.CustomerID = dt1.CustomerID
JOIN (
	SELECT CustomerID
	FROM Sales.SalesOrderHeader soh
	JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
	JOIN Production.Product pp
		ON sod.ProductID = pp.ProductID
	WHERE Name = 'HL Mountain Front Wheel') AS dt2
	ON sc.CustomerID = dt2.CustomerID;


-- CTE-通用表达式
WITH MyCTE AS (
	SELECT sc.CustomerID, sc.AccountNumber, sst.Name, pp.Name ProductName
	FROM Sales.SalesOrderHeader soh
	JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
	JOIN Production.Product pp
		ON sod.ProductID = pp.ProductID
	JOIN Sales.Customer sc
		ON sc.CustomerID = soh.CustomerID
	JOIN Sales.SalesTerritory sst
		ON sc.TerritoryID = sst.TerritoryID
)
SELECT DISTINCT Rear.AccountNumber, Rear.Name
FROM MyCTE Rear		--Rear Wheel
JOIN MyCTE Front	--Front Wheel
	ON Rear.CustomerID = Front.CustomerID
WHERE
	Rear.ProductName = 'HL Mountain Rear Wheel'
	AND Front.ProductName = 'HL Mountain Front Wheel';


-- CTE2
USE Chapter4DB;

SELECT v.VendorName, a.Address
FROM Vendors v
LEFT JOIN (
	VendorAddress va 
	JOIN Address a
	ON va.AddressID = a.AddressID)
ON v.VendorID = va.VendorID;

WITH a AS (
	SELECT va.VendorID, a.Address
	FROM VendorAddress va
	JOIN Address a
		ON va.AddressID = a.AddressID
)
SELECT v.VendorName, a.Address
FROM Vendors v
LEFT JOIN a
	ON v.VendorID = a.VendorID;


-- 使用多个CTE
USE AdventureWorks2017;

WITH CustomerTerritory AS (
	SELECT sc.CustomerID, sc.AccountNumber, sst.Name TerritoryName
	FROM Sales.Customer sc
	JOIN Sales.SalesTerritory sst
		ON sc.TerritoryID = sst.TerritoryID
), MyCTE AS (
	SELECT sc.CustomerID, sc.AccountNumber, sc.TerritoryName, pp.Name ProductName
	FROM Sales.SalesOrderHeader soh
	JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
	JOIN Production.Product pp
		ON sod.ProductID = pp.ProductID
	JOIN CustomerTerritory sc
		ON sc.CustomerID = soh.CustomerID
)
SELECT DISTINCT Rear.AccountNumber, Rear.TerritoryName
FROM MyCTE Rear			--Rear Wheel
JOIN MyCTE Front		--Front Wheel
	ON Rear.CustomerID = Front.CustomerID
WHERE Rear.ProductName = 'HL Mountain Rear Wheel'
AND Front.ProductName = 'HL Mountain Front Wheel';


-- EXISTS运算符
SELECT BusinessEntityID, LastName + ', ' + FirstName AS Name
FROM Person.Person pp
WHERE EXISTS (
	SELECT BusinessEntityID
	FROM HumanResources.Employee hre
	WHERE hre.BusinessEntityID = pp.BusinessEntityID);

SELECT pp.BusinessEntityID, LastName + ', ' + FirstName AS Name
FROM Person.Person pp
JOIN HumanResources.Employee hre
	ON pp.BusinessEntityID = hre.BusinessEntityID;

-- EXISTS2
IF EXISTS
	(SELECT * 
	FROM sys.objects
	WHERE OBJECT_NAME(object_id) ='foo'
		AND SCHEMA_NAME(schema_id) = 'dbo'
		AND OBJECTPROPERTY(object_id, 'IsUserTable') = 1)
BEGIN
	DROP TABLE dbo.foo;
	PRINT 'Table foo has been dropped';
END
GO

CREATE TABLE dbo.foo
(
	Column1 INT IDENTITY(1,1) NOT NULL,
	Column2 VARCHAR(50) NULL
);


-- EXISTS3
USE master;
GO

IF NOT EXISTS
	(SELECT 'True'
	FROM sys.databases
	WHERE name = 'AdventureWorksCreate')
BEGIN
	CREATE DATABASE AdventureWorkCreate;
END
ELSE
BEGIN
	PRINT 'Database already exists. Skipping CREATE DATABASE Statement';
END
GO 


-- CAST
SELECT 'The Customer has an Order numbered ' + CAST(SalesOrderID AS varchar)
FROM Sales.SalesOrderHeader;


-- CAST2
USE master;
CREATE TABLE ConvertTest
(
	ColID	int		IDENTITY,
	ColTS	timestamp
);
GO

INSERT INTO ConvertTest
	DEFAULT VALUES;

SELECT ColTS AS Unconverted, CAST(ColTS AS int) AS Converted
FROM ConvertTest;

-- CAST3
USE AdventureWorks2017;
SELECT OrderDate, CAST(OrderDate AS varchar) AS Converted
FROM Sales.SalesOrderHeader;


-- CONVERT
SELECT OrderDate, CONVERT(varchar(12), OrderDate, 5) AS Converted
FROM Sales.SalesOrderHeader
WHERE SalesOrderID = 43663;


-- MERGE
USE AdventureWorks2017;

CREATE TABLE Sales.MonthlyRollup
(
	Year	smallint	NOT NULL,
	Month	tinyint		NOT NULL,
	ProductID int		NOT NULL
	FOREIGN KEY
		REFERENCES Production.Product(ProductID),
	QtySold	  int		NOT NULL,
	CONSTRAINT PKYearMonthProductID
		PRIMARY KEY
		(Year, Month, ProductID)
);

SELECT soh.OrderDate, sod.ProductID, SUM(sod.OrderQty) AS QtySold
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod
	ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.OrderDate >= '2011-08-21'
	AND soh.OrderDate < '2011-08-22'
GROUP BY soh.OrderDate, sod.ProductID;


-- 构建merge子句
MERGE Sales.MonthlyRollup AS smr
USING
(
	SELECT soh.OrderDate, sod.ProductID, SUM(sod.OrderQty) AS QtySold
	FROM Sales.SalesOrderHeader soh
	JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
	WHERE soh.OrderDate >= '2011-08-21'
		AND soh.OrderDate < '2011-08-22'
	GROUP BY soh.OrderDate, sod.ProductID	
) AS s
ON (s.ProductID = smr.ProductID)
WHEN MATCHED THEN
	UPDATE  SET smr.QtySold = smr.QtySold + s.QtySold
WHEN NOT MATCHED THEN 
	INSERT (Year, Month, ProductID, QtySold)
		VALUES(DATEPART(yy, s.OrderDate),
				DATEPART(m, s.OrderDate),
				s.ProductID,
				s.QtySold);

SELECT * FROM Sales.MonthlyRollup;

SELECT OrderDate
FROM Sales.SalesOrderHeader

MERGE Sales.MonthlyRollup AS smr
USING
(
	SELECT soh.OrderDate, sod.ProductID, SUM(sod.OrderQty) AS QtySold
	FROM Sales.SalesOrderHeader soh
	JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
	WHERE soh.OrderDate >= '2011-08-22'
		AND soh.OrderDate < '2011-08-23'
	GROUP BY soh.OrderDate, sod.ProductID	
) AS s
ON (s.ProductID = smr.ProductID)
WHEN MATCHED THEN
	UPDATE  SET smr.QtySold = smr.QtySold + s.QtySold
WHEN NOT MATCHED THEN 
	INSERT (Year, Month, ProductID, QtySold)
		VALUES(DATEPART(yy, s.OrderDate),
				DATEPART(m, s.OrderDate),
				s.ProductID,
				s.QtySold);


-- 
SELECT * FROM Sales.MonthlyRollup;
--

-- 使用OUTPUT子句收集受影响的行
USE AdventureWorks2017;
TRUNCATE TABLE Sales.MonthlyRollup;

MERGE Sales.MonthlyRollup AS smr
USING
(
	SELECT soh.OrderDate, sod.ProductID, SUM(sod.OrderQty) AS QtySold
	FROM Sales.SalesOrderHeader soh
	JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
	WHERE soh.OrderDate >= '2011-08-21'
		AND soh.OrderDate < '2011-08-22'
	GROUP BY soh.OrderDate, sod.ProductID
) AS s
ON (s.ProductID = smr.ProductID)
WHEN MATCHED THEN
	UPDATE SET smr.QtySold = smr.QtySold + s.QtySold
WHEN NOT MATCHED THEN
	INSERT (Year, Month, ProductID, QtySold)
	VALUES (DATEPART(yy, s.OrderDate),
			DATEPART(m, s.OrderDate),
			s.ProductID,
			s.QtySold)
OUTPUT $action,
	inserted.Year,
	inserted.Month,
	inserted.ProductID,
	inserted.QtySold,
	deleted.Year,
	deleted.Month,
	deleted.ProductID,
	deleted.QtySold;



MERGE Sales.MonthlyRollup AS smr
USING
(
	SELECT soh.OrderDate, sod.ProductID, SUM(sod.OrderQty) AS QtySold
	FROM Sales.SalesOrderHeader soh
	JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
	WHERE soh.OrderDate >= '2011-08-22'
		AND soh.OrderDate < '2011-08-23'
	GROUP BY soh.OrderDate, sod.ProductID
) AS s
ON (s.ProductID = smr.ProductID)
WHEN MATCHED THEN
	UPDATE SET smr.QtySold = smr.QtySold + s.QtySold
WHEN NOT MATCHED THEN
	INSERT (Year, Month, ProductID, QtySold)
	VALUES (DATEPART(yy, s.OrderDate),
			DATEPART(m, s.OrderDate),
			s.ProductID,
			s.QtySold)
OUTPUT $action,
	inserted.Year,
	inserted.Month,
	inserted.ProductID,
	inserted.QtySold,
	deleted.Year,
	deleted.Month,
	deleted.ProductID,
	deleted.QtySold;


-- ROW_NUMBER()
SELECT p.LastName, ROW_NUMBER() OVER (PARTITION BY PostalCode ORDER BY s.SalesYTD DESC) AS 'Row Number', CAST(s.SalesYTD AS INT) SalesYTD, a.PostalCode 
FROM Sales.SalesPerson s
	INNER JOIN Person.Person p
		ON s.BusinessEntityID = p.BusinessEntityID
	INNER JOIN Person.Address a
		ON a.AddressID = p.BusinessEntityID
WHERE TerritoryID IS NOT NULL
	AND SalesYTD <> 0;

WITH Ranked AS(
	SELECT p.LastName, ROW_NUMBER() OVER (PARTITION BY PostalCode ORDER BY s.SalesYTD DESC) AS 'ROW Number', CAST(s.SalesYTD AS INT) SalesYTD, a.PostalCode
	FROM Sales.SalesPerson s
		INNER JOIN Person.Person p
			ON s.BusinessEntityID = p.BusinessEntityID
		INNER JOIN Person.Address a
			ON a.AddressID = p.BusinessEntityID
	WHERE TerritoryID IS NOT NULL
		AND SalesYTD <> 0
)
SELECT LastName, SalesYTD, PostalCode
FROM Ranked
WHERE [ROW Number] = 1;


-- RANK()
SELECT p.LastName,
	ROW_NUMBER() OVER (ORDER BY a.PostalCode) AS 'Row Number',
	RANK() OVER (ORDER BY a.PostalCode) AS 'Rank',
	DENSE_RANK() OVER (ORDER BY a.PostalCode) AS 'Dense Rank',
	NTILE(4) OVER (ORDER BY a.PostalCode) AS 'Quartile',
	CAST(s.SalesYTD AS INT) SalesYTD, a.PostalCode
FROM Sales.SalesPerson s
	INNER JOIN Person.Person p
		ON s.BusinessEntityID = p.BusinessEntityID
	INNER JOIN Person.Address a
		ON a.AddressID = p.BusinessEntityID
WHERE TerritoryID IS NOT NULL
	AND SalesYTD <> 0;


-- OFFSET...FETCH
SELECT TOP 20 ProductID, ProductNumber, Name
FROM Production.Product
ORDER BY ProductNumber;

SELECT ProductID, ProductNumber, Name
FROM Production.Product
ORDER BY ProductNumber
OFFSET 20 ROWS
FETCH NEXT 20 ROWS ONLY;

SELECT ProductID, ProductNumber, Name
FROM Production.Product
ORDER BY ProductNumber
OFFSET 40 ROWS
FETCH NEXT 20 ROWS ONLY;


-- exam
--1. 编写一个查询，以MM/DD/YY的格式返回AdventureWorks中所有雇员的就职日期。
SELECT CONVERT(varchar(50), HireDate, 5) AS HireDate
FROM HumanResources.Employee;

SELECT HireDate
FROM HumanResources.Employee;

--2. 分别使用JOIN，子查询，CTE和EXISTS编写查询，列出AdventureWorks中没有任何订单的所有客户。
-- JOIN
SELECT DISTINCT p.BusinessEntityID, p.LastName, p.MiddleName, p.FirstName
FROM Person.Person p
	LEFT JOIN Sales.Customer c
		ON p.BusinessEntityID = c.PersonID
	LEFT JOIN Sales.SalesOrderHeader soh
		ON soh.CustomerID = c.CustomerID
WHERE soh.CustomerID IS NULL;

-- 子查询
SELECT DISTINCT p.BusinessEntityID, p.LastName, p.MiddleName, p.FirstName
FROM Person.Person p
WHERE p.BusinessEntityID NOT IN (
	SELECT sc.PersonID
	FROM Sales.Customer sc
	JOIN Sales.SalesOrderHeader soh ON sc.CustomerID = soh.CustomerID);

-- CTE
WITH PID AS
(
	SELECT DISTINCT sc.PersonID
	FROM Sales.Customer sc
	JOIN Sales.SalesOrderHeader soh ON sc.CustomerID = soh.CustomerID
)
SELECT DISTINCT p.BusinessEntityID, p.LastName, p.MiddleName, p.FirstName
FROM Person.Person p
LEFT JOIN PID pid ON p.BusinessEntityID = pid.PersonID
WHERE pid.PersonID IS NULL;

-- EXISTS
SELECT DISTINCT p.BusinessEntityID, p.LastName, p.MiddleName, p.FirstName
FROM Person.Person p
WHERE NOT EXISTS (
	SELECT *
	FROM Sales.Customer sc
	LEFT JOIN Sales.SalesOrderHeader soh ON sc.CustomerID = soh.CustomerID
	WHERE sc.PersonID = p.BusinessEntityID);


--3. 编写查询显示AdventureWorks中花费超过70000美元的账号所对应的最近5个订单。
WITH BigSpenders AS
(
	SELECT CustomerID
	FROM Sales.SalesOrderHeader soh
	GROUP BY CustomerID
	HAVING SUM(TotalDue) > 70000
), TotalOrders AS (
	SELECT soh.CustomerID, soh.SalesOrderID, soh.OrderDate, soh.TotalDue, ROW_NUMBER() OVER (PARTITION BY soh.CustomerID ORDER BY soh.OrderDate DESC) OrderRow
	FROM Sales.SalesOrderHeader soh 
	JOIN BigSpenders bs ON soh.CustomerID = bs.CustomerID
	WHERE OrderRow <= 5
)
