-- Data standarization and consistency
insert into silver.erp_loc_a101
(cid,
cntry)
select 
replace(cid, '-', '') as cid,
case when trim(cntry) = 'DE' then 'Germany'
when trim(cntry) in ('US' , 'USA') THEN 'United states'
when trim(cntry) = ' ' or cntry is null  then 'N/A'
else trim(cntry)
end as cntry
from bronze.erp_loc_a101


select * from silver.erp_loc_a101
