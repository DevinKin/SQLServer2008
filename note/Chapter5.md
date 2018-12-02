# 第五章-创建和修改数据表

## SQL Server中的对象名

- SQL Server表有4层命名约定, 完全限定的名称为: `[ServerName.[DatabaseName.[SchemaName.]]]ObjectName`

### 模式名(也称为所有权)

- 一个所有者与特定的登录名相关, 而模式可以为多个登录名所共享.
- 一个登录名可以拥有多个模式.
- 默认模式: dbo, 无论谁创建了数据库, 它都被认为是"数据库所有者", 即dbo.
- dbo在数据库里面创建的任何对象都应该带有dbo模式, 而不是个体的用户名.
- 个体用户在数据库里面创建的任何对象都应该是`个体用户名.对象名`, 不带有dbo模式.
- sysadmin角色的成员(包括sa登录名)总是dbo的别名.
- 无论谁实际上拥有数据库, sysadmin角色的成员总拥有完全的权限. sysadmin角色的成员创建的任何对象都显示所有权为dbo.

### 回顾默认值

- 对象名: 没有默认值, 必须提供一个对象名.
- 所有权: 可以忽略该值, 在省略清苦将下, 首先当前用户名来解析, 如果这个对象名的所有者不是当前用户, 那么将使用dbo作为所有者.
- 数据库名: 除非提供了服务器名, 否则这个名称也可以省略. 在这种情况下, 必须为SQL Server提供数据库名.(其他服务器类型根据特定的服务器有所变化)
- 服务器名: 可以提供链接服务器的名称, 但是在大多情况下, 省略该名称, 这样 SQL Server就是登陆的默认服务器.

## CREATE语句

- CREATE语句的完整结构

  ```mssql
  CREATE <object type> <object name>
  ```

### CREATE DATABASE

- CREATE DATABASE语句最基本的语法

  ```mssql
  CREATE DATABASE <database name>
  ```

- CREATE DATABASE更完整的语法

  ```mssql
  CREATE DATABASE <database name>
  [ON [PRIMARY]
  	([NAME = <'logical file name'>,]
  	  FILENAME = <'file name'>
  	 [, SIZE = <size in kilobytes, megabytes, gigabytes, or terabytes>]
  	 [, MAXSIZE = <size in kilobytes, megabytes, gigabytes, or terabytes>]
  	 [, FILEGROTH = <kilobytes, megabytes, gigabytes, or terabytes|percentage>])]
  [LOG ON
  	([NAME = <'logical file name'>,]
  	  FILENAME = <'file name'>
  	 [, SIZE = <size in kilobytes, megabytes, gigabytes, or terabytes>]
  	 [, MAXSIZE = <size in kilobytes, megabytes, gigabytes, or terabytes>]
  	 [, FILEGROTH = <kilobytes, megabytes, gigabytes, or terabytes|percentage>])]
  [ CONTAINMENT = OFF|PARTIAL ]
  [ COLLATE <collation name> ]
  [ FOR ATTACH [WITH <service broker>] | FOR ATTACH_REBUILD_LOG |
  	WITH DB_CHAINING ON | OFF | TRUSTWORTHY ON | OFF]
  [AS SNAPSHOT OF <source database name>]
  [;]
  ```

- CONTAINMENT: 可以在目标SQL示例上部署具有很少以来关系的数据库. 默认值是OFF.

- ON

  - 定义存储数据的文件的位置.
  - 定义存储日志的文件的位置.
  - 后面跟随PRIMARY关键字表示物理上存储数据的主文件组.

- NAME: 是一个逻辑名称, SQL Server在内部使用该名称引用该文件.

- FILENAME: 实际的操作系统文件在磁盘的物理名称.

  - mdf为数据库文件的扩展名
  - ldf为日志文件扩展名

- SIZE: 指数据库的大小. 默认是兆字节.

- MAXSIZE: 是数据库可以增加的最大大小.

- FILEGROWTH: 主要用于确定数据库达到这个最大值的速度.

- LOG ON: 允许指定哪些文件需要日志, 以及这些日志文件位于什么位置.

- COLLATE: 处理排序, 字母大小写以及是否对重音敏感的问题.

- FOR ATTACH: 将已存在的一些数据库文件附加到当前的服务器上.

- TRUSTWORTHY: 访问在SQL Server环境意外的系统资源和文件添加额外的完全层.

### 构建数据库

```mssql
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
```

- 查看数据库的详细信息

  ```mssql
  EXEC sp_helpdb 'Accounting';
  ```


### CREATE TABLE

- 基础语法

  ```mssql
  CREATE <object type> <object name>
  ```

- 深层语法

  ```mssql
  CREATE TABLE [database_name.[owner].]table_name
  (<column name> <data type>
  [[DEFAULT <constant expression>]
  	| [IDENTIFITY [ (seed, increment) [NOT FOR REPLICATION]]]]
  	[ROWGUIDCOL]
  	[COLLATE <collation name>]
  	[NULL | NOT NULL]
  	[<column constraints>]
  	| [column_name AS computed_column_expression]
  	| [<table_constraint>]
  	[, ...n]
  )
  [ON {<filegroup | DEFAULT}]
  [TEXTIMAGE_ON {<filegroup | DEFAULT}]
  ```

- DEFAULT: 默认值是在插入任何记录时用户没有为某列提供值时采用的值.

- IDENTITY: 标识值. SQL Server在该列中自动分配一个顺序号给插入的每个行.

  - 标识列必须是数值类型.
  - 使用IDENTITY标识该列不允许有NULL值.

