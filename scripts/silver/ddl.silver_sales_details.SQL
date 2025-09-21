-- sales = quantity*price
 -- values must not be null, zero or negative
 -- updated the data type from varchar to dates
 -- checked data consistency between sales, quantity and price
 -- handling invalid data

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Insert into silver.crm_sales_details(
  sls_ord_num,
  sls_prd_key,
  sls_cust_id,
  sls_order_dt,
  sls_ship_dt,
  sls_due_dt,
  sls_sales,
  sls_quantity,
  sls_price
  )

SELECT 
  sls_ord_num,
  sls_prd_key,
  sls_cust_id,
  CASE 
    WHEN sls_order_dt = 0 OR LENGTH(CAST(sls_order_dt AS CHAR)) != 8 THEN NULL
    ELSE CAST(CAST(sls_order_dt AS CHAR) AS DATE)
  END AS sls_order_dt,
 CASE 
    WHEN sls_ship_dt = 0 OR LENGTH(CAST(sls_ship_dt AS CHAR)) != 8 THEN NULL
    ELSE CAST(sls_ship_dt  AS DATE)
  END AS sls_ship_dt,
  CASE 
    WHEN sls_due_dt = 0 OR LENGTH(CAST(sls_due_dt AS CHAR)) != 8 THEN NULL
    ELSE CAST(sls_due_dt  AS DATE)
  END AS sls_due_dt,
   case when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * abs(sls_price)
 then  sls_quantity * abs(sls_price)
 else sls_sales
 end as sls_sales,
  sls_quantity,
  case when sls_price is null or sls_price <=0 THEN sls_sales / CAST(sls_quantity AS DECIMAL(10,2))
 else sls_price
 end as sls_price
FROM bronze.crm_sales_details;

select * from silver.crm_sales_details
