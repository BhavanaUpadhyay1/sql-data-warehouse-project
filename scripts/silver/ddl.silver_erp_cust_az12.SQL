-- data standardization and consistency
-- identify out of range dates 
Insert into silver.erp_cust_az12
(
cid,
bdate,
gen
)
Select 
case when cid like 'NAS%' THEN Substring(cid, 4)
else cid
end cid,
case when bdate> curdate() then null
else bdate
end as bdate,
case when upper(trim(gen)) in ('F', 'Female') then 'Female'
    when upper(trim(gen)) in ('M', 'Male') then 'Male'
else 'N/A'
end as gen
from bronze.erp_cust_az12

------------------------------------------------------------------------------------------------------------------------------

Select * from silver.erp_cust_az12
