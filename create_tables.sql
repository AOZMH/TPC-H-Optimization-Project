drop database if exists TPCH;

create database TPCH;

use TPCH;

-- 零件表
create table PART(
	P_PARTKEY		integer			not null primary key,		-- 零件号，主键
	P_NAME			varchar(55)		not null,	-- 零件名称
	P_MFGR			char(25)		not null,	-- 制造商名称
	P_BRAND			char(10)		not null,	-- 品牌
	P_TYPE			varchar(25)		not null,	-- 类型
	P_SIZE			integer			not null,	-- 尺寸
	P_CONTAINER		char(10)		not null,	-- 包装
	P_RETAILPRICE	decimal(15,2)	not null,	-- 零售价格
	P_COMMENT		varchar(200)	null		-- 备注
);

-- 供应商表
create table SUPPLIER(
	S_SUPPKEY		integer			not null primary key,	-- 供应商号，主键
	S_NAME			char(25)		not null,	-- 名称
	S_ADDRESS		varchar(40)		not null,	-- 地址
	S_NATIONKEY		integer			not null,	-- 国家代码
	S_PHONE			char(15)		not null,	-- 国际电话，例:011-86-755-86285739
	S_ACCTBAL		decimal(15,2)	not null,	-- 账户余额
	S_COMMENT		varchar(200)	null		-- 备注
);

-- 供应商-零件表
create table PARTSUPP(
	PS_PARTKEY		integer			not null references PART(P_PARTKEY),		-- Foreign Key to P_PARTKEY
	PS_SUPPKEY		integer			not null references SUPPLIER(S_SUPPKEY),	-- Foreign Key to S_SUPPKEY
	PS_AVAILQTY		integer			not null,	-- 可用数量
	PS_SUPPLYCOST	decimal(15,2)	not null,	-- 供应价格
	PS_COMMENT		varchar(200)	null,		-- 备注
	primary key(PS_PARTKEY, PS_SUPPKEY)
);

-- 地区表
create table REGION(
	R_REGIONKEY		integer			not null primary key,	-- 地区表主键，5 regions are populated
	R_NAME			char(25)		not null,	-- 地区名称
	R_COMMENT		varchar(200)	null		-- 备注
);

-- 国家表
create table NATION(
	N_NATIONKEY		integer			not null primary key,	-- 国家表主键，25 nations are populated
	N_NAME			char(25)		not null,	-- 国家名称
	N_REGIONKEY		integer			not null references REGION(R_REGIONKEY),	-- Foreign Key to R_REGIONKEY
	N_COMMENT		varchar(200)	null		-- 备注
);

-- 客户表
create table CUSTOMER(
	C_CUSTKEY		integer			not null primary key,	-- 客户表主键，SF*150,000 are populated
	C_NAME			varchar(25)		not null,	-- 顾客姓名
	C_ADDRESS		varchar(40)		not null,	-- 地址
	C_NATIONKEY		integer			not null references NATION(N_NATIONKEY),		-- Foreign Key to N_NATIONKEY
	C_PHONE			char(15)		not null,	-- 国际电话，例:011-86-755-86285739
	C_ACCTBAL		decimal(15,2)	not null,	-- 账户余额
	C_MKTSEGMENT	char(10)		not null,	-- 市场区块（如中国区、南美区、北美区等）
	C_COMMENT		varchar(200)	null		-- 备注
);

-- 订单表
create table ORDERS(
	O_ORDERKEY		integer			not null primary key,	-- 订单表主键
	O_CUSTKEY		integer			not null references CUSTOMER(C_CUSTKEY),	-- Foreign Key to C_CUSTKEY
	O_ORDERSTATUS	char(1)			not null,	-- 订单状态
	O_TOTALPRICE	decimal(15,2)	not null,	-- 总金额
	O_ORDERDATE		date			not null,	-- 订单日期
	O_ORDERPRIORITY char(15)		not null,	-- 订单优先级
	O_CLERK			char(15)		not null,	-- 记账员
	O_SHIPPRIORITY	integer			not null,	-- 装运优先级
	O_COMMENT		varchar(100)	null		-- 备注
);

-- 订单明细
create table LINEITEM(
	L_ORDERKEY		integer			not null references ORDERS(O_ORDERKEY),		-- Foreign Key to O_ORDERKEY
	L_PARTKEY		integer			not null references PART(P_PARTKEY),		-- Foreign key to P_PARTKEY
	L_SUPPKEY		integer			not null references SUPPLIER(S_SUPPKEY),	-- Foreign key to S_SUPPKEY
	L_LINENUMBER	integer			not null,	-- 订单明细号
	L_QUANTITY		decimal(15,2)	not null,	-- 数量
	L_EXTENDEDPRICE	decimal(15,2)	not null,	-- 金额 (L_EXTENDEDPRICE = L_QUANTITY * P_RETAILPRICE)
	L_DISCOUNT		decimal(15,2)	not null,	-- 折扣
	L_TAX			decimal(15,2)	not null,	-- 税率
	L_RETURNFLAG	char(1)			not null,	-- 退货标志(If L_RECEIPTDATE <= CURRENTDATE then either "R" or "A" is selected at random else "N" is selected)
	L_LINESTATUS	char(1)			not null,	-- 明细状态("O" if L_SHIPDATE > CURRENTDATE "F" otherwise)
	L_SHIPDATE		date			not null,	-- 装运日期
	L_COMMITDATE	date			not null,	-- 委托日期
	L_RECEIPTDATE	date			not null,	-- 签收日期
	L_SHIPINSTRUCT	char(25)		not null,	-- 装运说明（如deliver in person）
	L_SHIPMODE		char(10)		not null,	-- 装运方式（如空运，陆运，海运）
	L_COMMENT		varchar(100)	null,		-- 备注
	primary key (L_ORDERKEY, L_LINENUMBER)
);