- NOT FOR REPLICATION: 决定了当列(通过复制)发布到另一个数据库时, 是为新的数据库分配一个新的标识值, 还是保留已有的值.

- ROWGUIDCOL: 它通常用于唯一地标识表的每行. SQL Server没有采用数字计数, 而是采用全局唯一标识符(Globally Unique Identifier, GUID). 唯一标志符在空间和时间上都是唯一的.

  - GUID是一个128位的值.

- COLLATE: 处理排序, 字母大小写以及是否对重音敏感的问题.

- NULL | NOT NULL: 表示该列是否接受NULL值.

  - 使用 `sp_dbcmptlevel` 存储过程设定一个值或者设定ANSI兼容选项.

- ON: 指定希望表位于哪个文件组(以及哪个物理设备)的一种方法.

- TEXTIMAGE_ON: 将表的特定部分移动到不同的文件组中. 这个子句只有在表的定义中有大型列时才有效

  - text或ntext
  - image
  - xml
  - varchar(max)或nvarchar(max)
  - Varbinary(max)
  - 任何CLR用户定义类型列(包括geometry和geography)

- 计算列: 创建一个本身没有任何数据的列, 但列值是由表中其他列动态生成的.

  - 具体语法: `<column name> AS <computed column expression>`

- 创建Customers表

  ```mssql
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
  ```

## ALTER语句

- 基本语法

  ```mssql
  ALTER <object type> <object name>
  ```

### ALTER DATABASE

- 完整语法

```mssql
ALTER DATABASE <database name>
	ADD FILE
		([NAME = <'logical file name'>,]
		  FILENAME = <'file name'>
		  [, SIZE = <size in KB, MB, GB or TB>]
		  [, MAXSIZE = <size in KB, MB, GB or TB>]
		  [, FILEEGROWTH = <No of KB, MB, GB or TB | percentage>]) [, ...n]
		  	[ TO FILEGROUP filegroup_name]
	[, OFFLINE]
	|ADD LOG FILE
		([NAME = <'logical file name'>,]
		  FILENAME = <'file name'>
		  [, SIZE = <size in KB, MB, GB or TB>]
		  [, MAXSIZE = <size in KB, MB, GB or TB>]
		  [, FILEEGROWTH = <No of KB, MB, GB or TB | percentage>])
	|REMOVE FILE <logical file name> [WITH DELETE]
	|ADD FILE GROUP <filegroup name>
	|REMOVE FILEGROUP <filegroup name>
	|MODIFY FILE <filespec>
	|MODIFY NAME = <new dbname>
	|MODIFY FILEGROUP <filegroup name {<filegroup property> | NAME = <new filegroup name>}
	|SET <optionspec> [,...n] [WITH <termination>]
	|COLLATE <collation name>
```

- 使用范例

  ```mssql
  ALTER DATABASE Accounting
  	MODIFY FILE
  	(NAME = Accounting,
  	 SIZE = 100MB)
  ```

### ALTER TABLE

- 基本语法

  ```mssql
  ALTER TABLE table_name
  	{[ALTER COLUMN <column_name>
  		{ [schema of new data type>]. <new_data_type>
  			(precision [, scale])] max |
  <xml schema collection>
  	[COLLATE <collation_name>]
  	[NULL | NOT NULL]
  	|[{ADD|DDROP} ROWGUIDCOL] | PERSISTED}]
  |ADD
  	<column name> <data_type>
  	[[DEFAULT <constant_expression>]
  	|[IDENTITY [(<seed>, <increment>) [NOT FOR REPLICATION]]]]
  	[ROWGUIDCOL]
  	[COLLATE <collation_name>]
  		[NULL | NOT NULL]
  	[<column_constraints>]
  	|[<column_name> AS <computed_column_expression>]
  |ADD
  	[CONSTRAINT <constraint_name>]
  	{[{PRIMARY KEY|UNIQUE}
  		[CLUSTERED|NONCLUSTERED]
  		{(<column_name>[,...n])}
  		[WITH FILLFACTOR = <fillfactor>]
  		[ON {filegroup> | DEFAULT}]
  		]
  		|FOREIGN KEY
  			[(<column_name>[,...n])]
  			REFERENCES <referenced_table> [(<referenced_column>[,...n])]
  			[ON DELETE {CASCADE | NO ACTION}]
  			[ON UPDATE {CASCADE | NO ACTION}]
  			[NOT FOR REPLICATION]
  		|DEFAULT <constant_expreession>
  			[FOR <column_name>]
  		|CHECK [NOT FOR REPLICATION]
  	[,...n][,...n]
  		|[WITH CHECK | WITH NOCHECK]
  | {ENABLE | DISALBE} TRIGGER
  	{ALL | <trigger name> [,...n]}
  |DROP
  	{[CONSTRAINT <constraint_name>]
  		|COLUMN <column_name>}[,...n]
  	| {CHECK|NOCHECK} CONSTRAINT
  		{ALL | <constraint_name>[,...n]}
  	| {ENABLE|DISABLE} TRIGGER
  		{ALL | <trigger_name>[,...n]}
  	| SWITCH [ PARTITION <source partition number expression>]
  		TO [schema_name.] target_table
  		[ PARTITION <target partition number expression>]
  ```

- 使用范例

  ```mssql
  ALTER TABLE Employees
  	ADD
  		PreviousEmployer	VARCHAR(30)	NULL,
  		DateOfBirth			DATE		NULL,
  		LastRaiseDate		DATE		NOT NULL	DEFAULT '2018-01-01';
  ```


## DROP语句

- 基本语法

  ```mssql
  DROP <object type> <object name [,...n]
  ```
