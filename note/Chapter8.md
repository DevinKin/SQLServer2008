# 第八章-规范化和其他基本设计问题

## 理解表

- 表时具有相同常规属性的数据实例的集合。
- 表应该表示“现实中”的数据集合（通常称为实体），而且和其他表之间存在信息关系。
- 关于不同实体（表）和关系（实体之间如何一起工作）的图称为实体-关系数据库关系图（ER图）。

## 保持数据“规范”

- 规范化的概念的几个关键部分
  - 顺序必须是不重要的。
  - 表可以以非过程的方式彼此“关联”。
  - 通过关联这些基表，可以创建虚拟表来满足新的需求。
- 总共有6中范式。

### 准备工作

- 将数据变成第一范式的先决条件
  - 表只应描述一个实体（不要简化或者组合）。
  - 所有行必须是唯一的，而且必须有一个主键。
  - 行和列的顺序必须是无关的。

### 第一范式

- 第一范式（1NF）全部是关于消除重复数据组和保证原子性（数据时自包含和独立的）的规范化信息。
- 在高层次，这指的是创建主键，然后将任何重复的数据移动到新的表中，为这些表创建新键，如此进行下去。另外，将任何组合数据的列按每部分数据分成不同的行。
- 问题：
  - 花费磁盘空间多。
  - 性能会下降。
  - 数据完整性，行与行之间的重复数据经常出现不一致。
  - 分析数据。

### 第二范式

- 规范化的第二步是达到第二范式（2NF）。第二范式进一步减少重复数据的出现（不一定是数据组）。
- 第二范式有以下两个规则
  - 表必须符合第一范式的规则。
  - 每列必须依赖整个键。

### 第三范式

- 第三范式有以下3个规则
  - 表必须符合2NF。
  - 任何列都不能依赖非键列。譬如计算列，依赖其他列的计算结果。
  - 不可以有派生的数据。

### 其他范式

- Boyce-Codd范式（第三范式变体）：这个范式视图解决有多个重叠候选键的情况。这只可能在下列条件下发生
  - 所有候选键是组合键（即键由多个列组成）。
  - 有多个候选键。
  - 每个候选键至少有一个列和另一个候选键的列相同。
- 第四范式：视图解决多值依赖问题。
- 第五范式：处理无损和有损分解。

## 理解关系

- 3种主要的关系
  - 一对一
  - 一对多
  - 多对多

### 一对一关系

- 一对一关系指如果在一个表中有一个记录，那么在另一个表中也会有一个相匹配的记录。

### 零或一对一关系

- SQL Server中，可以通过下列的方式强制实施零活一对一关系：
  - 唯一键约束或者主键约束和外键约束的组合。
  - 触发器。

### 一对零，一对一或一对多关系

- SQL Server中，可以通过下面两个方法强制实施这种关系
  - 外键约束。
  - 触发器。

### 
