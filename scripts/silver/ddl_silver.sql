
/*
===============================================================================
Silver Layer Table Creation Script
===============================================================================
Script Purpose:
    This script creates the Silver layer tables in the 'silver' schema, which serve 
    as the cleaned and transformed layer for data warehousing. It includes the 
    following tables:
    - silver.crm_cust_info: Customer master data with standardized fields.
    - silver.crm_prd_info: Product information with category and line details.
    - silver.crm_sales_details: Sales transaction data with order and pricing details.
    - silver.erp_loc_a101: Location/country information from ERP system.
    - silver.erp_cust_az12: Customer demographic data including birth date and gender.
    - silver.erp_px_cat_g1v2: Product category hierarchy with maintenance flags.

Table Features:
    - Each table includes a dwh_create_date column with DEFAULT CURRENT_TIMESTAMP 
      for audit trail and data lineage tracking.
    - Tables are dropped if they already exist to ensure clean recreation.
    - Data types are optimized for the expected data (VARCHAR for strings, INT for 
      numeric values, DATE for date fields).

Usage Notes:
    - Execute this script before loading data into the Silver Layer.
    - Ensure the 'silver' schema exists before running this script.
    - All tables are designed to match the structure of the bronze layer sources 
      after data cleansing and standardization.
===============================================================================
*/




drop table if exists silver.crm_cust_info;
create table silver.crm_cust_info(
	cst_id INT,
	cst_key VARCHAR(70),
	cst_firstname VARCHAR(70),
	cst_lastname VARCHAR(70),
	cst_marital_status VARCHAR(70),
	cst_gndr VARCHAR(70),
	cst_create_date DATE,	
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

drop table if exists silver.crm_prd_info;
create table silver.crm_prd_info(
	prd_id INT,
	cat_id VARCHAR(70),
	prd_key VARCHAR(70),
	prd_nm VARCHAR(70),
	prd_cost INT,
	prd_line VARCHAR(70),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);


drop table if exists silver.crm_sales_details;
create table silver.crm_sales_details(
	sls_ord_num VARCHAR(70),
	sls_prd_key VARCHAR(70),
	sls_cust_id INT,
	sls_order_id INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

drop table if exists silver.erp_loc_a101;
create table silver.erp_loc_a101(
	cid VARCHAR(70),
	cntry VARCHAR(70),
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

drop table if exists silver.erp_cust_az12;
create table silver.erp_cust_az12(
	cid VARCHAR(70),
	bdate DATE,
	gen VARCHAR(70),
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

drop table if exists silver.erp_px_cat_g1v2;
create table silver.erp_px_cat_g1v2(
	id VARCHAR(70),
	cat VARCHAR(70),
	subcat VARCHAR(70),
	maintenance VARCHAR(70),
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);






