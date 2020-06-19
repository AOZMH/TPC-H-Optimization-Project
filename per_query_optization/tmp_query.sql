set statistics IO on
set statistics time on
dbcc dropcleanbuffers
dbcc freeproccache


/* TPC_H Query 5 - Local Supplier Volume */
SELECT N_NAME, SUM(L_EXTENDEDPRICE*(1-L_DISCOUNT)) AS REVENUE
FROM CUSTOMER, ORDERS, LINEITEM, SUPPLIER, NATION, REGION
WHERE C_CUSTKEY = O_CUSTKEY AND L_ORDERKEY = O_ORDERKEY AND L_SUPPKEY = S_SUPPKEY
AND C_NATIONKEY = S_NATIONKEY AND S_NATIONKEY = N_NATIONKEY AND N_REGIONKEY = R_REGIONKEY
AND R_NAME = 'ASIA' AND O_ORDERDATE >= '1994-01-01' 
AND O_ORDERDATE < DATEADD(YY, 1, cast('1994-01-01' as datetime))
GROUP BY N_NAME
ORDER BY REVENUE DESC;


set transaction isolation level read UNcommitted;

/* Index */
-- schema 1
drop index if exists ix3 on ORDERS;
create nonclustered index ix3 on ORDERS(O_ORDERDATE) include (O_ORDERKEY, O_CUSTKEY);

drop index if exists ix2 on CUSTOMER;
create nonclustered index ix2 on CUSTOMER(C_CUSTKEY) include (C_NATIONKEY);

drop index if exists ix4 on LINEITEM;
create nonclustered index ix4 on LINEITEM(L_ORDERKEY) include (L_SUPPKEY, L_EXTENDEDPRICE, L_DISCOUNT);

drop index if exists ix2 on SUPPLIER;
create nonclustered index ix2 on SUPPLIER(S_SUPPKEY) include (S_NATIONKEY);

drop index if exists ix2 on NATION;
create nonclustered index ix2 on NATION(N_NATIONKEY) include (N_REGIONKEY);

drop index if exists ix1 on REGION
create nonclustered index ix1 on REGION(R_REGIONKEY) include (R_NAME);

-- schema 2
drop index if exists ix4 on ORDERS;
create nonclustered index ix4 on ORDERS(O_ORDERKEY) include (O_ORDERDATE, O_CUSTKEY);

drop index if exists ix3 on CUSTOMER;
create nonclustered index ix3 on CUSTOMER(C_NATIONKEY);

drop index if exists ix5 on LINEITEM;
create nonclustered index ix5 on LINEITEM(L_SUPPKEY) include (L_ORDERKEY, L_EXTENDEDPRICE, L_DISCOUNT);

drop index if exists ix3 on SUPPLIER;
create nonclustered index ix3 on SUPPLIER(S_NATIONKEY);

drop index if exists ix3 on NATION;
create nonclustered index ix3 on NATION(N_REGIONKEY);

drop index if exists ix2 on REGION
create nonclustered index ix2 on REGION(R_NAME);


/* Partition */
drop table if exists ORDERS_PAR;
create table ORDERS_PAR(
	O_ORDERKEY		integer			not null,	-- ����������
	O_CUSTKEY		integer			not null references CUSTOMER(C_CUSTKEY),	-- Foreign Key to C_CUSTKEY
	O_ORDERSTATUS	char(1)			not null,	-- ����״̬
	O_TOTALPRICE	decimal(15,2)	not null,	-- �ܽ��
	O_ORDERDATE		date			not null,	-- ��������
	O_ORDERPRIORITY char(15)		not null,	-- �������ȼ�
	O_CLERK			char(15)		not null,	-- ����Ա
	O_SHIPPRIORITY	integer			not null,	-- װ�����ȼ�
	O_COMMENT		varchar(100)	null		-- ��ע
	--primary key (O_ORDERKEY)
) 
--on sche_fun_hash( O_ORDERKEY );
on tpch_partition_scheme_q3date( O_ORDERDATE );


