-- INNER JOIN
SELECT *
	FROM Person.Person
	INNER JOIN HumanResources.Employee
	ON Person.Person.BusinessEntityID = HumanResources.Employee.BusinessEntityID;

SELECT Person.BusinessEntity.*, JobTitle
	FROM Person.BusinessEntity
	INNER JOIN HumanResources.Employee
		ON Person.BusinessEntity.BusinessEntityID = 
		HumanResources.Employee.BusinessEntityID;

SELECT Person.BusinessEntity.*, HumanResources.Employee.BusinessEntityID
	FROM Person.BusinessEntity
	INNER JOIN HumanResources.Employee
		ON Person.BusinessEntity.BusinessEntityID = 
		HumanResources.Employee.BusinessEntityID;

SELECT pbe.*, hre.BusinessEntityID
	FROM Person.BusinessEntity pbe
	INNER JOIN HumanResources.Employee hre
		ON pbe.BusinessEntityID = hre.BusinessEntityID;

SELECT pbe.BusinessEntityID, hre.JobTitle, pp.FirstName, pp.LastName
	FROM Person.BusinessEntity pbe
	INNER JOIN HumanResources.Employee hre
		ON pbe.BusinessEntityID = hre.BusinessEntityID
	INNER JOIN Person.Person pp
		ON pbe.BusinessEntityID = pp.BusinessEntityID
	WHERE hre.BusinessEntityID < 4;


SELECT COUNT(*)
FROM Person.BusinessEntity;


SELECT CAST(LastName + '. ' + FirstName AS varchar(35)) AS Name, AccountNumber
	FROM Person.Person pp
	JOIN Sales.Customer sc
		ON pp.BusinessEntityID = sc.PersonID;


-- 假设要知道具体折扣信息, 每一种折扣的数量和哪些商品打折.
SELECT sso.SpecialOfferID, Description, DiscountPct, ProductID
	FROM Sales.SpecialOffer sso
	JOIN Sales.SpecialOfferProduct ssop
		ON sso.SpecialOfferID = ssop.SpecialOfferID
	WHERE sso.SpecialOfferID != 1;

SELECT sso.SpecialOfferID, Description, DiscountPct, ProductID
	FROM Sales.SpecialOffer sso
	LEFT JOIN Sales.SpecialOfferProduct ssop
		ON sso.SpecialOfferID = ssop.SpecialOfferID
	WHERE sso.SpecialOfferID != 1;

SELECT sso.SpecialOfferID, Description, DiscountPct, ProductID
	FROM Sales.SpecialOfferProduct ssop
	RIGHT JOIN Sales.SpecialOffer sso
		ON ssop.SpecialOfferID = sso.SpecialOfferID
	WHERE sso.SpecialOfferID != 1;

-- 返回与任何产品不关联的折扣名称
SELECT Description
	FROM Sales.SpecialOffer sso
	LEFT JOIN Sales.SpecialOfferProduct ssop
		ON sso.SpecialOfferID = ssop.SpecialOfferID
	WHERE sso.SpecialOfferID != 1
	AND ssop.SpecialOfferID IS NULL;

SELECT Description
	FROM Sales.SpecialOfferProduct ssop
	RIGHT JOIN Sales.SpecialOffer sso
		ON ssop.SpecialOfferID = sso.SpecialOfferID
	WHERE sso.SpecialOfferID != 1
	AND ssop.SpecialOfferID IS NULL;

SELECT * FROM Sales.SpecialOffer;
SELECT * FROM Sales.SpecialOfferProduct;

-- NULL != NULL
IF (NULL = NULL)
	PRINT 'It Does'
ELSE
	PRINT 'It Doesn''t'


SELECT pbe.BusinessEntityID, hre.JobTitle, pp.FirstName, pp.LastName
	FROM Person.BusinessEntity pbe
	INNER JOIN HumanResources.Employee hre
		ON pbe.BusinessEntityID = hre.BusinessEntityID
	INNER JOIN Person.Person pp
		ON pbe.BusinessEntityID = pp.BusinessEntityID
	WHERE hre.BusinessEntityID < 4;

SELECT COUNT(*)
FROM Person.BusinessEntity;

-- 只包含客户的联系人列表
SELECT pp.BusinessEntityID, pp.FirstName, pp.LastName
	FROM Person.Person pp
	LEFT JOIN HumanResources.Employee hre
		ON pp.BusinessEntityID = hre.BusinessEntityID;


-- Chapter4DB
USE Chapter4DB;

-- 获取所有供应商的名称
SELECT v.VendorName
	FROM Vendors v;

SELECT v.VendorName
	FROM Vendors v
	LEFT JOIN VendorAddress va
		ON v.VendorID = va.VendorID;

SELECT *
	FROM VendorAddress;

-- 返回所有的供应闪及其供应商id
SELECT v.VendorName, va.VendorID
	FROM Vendors v
	LEFT JOIN VendorAddress va
		ON v.VendorID = va.VendorID;

