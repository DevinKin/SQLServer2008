# 第6章-键和约束

- 约束是一种限制, 通过在列级或表级设置约束, 确保数据符合某种数据完整性规则.
- 三种不同类型的约束
  - 实体约束
  - 域约束
  - 参照完整性约束
- 更具体的约束
  - 主键约束
  - 外键约束
  - 唯一约束(也称为替换键)
  - CHECK约束
  - DEFAULT约束
  - 规则
  - 默认值(和DEFAULT约束类似)

## 约束的类型

​	![约束类型](E:\Learning\DataBase\SQLServer2012\note\img\yueshu.png)

### 域约束

- 域约束处理一个或多个列.

### 实体约束

- 实体约束并不关系列中的数据, 它只对特定的行感兴趣.

参照完整性约束

- 如果某列的值必须与其他列(该列可能在同一个表中, 或者更通畅的是在不同的表中)的值匹配, 就意味着创建了参照完整性约束.

## 约束命名

- PK前缀代表主键约束.
- CK前缀代表CHECK约束

## 键约束

- 4种不同类型的常用键
  - 主键
  - 外键
  - 替换键
  - 倒置键
- 倒置键基本上是一种约束, 该索引对表不应用某种形式的约束(主键, 外键, 唯一).
- 倒置键并没有强制实施数据完整性, 只是一种排列数据的可选方法.

### 主键约束

- 主键是每行的唯一标识符, 必须包含唯一的值(因此不能为NULL).

- 主键唯一标识表中的每一行, 而GUID是更一般的工具, 常用于空间和时间上标识任意事物.

- 在已存在的表中创建主键

  ```mssql
  ALTER TABLE Employees
  	ADD CONSTRAINT PK_Employees
  	PRIMARY KEY (EmployeeID);
  ```

### 外键约束

- 外键既能确保书的完整性, 也能表现表与表之间的关系.

- 设置一列或几列外键约束的语法

  ```mssql
  <column name> <data type> <nullability>
  FOREIGN KEY REFERENCES <table name>(<column name>)
  	[ON DELETE {CASCADE | NO ACTION | SET NULL | SET DEFAULT}]
  	[ON UPDATE {CASCADE | NO ACTION | SET NULL | SET DEFAULT}]
  ```

- 查看约束的更详细信息, 使用存储过程`sp_helpconstraint`

  ```mssql
  EXEC sp_helpconstraint Orders;
  ```

- 和主键不同, 每个表可以有多个外键. 在每个表中, 可以有 0~253 个外键.

- 一个给定的列只能引用一个外键.

- 一个外键能涉及多列.

- 一个给定的被外键引用的列也可以被很多表引用.

- 在已存在的表中添加一个外键.

  ```mssql
  ALTER TABLE Orders
  	ADD CONSTRAINT FK_EmployeeCreatesOrder
  	FOREIGN KEY(EmployeeID) REFERENCES Employees(EmployeeID);
  ```

#### 使用一个表自引用

- 在实际创建这种引用基于标识列的非空字段的自引用约束之前, 很关键的一点是在添加外键之前表中至少有一行.

  - 原因: 检查并强制实施外键操作之后才选择并填充标识值的. 这意味着当检查发生时, 还没有值供第一行引用.

  ```mssql
  ALTER TABLE Employees
  	ADD CONSTRAINT FK_EmployeeHasManager
  	FOREIGN KEY (ManagerEmpID) REFERENCES Employees(EmployeeID);
  ```

- 创建表时创建自引用外键

  ```mssql
  CREATE TABLE Employees (
  	EmployeeID	INT	IDENTITY	NOT NULL	PRIMARY KEY,
  	FirstName	VARCHAR(25)		NOT NULL,
  	MiddleInitial	CHAR(1)		NULL,
  	LastName	VARCHAR(25)		NOT NULL,
  	Title		VARCHAR(25)		NOT NULL,
  	SSN			VARCHAR(11)		NOT NULL,
  	Salary		MONEY			NOT NULL,
  	PriorSalary	MONEY			NOT NULL,
  	LastRaise	AS	Salary - PriorSalary,
  	HireDate	SMALLDATETIME	NOT NULL,
  	TerminationDate	SMALLDATETIME	NULL,
  	ManagerEmpID	INT			NOT NULL
  		REFERENCES	Employeees(EmployeeID),
  	Department		VARCHAR(25)	NOT NULL
  );
  ```

