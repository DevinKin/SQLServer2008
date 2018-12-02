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


-- ����Ҫ֪�������ۿ���Ϣ, ÿһ���ۿ۵���������Щ��Ʒ����.
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

-- �������κβ�Ʒ���������ۿ�����
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

-- ֻ�����ͻ�����ϵ���б�
SELECT pp.BusinessEntityID, pp.FirstName, pp.LastName
	FROM Person.Person pp
	LEFT JOIN HumanResources.Employee hre
		ON pp.BusinessEntityID = hre.BusinessEntityID;


-- Chapter4DB
USE Chapter4DB;

-- ��ȡ���й�Ӧ�̵�����
SELECT v.VendorName
	FROM Vendors v;

SELECT v.VendorName
	FROM Vendors v
	LEFT JOIN VendorAddress va
		ON v.VendorID = va.VendorID;

SELECT *
	FROM VendorAddress;

-- �������еĹ�Ӧ�����乩Ӧ��id
SELECT v.VendorName, va.VendorID
	FROM Vendors v
	LEFT JOIN VendorAddress va
		ON v.VendorID = va.VendorID;

-- �������й�Ӧ�̵ĵ�ַ
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

-- ʹ�÷�������
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

-- UNION ȥ���ظ���
-- �����������100�������ڴ��������в�Ʒ���б�.
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


-- ��ѯ����ؼ۹�Ӧ��Ʒ������
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