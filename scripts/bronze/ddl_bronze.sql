/*
===============================================================================
BRONZE LAYER DDL SCRIPT
===============================================================================
PURPOSE:
    Defines the physical schema for the raw landing zone. This layer mirrors 
    source data exactly to ensure fast and reliable ingestion from CSV files.

NOTES:
    - Tables are dropped and recreated to ensure a clean structural state.
    - Standardized VARCHAR lengths are used to accommodate raw source text.
===============================================================================
*/


drop table if exists crm_cust_info;
create table crm_cust_info(
	cst_id INT,
	cst_key VARCHAR(70),
	cst_firstname VARCHAR(70),
	cst_lastname VARCHAR(70),
	cst_marital_status VARCHAR(70),
	cst_gndr VARCHAR(70),
	cst_create_date DATE	
);

drop table if exists crm_prd_info;
create table crm_prd_info(
	prd_id INT,
	prd_key VARCHAR(70),
	prd_nm VARCHAR(70),
	prd_cost INT,
	prd_line VARCHAR(70),
	prd_start_dt DATE,
	prd_end_date DATE
);

drop table if exists crm_sales_details;
create table crm_sales_details(
	sls_ord_num VARCHAR(70),
	sls_prd_key VARCHAR(70),
	sls_cust_id INT,
	sls_order_id INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);

drop table if exists erp_loc_a101;
create table erp_loc_a101(
	cid VARCHAR(70),
	cntry VARCHAR(70)
);

drop table if exists erp_cust_az12;
create table erp_cust_az12(
	cid VARCHAR(70),
	bdate DATE,
	gen VARCHAR(70)
);

drop table if exists erp_px_cat_g1v2;
create table erp_px_cat_g1v2(
	id VARCHAR(70),
	cat VARCHAR(70),
	subcat VARCHAR(70),
	maintenance VARCHAR(70)
);


