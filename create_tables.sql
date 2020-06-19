drop database if exists TPCH;

create database TPCH;

use TPCH;

-- �����
create table PART(
	P_PARTKEY		integer			not null primary key,		-- ����ţ�����
	P_NAME			varchar(55)		not null,	-- �������
	P_MFGR			char(25)		not null,	-- ����������
	P_BRAND			char(10)		not null,	-- Ʒ��
	P_TYPE			varchar(25)		not null,	-- ����
	P_SIZE			integer			not null,	-- �ߴ�
	P_CONTAINER		char(10)		not null,	-- ��װ
	P_RETAILPRICE	decimal(15,2)	not null,	-- ���ۼ۸�
	P_COMMENT		varchar(200)	null		-- ��ע
);

-- ��Ӧ�̱�
create table SUPPLIER(
	S_SUPPKEY		integer			not null primary key,	-- ��Ӧ�̺ţ�����
	S_NAME			char(25)		not null,	-- ����
	S_ADDRESS		varchar(40)		not null,	-- ��ַ
	S_NATIONKEY		integer			not null,	-- ���Ҵ���
	S_PHONE			char(15)		not null,	-- ���ʵ绰����:011-86-755-86285739
	S_ACCTBAL		decimal(15,2)	not null,	-- �˻����
	S_COMMENT		varchar(200)	null		-- ��ע
);

-- ��Ӧ��-�����
create table PARTSUPP(
	PS_PARTKEY		integer			not null references PART(P_PARTKEY),		-- Foreign Key to P_PARTKEY
	PS_SUPPKEY		integer			not null references SUPPLIER(S_SUPPKEY),	-- Foreign Key to S_SUPPKEY
	PS_AVAILQTY		integer			not null,	-- ��������
	PS_SUPPLYCOST	decimal(15,2)	not null,	-- ��Ӧ�۸�
	PS_COMMENT		varchar(200)	null,		-- ��ע
	primary key(PS_PARTKEY, PS_SUPPKEY)
);

-- ������
create table REGION(
	R_REGIONKEY		integer			not null primary key,	-- ������������5 regions are populated
	R_NAME			char(25)		not null,	-- ��������
	R_COMMENT		varchar(200)	null		-- ��ע
);

-- ���ұ�
create table NATION(
	N_NATIONKEY		integer			not null primary key,	-- ���ұ�������25 nations are populated
	N_NAME			char(25)		not null,	-- ��������
	N_REGIONKEY		integer			not null references REGION(R_REGIONKEY),	-- Foreign Key to R_REGIONKEY
	N_COMMENT		varchar(200)	null		-- ��ע
);

-- �ͻ���
create table CUSTOMER(
	C_CUSTKEY		integer			not null primary key,	-- �ͻ���������SF*150,000 are populated
	C_NAME			varchar(25)		not null,	-- �˿�����
	C_ADDRESS		varchar(40)		not null,	-- ��ַ
	C_NATIONKEY		integer			not null references NATION(N_NATIONKEY),		-- Foreign Key to N_NATIONKEY
	C_PHONE			char(15)		not null,	-- ���ʵ绰����:011-86-755-86285739
	C_ACCTBAL		decimal(15,2)	not null,	-- �˻����
	C_MKTSEGMENT	char(10)		not null,	-- �г����飨���й��������������������ȣ�
	C_COMMENT		varchar(200)	null		-- ��ע
);

-- ������
create table ORDERS(
	O_ORDERKEY		integer			not null primary key,	-- ����������
	O_CUSTKEY		integer			not null references CUSTOMER(C_CUSTKEY),	-- Foreign Key to C_CUSTKEY
	O_ORDERSTATUS	char(1)			not null,	-- ����״̬
	O_TOTALPRICE	decimal(15,2)	not null,	-- �ܽ��
	O_ORDERDATE		date			not null,	-- ��������
	O_ORDERPRIORITY char(15)		not null,	-- �������ȼ�
	O_CLERK			char(15)		not null,	-- ����Ա
	O_SHIPPRIORITY	integer			not null,	-- װ�����ȼ�
	O_COMMENT		varchar(100)	null		-- ��ע
);

-- ������ϸ
create table LINEITEM(
	L_ORDERKEY		integer			not null references ORDERS(O_ORDERKEY),		-- Foreign Key to O_ORDERKEY
	L_PARTKEY		integer			not null references PART(P_PARTKEY),		-- Foreign key to P_PARTKEY
	L_SUPPKEY		integer			not null references SUPPLIER(S_SUPPKEY),	-- Foreign key to S_SUPPKEY
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
	primary key (L_ORDERKEY, L_LINENUMBER)
);
