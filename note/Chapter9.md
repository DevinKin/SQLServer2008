# 第9章-SQL Server存储和索引结构

## SQL Server存储机制

### 数据库

- 数据库是最高级别的存储机制。

### 区段

- 区段是用来为表和索引分配空间的基本存储单元。它由8个连续的8KB数据页组成，共计64KB大小。
- 区段的要点
  - 一旦区段已满，那么下一记录将要占据的空间不是记录的大小，而是整个新区段大小。
  - 通过预先分配空间，SQL Server节省了为每个记录分配新空间的时间。

### 页

- 页是特定区段的分配单元。每个区段包含8页。
- 页是在达到实际数据行之前所能达到的最后一个存储级别。
- 每一页中的行数不是固定的，这取决于行的大小，行的大小是可以改变的。
- 通常不允许跨页。
- 页类型
  - 数据：它们是表中的实际数据。
  - 索引：索引页既包括非群集索引的非叶级页和叶级页。
- 页拆分
  - 当页已满，它会进行拆分。意味着有多个新页被分配。

### 行

- 行最大可达8KB。

### 稀疏列

- 稀疏列(sparse column)主要用于处理重复的场景。
- image，text，ntext，geography，geometry，timestamp和所有用户自定义数据类型不能被标记为稀疏列。

## 理解索引

### 平衡树（B-树）

- 搜索B-树
- 更新B-树：页拆分。

### SQL Server中的数据访问方式

- 广义上，SQL Server检索所需数据的方法只有两种
  - 使用表扫描。
  - 使用索引。
- SQL Server使用何种方法来执行特定查询将取决于可用的索引，所需的列，使用的连接以及表的大小。
- WHERE中恰当使用EXISTS可以提高性能。

- SQL Server中有两种索引结构
  - 群集索引
  - 非群集索引，该索引又包括以下两种
    - 堆上的非群集索引。
    - 群集索引上的非群集索引。
- 索引在群基表或者堆上创建
  - 群集表：群集表时在其上具有群集索引的任意表。通过使用群集键唯一地标识独立的行，群集键即定义群集索引的列。
  - 堆：堆是在其上没有群集索引的任意表。基于行的区段，页以及行偏移量（偏移页顶部的位置）的组合创建唯一的标识符，或者成为行ID（Row ID，RID）。

- 群集索引对于任意给定的表而言是唯一的，每个表只能有一个群集索引。
- 当搜索条件非常符合一个索引，从而索引可以直接定位至数据中的特定位置时，这种查找就称为seek。

## 创建、修改和删除索引

### CREATE INDEX语句

- 语法

  ```mssql
  CREATE [UNIQUE] [CLUSTERED|NONCLUSTERED]
  INDEX <index name> ON <table or view name>(<column name> [ASC|DESC][,...n])
  INCLUDE (<column name> [, ...n]
  [WHERE <codition>])
  [WITH
  [PAD_INDEX = {ON | OFF}]
  [[,] FILLFACTOR = <fillfactor>]
  [[,] IGNORE_DUP_KEY = {ON | OFF}]
  [[,] DROP_EXISTING = {ON | OFF}]
  [[,] STATISTIC_NORECOMPUTE = {ON | OFF}]
  [[,] SORT_IN_TEMPDB = {ON | OFF}]
  [[,] ONLINE = {ON | OFF}]
  [[,] ALLOW_ROW_LOCKS = {ON | OFF}]
  [[,] MAXDOP = <maximum degree of parallelism>]
  [[,] DATA_COMPRESSION = {NONE | ROW | PAGE}]
  ]
  [ON {<filegroup> | <partition schema name | DEFAULT}]
  ```

- `ASC/DESC`允许为索引选择圣墟和降序排列顺序，默认是ASC，升序。

- `INCLUDE`目的是为了覆盖索引提供更好的支持。

- `WHERE`设置在索引中包含哪些行的条件。

- `PAD_INDEX`该选项决定了第一次创建索引时索引的非叶级页将有多满（用百分比表示）

- `FILLFACTOR`SQL Server第一次创建索引时，默认情况下尽可能将页填满，仅留两个记录的空间。可以设置FILLTACTOR设置1~100之间的任意值。

- `DROP_EXISTING`具有所讨论名称的任何现有索引将在构造新索引之前被删除。

- `STATISTICS_NORECOMPUTE`表明将负责更新统计信息。不建议用该选项。

- `ONLINE`将强指表对于一般的访问保持有效，并且不创建任何组织用户使用索引和/或表的锁。

- `MAXDOP`构建索引重写关于最大并行度的系统设置。

- `DATA COMPRESSION`表或索引中压缩数据。

### 创建XML索引

- 在SQL Server中，可以在类型为XML的列上创建索引，要求如下
  - 在包含需要索引的XML的表上必须具有群集索引。
  - 在创建“辅助”索引之间，必须现在XML数据列上创建”主“XML索引。
  - XML索引只能在XML类型的列上创建（而且XML索引是可以在该类型的列上创建的唯一一种索引）
  - XML列必须是基表的一部分，不能再视图上创建索引。

