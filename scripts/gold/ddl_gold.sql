/* =============================================================================
SCHEMA  : gold
OBJECTS : dim_products, dim_customers, fact_sales
PURPOSE : Gold-layer star schema for analytical workloads
          - Dimensions provide descriptive context
          - Fact table stores measurable sales events
          - Designed for BI tools and ad-hoc analytics

NOTES   :
- Surrogate keys generated using ROW_NUMBER()
- Views reflect current state of Silver layer
- Historical handling is done upstream
============================================================================= */

------------------------------------------------------------
-- DIMENSION: PRODUCTS
------------------------------------------------------------
/*
Purpose:
- Stores current (active) product master data
- Enriches CRM products with ERP category attributes
- Used by fact_sales for product-level analysis

Grain:
- One row per active product
*/
CREATE OR ALTER VIEW gold.dim_products AS
SELECT
    -- Surrogate key for dimensional joins
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,

    -- Business identifiers
    pn.prd_id   AS product_id,
    pn.prd_key  AS product_number,

    -- Descriptive attributes
    pn.prd_nm      AS product_name,
    pn.cat_id      AS category_id,
    pc.cat         AS category,
    pc.subcat      AS subcategory,
    pc.maintenance AS maintenance,

    -- Commercial attributes
    pn.prd_cost AS cost,
    pn.prd_line AS product_line,

    -- Lifecycle attributes
    pn.prd_start_dt AS start_date

FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
       ON pn.cat_id = pc.id

-- Exclude historical (inactive) product records
WHERE pn.prd_end_dt IS NULL;



------------------------------------------------------------
-- DIMENSION: CUSTOMERS
------------------------------------------------------------
/*
Purpose:
- Creates a unified customer profile
- Merges CRM, ERP, and location data
- Resolves conflicting gender values using business rules

Grain:
- One row per customer
*/
CREATE OR ALTER VIEW gold.dim_customers AS
SELECT 
    -- Surrogate key for dimensional joins
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,

    -- Business identifiers
    ci.cst_id  AS customer_id,
    ci.cst_key AS customer_number,

    -- Personal attributes
    ci.cst_firstname AS firstname,
    ci.cst_lastname  AS lastname,

    -- Geographic attributes
    la.cntry AS country,

    -- Demographic attributes
    ci.cst_marital_status AS marital_status,

    -- Gender resolution logic
    -- Prefer CRM value unless it is 'n/a'
    CASE 
        WHEN ci.cst_gndr <> 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,

    -- Birth date sourced from ERP
    ca.bdate AS birthdate,

    -- Record creation date
    ci.cst_create_date

FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
       ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
       ON ci.cst_key = la.cid;



------------------------------------------------------------
-- FACT: SALES
------------------------------------------------------------
/*
Purpose:
- Stores transactional sales measures
- Connects products and customers via surrogate keys
- Forms the core of revenue and volume analysis

Grain:
- One row per sales order line
*/
CREATE OR ALTER VIEW gold.fact_sales AS
SELECT 
    -- Business order reference
    sd.sls_ord_num AS order_number,

    -- Dimension surrogate keys
    pr.product_key,
    cu.customer_key,

    -- Date attributes
    sd.sls_oder_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt  AS due_date,

    -- Measures
    sd.sls_sales   AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price   AS price

FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
       ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
       ON cu.customer_id = sd.sls_cust_id;