#### 级联操作

- 外键和其他类型键的一个重要区别: 外键是双向的.
  - 不仅是限制子表的值必须存在于父表中
  - 还在每次对父表操作后检查子行(避免了孤立行).
- 在外键引用记录过程中自动删除和更新的过程称为级联.

- 示例

  ```mssql
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
  ```

  - 将`OrderID`声明为依赖于"外部列". 依赖的是在另一个表(Orders 表)里的一个`OrderID`列.
  - 在父记录(Orders表中)被更新的情况下, 不级联更新到子表(OrderDetails)中.
  - 在父记录(Orders表中)被删除的情况下, 级联删除子表(OrderDetails)中对应的行.

- CASCADE操作所能影响的深度并未受限制. 因此使用CASCADE要慎重.

#### 外键的注意事项

- 如何使用外键中的值为必须的或可选的
  - 在列中填充与被引用表的相应列匹配的值.
  - 不填充任何值, 而使该值为NULL.
- 外键的双向实现方式: CASCADE(级联)操作.
- 创建非NULL值外键约束有额外的优点: 被引用表和引用表之间任何连接都可以编写为`INNER JOIN`, 而且不会丢失数据.
- 创建NULL值外键约束可以在被引用表中没有与NULL值匹配的行时, 仍允许插入.

### 唯一约束

- 唯一约束(也称为替换键), 指列中的每个值必须是唯一的.

- 唯一约束和主键不同, 唯一约束不会自动防止设置一个NULL值. 是否允许NULL取决于表中相应列的NULL选项的设置.

- 创建表时添加唯一约束

  ```mssql
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
  ```

- 在已存在的表中添加唯一约束

  ```mssql
  ALTER TABLE Employees
  	ADD CONSTRAINT AK_EmployeeSSN
  	UNIQUE(SSN);
  ```

- 约束的前缀

  - AK代表替换键(Alternate Key)
  - PK代表主键(Primary Key)
  - FK代表外键(Foreign Key)
  - UQ或U代表唯一约束(Unique)
  - CN代表CHECK约束

## CHECK约束

- CHECK约束不限于一个特定的列, CHECK约束可以和一个列或一个表关联.

- 和规则和触发器相比, CHECK约束执行速度更快.

- 在已经存在的表中添加CHECK约束.

  ```mssql
  ALTER TABLE Customers
  	ADD CONSTRAINT CN_CustomerDateInSystem
  	CHECK
  	(DateInSystem <= GETDATE());
  ```

## DEFAULT约束

- DEFAULT约束

  - 默认值只在INSERT语句中使用, 在UPDATE语句和DELETE语句中被忽略.
  - 如果在INSERT语句中提供了任意值, 就不使用默认值.
  - 如果没有提供值, 那么总是使用默认值.

- 创建表时定义DEFAULT约束

  ```mssql
  CREATE TABLE Shippers
  (
  	ShipperID	INT		IDENTITY	NOT NULL	PRIMARY KEY,
  	ShipperName	VARCHAR(30)			NOT NULL,
  	DateInSystem	SMALLDATETIME	NOT NULL	DEFAULT	GETDATE()
  );
  ```

- 在已存在的表中添加DEFAULT约束

  ```mssql
  ALTER TABLE Customers
  	ADD CONSTRAINT CN_CustomerDefaultDateInSystem
  		DEFAULT GETDATE() FOR DateInSystem;
  ```

## 禁用约束

- SQL Server只允许禁用外键约束或者CHECK约束, 而同时保持约束的完整性.
- 不能禁用主键约束或者唯一约束.

### 在创建约束时忽略无效的数据

- 要添加一个约束, 但是又不将其应用到已存在的数据中, 那么可以在执行`ALTER TABLE`语句添加约束时使用`WITH NOCHECK`选项.

  ```mssql
  ALTER TABLE Customers
  	WITH NOCHECK
  	ADD CONSTRAINT CN_CustomerPhoneNo
  	CHECK
  	(Phone LIKE '([0-9][0-9][0-9]) [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');
  ```

### 临时禁用已存在的约束

