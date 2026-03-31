/* 
============================================================
create database and schemas
============================================================
Script Purpose:
 This script creates a new database named 'DataWarehouse' after checking if it already exists.
 if the database exists,it is dropped and recreated.Additionally,the scripts sets up three schemas
 within the database:'bronze','silver',and 'gold'.

WARNING:
   Running this script will drop the entire 'DataWarehouse' after checking if it already exists.
   All data in the database will be permanently deleted.proceed with caution
   and ensure you have proper backups before running this script.
*/
Use master;
go

if exists(select 1 from sys.database where name='DataWarehouse')
begin
  alter database DataWareHouse  SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  drop database DataWareHouse;
end;
go
  -- Create the 'DataWarehouse' database
create database DataWarehouse;
go
use DataWarehouse
  go

-- create schemas
create schema bronze
GO --it is like a seperator
create schema silver
 GO --it is like a seperator
create schema gold
 GO --it is like a seperator
