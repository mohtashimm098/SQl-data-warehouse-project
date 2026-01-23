# SQl-data-warehouse-project


# SQL Data Warehouse Project

## Overview

This project demonstrates the design and implementation of a **SQL Server–based data warehouse** using a **Bronze → Silver → Gold** layered architecture.
It shows how raw operational data is ingested, cleaned, transformed, validated, and finally shaped into **analytics-ready datasets** using **T-SQL only**.

The emphasis is on **ETL logic, data quality, and structure**, not on dashboards or UI tools.

---

## Architecture Approach

The warehouse follows a **medallion architecture**, a common industry pattern for building scalable and maintainable data platforms.

### Bronze Layer (Raw Data)

* Stores data exactly as received from the source
* Loaded using **bulk import**
* No business logic or assumptions applied
* Acts as a historical record and rollback point

### Silver Layer (Cleansed & Standardized)

* Cleans raw data from Bronze
* Handles:

  * Data type corrections
  * Null and invalid value handling
  * Deduplication and standardization
* Produces consistent, reliable datasets
* Includes **data validation checks**

### Gold Layer (Business & Analytics Ready)

* Merges and aggregates Silver data
* Applies business logic
* Creates final tables used for reporting and analysis
* Represents the **single source of truth**

---

## Project Structure

```text
Creating table step 1.sql     -- Bronze layer table creation
Bulk import step 2.sql        -- Raw data ingestion into Bronze
silver ddl.sql                -- Silver layer schema definitions
silver_merged.sql             -- Silver transformation logic
silver_check.sql              -- Silver data quality checks
gold_merged.sql               -- Gold layer transformations
gold_check.sql                -- Final validation and consistency checks
```

---

## Data Flow

1. **Bronze Setup**
   Tables are created and raw data is loaded using bulk import.

2. **Silver Transformation**
   Raw data is cleaned, standardized, and validated to ensure consistency and correctness.

3. **Gold Transformation**
   Clean data is merged and aggregated into business-ready tables optimized for analytics.

Each layer is **independent and rerunnable**, making the pipeline easier to debug and extend.

---

## Technologies Used

* **Database**: Microsoft SQL Server
* **Language**: T-SQL
* **ETL Style**: Script-based transformations

---

## Key Concepts Demonstrated

* Data warehousing fundamentals
* Medallion (Bronze/Silver/Gold) architecture
* SQL-based ETL pipelines
* Data quality validation
* Schema separation and data lineage
* Analytics-ready data modeling

---

## Purpose of the Project

This project is intended to:

* Practice real-world data warehouse design
* Demonstrate ETL thinking using SQL
* Show understanding of data flow and quality control
* Serve as a **portfolio project** for data-related roles

---

## Future Enhancements

* Incremental data loading
* Error logging and audit tables
* Stored procedures for orchestration
* Performance optimization and indexing
* Dimensional modeling (star schema)

---

## Author

**Mohammad Mohtashim**


