/*
===============================================================================
Silver Layer Data Load Procedure
===============================================================================
Script Purpose:
    This stored procedure loads and transforms data from the Bronze layer into 
    the Silver layer tables. It performs data cleansing, standardization, and 
    deduplication across all dimension and fact tables.

Tables Processed:
    - silver.crm_cust_info: Customer data with deduplication (latest record only),
      marital status and gender standardization, and string trimming.
    - silver.crm_prd_info: Product data with category extraction from product key,
      product line standardization, and end date calculation using LEAD function.
    - silver.crm_sales_details: Sales transactions with date validation (1900-2100),
      sales amount calculation when NULL/invalid, and price derivation from sales/quantity.
    - silver.erp_cust_az12: Customer ERP data with ID cleansing (removing 'NAS' prefix),
      future birth dates set to NULL, and gender standardization.
    - silver.erp_loc_a101: Location data with ID cleansing (removing hyphens) and 
      country name standardization (DE→Germany, US/USA→United States).
    - silver.erp_px_cat_g1v2: Product category data passed through as it is.

Data Quality Rules Applied:
    - Primary key deduplication using ROW_NUMBER()
    - String trimming for all text fields
    - NULL handling with COALESCE and CASE statements
    - Date range validation (1900-2100)
    - Standardization of codes to descriptive values
    - Division by zero prevention using NULLIF

Usage Notes:
    - Execute this procedure AFTER creating all Silver layer tables.
    - Run CALL silver.load_silver(); to execute.
    - Tables are truncated before each load for full refresh.
    - Source tables must exist in the bronze schema.
===============================================================================
*/




-- call comes after creating the procedure
call silver.load_silver();



create or replace procedure silver.load_silver() 
language plpgsql
as $$
begin 
	
	-- silver.crm_cust_info insert
	truncate table silver.crm_cust_info;
	insert into silver.crm_cust_info (
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
	)
	
	select 
	cst_id,
	cst_key,
	TRIM(cst_firstname) as cst_firstname, 
	TRIM(cst_lastname) as cst_lastname,
	
	case when upper(TRIM(cst_marital_status)) = 'S' then 'Single'
		 when upper(TRIM(cst_marital_status)) = 'M' then 'Married'
		 else 'n/a'
	 end cst_marital_status,
	
	case when upper(TRIM(cst_gndr)) = 'F' then 'Female'
		 when upper(TRIM(cst_gndr)) = 'M' then 'Male'
		 else 'n/a'
	 end cst_gndr,
	 
	cst_create_date
	
	from (
		select *,
		row_number() over (partition by cst_id order by cst_create_date desc) as flag_last
		from crm_cust_info cci 
	)t where flag_last = 1 ;
	
	
	
	
	-- silver.crm_prd_info insert
	truncate table silver.crm_prd_info;
	insert INTO silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	
	)
	
	select
	prd_id,
	replace(SUBSTRING(prd_key,1,5), '-','_') as cat_id,
	replace(SUBSTRING(prd_key from 7), '-', '_') as prd_key,
	prd_nm,
	coalesce (prd_cost, 0) as prd_cost,
	
	case upper(TRIM(prd_line))
		 when 'M' then 'Mountain'
		 when 'R' then 'Road'
		 when 'S' then 'Other Sales'
		 when 'T' then 'Touring'
		 else 'n/a'
	end as prd_line,
	prd_start_dt,
	lead (prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as prd_end_dt
	from bronze.crm_prd_info;
	
	
	-- silver.crm_sales_details insert 
	truncate table silver.crm_sales_details;
	insert into silver.crm_sales_details (
		sls_ord_num,
		sls_prd_key ,
		sls_cust_id ,
		sls_order_dt ,
		sls_ship_dt ,
		sls_due_dt,
		sls_sales ,
		sls_quantity ,
		sls_price
	)
	
	
	select
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	
	CASE 
	    WHEN sls_order_id BETWEEN 19000101 AND 21001231 
	    THEN TO_DATE(CAST(sls_order_id AS VARCHAR), 'YYYYMMDD')
	    ELSE NULL
	END AS sls_order_dt,
	
	CASE 
	    WHEN sls_ship_dt BETWEEN 19000101 AND 21001231 
	    THEN TO_DATE(CAST(sls_ship_dt AS VARCHAR), 'YYYYMMDD')
	    ELSE NULL
	END AS sls_ship_dt,
	
	
	CASE 
	    WHEN sls_due_dt BETWEEN 19000101 AND 21001231 
	    THEN TO_DATE(CAST(sls_due_dt AS VARCHAR), 'YYYYMMDD')
	    ELSE NULL
	END AS sls_due_dt,
	
	case when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * ABS(sls_price)
		 then sls_quantity * ABS(sls_price)
		 else sls_sales
	 end as sls_sales,
	
	sls_quantity,
	
	
	 case when sls_price is null or sls_price <=0
	 	  then sls_sales / NULLIF(sls_quantity, 0)
	 	  else sls_price 
	  end as sls_price
	 
	
	from bronze.crm_sales_details;
	
	
	-- silver.erp_cust_az12
	truncate table silver.erp_cust_az12;
	insert into silver.erp_cust_az12 (
		cid ,
		bdate ,
		gen 
	)
	
	
	select 
	
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
	     ELSE cid 
	 END AS cid,
	 CASE WHEN bdate > NOW() THEN null
	 	  ELSE bdate 
	  END AS bdate,
	 CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	 	  WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	 	  ELSE 'n/a'
	  END AS gen 
	  FROM bronze.erp_cust_az12;
	  
	  
	  -- silver.erp_loc_a101
	  truncate table silver.erp_loc_a101;
	  insert into silver.erp_loc_a101 (
		cid,
		cntry
	)
	
	select REPLACE(cid, '-', '') cid,
	
	CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
		 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
		 ELSE TRIM(cntry)
	 END AS cntry 
	 FROM bronze.erp_loc_a101;
	 
	 
	 -- insert into silver .erp_px_cat_g1v2
	 truncate table silver .erp_px_cat_g1v2;
	 insert into silver .erp_px_cat_g1v2 (
		id ,
		cat ,
		subcat,
		maintenance
	
	)
	
	select 
		id ,
		cat ,
		subcat,
		maintenance
	from bronze.erp_px_cat_g1v2;
		
end;
$$
	 






