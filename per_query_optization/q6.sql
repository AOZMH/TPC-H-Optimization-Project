set statistics IO on
set statistics time on
dbcc dropcleanbuffers
dbcc freeproccache
drop index if exists Q6_IDX on lineitem;
/* TPC_H Query 6 - Forecasting Revenue Change */
SELECT SUM(L_EXTENDEDPRICE*L_DISCOUNT) AS REVENUE
FROM LINEITEM
WHERE L_SHIPDATE >= '1994-01-01' AND L_SHIPDATE < dateadd(yy, 1, cast('1994-01-01' as datetime))
    AND L_DISCOUNT BETWEEN .06 - 0.01 AND .06 + 0.01 AND L_QUANTITY < 24;

set transaction isolation level read uncommitted;

/* Index */
drop index if exists Q6_IDX on lineitem;

CREATE NONCLUSTERED INDEX Q6_IDX
ON [dbo].[LINEITEM] ([L_QUANTITY],[L_DISCOUNT],[L_SHIPDATE])
INCLUDE ([L_EXTENDEDPRICE])

/* q6 again */

SELECT SUM(L_EXTENDEDPRICE*L_DISCOUNT) AS REVENUE
FROM LINEITEM
WHERE L_SHIPDATE >= '1994-01-01' AND L_SHIPDATE < dateadd(yy, 1, cast('1994-01-01' as datetime))
    AND L_DISCOUNT BETWEEN .06 - 0.01 AND .06 + 0.01 AND L_QUANTITY < 24;

/* Partition */
-- date partition
drop partition function tpch_partition_q6date;
CREATE PARTITION FUNCTION tpch_partition_q6date( DATE )
AS RANGE RIGHT
FOR VALUES( '1993-12-31','1994-12-31', '1995-12-31', '1996-12-31');

drop partition scheme tpch_partition_scheme_q6date;
CREATE PARTITION SCHEME tpch_partition_scheme_q6date
AS PARTITION tpch_partition_q6date
TO (GROUP1, GROUP2, GROUP3, GROUP4, GROUP5 );

drop table if exists LINEITEM_PAR;
create table LINEITEM_PAR
(
    L_ORDERKEY integer not null,
    -- Foreign Key to O_ORDERKEY
    L_PARTKEY integer not null,
    -- Foreign key to P_PARTKEY
    L_SUPPKEY integer not null,
    -- Foreign key to S_SUPPKEY
    L_LINENUMBER integer not null,
    -- 订单明细号
    L_QUANTITY decimal(15,2) not null,
    -- 数量
    L_EXTENDEDPRICE decimal(15,2) not null,
    -- 金额 (L_EXTENDEDPRICE = L_QUANTITY * P_RETAILPRICE)
    L_DISCOUNT decimal(15,2) not null,
    -- 折扣
    L_TAX decimal(15,2) not null,
    -- 税率
    L_RETURNFLAG char(1) not null,
    -- 退货标志(If L_RECEIPTDATE <= CURRENTDATE then either "R" or "A" is selected at random else "N" is selected)
    L_LINESTATUS char(1) not null,
    -- 明细状态("O" if L_SHIPDATE > CURRENTDATE "F" otherwise)
    L_SHIPDATE date not null,
    -- 装运日期
    L_COMMITDATE date not null,
    -- 委托日期
    L_RECEIPTDATE date not null,
    -- 签收日期
    L_SHIPINSTRUCT char(25) not null,
    -- 装运说明（如deliver in person）
    L_SHIPMODE char(10) not null,
    -- 装运方式（如空运，陆运，海运）
    L_COMMENT varchar(100) null,
    -- 备注
    --primary key (L_ORDERKEY, L_LINENUMBER)
)
--on sche_fun_hash( L_ORDERKEY );
on tpch_partition_scheme_q6date( L_SHIPDATE );

insert into LINEITEM_PAR
select *
from LINEITEM;

/* query6 run on partitioned table */
SELECT SUM(L_EXTENDEDPRICE*L_DISCOUNT) AS REVENUE
FROM LINEITEM_PAR
WHERE L_SHIPDATE >= '1994-01-01' AND L_SHIPDATE < dateadd(yy, 1, cast('1994-01-01' as datetime))
    AND L_DISCOUNT BETWEEN .06 - 0.01 AND .06 + 0.01 AND L_QUANTITY < 24;

/* 物化视图 */
create view dbo.query6
with schemabinding
as
	SELECT 
	SUM(L_EXTENDEDPRICE*L_DISCOUNT) AS REVENUE,
	L_DISCOUNT,
	L_QUANTITY,
	count_big(*) as count_order
	FROM dbo.LINEITEM
	WHERE L_SHIPDATE >= CONVERT(DATETIME, '1994-01-01', 102) 
	AND L_SHIPDATE < dateadd(yy, 1, CONVERT(DATETIME, '1994-01-01', 102) )
	group by L_DISCOUNT,
	L_QUANTITY
;
create unique clustered index ix6 on dbo.query6 (L_DISCOUNT,L_QUANTITY);