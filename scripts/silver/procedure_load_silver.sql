/*
================================================================================
Procedure : silver.load_silver
Purpose   : Load cleaned, standardized, and deduplicated data from Bronze to Silver.

Behavior:
    - Performs FULL reloads (TRUNCATE + INSERT) on all Silver tables
    - NOT incremental
    - Executes transformations, standardization, and data quality fixes
    - Includes step-level and batch-level execution timing via PRINT logs

Key Logic:
    - Deduplicates customer records using ROW_NUMBER (latest record wins)
    - Standardizes codes (gender, marital status, product line, country)
    - Cleans malformed dates and invalid numeric values
    - Recalculates sales when source data is inconsistent

Warnings:
    - Do NOT run concurrently
    - Truncates Silver tables (data loss if interrupted)
    - Ensure Bronze layer load is complete before execution
    - Partial loads possible if failure occurs after TRUNCATE

Error Handling:
    - Wrapped in TRY/CATCH
    - Logs error message, number, and state on failure
    - Execution stops on first error

Author:
    Mohammad Mohtashim

================================================================================
*/


CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    DECLARE 
        @start_time DATETIME,
        @end_time DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time DATETIME;

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT '====================================================';
        PRINT 'Loading Silver Layer';
        PRINT '====================================================';

        /* ================= CRM CUSTOMER ================= */

        SET @start_time = GETDATE();

        PRINT '>> Truncating table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Inserting data into table: silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT 
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            CASE 
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                ELSE 'n/a'
            END,
            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                ELSE 'n/a'
            END,
            cst_create_date
        FROM (
            SELECT *,
                   ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag
            FROM bronze.crm_cust_info
        ) t
        WHERE flag = 1
          AND cst_id IS NOT NULL;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
              + ' seconds';
        PRINT '----------------------------------------------------';

        /* ================= CRM PRODUCT ================= */

        SET @start_time = GETDATE();

        PRINT '>> Truncating table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        PRINT '>> Inserting data into table: silver.crm_prd_info';
        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT  
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
            SUBSTRING(prd_key, 7, LEN(prd_key)),
            prd_nm,
            ISNULL(prd_cost, 0),
            CASE UPPER(TRIM(prd_line))
                WHEN 'R' THEN 'Road'
                WHEN 'M' THEN 'Mountain'
                WHEN 'T' THEN 'Touring'
                WHEN 'S' THEN 'Other sales'
                ELSE 'n/a'
            END,
            CAST(prd_start_dt AS DATE),
            CAST(
                LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1
                AS DATE
            )
        FROM datawarehouse.bronze.crm_prd_info;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
              + ' seconds';
        PRINT '----------------------------------------------------';

        /* ================= ERP PRICE CATEGORY ================= */

        SET @start_time = GETDATE();

        PRINT '>> Truncating table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT '>> Inserting data into table: silver.erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT 
            id,
            cat,
            subcat,
            maintenance
        FROM bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' 
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
              + ' seconds';
        PRINT '----------------------------------------------------';

        /* ================= BATCH END ================= */

        SET @batch_end_time = GETDATE();

        PRINT '====================================================';
        PRINT 'Loading Silver Layer Completed';
        PRINT '>> Total Load Duration: ' 
              + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) 
              + ' seconds';
        PRINT '====================================================';

    END TRY
    BEGIN CATCH

        PRINT '====================================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        PRINT 'Error Message : ' + ERROR_MESSAGE();
        PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State   : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '====================================================';

    END CATCH
END;

