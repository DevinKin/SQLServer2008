# 第7章-更复杂的查询

## 子查询的概念

- 子查询满足下列某个需求
  - 将一个查询分解为一系列的逻辑步骤。
  - 提供一个列表作为WHERE子句和[IN|EXISTS|ANY|ALL]的目标。
  - 为父查询中的每个记录提供一个查询表。

### 构造嵌套子查询

- 嵌套子查询语法一

  ```mssql
  SELECT <SELECT list>
  FROM <SomeTable>
  WHERE <SomeColumn> = (
  	SELECT <single column>
      FROM <SomeTable>
      WHERE <condition that results in only one row returned>)
  ```

- 嵌套子查询语法二

  ```mssql
  SELECT <SELECT list>
  FROM <SomeTable>
  WHERE <SomeColumn> IN (
  	SELECT <single column>
      FROM <SomeTable>
      [WHERE <condition>])
  ```

- 使用返回单个值的SELECT语句的嵌套查询

  ```mssql
  SELECT DISTINCT sod.ProductID
  FROM Sales.SalesOrderHeader soh
  JOIN Sales.SalesOrderDetail sod
  	ON soh.SalesOrderID = sod.SalesOrderID
  WHERE OrderDate = (
  	SELECT MIN(OrderDate) FROM Sales.SalesOrderHeader);
  ```

- 使用返回多个值的子查询的嵌套查询

  ```mssql
  SELECT ProductID, Name
  FROM Production.Product
  WHERE ProductID IN (
  SELECT ProductID FROM Sales.SpecialOfferProduct);
  ```

-  使用嵌套的SELECT发现孤立的记录

  ```mssql
  SELECT Description
  FROM Sales.SpecialOffer sso
  WHERE sso.SpecialOfferID != 1
  	AND sso.SpecialOfferID NOT IN (
  	SELECT SpecialOfferID FROM Sales.SpecialOfferProduct);
  ```

## 关联子查询

- 关联子查询与嵌套子查询的不同之处在于信息传递是双向的，而不是单向的。
- 嵌套子查询中，内部查询只执行一次，然后将信息传递到外部查询。

### 关联子查询的工作原理

- 关联子查询一般分为3个步骤
  - 外部查询获得一个记录，然后将该记录传递到内部查询。
  - 内部查询根据传递的值执行。
  - 内部查询查询将结果传回外部查询，而外部查询利用这些值完成处理过程。

- 在WHERE子句中的关联子查询

  ```mssql
  SELECT soh1.CustomerID, soh1.SalesOrderID, soh1.OrderDate
  FROM Sales.SalesOrderHeader soh1
  WHERE soh1.OrderDate = (
  	SELECT MIN(soh2.OrderDate)
  	FROM Sales.SalesOrderHeader soh2
  	WHERE soh2.CustomerID = soh1.CustomerID)
  	ORDER BY CustomerID;
  ```

- 在SELECT列表中的关联子查询

  ```mssql
  SELECT sc.AccountNumber,
  	(SELECT MIN(OrderDate)
  		FROM Sales.SalesOrderHeader soh
  		WHERE soh.CustomerID = sc.CustomerID)
  		AS OrderDate
  FROM Sales.Customer sc;
  ```

### 处理NULL数据-ISNULL函数

- 语法

  ```mssql
  ISNULL(<expression to test>, <replacement value if null>)
  ```

- COALESCE函数可以接收两个以上的参数。所有参数为NULL时返回最后一个参数。否则返回第一个非NULL的参数。

- 使用示例

  ```mssql
  SELECT sc.AccountNumber,
  	ISNULL(CAST((SELECT MIN(OrderDate)
  		FROM Sales.SalesOrderHeader soh
  		WHERE soh.CustomerID = sc.CustomerID) AS varchar), 'NEVER ORDERED') AS OrderDate
  FROM Sales.Customer sc;
  ```

## 派生表

- 派生表由一个查询结果集的列和行构成。

- 创建派生表，需要做两件事

  - 将生成结果集的查询用小括号括起来。
  - 给查询结果起别名，这样它可以作为表被引用。

- 创建派生表语法

  ```mssql
  SELECT <select list>
  FROM (<query that returns a regular resultset>) AS <alias name>
  JOIN <some other base or derived table>
  ```

- 查询代码示例

  ```mssql
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
  ```

## 使用通用表达式(CTE)

- CTE(Common Table Expression)通用表达式。

- 要使用CTE开始创建一个查询，可以使用WITH关键字。

- 语法

  ```mssql
  WITH <expression_name [(column_name [,...n])]
  	AS
  	(CTE_query_definition)
  	[, <another_expression>]
  <query>
  ```

- CTE使用示例

  ```mssql
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
  ```

### 使用多个CTE