### 随约束创建的隐含索引

- 当向表中添加如下两种约束之一时，就会创建隐含索引
  - 主键约束
  - 唯一约束（也称为替换键）

## 在何时何地使用何种索引

### 选择性

- 所谓选择性，指的是列中唯一值的百分比。列中唯一值的百分比越高，选择性就越高，从而索引的益处就越大。
- 选择性规则的一个例外是：如果表中有一列是外键，那么在该列上有一个索引很可能是有益的。

### 选择群集索引

- 默认情况下，主键和群集索引一起创建的。可以在创建表时指定在设置主键后面添加`NONCLUSTERED`即可

  ```mssql
  CREATE TABLE MyTableKeyExample
  (
  	Column1 int IDENTITY
      	PRIMARY KEY NONCLUSTERED,
      Column2 int
  );
  ```

### 过滤索引

- 过滤索引注意的地方
  - 索引深度远小于全表索引。遍历索引的速度比较快。
  - 通过插入，更新，删除操作维护索引的开销比较低。

### 修改索引

- 语法

  ```mssql
  ALTER INDEX { <name of index> | ALL }
  ON <table or view name>
  {REBUILD
  [[WITH (
  	[PAD_INDEX = {ON | OFF}]
  	| [[,] FILLFACTOR = <fillfactor>]
  	| [[,] IGNORE_DUP_KEY = {ON | OFF}]
  	| [[,] DROP_EXISTING = {ON | OFF}]
  	| [[,] STATISTIC_NORECOMPUTE = {ON | OFF}]
  	| [[,] SORT_IN_TEMPDB = {ON | OFF}]
  	| [[,] ONLINE = {ON | OFF}]
  	| [[,] ALLOW_ROW_LOCKS = {ON | OFF}]
  	| [[,] MAXDOP = <maximum degree of parallelism>])]
  	| [ PARTITION = <partition number>
        	[ WITH ( <partition rebuild index option>
                 [,...n])]]]
  | DISABLE
  | REORGANIZE
  	[ PARTITION = <partition number> ]
  	[ WITH (LOB_COMPACTION = {ON | OFF})]
  | SET ([ ALLOW_ROW_LOCKS={ON | OFF}]
        | [[,] ALLOW_ROW_LOCKS = {ON | OFF}]
        | [[,] IGNORE_DUP_KEY = {ON | OFF}]
        | [[,] STATISTIC_NORECOMPUTE = {ON | OFF}])}
  ```

### 删除索引

- 语法

  ```mssql
  DROP INDEX <table or view name>.<index name>
  DROP INDEX <index name> ON <table or view name>
  ```

## 维护索引

- 索引的维护有两个问题需要处理
  - 页拆分。
  - 碎片。

### 确定碎片和页拆分的可能性

- SQL Server提供了一个特殊的元数据函数`sys.dm_db_index_phjysical_stats`，它有助于数据库中的页和区段有多满。

- `sys.dm_db_index_phjysical_stats`的语法

  ```mssql
  sys.dm_db_index_physical_stats (
  	{ <database id> | NULL | 0 | DEFAULT}
      , { <object id> | NULL | 0 | -1 | DEFAULT}
      , { <index id> | NULL | 0 | DEFAULT}
      , {<mode> | NULL | DEFAULT}
  )
  ```

- 使用方式

  ```mssql
  DECLARE @db_id SMALLINT;
  DECLARE @object_id INT;
  SET @db_id = DB_ID(N'AdventureWorks');
  SET @object_id = OBJECT_ID(N'AdventureWorks.Sales.SalesOrderDetail');
  SELECT database_id, object_id, index_id, index_depth
  avg_fragmentation_in_percent,page_count
  FROM sys.dm_db_index_physical_stats(@db_id,@object_id,NULL,NULL,NULL);
  ```

- 使用ALTER INDEX重建索引。

  ```mssql
  ALTER INDEX PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID
  ON Sales.SalesOrderDetail
  REBUILD WITH (FILLFACTOR = 100);
  ```

## 本章小结

- 群集索引通常比非群集索引快。（有例外）
- 仅在将得到高级别选择性列（95%或者更多的行是唯一的）上防止非集群索引。
- 所有的数据库操作语言(DML: INSERT, UPDATE, DELETE, SELECT)语句可以通过索引获益，但是插入，删除和更新（记住，它们使用删除和插入方法）会因为索引而变慢。索引有助于查询的查找过程，但是任何修改数据的行为将要进行额外的维护索引操作。
- 索引会占用空间。
- 仅当索引中的第一列和查询相关时才使用索引。
- 索引的负面影响和它的正面影响一样多。
- 索引可以为非结构化XML数据提供结构化的数据性能，但会涉及其他系统开销。

