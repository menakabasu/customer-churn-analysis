Use [Customer Churn]


/*Overall Churn Overview
Total Customers
Churned Customers
Active Customers
Churn Rate*/
--Total Customers--
select 
	count(*) as Total_Customers
	FROM CustomerChurnAnalysis_New
--Churned Customers--
select
	sum(cast( churned as int) ) as Churned_Customers
FROM CustomerChurnAnalysis_New


select 
count(*) as Total_Customers	,
sum(cast( churned as int) ) as Churned_Customers,

count(*)	-  sum(cast( churned as int) ) as Active_Customers,

cast(
	sum(cast( churned as int) )*100.0 /nullif(count(*),0) as decimal(10,2)) as Churn_rate
from CustomerChurnAnalysis_New

