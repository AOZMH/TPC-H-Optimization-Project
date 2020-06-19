alter database TPCH add filegroup group1
alter database TPCH add filegroup group2
alter database TPCH add filegroup group3
alter database TPCH add filegroup group4
alter database TPCH add filegroup group5


ALTER DATABASE TPCH ADD FILE(NAME=N'tpch_group1',FILENAME=N'D:\learn\data_for_english_route\TPCH_GROUP\tpch_group1.ndf',SIZE=3MB, MAXSIZE=UNLIMITED,FILEGROWTH=5MB)
TO FILEGROUP group1 --ÎÄ¼þ×é
ALTER DATABASE TPCH ADD FILE(NAME=N'tpch_group2',FILENAME=N'D:\learn\data_for_english_route\TPCH_GROUP\tpch_group2.ndf',SIZE=3MB, MAXSIZE=UNLIMITED,FILEGROWTH=5MB)
TO FILEGROUP group2
ALTER DATABASE TPCH ADD FILE(NAME=N'tpch_group3',FILENAME=N'D:\learn\data_for_english_route\TPCH_GROUP\tpch_group3.ndf',SIZE=3MB, MAXSIZE=UNLIMITED,FILEGROWTH=5MB)
TO FILEGROUP group3
ALTER DATABASE TPCH ADD FILE(NAME=N'tpch_group4',FILENAME=N'D:\learn\data_for_english_route\TPCH_GROUP\tpch_group4.ndf',SIZE=3MB, MAXSIZE=UNLIMITED,FILEGROWTH=5MB)
TO FILEGROUP group4
ALTER DATABASE TPCH ADD FILE(NAME=N'tpch_group5',FILENAME=N'D:\learn\data_for_english_route\TPCH_GROUP\tpch_group5.ndf',SIZE=3MB, MAXSIZE=UNLIMITED,FILEGROWTH=5MB)
TO FILEGROUP group5

select *  from sys.filegroups