drop table if exists LINEITEM_PAR;
create table LINEITEM_PAR(
	L_ORDERKEY		integer			not null,		-- Foreign Key to O_ORDERKEY
	L_PARTKEY		integer			not null,		-- Foreign key to P_PARTKEY
	L_SUPPKEY		integer			not null,	-- Foreign key to S_SUPPKEY
	L_LINENUMBER	integer			not null,	-- ������ϸ��
	L_QUANTITY		decimal(15,2)	not null,	-- ����
	L_EXTENDEDPRICE	decimal(15,2)	not null,	-- ��� (L_EXTENDEDPRICE = L_QUANTITY * P_RETAILPRICE)
	L_DISCOUNT		decimal(15,2)	not null,	-- �ۿ�
	L_TAX			decimal(15,2)	not null,	-- ˰��
	L_RETURNFLAG	char(1)			not null,	-- �˻���־(If L_RECEIPTDATE <= CURRENTDATE then either "R" or "A" is selected at random else "N" is selected)
	L_LINESTATUS	char(1)			not null,	-- ��ϸ״̬("O" if L_SHIPDATE > CURRENTDATE "F" otherwise)
	L_SHIPDATE		date			not null,	-- װ������
	L_COMMITDATE	date			not null,	-- ί������
	L_RECEIPTDATE	date			not null,	-- ǩ������
	L_SHIPINSTRUCT	char(25)		not null,	-- װ��˵������deliver in person��
	L_SHIPMODE		char(10)		not null,	-- װ�˷�ʽ������ˣ�½�ˣ����ˣ�
	L_COMMENT		varchar(100)	null,		-- ��ע
	--primary key (L_ORDERKEY, L_LINENUMBER)
)
on sche_fun_hash( L_ORDERKEY );
--on tpch_partition_scheme_q4key( L_ORDERKEY );

drop table if exists CUSTOMER_PAR
create table CUSTOMER_PAR(
	C_CUSTKEY		integer			not null,	-- �ͻ���������SF*150,000 are populated
	C_NAME			varchar(25)		not null,	-- �˿�����
	C_ADDRESS		varchar(40)		not null,	-- ��ַ
	C_NATIONKEY		integer			not null references NATION(N_NATIONKEY),		-- Foreign Key to N_NATIONKEY
	C_PHONE			char(15)		not null,	-- ���ʵ绰����:011-86-755-86285739
	C_ACCTBAL		decimal(15,2)	not null,	-- �˻����
	C_MKTSEGMENT	char(10)		not null,	-- �г����飨���й��������������������ȣ�
	C_COMMENT		varchar(200)	null		-- ��ע
	primary key (C_CUSTKEY)
)
on sche_fun_hash( C_CUSTKEY );

drop table if exists SUPPLIER_PAR
create table SUPPLIER_PAR(
	S_SUPPKEY		integer			not null primary key,	-- ��Ӧ�̺ţ�����
	S_NAME			char(25)		not null,	-- ����
	S_ADDRESS		varchar(40)		not null,	-- ��ַ
	S_NATIONKEY		integer			not null,	-- ���Ҵ���
	S_PHONE			char(15)		not null,	-- ���ʵ绰����:011-86-755-86285739
	S_ACCTBAL		decimal(15,2)	not null,	-- �˻����
	S_COMMENT		varchar(200)	null		-- ��ע
)
on sche_fun_hash( S_SUPPKEY );

drop table if exists NATION_PAR
create table NATION_PAR(
	N_NATIONKEY		integer			not null primary key,	-- ���ұ�������25 nations are populated
	N_NAME			char(25)		not null,	-- ��������
	N_REGIONKEY		integer			not null references REGION(R_REGIONKEY),	-- Foreign Key to R_REGIONKEY
	N_COMMENT		varchar(200)	null		-- ��ע
)
on sche_fun_hash( N_NATIONKEY );

drop table if exists REGION_PAR
create table REGION_PAR(
	R_REGIONKEY		integer			not null primary key,	-- ������������5 regions are populated
	R_NAME			char(25)		not null,	-- ��������
	R_COMMENT		varchar(200)	null		-- ��ע
)
on sche_fun_hash( R_REGIONKEY );


insert into ORDERS_PAR
select * from ORDERS;

insert into LINEITEM_PAR
select * from LINEITEM;

insert into CUSTOMER_PAR
select * from CUSTOMER;

insert into SUPPLIER_PAR
select * from SUPPLIER;

insert into NATION_PAR
select * from NATION;

insert into REGION_PAR
select * from REGION;


dbcc dropcleanbuffers
dbcc freeproccache

SELECT N_NAME, SUM(L_EXTENDEDPRICE*(1-L_DISCOUNT)) AS REVENUE
FROM CUSTOMER_par, ORDERS_par, LINEITEM_par, SUPPLIER_par, NATION_par, REGION_par
WHERE C_CUSTKEY = O_CUSTKEY AND L_ORDERKEY = O_ORDERKEY AND L_SUPPKEY = S_SUPPKEY
AND C_NATIONKEY = S_NATIONKEY AND S_NATIONKEY = N_NATIONKEY AND N_REGIONKEY = R_REGIONKEY
AND R_NAME = 'ASIA' AND O_ORDERDATE >= '1994-01-01' 
AND O_ORDERDATE < DATEADD(YY, 1, cast('1994-01-01' as datetime))
GROUP BY N_NAME
ORDER BY REVENUE DESC;


/* Indexed views */
SET NUMERIC_ROUNDABORT OFF;
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT,
   QUOTED_IDENTIFIER, ANSI_NULLS ON;