- 使用WITH开始语句就可以定义许多CTE，同时不需要重复使用WITH关键字。

- 一个CTE可以使用在该语句中已经定义的任意CTE(作为其定义的一部分)，我们只需使用冒号结束CTE并开始下一个CTE的定义。

  ```mssql
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
  ```

### 递归CTE

```mssql
WITH DirectReports(ManagerID, EmployeeID, EmployeeLevel) AS 
(
    SELECT ManagerID, EmployeeID, 0 AS EmployeeLevel
    FROM HumanResources.Employee
    WHERE ManagerID IS NULL
    UNION ALL
    SELECT e.ManagerID, e.EmployeeID, EmployeeLevel + 1
    FROM HumanResources.Employee e
        INNER JOIN DirectReports d
        ON e.ManagerID = d.EmployeeID 
)
SELECT ManagerID, EmployeeID, EmployeeLevel 
FROM DirectReports ;
```

## 使用EXISTS运算符

- 使用示例

  ```mssql
  SELECT BusinessEntityID, LastName + ', ' + FirstName AS Name
  FROM Person.Person pp
  WHERE EXISTS (
  	SELECT BusinessEntityID
  	FROM HumanResources.Employee hre
  	WHERE hre.BusinessEntityID = pp.BusinessEntityID);
  ```

### 以其他方式使用EXISTS

- 创建表

```mssql
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
```

- 创建数据库

```mssql
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
```

## 混合数据类型：CAST和CONVERT

- CAST和CONVERT都可以执行数据类型转换。两者执行同样的功能，不同的是CONVERT还提供一些日期格式转换，而CAST没有这个功能。

- CAST是ANSI兼容，CONVERT不兼容。

- CAST语法

  ```mssql
  CAST(expression AS data_type)
  ```

- CONVERT语法

  ```mssql
  CONVERT(data_type, expression[, style])
  ```

- CAST使用示例

  ```mssql
  SELECT 'The Customer has an Order numbered ' + CAST(SalesOrderID AS varchar)
  FROM Sales.SalesOrderHeader;
  ```

- CAST使用示例2

  ```mssql
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
  ```

- CAST使用示例3

  ```mssql
  USE AdventureWorks2017;
  SELECT OrderDate, CAST(OrderDate AS varchar) AS Converted
  FROM Sales.SalesOrderHeader;
  ```

- CONVERT控制日期格式

  ```mssql
  SELECT OrderDate, CONVERT(varchar(12), OrderDate, 5) AS Converted
  FROM Sales.SalesOrderHeader
  WHERE SalesOrderID = 43663;
  ```

## 使用MERGE命令同步数据

- MERGE基本语法

  ```mssql
  MERGE [ TOP ( <expression> ) [ PERCENT ] ]
  	[ INTO ] <target table> [ WITH ( <hint> ) ] [ [ AS ] <alias> ]
  	USING <source query>
  		ON <condition for join with target>
  	[ WHEN MATCHED [ AND <clause search condition> ] 
      	THEN <merge matched> ]
      [ WHEN NOT MATCHED [ BY TARGET ] [ AND <clause search condition> ]
      	THEN <merge not matched> ]
      [ <output clause> ]
      [ OPTION ( <query hint [ ,...n ] ) ];
  ```

### 实际使用MERGE命令

- 创建汇总表

  ```mssql
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
  ```

### BY TARGET 和 BY SOURCE

- 默认使用`BY TARGET`
- 指定了`BY TARGET`关键字，只有在连接的目标方有匹配时，才应用（插入，更新或删除）操作。
- 指定了`BY SOURCE`关键字，只有在连接的源方有匹配时，才应用合并操作。
- `NOT MATCHED [BY TARGET]`：这通常对应根据源表中的数据将行插入到表中的场景。
- `MATCHED [BY TARGET]`：这暗示了行已经存在于目标表上，因此很可能对目标表的行执行更新操作。
- `NOT MATCHED BY SOURCE`：这通常用于处理源表中缺少（可能已删除）的行，在这种场景下，通常将删除目标表中的行。（尽管更新行的操作可能只是设置无效标志或类似标记）。

## 使用OUTPUT子句收集受影响的行

- 特殊运算符来匹配合并的数据

  - `$action`：只用于MERGE。返回INSERTED，UPDATE或DELETED，表明对特定行执行的操作。
  - `inserted`：用于MERGE，INSERT或UPDATE。对内部工作表的引用，该工作表包含了为给定行插入的数据的引用。注意，这包括了已更新数据的当前值。
  - `deleted`：用于MERGE，DELETE或UPDATE。对内部工作表的引用，该工作表包含了从给定行中删除的数据的引用。注意，这包括了已更新数据之前的值。

