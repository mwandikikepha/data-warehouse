/*
CREATE DATABASE AND SCHEMAS 
-------------------------------
Script purpose: 
This script creates a new db called 'data warehouse'
Then, we setup three schemas inside within the db: bronze, silver and gold 

---------------------------------
*/

create database data_warehouse;
alter database owner to kepha;

-- Create the schemas
create schema bronze;
create schema silver;
create schema gold;
