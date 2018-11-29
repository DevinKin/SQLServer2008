# T-SQL基本语句

## 基本的SELECT语句

- Select语句的基本语法规则

  ```mssql
  SELECT [ALL|DISTINCT] [TOP (<expression>) [PERCENT] [WITH TIES]]
  FROM <source table(s)/view(s)>]
  [WHERE <restrictive condition>]
  [GROUP BY <column name or expression using a column in the SELECT list>]
  [HAVING <restrictive condition based on the GROUP BY results]
  [ORDER BY <column list>]
  [[FOR XML {RAW|AUTO|EXPLICIT|PATH [(<element>)]} [, XMLDATA]
   								[, ELEMENTS][, BINARY base 64]]
  [OPTION (<query hint>, [, ...n])]
  ```

- `INFORMATION_SCHEMA`是特定的访问路径,用于显示系统数据库及其内容的相关元数据.

```mssql
SELECT * FROM INFORMATION_SCHEMA.TABLES;
```

- MSSQL中的表名的规范为`数据库名.构架名.表名	`.

### WHERE子句

- 使用范例

```mssql
SELECT Name, ProductNumber, ReorderPoint
FROM Production.Product
WHERE ProductID = 356;
```



- WHERE子句的运算符

  |           运算符            |                           示例用法                           |                             功能                             |
  | :-------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
  | =, >, <, >=, <=,<>,!=,!>,!< | <Column Name> =<Other Column Name>          <Colum Name='Bob' | 标准的比较运算符                                         (1)!=和<>都表示"不相等".而 !< 和 !> 分别表示 "不小于" 和 "不大于" |
  |         AND,OR,NOT          |        <Column1>=<Column2> AND <Column3> >= <Column4>        |                     标准布尔逻辑运算符.                      |
  |           BETWEEN           |                  <Column1> BETWEEN 1 AND 5                   |    在某个范围之间.闭区间.指定的只可以为列名,变量或字面量.    |
  |            LIKE             |                    <Column1> LIKE "ROM%"                     | 可使用%和_作为通配符.%表示可以代替任意长度的任意字符. _表示可以代替任意单个字符.[]符号用于指定一个字符,字符串或范围.^运算符表示下一个字符是要被排除的. |
  |             IN              |                     <Column1> IN (列表)                      | 关键字IN表示Column1在列表中则返回TRUE, IN关键字常用于子查询  |
  |       ALL, ANY, SOME        |     <column\|expression>(比较运算符) <ANY\|SOME>(子查询)     | 子查询中的全部值/任意值满足比较运算符的条件时返回true.ALL指示表达式要匹配结果集中的所有值.ANY和SOME功能相似,在表达式匹配结果集中的任意值时返回TRUE. |
  |           EXISTS            |                        EXISTS(子查询)                        |               子查询返回至少一行记录时为TRUE.                |



  ### ORDER BY子句

  - ORDER BY子句用来返回数据的排列顺序.

    ```mssql
    SELECT Name, ProductNumber, ReorderPoint
    FROM Production.Product
    ORDER BY ProductNumber;DESC 
    ```

  - 使用`DESC`降序排序



  ### 使用GROUP BY子句聚合数据

  - `GROUP BY`子句用于聚合信息.

  ```mssql
  SELECT SalesOrderID, SUM(OrderQty)
  FROM Sales.SalesOrderDetail
  WHERE SalesOrderID IN (43660, 43670, 43672)
  GROUP BY SalesOrderID;
  ```

  - 在使用GROUP BY子句时, SELECT列表中所有列必须为聚合列(SUM, MIN, MAX, AVG等)或是GROUP BY子句中包括的列.

  - 如果在SELECT列表中使用聚合列,SELECT列表必须只包含聚合列,否则必须有一个GROUP BY子句.

    ```mssql
    SELECT CustomerID, SalesPersonID, COUNT(*)
    FROM Sales.SalesOrderHeader
    WHERE CustomerID <= 11010
    GROUP BY CustomerID, SalesPersonID;
    ```

  #### 聚合函数

  - 聚合函数常用于GROUP BY子句,用于聚合分组的数据.

  - AVG函数用于计算平均值.

    ```mssql
    SELECT SalesOrderID, AVG(OrderQty) AS AVG
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID IN (43660, 43670, 43672)
    GROUP BY SalesOrderID;
    ```

  - MIN/MAX用于计算选择列分组的最小值与最大值.

    ```mssql
    SELECT SalesOrderID, MIN(OrderQty)  AS MinOrder, Max(OrderQty) AS MaxOrder
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID IN (43660, 43670, 43672)
    GROUP BY SalesOrderID;
    ```

  - COUNT(表达式|*)函数用于计算查询中返回的行数.返回结果没有默认的列名,需要指定别名.

    ```mssql
    SELECT COUNT(*)
    FROM HumanResources.Employee
    WHERE HumanResources.Employee.BusinessEntityID = 5;
    ```

  - 除了COUNT(*)函数外,所有的聚合函数都忽略NULL值.



