# ==============================================================================
# BRONZE LAYER INGESTION SCRIPT (PostgreSQL)
# ==============================================================================
# WHY A BASH SCRIPT INSTEAD OF A STORED PROCEDURE?
# 1. PERMISSIONS: SQL Procedures run as 'postgres' user, which cannot access /home/.
# 2. CLIENT COMMANDS: '\copy' is a psql tool, not native SQL.
# 3. AUTOMATION: Handles OS-level file movements and DB load in one workflow.
# 4. ENVIRONMENT: Requires 'psql' client and 'sudo' privileges for the postgres user.
# 5. ERROR HANDLING: Uses 'set -e' to halt execution if any single step fails.
# 6. DATA HANDLING: Configured to treat empty CSV fields as NULL to prevent 
#    type errors in numeric columns.

# ==============================================================================

# Exit immediately if a command fails (Similar to a 'Try' block)
set -e

# Start the stopwatch
start_time=$SECONDS

# 1. SETUP PATHS
SOURCE_DIR="/home/kepha/Downloads/dbc9660c89a3480fa5eb9bae464d6c07/sql-data-warehouse-project/datasets"

echo "------------------------------------------------------------------------"
echo "Load Started at: $(date)"
echo "------------------------------------------------------------------------"



# 2. PREPARE FILES
echo "------------------------------------------------------------------------"
echo "Moving files to /tmp and setting permissions..."
echo "------------------------------------------------------------------------"

# Use 'if' to check if the source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "ERROR: Source directory not found!"
    exit 1
fi

cp "$SOURCE_DIR/source_crm/cust_info.csv" /tmp/
cp "$SOURCE_DIR/source_crm/prd_info.csv" /tmp/
cp "$SOURCE_DIR/source_crm/sales_details.csv" /tmp/
cp "$SOURCE_DIR/source_erp/CUST_AZ12.csv" /tmp/
cp "$SOURCE_DIR/source_erp/LOC_A101.csv" /tmp/
cp "$SOURCE_DIR/source_erp/PX_CAT_G1V2.csv" /tmp/

chmod 644 /tmp/*.csv
echo "Files successfully moved to /tmp."

# 3. LOAD CRM TABLES
echo ""
echo "------------------------------------------------------------------------"
echo "Loading Tables from the CRM source"
echo "------------------------------------------------------------------------"

# Run psql and catch error if it fails
if ! sudo -u postgres psql -d data_warehouse <<EOF
    TRUNCATE TABLE bronze.crm_cust_info;
    \copy bronze.crm_cust_info \
    FROM '/tmp/cust_info.csv' \
    WITH (FORMAT CSV, HEADER true, NULL '', QUOTE '"');

    TRUNCATE TABLE bronze.crm_prd_info;
    \copy bronze.crm_prd_info \
    FROM '/tmp/prd_info.csv' \
    WITH (FORMAT CSV, HEADER true, NULL '', QUOTE '"');

    TRUNCATE TABLE bronze.crm_sales_details;
    \copy bronze.crm_sales_details \
    FROM '/tmp/sales_details.csv' \
    WITH (FORMAT CSV, HEADER true, NULL '', QUOTE '"');
EOF
then
    echo " ERROR: CRM data load failed!"
    exit 1
fi

# 4. LOAD ERP TABLES
echo ""
echo "------------------------------------------------------------------------"
echo "Loading tables from the ERP source"
echo "------------------------------------------------------------------------"

if ! sudo -u postgres psql -d data_warehouse <<EOF
    TRUNCATE TABLE bronze.erp_cust_az12;
    \copy bronze.erp_cust_az12 \
    FROM '/tmp/CUST_AZ12.csv' \
    WITH (FORMAT CSV, HEADER true, NULL '', QUOTE '"');

    TRUNCATE TABLE bronze.erp_loc_a101;
    \copy bronze.erp_loc_a101 \
    FROM '/tmp/LOC_A101.csv' \
    WITH (FORMAT CSV, HEADER true, NULL '', QUOTE '"');

    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    \copy bronze.erp_px_cat_g1v2 \
    FROM '/tmp/PX_CAT_G1V2.csv' \
    WITH (FORMAT CSV, HEADER true, NULL '', QUOTE '"');
EOF
then
    echo " ERROR: ERP data load failed!"
    exit 1
fi

# Calculate Duration
end_time=$SECONDS
duration=$((end_time - start_time))


echo ""
echo "------------------------------------------------------------------------"
echo "SUCCESS: All tables loaded successfully"
echo "Load Duration: $duration seconds"
echo "Load Finished at: $(date)"
echo "------------------------------------------------------------------------"





















