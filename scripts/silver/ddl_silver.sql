
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






