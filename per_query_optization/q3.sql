set statistics IO on
set statistics time on
dbcc dropcleanbuffers
dbcc freeproccache


/* TPC_H Query 3 - Shipping Priority */
SELECT TOP 10 L_ORDERKEY, SUM(L_EXTENDEDPRICE*(1-L_DISCOUNT)) AS REVENUE, O_ORDERDATE, O_SHIPPRIORITY
FROM CUSTOMER_par, ORDERS_par, LINEITEM_par
WHERE C_MKTSEGMENT = 'BUILDING' AND C_CUSTKEY = O_CUSTKEY AND L_ORDERKEY = O_ORDERKEY AND
O_ORDERDATE < '1995-03-15' AND L_SHIPDATE > '1995-03-15'
GROUP BY L_ORDERKEY, O_ORDERDATE, O_SHIPPRIORITY
ORDER BY REVENUE DESC, O_ORDERDATE;


set transaction isolation level read uncommitted;


/* Index */

drop index if exists date_ix on lineitem;
drop index if exists ix2 on lineitem;
create nonclustered index ix2 on LINEITEM(L_SHIPDATE) include (L_EXTENDEDPRICE, L_DISCOUNT);

drop index if exists ix1 on ORDERS;
create nonclustered index ix1 on ORDERS(O_ORDERDATE) include (O_CUSTKEY, O_SHIPPRIORITY);

drop index if exists ix1 on CUSTOMER;
create nonclustered index ix1 on CUSTOMER(C_MKTSEGMENT);


/* Partition */

-- Date partition
drop partition function tpch_partition_q3date;
CREATE PARTITION FUNCTION tpch_partition_q3date( DATE )
AS RANGE RIGHT
FOR VALUES( '1993-05-01','1994-09-01', '1995-12-31', '1997-04-15');

drop partition scheme tpch_partition_scheme_q3date;
CREATE PARTITION SCHEME tpch_partition_scheme_q3date
AS PARTITION tpch_partition_q3date
TO (GROUP1, GROUP2, GROUP3, GROUP4, GROUP5 );


-- Hash-int partition
drop partition function fun_hash;
CREATE PARTITION FUNCTION fun_hash (int) AS
RANGE LEFT FOR VALUES (-1073741824, 0, 1073741824)

drop partition scheme sche_fun_hash
CREATE PARTITION SCHEME sche_fun_hash AS PARTITION fun_hash
TO (GROUP1, GROUP2, GROUP3, GROUP4, GROUP5 );


-- Char partition
drop partition function tpch_partition_q3char;
CREATE PARTITION FUNCTION tpch_partition_q3char ( char(10) ) AS
RANGE LEFT FOR VALUES (0,1,2,3)

drop partition scheme tpch_partition_scheme_q3char
CREATE PARTITION SCHEME tpch_partition_scheme_q3char
AS PARTITION tpch_partition_q3char TO (GROUP1, GROUP2, GROUP3, GROUP4, GROUP5 );


-- new tables
drop table if exists ORDERS_PAR;
create table ORDERS_PAR(
	O_ORDERKEY		integer			not null,	-- 订单表主键
	O_CUSTKEY		integer			not null references CUSTOMER(C_CUSTKEY),	-- Foreign Key to C_CUSTKEY
	O_ORDERSTATUS	char(1)			not null,	-- 订单状态
	O_TOTALPRICE	decimal(15,2)	not null,	-- 总金额
	O_ORDERDATE		date			not null,	-- 订单日期
	O_ORDERPRIORITY char(15)		not null,	-- 订单优先级
	O_CLERK			char(15)		not null,	-- 记账员
	O_SHIPPRIORITY	integer			not null,	-- 装运优先级
	O_COMMENT		varchar(100)	null		-- 备注
	primary key (O_ORDERKEY)
) 
on sche_fun_hash( O_ORDERKEY );
--on tpch_partition_scheme_q3date( O_ORDERDATE );

drop table if exists LINEITEM_PAR;
create table LINEITEM_PAR(
	L_ORDERKEY		integer			not null,		-- Foreign Key to O_ORDERKEY
	L_PARTKEY		integer			not null,		-- Foreign key to P_PARTKEY
	L_SUPPKEY		integer			not null,	-- Foreign key to S_SUPPKEY
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
)
on sche_fun_hash( L_ORDERKEY );
--on tpch_partition_scheme_q3date( L_SHIPDATE );

drop table if exists CUSTOMER_PAR
create table CUSTOMER_PAR(
	C_CUSTKEY		integer			not null,	-- 客户表主键，SF*150,000 are populated
	C_NAME			varchar(25)		not null,	-- 顾客姓名
	C_ADDRESS		varchar(40)		not null,	-- 地址
	C_NATIONKEY		integer			not null references NATION(N_NATIONKEY),		-- Foreign Key to N_NATIONKEY
	C_PHONE			char(15)		not null,	-- 国际电话，例:011-86-755-86285739
	C_ACCTBAL		decimal(15,2)	not null,	-- 账户余额
	C_MKTSEGMENT	char(10)		not null,	-- 市场区块（如中国区、南美区、北美区等）
	C_COMMENT		varchar(200)	null,		-- 备注
	primary key (C_CUSTKEY)
)
on sche_fun_hash( C_CUSTKEY );
--on tpch_partition_scheme_q3char( C_MKTSEGMENT );


insert into ORDERS_PAR
select * from ORDERS;

insert into LINEITEM_PAR
select * from LINEITEM;

insert into CUSTOMER_PAR
select * from CUSTOMER;


