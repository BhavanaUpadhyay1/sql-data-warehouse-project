use Datawarehouse;
 -- check for nulls or duplicates in primary key
 -- expectation: No result
 SELECT cst_id,
 count(*)
 FROM bronze.crm_cust_info
 group by cst_id
 having count(*)>1 or cst_id is null;
 
 select * from silver.crm_cust_info
 
 -- partitioned the cst_id so that it removes any duplicates
 select
 *
 from(
 select * ,
 row_number() over (partition by cst_id order by cst_create_date desc) as flag_last
 
 from bronze.crm_cust_info
 )t where flag_last = 1
 
 ----------------------------------------------------------------------------------------------------------------
 
 -- check for unwanted spaces
 -- expectation: no results
 
  SELECT
  cst_id,
  cst_key,
  trim(cst_firstname) as cst_firstname,
  trim(cst_lastname) as cst_lastname,
  cst_marital_status,
  cst_gndr,
  cst_create_date
  from bronze.crm_cust_info
  
  -----------------------------------------------------------------------------------------------------------------
  
-- data standardization and consistency
TRUNCATE TABLE silver.crm_cust_info;
SET GLOBAL sql_mode = 'ALLOW_INVALID_DATES';
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
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname)  AS cst_lastname,

    -- Marital status transformation
    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'NA'
    END AS cst_marital_status,

    -- Gender transformation/ data normalization and standarization
    -- handling missing data
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'NA'
    END AS cst_gndr,

    cst_create_date_clean
FROM (
    SELECT 
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,

        -- Clean date here so ROW_NUMBER doesn’t choke
        COALESCE(
            STR_TO_DATE(NULLIF(CAST(cst_create_date AS CHAR), '0000-00-00'), '%Y-%m-%d'),
            '1970-01-01'
        ) AS cst_create_date_clean,
-- removing duplicates and filtering
        ROW_NUMBER() OVER (
            PARTITION BY cst_id 
            ORDER BY COALESCE(
                STR_TO_DATE(NULLIF(CAST(cst_create_date AS CHAR), '0000-00-00'), '%Y-%m-%d'),
                '1970-01-01'
            ) DESC
        ) AS flag_last
    FROM bronze.crm_cust_info
) t
WHERE flag_last = 1;

-- checking the duplicate values in cst_id

SELECT cst_id, COUNT(*) AS cnt
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;
 
select cst_firstname
from silver.crm_cust_info
where cst_firstname!= trim(cst_firstname)
