/*
===============================================================================
BRONZE LAYER INGESTION SCRIPT (PostgreSQL)
===============================================================================
IMPORTANT NOTES:
1. ENVIRONMENT: This script uses psql meta-commands (\copy) and will NOT work 
   in standard SQL editors (like DBeaver or PGAdmin) unless they support psql.
   
2. FILE ACCESS: Due to Linux permission restrictions on /home/ directories, 
   all CSV files MUST be moved to /tmp/ before running this script.
   
3. DATA HANDLING: 
   - Uses NULL '' to prevent empty numeric fields from failing.
   - Uses QUOTE '"' to handle quoted text fields correctly.

4. AUTOMATION:
   - For a fully automated execution (including file movement), use the 
     accompanying 'load_bronze.sh' shell script.
===============================================================================
*/

truncate table crm_cust_info;
\copy bronze.crm_cust_info 
FROM '/tmp/cust_info.csv' 
WITH (
	FORMAT CSV, 
	HEADER true, 
	NULL '', 
	QUOTE '"'
);

truncate table crm_prd_info;
\copy bronze.crm_prd_info 
FROM '/tmp/prd_info.csv' 
WITH (
	FORMAT CSV, 
	HEADER true, 
	NULL '', 
	QUOTE '"'
);

truncate table crm_sales_details;
\copy bronze.crm_sales_details 
FROM '/tmp/sales_details.csv' 
WITH (
	FORMAT CSV, 
	HEADER true, 
	NULL '', 
	QUOTE '"'
);

truncate table erp_cust_az12;
\copy bronze.erp_cust_az12
FROM '/tmp/CUST_AZ12.csv' 
WITH (
	FORMAT CSV, 
	HEADER true, 
	NULL '', 
	QUOTE '"'
);

truncate table erp_loc_a101;
\copy bronze.erp_loc_a101
FROM '/tmp/LOC_A101.csv' 
WITH (
	FORMAT CSV, 
	HEADER true, 
	NULL '', 
	QUOTE '"'
);

truncate table erp_px_cat_g1v2;
\copy bronze.erp_px_cat_g1v2
FROM '/tmp/PX_CAT_G1V2.csv' 
WITH (
	FORMAT CSV, 
	HEADER true, 
	NULL '', 
	QUOTE '"'
);
