# TPC-H-Optimization-Project
Lab project of 2020 sprint Intro2DB course

## Lab Report (still developing)
性能调优报告_1700017815_张旻昊_1700017802_耿思博_1700017828_胡时京.docx

## Data preparation
Create all tables:
> create_tables.sql 
Load data using Python APIs:
> load_data.py
SQL-Server-styled TPC-H queries:
>all_tpch_queries.sql

## Optimizatiion codes
All included in **per_query_optization/** directory.
The optimization of each query grouped into a .sql file, utilizing techniques including **indices, table partition & indexed views**.
Add_group.sql performs the operations to add file groups for partitioned data to be saved.
