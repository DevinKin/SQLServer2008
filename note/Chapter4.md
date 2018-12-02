# 第四章-连接

## 内部连接

- 语法结构

  ```mssql
  SELECT <select list>
  FROM <first_table>
  <join_type> <second_table>
  	[ON <join_condition>]
  ```

- 使用范例

  ```mssql
  SELECT Person.BusinessEntity.*
  	FROM Person.BusinessEntity
  	INNER JOIN HumanResources.Employee
  		ON Person.BusinessEntity.BusinessEntityID = 
  		HumanResources.Employee.BusinessEntityID;
  ```

- 内连接具有排他特性.

- INNER JOIN类似于WHERE

## 外连接

- 外连接的简易语法

  ```mssql
  SELECT <SELECT list>
  	FROM <the table you want to be the "LEFT" table>
  	<LEFT|RIGHT> [OUTER] JOIN <table you want to be the "RIGHT" table>
  	ON <join condition>
  ```

- 外连接本质上是包含的.

- 假设要知道具体折扣信息, 每一种折扣的数量和哪些商品打折.

  ```mssql
  SELECT sso.SpecialOfferID, Description, DiscountPct, ProductID
  	FROM Sales.SpecialOffer sso
  	LEFT JOIN Sales.SpecialOfferProduct ssop
  		ON sso.SpecialOfferID = ssop.SpecialOfferID
  	WHERE sso.SpecialOfferID != 1;
  ```

- LEFT JOIN保留的是左侧表的字段, 如果右侧表中不存在与左侧表匹配的字段, SQL Server会为其他任意值填充NULL.

- RIGHT JOIN保留的是右侧表的字段, 如果左侧表中不存在与右侧表匹配的字段, SQL Server会为其他任意值填充NULL.

  ```mssql
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
  ```

- 返回与任何产品不关联的折扣名称

  ```mssql
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
  ```

- NULL值不等于NULL值.

  ```mssql
  IF (NULL = NULL)
  	PRINT 'It Does'
  ELSE
  	PRINT 'It Doesn''t'
  ```

### 处理更复杂的外部连接

```mssql
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
```



## 完全连接

- FULL JOIN将左右两侧的数据全部匹配, 并返回所有的记录. 无论记录在JOIN的哪一侧.

- FULL JOIN查询出来是两个表的并集.

  ```mssql
  SELECT a.Address, va.AddressID, v.VendorID, v.VendorName
  	FROM VendorAddress va
  	FULL JOIN Address a
  		ON va.AddressID = a.AddressID
  	FULL JOIN Vendors v
  		ON va.VendorID = v.VendorID;
  ```


## 交叉连接

- 交叉连接是将JOIN左侧的所有记录与另一侧的所有记录连接.

- 交叉连接返回的是JOIN两侧表的所有记录的笛卡尔积.

- 交叉连接使用范例

  ```mssql
  SELECT v.VendorName, a.Address
  	FROM Vendors v
  	CROSS JOIN Address a;
  ```

## 联合

- JOIN 将信息水平连接(添加更多列)

- UNION 将数据垂直连接(添加更多行)

- UNOIN查询的关键点

  - 所有联合的查询必须在SELECT列表中有相同的列数.
  - UNION返回的结果集的标题(列名)仅从第一个查询获得.
  - 查询中的对应列的数据类型必须隐式一致.
  - UNION查询的默认返回选项为DISTINCT, 而不是ALL.

- UNION使用范例:

  ```mssql
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
  		ON pp.BusinessEntityID = pv.BusinessEntityID
  ```

- UNION去除重复行, SQL Server会将具有相等NULL列的行视为重复行.

  ```mssql
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
  ```


## 小结

- 要排除不匹配的字段的时候 使用内部链接(INNER JOIN | JOIN)
- 要检索尽可能匹配的数据, 但又要包含JOIN一侧的表的所有数据, 使用外部链接.(LEFT | RIGHT  OUTER JOIN)
- 要检索尽可能匹配的数据, 但又要包含JOIN两侧的表的所有数据, 使用完全外连接.(FULL OUTER JOIN)
- 要基于两个表的记录建立笛卡尔积时, 使用交叉连接.(CROSS JOIN)
- 要将第二个查询结果附加到第一个查询结果时, 使用联合.(UNION | UNION ALL)



## 练习题

- 针对AdventureWorks数据库编写一条查询语句, 要求返回Name列并包含NationalIDNumber为112457891的雇员的姓.

  ```mssql
  SELECT P.LastName AS Name
  	FROM Person.Person P
  	JOIN HumanResources.Employee E
  		ON P.BusinessEntityID = E.BusinessEntityID
  	WHERE E.NationalIDNumber = '112457891';
  ```

- 针对AdventureWorks数据库编写一条查询语句, 要求返回所有产品的ID和Name列, 包括没有特价供应的所有产品和有No Discount特价供应的所有产品.

  ```mssql
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
  ```