- 使用示例

  ```mssql
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
  ```



## 研究窗口化函数

### ROW_NUMBER

- ROW_NUMBER是为每个返回的行输出唯一的，递增的值。

  ```mssql
  SELECT p.LastName, ROW_NUMBER() OVER (PARTITION BY PostalCode ORDER BY s.SalesYTD DESC) AS 'Row Number', CAST(s.SalesYTD AS INT) SalesYTD, a.PostalCode 
  FROM Sales.SalesPerson s
  	INNER JOIN Person.Person p
  		ON s.BusinessEntityID = p.BusinessEntityID
  	INNER JOIN Person.Address a
  		ON a.AddressID = p.BusinessEntityID
  WHERE TerritoryID IS NOT NULL
  	AND SalesYTD <> 0;
  ```

- ROW_NUMBER()和CTE结合使用

  ```mssql
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
  ```

### RANK，DENSE_RANK和NTILE

- RANK：如果多行具有相同的顺序值，则允许这些行具有相同的值，但是对ROW_NUMBER值重新开始计算。

- DENSE_RANK：仍然是具有相同的顺序值就具有相同的值，但排名始终是递增的。

- NTILE(x)：将总的结果划分为x个类别，从1-x开始对这些类别排名。

  ```mssql
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
  ```


## 一次一个数据块：特殊的查询分页

- `OFFSET...FETCH`：OFFSET向SELECT查询表明跳过多少行，而FETCH表明从特定位置开始检索多少行。
- 使用`OFFSET...FETCH`子句时必须同时使用`ORDER BY`。
- 可以单独使用OFFSET，但不能单独使用FETCH。
- 不可以同时使用`SELECT TOP`和`OFFSET...FETCH`。
- 可以使用算术式或变量来确定偏移多少航或获取多少行，但不可以使用标量子查询。

```mssql
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
```

## 本章小结

|      主题       |                             概念                             |
| :-------------: | :----------------------------------------------------------: |
|   嵌套子查询    | 可以使用嵌套子查询向外部查询返回表中的一个或多个值，在该子查询中不一定处理这些值。通常可以使用连接更有效地完成相同的工作，但并不总是如此。 |
|   关联子查询    | 这是引用外部查询中的字段的子查询，因此它会针对外部查询返回的每一行执行一次。关联子查询既有可能对查询性能产生正面影响，也有可能产生负面影响。 |
|     派生表      | 该语法用于查询中嵌套另一个查询，并为嵌入的查询提供类似于表的别名，从而使该查询的工作方式类似于表。 |
| 通用表达式(CTE) | CTE在语句的开始位置进行声明，它的作用上类似于派生表，但是在一定程度上更加灵活，并且通常执行性能更佳。CTE可以引用在相同语句中之前定义的其他CTE，甚至可以递归引用自身。 |
|     EXISTS      | EXISTS的工作方式类似于子查询上的运算符，用于查找第一个匹配行。它是查找信息的非常有效的方式（也可以通过连接查找信息），因为它可以在找到第一个匹配行时就停止搜索。 |
|      MERGE      | 用于在一次遍历数据的过程中比较两个数据集，并根据任意一个数据集中的匹配行插入，更新或删除行。 |
|   窗口化函数    | 可以基于没有应用于查询的排序方式对数据进行排名，甚至对不同的函数使用多种排序方式。不同的排名函数包括ROW_NUMBER，RANK，DENSE_RANK和NTILE。窗口函数在于CTE结合使用时会非常有用 |
| OFFSET...FETCH  | 通过使用相对开始位置的偏移量和返回的行数，OFFSET...FETCH对结果集进行特殊的分页。OFFSET...FETCH对于将多页数据返回到UI非常有用 |
|    测试性能     | 查看查询计划以及测量实际运行的I/O和时间是测量查询性能的两种优秀方式。它可能基于硬件差异，数据数量，数据配置文件或其他考虑事项使用不同的查询计划，所以关键是在与现实情况尽可能接近的环境中测试性能。 |

### 练习题

- 编写一个查询，以`MM/DD/YY`的格式返回AdventureWorks中所有雇员的就职日期。

  ```mssql
  SELECT CONVERT(varchar(50), HireDate, 1) AS HireDate
  FROM HumanResources.Employee;
  ```

- 分别使用JOIN，子查询，CTE和EXISTS编写查询，列出AdventureWorks中没有任何订单的所有客户。

  ```mssql
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
  ```

- 编写查询显示AdventureWorks中花费超过70000美元的账号所对应的最近5个订单。

  ```mssql
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
  )
  SELECT CustomerID, SalesOrderID, OrderDate, TotalDue
  FROM TotalOrders
  WHERE OrderRow <= 5
  ORDER BY CustomerID, OrderRow;
  ```
