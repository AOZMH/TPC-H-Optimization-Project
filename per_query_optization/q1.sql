set statistics IO on
set statistics time on
dbcc dropcleanbuffers
dbcc freeproccache


/* TPC_H Query 1 - */
SELECT L_RETURNFLAG, L_LINESTATUS, SUM(L_QUANTITY) AS SUM_QTY,
 SUM(L_EXTENDEDPRICE) AS SUM_BASE_PRICE, SUM(L_EXTENDEDPRICE*(1-L_DISCOUNT)) AS SUM_DISC_PRICE,
 SUM(L_EXTENDEDPRICE*(1-L_DISCOUNT)*(1+L_TAX)) AS SUM_CHARGE, AVG(L_QUANTITY) AS AVG_QTY,
 AVG(L_EXTENDEDPRICE) AS AVG_PRICE, AVG(L_DISCOUNT) AS AVG_DISC, COUNT(*) AS COUNT_ORDER
FROM LINEITEM
WHERE L_SHIPDATE <= dateadd(dd, -90, cast('1998-12-01' as datetime))
GROUP BY L_RETURNFLAG, L_LINESTATUS
ORDER BY L_RETURNFLAG, L_LINESTATUS;


set transaction isolation level read uncommitted;


/* Index */
drop index if exists date_ix on lineitem;
create nonclustered index date_ix on LINEITEM(L_SHIPDATE) include (L_QUANTITY, L_EXTENDEDPRICE, L_DISCOUNT, L_TAX, L_RETURNFLAG, L_LINESTATUS);
create nonclustered index date_ix on LINEITEM(L_SHIPDATE, L_RETURNFLAG, L_LINESTATUS) include (L_QUANTITY, L_EXTENDEDPRICE, L_DISCOUNT, L_TAX);


/* Partition */
-- date partition
drop partition function tpch_partition_q1date;
CREATE PARTITION FUNCTION tpch_partition_q1date( DATE )
AS RANGE RIGHT
FOR VALUES( '1993-07-01','1994-10-24', '1996-03-01', '1997-06-15');

drop partition scheme tpch_partition_scheme_q1date;
CREATE PARTITION SCHEME tpch_partition_scheme_q1date
AS PARTITION tpch_partition_q1date
TO (GROUP1, GROUP2, GROUP3, GROUP4, GROUP5 );

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
	--primary key (L_ORDERKEY, L_LINENUMBER)
)
--on sche_fun_hash( L_ORDERKEY );
on tpch_partition_scheme_q1date( L_SHIPDATE );

insert into LINEITEM_PAR
select * from LINEITEM;

select count(*)/6001215.0
from LINEITEM
where L_SHIPDATE <= '1997-06-15';

select dateadd(dd, -90, cast('1998-12-01' as datetime))


/* Indexed views */
SET NUMERIC_ROUNDABORT OFF;
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT,
   QUOTED_IDENTIFIER, ANSI_NULLS ON;

drop view if exists dbo.query1;
create view dbo.query1
with schemabinding
as
	SELECT L_RETURNFLAG, L_LINESTATUS,
	SUM(L_EXTENDEDPRICE) AS SUM_BASE_PRICE, SUM(L_EXTENDEDPRICE*(1-L_DISCOUNT)) AS SUM_DISC_PRICE,
	SUM(L_EXTENDEDPRICE*(1-L_DISCOUNT)*(1+L_TAX)) AS SUM_CHARGE,
	SUM(L_QUANTITY) AS SUM_QTY, COUNT_BIG(L_QUANTITY) AS CT_QTY,
	SUM(L_EXTENDEDPRICE) AS SUM_PRICE, COUNT_BIG(L_EXTENDEDPRICE) AS CT_PRICE,
	SUM(L_DISCOUNT) AS SUM_DISC, COUNT_BIG(L_DISCOUNT) AS CT_DISC,
	COUNT_BIG(*) AS COUNT_ORDER
	FROM dbo.LINEITEM
	WHERE L_SHIPDATE <= dateadd(dd, -90, CONVERT(DATETIME, '1998-12-01', 102))
	GROUP BY L_RETURNFLAG, L_LINESTATUS
;

drop index if exists ix1 on dbo.query1;
create unique clustered index ix1
on dbo.query1( L_RETURNFLAG, L_LINESTATUS );

dbcc dropcleanbuffers
dbcc freeproccache

select L_RETURNFLAG, L_LINESTATUS,SUM_QTY, SUM_BASE_PRICE, SUM_DISC_PRICE, SUM_CHARGE,
	SUM_QTY/CT_QTY AS AVG_QTY, SUM_PRICE/CT_PRICE AS AVG_PRICE, SUM_DISC/CT_DISC AS AVG_DISC,COUNT_ORDER
from dbo.query1
ORDER BY L_RETURNFLAG, L_LINESTATUS;

SELECT dateadd(dd, -90, CONVERT(DATETIME, '1998-12-01', 101));
SELECT dateadd(dd, -90, cast('1998-12-01' as datetime));
