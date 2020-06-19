set statistics IO on
set statistics time on
dbcc dropcleanbuffers
dbcc freeproccache


/* TPC_H Query 2 - Minimum Cost Supplier */
SELECT TOP 100 S_ACCTBAL, S_NAME, N_NAME, P_PARTKEY, P_MFGR, S_ADDRESS, S_PHONE, S_COMMENT
FROM PART, SUPPLIER, PARTSUPP, NATION, REGION
WHERE P_PARTKEY = PS_PARTKEY AND S_SUPPKEY = PS_SUPPKEY AND P_SIZE = 15 AND
P_TYPE LIKE '%%BRASS' AND S_NATIONKEY = N_NATIONKEY AND N_REGIONKEY = R_REGIONKEY AND
R_NAME = 'EUROPE' AND
PS_SUPPLYCOST = (SELECT MIN(PS_SUPPLYCOST) FROM PARTSUPP, SUPPLIER, NATION, REGION
 WHERE P_PARTKEY = PS_PARTKEY AND S_SUPPKEY = PS_SUPPKEY
 AND S_NATIONKEY = N_NATIONKEY AND N_REGIONKEY = R_REGIONKEY AND R_NAME = 'EUROPE')
ORDER BY S_ACCTBAL DESC, N_NAME, S_NAME, P_PARTKEY;


set transaction isolation level read uncommitted;


/* Index */
drop index if exists ix1 on PARTSUPP;
--create nonclustered index ix1 on PARTSUPP(PS_PARTKEY) include (PS_SUPPLYCOST);
create nonclustered index ix1 on PARTSUPP(PS_PARTKEY) include (PS_SUPPLYCOST, PS_SUPPKEY);
--create nonclustered index ix1 on PARTSUPP(PS_SUPPKEY) include (PS_SUPPLYCOST, PS_PARTKEY);

drop index if exists ix1 on PART;
--create nonclustered index ix1 on PART(P_PARTKEY) include (P_MFGR, P_SIZE, P_TYPE);
create nonclustered index ix1 on PART(P_SIZE) include (P_MFGR, P_TYPE);


drop index if exists ix1 on SUPPLIER;
create nonclustered index ix1 on SUPPLIER(S_SUPPKEY) include (S_NATIONKEY, S_ACCTBAL, S_NAME, S_ADDRESS, S_PHONE, S_COMMENT);

drop index if exists ix1 on NATION;
create nonclustered index ix1 on NATION(N_NATIONKEY) include (N_NAME);


/* Indexed view */
SET NUMERIC_ROUNDABORT OFF;
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT,
   QUOTED_IDENTIFIER, ANSI_NULLS ON;

drop view if exists dbo.query2_1;
create view dbo.query2_1
with schemabinding as
	SELECT PS_PARTKEY, PS_SUPPLYCOST FROM dbo.PARTSUPP, dbo.SUPPLIER, dbo.NATION, dbo.REGION
	WHERE S_SUPPKEY = PS_SUPPKEY AND S_NATIONKEY = N_NATIONKEY
	AND N_REGIONKEY = R_REGIONKEY AND R_NAME = 'EUROPE';

create unique clustered index ix1
on dbo.query2_1( PS_PARTKEY, PS_SUPPLYCOST )


drop view if exists dbo.query2_2;
create view dbo.query2_2
with schemabinding as
	SELECT S_SUPPKEY, S_ACCTBAL, S_NAME, N_NAME, P_PARTKEY, P_MFGR, S_ADDRESS, S_PHONE, S_COMMENT, PS_SUPPLYCOST
	FROM dbo.PART, dbo.SUPPLIER, dbo.PARTSUPP, dbo.NATION, dbo.REGION
	WHERE P_PARTKEY = PS_PARTKEY AND S_SUPPKEY = PS_SUPPKEY AND P_SIZE = 15 AND
	P_TYPE LIKE '%%BRASS' AND S_NATIONKEY = N_NATIONKEY AND N_REGIONKEY = R_REGIONKEY AND
	R_NAME = 'EUROPE';

create unique clustered index ix1
on dbo.query2_2( P_PARTKEY, S_SUPPKEY )
