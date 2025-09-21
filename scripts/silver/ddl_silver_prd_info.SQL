-- Check for nulls or duplicates in primary key
-- Expectation: No result
-- categorized product key
-- checked the product with sales table that product is sold for atleast one time or not
-- done data modelling, mapping, standardization and normalization
-- derived new columns
-- handled missing information
-- data type casting
-- data enrichment

INSERT INTO silver.crm_prd_info (
  prd_id,
  cat_id,
  prd_key,
  prd_nm,
  prd_cost,
  prd_line,
  prd_start_dt,
  prd_end_dt,
  dwh_create_date
)
SELECT 
  prd_id,
  REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,   
  SUBSTRING(prd_key, 7) AS prd_key,                        
  prd_nm,
  IFNULL(prd_cost, 0) AS prd_cost, 
  CASE 
    WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
    WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
    WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other sales'
    WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
    ELSE 'n/a'
  END AS prd_line,
  CAST(prd_start_dt AS DATE) AS prd_start_dt,
  CAST(DATE_SUB(
    LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt),
    INTERVAL 1 DAY
  ) AS DATE) AS prd_end_dt,                                         
  CURRENT_DATE() AS dwh_create_date                       
FROM bronze.crm_prd_info;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Extra information:

  -- where replace(substring(prd_key, 1, 5), '-', '_') not in
-- (select distinct id from bronze.erp_px_cat_g1v2)

-----------------------------------------------------------------------------------------------------------------------

-- check for unwanted spaces
-- expectation: no results

select prd_nm
from silver.crm_prd_info
where prd_nm != trim(prd_nm)

-------------------------------------------------------------------------------------------------------------------------

-- check for NULLs or negative numbers 
-- expectation: no results
select prd_cost
from silver.crm_prd_info
where prd_cost < 0 or prd_cost is null

-------------------------------------------------------------------------------------------------------------------------

-- check for invalid date orders
select * 
from silver.crm_prd_info
where prd_end_dt < prd_start_dt

--------------------------------------------------------------------------------------------------------------------------

-- correcting start and end dates

select 
prd_id,
prd_key,
prd_nm,
prd_start_dt,
prd_end_dt,
date_sub(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt) ,  INTERVAL 1 DAY) as prd_end_dt_test
from bronze.crm_prd_info
where prd_key in ('AC-HE-HL-U509-R' , 'AC-HE-HL-U509')

---------------------------------------------------------------------------------------------------------------------------

-- adding one column and changing the datatype

ALTER TABLE silver.crm_prd_info
ADD COLUMN cat_id VARCHAR(50);

ALTER TABLE silver.crm_prd_info
MODIFY COLUMN prd_start_dt date,
MODIFY COLUMN prd_end_dt date;

-- TO CHECK COMPLETE CLEANED PRODUCT TABLE RUN THIS COMMAND

select * from silver.crm_prd_info


