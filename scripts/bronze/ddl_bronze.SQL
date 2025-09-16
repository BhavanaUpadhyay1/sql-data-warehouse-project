 use Datawarehouse;
 
 /*
 DDL Script: create bronze tables
 
 Script purpose: 
 This script creates tables in the 'bronze' schema, dropping existing tables if they already exist.
 Run this script to re-define the DDL structure of 'bronze' Tables
 
 */
create table bronze.crm_cust_info (
cst_id INT,	
cst_key	VARCHAR(50),
cst_firstname	VARCHAR(50),
cst_lastname	VARCHAR(50),
cst_marital_status	VARCHAR(50),
cst_gndr	VARCHAR(50),
cst_create_date DATE );

-- DDL for table: prd_info
-- Source file: C:\Users\bhava\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv
-- Columns: 7, Rows analyzed: 397
DROP TABLE IF EXISTS prd_info;
CREATE TABLE bronze.crm_prd_info (
    prd_id INTEGER,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost DECIMAL(10,2),
    prd_line VARCHAR(50),
    prd_start_dt VARCHAR(50),
    prd_end_dt VARCHAR(50)
);

-- DDL for table: sales_details
-- Source file: C:\Users\bhava\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv
-- Columns: 9, Rows analyzed: 1000
DROP TABLE IF EXISTS sales_details;
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INTEGER,
    sls_order_dt INTEGER,
    sls_ship_dt INTEGER,
    sls_due_dt INTEGER,
    sls_sales INTEGER,
    sls_quantity INTEGER,
    sls_price INTEGER
);

-- DDL for table: cust_az12
-- Source file: C:\Users\bhava\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv
-- Columns: 3, Rows analyzed: 1000
DROP TABLE IF EXISTS bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12 (
    cid VARCHAR(50),
    bdate VARCHAR(50),
    gen VARCHAR(50)
);

-- DDL for table: loc_a101
-- Source file: C:\Users\bhava\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv
-- Columns: 2, Rows analyzed: 1000
DROP TABLE IF EXISTS bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101 (
    cid VARCHAR(50),
    cntry VARCHAR(50)
);

-- DDL for table: px_cat_g1v2
-- Source file: C:\Users\bhava\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv
-- Columns: 4, Rows analyzed: 37
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(50)
);

-- creating temp table to load the data in structrured way

CREATE TEMPORARY TABLE temp_cust_info (
    col1 VARCHAR(255),
    col2 VARCHAR(255),
    col3 VARCHAR(255),
    col4 VARCHAR(255),
    col5 VARCHAR(255),
    col6 VARCHAR(255),
    col7 VARCHAR(255)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_info.csv'
INTO TABLE temp_cust_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@col1, @col2, @col3, @col4, @col5, @col6, @col7)
SET col1 = NULLIF(@col1, ''),
    col2 = @col2,
    col3 = @col3,
    col4 = @col4,
    col5 = @col5,
    col6 = @col6,
    col7 = NULLIF(@col7, '');
    
    SELECT COUNT(*) FROM temp_cust_info;
SELECT * FROM temp_cust_info LIMIT 5;

INSERT INTO bronze.crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
SELECT 
    CASE WHEN col1 = '' OR col1 IS NULL THEN NULL ELSE CAST(col1 AS SIGNED) END,
    col2,
    col3,
    col4,
    col5,
    col6,
    CASE WHEN col7 = '' OR col7 IS NULL THEN NULL ELSE STR_TO_DATE(col7, '%Y-%m-%d') END
FROM temp_cust_info
WHERE col1 IS NOT NULL AND col1 != '';  -- Only insert rows with valid cst_id

SELECT COUNT(*) FROM bronze.crm_cust_info;
SELECT * FROM bronze.crm_cust_info LIMIT 5;

DROP TEMPORARY TABLE temp_cust_info;

-- created another temp table

CREATE TEMPORARY TABLE temp_prd_info (
prd_id int,
prd_key varchar(250),
prd_nm varchar(250),
prd_cost int,
prd_line varchar(250),
prd_start_dt date,
prd_end_dt date
);
    
    LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/prd_info.csv'
INTO TABLE temp_prd_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(prd_id, prd_key, prd_nm, prd_cost, prd_line, @prd_start_dt, @prd_end_dt)
SET prd_start_dt = STR_TO_DATE(NULLIF(@prd_start_dt, ''), '%m/%d/%Y'),
    prd_end_dt = STR_TO_DATE(NULLIF(@prd_end_dt, ''), '%m/%d/%Y');

insert into bronze.crm_prd_info (prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
select * from temp_prd_info;
SELECT COUNT(*) FROM bronze.crm_prd_info;
SELECT * FROM bronze.crm_cust_info LIMIT 5;

drop temporary table temp_prd_info;

-- loading data for sales file

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_details.csv'
into table bronze.crm_sales_details
fields terminated by ','
lines terminated by '\r\n'
ignore 1 rows
(sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, @sls_sales, sls_quantity, @sls_price
)
set sls_price = nullif(@sls_price, ''),
    sls_sales = nullif(@sls_sales, '');
    
    SELECT COUNT(*) FROM bronze.crm_sales_details;
SELECT * FROM bronze.crm_cust_info LIMIT 5;

-- loading data for erp file

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CUST_AZ12.csv'
INTO TABLE bronze.erp_cust_az12
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@col1, @col2, @col3)
SET CID = @col1,
    BDATE = @col2,
    GEN = NULLIF(@col3, '');
    
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LOC_A101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LOC_A101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS

  SELECT COUNT(*) FROM bronze.erp_loc_a101;
SELECT * FROM bronze.crm_cust_info LIMIT 5;

bronze.erp_px_cat_g1v2

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PX_CAT_G1V2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