-- 返回所有供应商的地址
SELECT v.VendorName, a.Address
	FROM Vendors v
	LEFT JOIN VendorAddress va
		ON v.VendorID = va.VendorID
	LEFT JOIN Address a
		ON va.AddressID = a.AddressID;

SELECT v.VendorName, a.Address
	FROM VendorAddress va
	JOIN Address a
		ON va.AddressID = a.AddressID
	RIGHT JOIN Vendors v
		ON v.VendorID = va.VendorID;

-- 使用分组连接
SELECT v.VendorName, a.Address
	FROM Vendors v
	LEFT JOIN (
		VendorAddress va
		JOIN Address a
		ON va.AddressID = a.AddressID
	)
	ON v.VendorID = va.VendorID;


-- FULL OUTER JOIN
SELECT v.VendorName, a.Address
	FROM VendorAddress va
	JOIN Address a
		ON va.AddressID = a.AddressID
	RIGHT JOIN Vendors v
		ON v.VendorID = va.VendorID;

SELECT a.Address, va.AddressID
	FROM VendorAddress va
	FULL JOIN Address a
		ON va.AddressID = a.AddressID;

SELECT a.Address, va.AddressID, v.VendorID, v.VendorName
	FROM VendorAddress va
	FULL JOIN Address a
		ON va.AddressID = a.AddressID
	FULL JOIN Vendors v
		ON va.VendorID = v.VendorID;

SELECT * FROM Address;


-- CROSS JOIN
SELECT v.VendorName, a.Address
	FROM Vendors v
	CROSS JOIN Address a

-- UNION
USE AdventureWorks2017;

SELECT FirstName + ' ' + LastName AS Name
	FROM Person.Person pp
	JOIN Person.EmailAddress pe
		ON pp.BusinessEntityID = pe.BusinessEntityID
	JOIN Sales.Customer sc
		ON pp.BusinessEntityID = sc.CustomerID

	UNION
SELECT FirstName + ' ' + LastName AS Name
	FROM Person.Person pp
	JOIN Person.EmailAddress pe
		ON pp.BusinessEntityID = pe.BusinessEntityID
	JOIN Purchasing.Vendor pv
		ON pp.BusinessEntityID = pv.BusinessEntityID;

-- UNION 去除重复行
-- 产生库存少于100或者正在促销的所有产品的列表.
SELECT P.ProductNumber
	FROM Production.Product P
	JOIN Production.ProductInventory I
		ON I.ProductID = P.ProductID
	WHERE I.Quantity < 100
	UNION
SELECT P.ProductNumber
	FROM Production.Product P
	JOIN Sales.SpecialOfferProduct O
		ON P.ProductID = O.ProductID
	WHERE O.SpecialOfferID > 1;


-- 查询添加特价供应产品的名称
SELECT P.ProductNumber, 'Less than 100 left' AS SpecialOffer
	FROM Production.Product P
	JOIN Production.ProductInventory I
		ON I.ProductID = P.ProductID
	WHERE I.Quantity < 100
	UNION
SELECT P.ProductNumber, SO.Description
	FROM Production.Product P
	JOIN Sales.SpecialOfferProduct O
		ON P.ProductID = O.ProductID
	JOIN Sales.SpecialOffer SO
		ON SO.SpecialOfferID = O.SpecialOfferID
	WHERE O.SpecialOfferID > 1


SELECT P.ProductNumber, 'Less than 100 left' AS SpecialOffer
	FROM Production.Product P
	JOIN Production.ProductInventory I
		ON I.ProductID = P.ProductID
	WHERE I.Quantity < 100
	UNION ALL
SELECT P.ProductNumber, SO.Description
	FROM Production.Product P
	JOIN Sales.SpecialOfferProduct O
		ON P.ProductID = O.ProductID
	JOIN Sales.SpecialOffer SO
		ON SO.SpecialOfferID = O.SpecialOfferID
	WHERE O.SpecialOfferID > 1;


-- test1
SELECT P.LastName AS Name
	FROM Person.Person P
	JOIN HumanResources.Employee E
		ON P.BusinessEntityID = E.BusinessEntityID
	WHERE E.NationalIDNumber = '112457891';

-- test2
SELECT P.ProductID, P.Name
	FROM Production.Product P
	LEFT JOIN Sales.SpecialOfferProduct SSP
		ON P.ProductID = SSP.ProductID
	WHERE SSP.SpecialOfferID IS NULL
	UNION
SELECT P.ProductID, P.Name
	FROM Production.Product P
	JOIN Sales.SpecialOfferProduct SSP
		ON P.ProductID = SSP.ProductID
	JOIN Sales.SpecialOffer SSO
		ON SSO.SpecialOfferID = SSP.SpecialOfferID
	WHERE SSO.Description = 'No Discount';

SELECT * FROM Sales.SpecialOfferProduct