### 	使用HAVING子句给分组设置条件

- HAVING子句仅用于带有GROUP BY子句的查询语句中,用于分组后进行条件查询.

  ```mssql
  SELECT ManagerID AS Manager, COUNT(*) AS Reports
  FROM HumanResources.Employee2
  WHERE Employee != 5
  GROUP BY ManagerID
  HAVING COUNT(*) > 3;
  ```



### 	DISTINCT和ALL谓词

- 键是数据库的一个术语,用于描述一列或多列,这些列用于标识表中的一行.
  - 主键是能唯一标识行的一列或列组.
- DISTINCT谓词可以过滤重复的行.
- ALL谓词可以包括所有的行.ALL是任意SELECT语句的默认值.



## 使用INSERT语句添加数据

- INSERT语句语法结构

  ```mssql
  INSERT [TOP (<expression>) [PERCEENT]] [INTO] <tabular object>
  [(<column list>)]
  [OUTPUT <output clause>]
  [VALUES (<data values>) [, (<data values)] [, ..n]
  | <table source>
  | EXEC <procedure>
  | DEFAULT VALUES
  ```

- DEFAULT关键字告诉SQL Server为该列使用默认值.(如果没有默认值,则会出错)

- 存储过程`sp_help`的功能是给出任意数据库对象,用户自定义数据类型或SQL Sever数据类型信息.

  - 查看Sales表属性: `EXEC sp_help Sales`

### INSERT INTO...SELECT语句

- `INSERT INTO...SELECT`语句可以完成一次插入一个数据块的内容.

- 语法结构

  ```mssql
  INSERT INTO <table name>
  [<column list>]
  <SELECT statement>
  ```

- 使用示例

  ```mssql
  DECLARE @MyTable Table
  (
  	SalesOrderID	int,
  	CustomerID		char(5)
  )
  INSERT INTO @MyTable
  	SELECT SalesOrderID, CustomerID
  	FROM AdventureWorks2017.Sales.SalesOrderHeader
  	WHERE SalesOrderID BETWEEN 44000 AND 44010;
  ```


## 用UPDATE语句更改获得的数据

- 语法

  ```mssql
  UPDATE [TOP (<expression>) [PERCENT]] <tabular object>
  	SET <column> = <value> [,WRITE(<expression>, <offset>, <length>)]
  		[, <column> = <value> [,WRITE(<expression>, <offset>, <length>)]]
  	[ OUTPUT <output clause> ]
  [FROM <source table(s)>]
  [WHERE <restrictive condition>]
  ```

- 使用范例

  ```mssql
  UPDATE Stores
  SET City = 'There'
  WHERE StoreCode = 'TEST';
  ```


## DELETE语句

- 语法

  ```
  DELETE [TOP (<expression>) [PERCENT]] [FROM] <tabular object>
  	[OUTPUT <output clause>]
  [FROM <table or join condition>]
  [WHERE <search condition> | CURRENT OF [GLOBAL] <cursor name>]
  ```

- 使用范例

  ```mssql
  DELETE Stores
  WHERE StoreCode = 'TEST';
  ```




## 练习题

- 编写输出AdventureWorks数据库的Product表(Production模式中)所有行和列的数据的查询语句.

  ```mssql
  SELECT *
  FROM AdventureWorks2017.Production.Product;
  ```

- 修改练习1的查询语句,仅搜索无 ProductionSubcategoryID的产品(提示: 有209个产品,需要搜索NULL值)

  ```mssql
  SELECT *
  FROM AdventureWorks2017.Production.Product
  WHERE ProductSubcategoryID IS NULL;
  ```

- 在AdventureWorks数据库的Location表(Production模式中)添加一行.

  ```mssql
  INSERT INTO AdventureWorks2017.Production.Location(Name, CostRate, Availability, ModifiedDate)
  values('King Oliver', 12.31, 22.31, GETDATE());
  ```


- 删除刚刚添加的行

  ```mssql
  DELETE FROM AdventureWorks2017.Production.Location
  WHERE Name='King Oliver';
  ```
