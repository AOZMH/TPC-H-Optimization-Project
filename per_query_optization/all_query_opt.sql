create nonclustered index L_idx1
on LINEITEM(L_SHIPDATE) 
include (L_QUANTITY, L_EXTENDEDPRICE, L_DISCOUNT, L_TAX, L_RETURNFLAG, L_LINESTATUS);

create nonclustered index L_idx2 
on LINEITEM(L_SHIPDATE) 
include (L_EXTENDEDPRICE, L_DISCOUNT, L_SUPPKEY);

create nonclustered index L_idx3 
on LINEITEM(L_ORDERKEY) 
include (L_COMMITDATE, L_RECEIPTDATE);

create nonclustered index L_idx4 
on LINEITEM(L_SUPPKEY)
include (L_ORDERKEY, L_EXTENDEDPRICE, L_DISCOUNT);


create nonclustered index O_idx1 
on ORDERS(O_ORDERDATE) 
include (O_CUSTKEY, O_SHIPPRIORITY);

create nonclustered index O_idx2 
on ORDERS(O_ORDERDATE) 
include (O_ORDERPRIORITY);

create nonclustered index O_idx3 
on ORDERS(O_ORDERKEY) 
include (O_ORDERDATE, O_CUSTKEY);

create nonclustered index C_idx1 on CUSTOMER(C_MKTSEGMENT);


create nonclustered index PS_idx1
on PARTSUPP(PS_PARTKEY) 
include (PS_SUPPLYCOST, PS_SUPPKEY);

create nonclustered index S_idx1
on SUPPLIER(S_SUPPKEY) 
include (S_NATIONKEY, S_ACCTBAL, S_NAME, S_ADDRESS, S_PHONE, S_COMMENT);

create nonclustered index N_idx1
on NATION(N_NATIONKEY) 
include (N_NAME);
create nonclustered index N_idx2 
on NATION(N_REGIONKEY);

create nonclustered index P_idx1 
on PART(P_SIZE) 
include (P_MFGR, P_TYPE);

create nonclustered index R_idx1 
on REGION(R_NAME);
