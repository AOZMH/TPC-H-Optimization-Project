use TPCH
dbcc dropcleanbuffers
dbcc freeproccache

/* TPC_H Query 7 - Volume Shipping */
SELECT SUPP_NATION, CUST_NATION, L_YEAR, SUM(VOLUME) AS REVENUE
FROM ( SELECT N1.N_NAME AS SUPP_NATION, N2.N_NAME AS CUST_NATION, datepart(yy, L_SHIPDATE) AS L_YEAR,
 L_EXTENDEDPRICE*(1-L_DISCOUNT) AS VOLUME
 FROM SUPPLIER, LINEITEM, ORDERS, CUSTOMER, NATION N1, NATION N2
 WHERE S_SUPPKEY = L_SUPPKEY AND O_ORDERKEY = L_ORDERKEY AND C_CUSTKEY = O_CUSTKEY
 AND S_NATIONKEY = N1.N_NATIONKEY AND C_NATIONKEY = N2.N_NATIONKEY AND  ((N1.N_NAME = 'FRANCE' AND N2.N_NAME = 'GERMANY') OR
 (N1.N_NAME = 'GERMANY' AND N2.N_NAME = 'FRANCE')) AND
 L_SHIPDATE BETWEEN '1995-01-01' AND '1996-12-31' ) AS SHIPPING
GROUP BY SUPP_NATION, CUST_NATION, L_YEAR
ORDER BY SUPP_NATION, CUST_NATION, L_YEAR;


/* index */
DROP INDEX if EXISTS q7_idx_ord on orders;
CREATE NONCLUSTERED INDEX q7_idx_ord
ON [dbo].[ORDERS] ([O_CUSTKEY])
INCLUDE([O_ORDERKEY])

DROP INDEX if EXISTS q7_idx_itm on LINEITEM;
CREATE NONCLUSTERED INDEX q7_idx_itm
ON [dbo].[LINEITEM] ([L_SHIPDATE])
INCLUDE ([L_EXTENDEDPRICE],[L_DISCOUNT],[L_SUPPKEY],[L_ORDERKEY])

DROP INDEX if EXISTS q7_idx_itm_2 on LINEITEM;
CREATE NONCLUSTERED INDEX q7_idx_itm_2
ON [dbo].[LINEITEM] ([L_SUPPKEY],[L_ORDERKEY])
INCLUDE ([L_EXTENDEDPRICE],[L_DISCOUNT])

DROP INDEX if EXISTS q7_idx_cus on CUSTOMER;
CREATE NONCLUSTERED INDEX q7_idx_cus
ON [dbo].[CUSTOMER] ([C_NATIONKEY])

--drop view dbo.query7_1
--create unique clustered index ix7 on dbo.query7_1( SUPP_NATION,CUST_NATION,L_YEAR,VOLUME );
drop partition function tpch_partition_q7date;
CREATE PARTITION FUNCTION tpch_partition_q7date( DATE )
AS RANGE RIGHT
FOR VALUES( '1993-12-31','1994-12-31', '1995-12-31', '1996-12-31');

drop partition scheme tpch_partition_scheme_q7date;
CREATE PARTITION SCHEME tpch_partition_scheme_q7date
AS PARTITION tpch_partition_q7date
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

/* Conduct Search on Partitioned Table */
SELECT SUPP_NATION, CUST_NATION, L_YEAR, SUM(VOLUME) AS REVENUE
FROM ( SELECT N1.N_NAME AS SUPP_NATION, N2.N_NAME AS CUST_NATION, datepart(yy, L_SHIPDATE) AS L_YEAR,
 L_EXTENDEDPRICE*(1-L_DISCOUNT) AS VOLUME
 FROM SUPPLIER, LINEITEM_PAR, ORDERS, CUSTOMER, NATION N1, NATION N2
 WHERE S_SUPPKEY = L_SUPPKEY AND O_ORDERKEY = L_ORDERKEY AND C_CUSTKEY = O_CUSTKEY
 AND S_NATIONKEY = N1.N_NATIONKEY AND C_NATIONKEY = N2.N_NATIONKEY AND  ((N1.N_NAME = 'FRANCE' AND N2.N_NAME = 'GERMANY') OR
 (N1.N_NAME = 'GERMANY' AND N2.N_NAME = 'FRANCE')) AND
 L_SHIPDATE BETWEEN '1995-01-01' AND '1996-12-31' ) AS SHIPPING
GROUP BY SUPP_NATION, CUST_NATION, L_YEAR
ORDER BY SUPP_NATION, CUST_NATION, L_YEAR;
