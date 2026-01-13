


CREATE OR ALTER PROCEDURE bronze.LOAD_BRONZE AS
BEGIN
	Begin try

		print '==========================================================';
		print '                Loading bronze layer';
		print '==========================================================';
		truncate table bronze.crm_cust_info;
		bulk insert bronze.crm_cust_info
		from 'C:\Users\zainul\Downloads\Baraa SQL\SQl data warehouse\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with(
		firstrow = 2,
		fieldterminator = ',',
		tablock
		);


		truncate table bronze.crm_prd_info;
		bulk insert bronze.crm_prd_info
		from 'C:\Users\zainul\Downloads\Baraa SQL\SQl data warehouse\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with(
		firstrow = 2,
		fieldterminator = ',',
		tablock
		);


		truncate table bronze.crm_sales_details;
		bulk insert bronze.crm_sales_details
		from 'C:\Users\zainul\Downloads\Baraa SQL\SQl data warehouse\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with(
		firstrow = 2,
		fieldterminator = ',',
		tablock
		);


		truncate table bronze.erp_cust_az12;
		bulk insert bronze.erp_cust_az12
		from 'C:\Users\zainul\Downloads\Baraa SQL\SQl data warehouse\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		with(
		firstrow = 2,
		fieldterminator = ',',
		tablock
		);



		truncate table bronze.erp_loc_a101;
		bulk insert bronze.erp_loc_a101
		from 'C:\Users\zainul\Downloads\Baraa SQL\SQl data warehouse\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		with(
		firstrow = 2,
		fieldterminator = ',',
		tablock
		);


		truncate table bronze.erp_px_cat_g1v2;
		bulk insert bronze.erp_px_cat_g1v2
		from 'C:\Users\zainul\Downloads\Baraa SQL\SQl data warehouse\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		with(
		firstrow = 2,
		fieldterminator = ',',
		tablock
		);
	END try
	begin catch
	PRINT '========================================================'
	PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
	PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
	PRINT '========================================================'
	end catch
END
