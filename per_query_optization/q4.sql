set statistics IO on
set statistics time on
dbcc dropcleanbuffers
dbcc freeproccache


/* TPC_H Query 4 - Order Priority Checking */
SELECT O_ORDERPRIORITY, COUNT(*) AS ORDER_COUNT FROM ORDERS_par
WHERE O_ORDERDATE >= '1993-07-01' AND O_ORDERDATE < dateadd(mm,3, cast('1993-07-01' as datetime))
AND EXISTS (SELECT * FROM LINEITEM_par WHERE L_ORDERKEY = O_ORDERKEY AND L_COMMITDATE < L_RECEIPTDATE)
GROUP BY O_ORDERPRIORITY
ORDER BY O_ORDERPRIORITY;

set transaction isolation level read uncommitted;

/* Index */
drop index if exists ix2 on ORDERS;
create nonclustered index ix2 on ORDERS(O_ORDERDATE) include (O_ORDERPRIORITY);

drop index if exists ix3 on LINEITEM;
create nonclustered index ix3 on LINEITEM(L_ORDERKEY) include (L_COMMITDATE, L_RECEIPTDATE);


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

-- ORDERKEY partition
drop partition function tpch_partition_q4key;
CREATE PARTITION FUNCTION tpch_partition_q4key( int )
AS RANGE RIGHT
FOR VALUES(1200000, 2400000, 3600000, 4800000);

drop partition scheme tpch_partition_scheme_q4key;
CREATE PARTITION SCHEME tpch_partition_scheme_q4key
AS PARTITION tpch_partition_q4key
TO (GROUP1, GROUP2, GROUP3, GROUP4, GROUP5 );

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
--on tpch_partition_scheme_q4key( L_ORDERKEY );


insert into ORDERS_PAR
select * from ORDERS;

insert into LINEITEM_PAR
select * from LINEITEM;

select count(*)
from LINEITEM;

select count(*)/6001215.0
from lineitem
where l_orderkey<1500000;