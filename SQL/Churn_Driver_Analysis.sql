/* ============================================================
   CUSTOMER CHURN ANALYSIS
   Purpose: Investigate factors associated with customer churn
   ============================================================ */
USE [Customer Churn];

/* ============================================================
   1. CHURN BY CONTRACT TYPE
   Business Question:
   Are customers on shorter-term contracts more likely to churn?
   ============================================================ */
SELECT Contract_Type
	,COUNT(*) AS Total_Customers
	,SUM(CAST(Churned AS INT)) AS Churned_Customers
	,COUNT(*) - SUM(CAST(Churned AS INT)) AS Active_Customers
	,CAST(SUM(CAST(Churned AS INT)) * 100.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 2)) AS Churn_Rate
FROM dbo.vw_CustomerChurnAnalysis
GROUP BY Contract_Type
ORDER BY Churn_Rate DESC;

/* Business Insight:
   Customers on month-to-month contracts have a substantially
   higher churn rate than customers on longer-term contracts.

   Recommendation:
   - Identify why month-to-month customers leave.
   - Offer suitable incentives for longer-term contracts.
   - Target high-risk month-to-month customers with retention campaigns.
   - Investigate whether pricing, service quality or flexibility
     is driving the difference.
*/
/* ============================================================
   2. CHURN BY ACCOUNT TENURE
   Business Question:
   Does customer tenure influence churn?
   ============================================================ */
SELECT Tenure_Group
	,COUNT(*) AS Total_Customers
	,SUM(CAST(Churned AS INT)) AS Churned_Customers
	,COUNT(*) - SUM(CAST(Churned AS INT)) AS Active_Customers
	,CAST(SUM(CAST(Churned AS INT)) * 100.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 2)) AS Churn_Rate
FROM dbo.vw_CustomerChurnAnalysis
GROUP BY Tenure_Group
ORDER BY Churn_Rate DESC;

/* ============================================================
   3. CHURN BY PAYMENT METHOD AND CONTRACT TYPE
   Business Question:
   Does payment method influence churn after considering
   contract type?
   ============================================================ */
SELECT Payment_Method
	,Contract_Type
	,COUNT(*) AS Total_Customers
	,SUM(CAST(Churned AS INT)) AS Churned_Customers
	,COUNT(*) - SUM(CAST(Churned AS INT)) AS Active_Customers
	,CAST(SUM(CAST(Churned AS INT)) * 100.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 2)) AS Churn_Rate
FROM dbo.vw_CustomerChurnAnalysis
GROUP BY Payment_Method
	,Contract_Type
ORDER BY Churn_Rate DESC;

/* Business Insight:
   Contract type appears to be a stronger indicator of churn
   than payment method. Month-to-month customers show
   substantially higher churn across payment methods.

   Recommendation:
   Prioritise high-risk month-to-month customers rather than
   targeting payment methods independently.
*/
/* ============================================================
   4. CHURN BY AGE GROUP
   Business Question:
   Does customer age influence churn?
   ============================================================ */
SELECT  Age_Group
	,COUNT(*) AS Total_Customers
	,SUM(CAST(Churned AS INT)) AS Churned_Customers
	,COUNT(*) - SUM(CAST(Churned AS INT)) AS Active_Customers
	,CAST(SUM(CAST(Churned AS INT)) * 100.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 2)) AS Churn_Rate
FROM dbo.vw_CustomerChurnAnalysis
GROUP BY Age_Group
ORDER BY Churn_Rate DESC;

/* ============================================================
   5. CHURN BY GENDER
   Business Question:
   Does gender show any meaningful difference in churn?
   ============================================================ */
SELECT Gender
	,COUNT(*) AS Total_Customers
	,SUM(CAST(Churned AS INT)) AS Churned_Customers
	,COUNT(*) - SUM(CAST(Churned AS INT)) AS Active_Customers
	,CAST(SUM(CAST(Churned AS INT)) * 100.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 2)) AS Churn_Rate
FROM dbo.vw_CustomerChurnAnalysis
GROUP BY Gender
ORDER BY Churn_Rate DESC;

/* ============================================================
   6. CHURN BY AGE / SENIOR STATUS
   Business Question:
   Do senior customers have a different churn pattern?
   ============================================================ */
SELECT Age_Group
	,COUNT(*) AS Total_Customers
	,SUM(CAST(Churned AS INT)) AS Churned_Customers
	,COUNT(*) - SUM(CAST(Churned AS INT)) AS Active_Customers
	,CAST(SUM(CAST(Churned AS INT)) * 100.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 2)) AS Churn_Rate
FROM dbo.vw_CustomerChurnAnalysis
GROUP BY Age_Group
ORDER BY Churn_Rate DESC;

/* ============================================================
   7. CHURN BY INTERNATIONAL PLAN AND ACTIVITY
   Business Question:
   Does international service subscription and activity
   influence churn?
   ============================================================ */
SELECT Intl_Plan
	,Intl_Active
	,COUNT(*) AS Total_Customers
	,SUM(CAST(Churned AS INT)) AS Churned_Customers
	,CAST(SUM(CAST(Churned AS INT)) * 100.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 2)) AS Churn_Rate
FROM dbo.vw_CustomerChurnAnalysis
GROUP BY Intl_Plan
	,Intl_Active
ORDER BY Churn_Rate DESC;

/* Business Insight:
   Customers with an international plan but no international
   activity show particularly high churn. This suggests that
   service engagement may be associated with customer retention.

   Important:
   This analysis shows association, not causation.
*/
/* ============================================================
   8. CHURN BY INTERNATIONAL USAGE
   Business Question:
   Are customers with higher international usage less likely
   to churn?
   ============================================================ */
SELECT Intl_Active
	,Intl_Mins_Group
	,COUNT(*) AS Total_Customers
	,SUM(CAST(Churned AS INT)) AS Churned_Customers
	,CAST(SUM(CAST(Churned AS INT)) * 100.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 2)) AS Churn_Rate
FROM dbo.vw_CustomerChurnAnalysis
GROUP BY Intl_Active
	,Intl_Mins_Group
ORDER BY Churn_Rate DESC;

/* Business Insight:
   Among customers with active international service, lower
   international usage is associated with substantially higher
   churn. Higher usage may indicate stronger customer engagement.
*/
/* ============================================================
   9. CHURN BY UNLIMITED DATA PLAN
   Business Question:
   Does having an unlimited data plan influence churn?
   ============================================================ */
SELECT Unlimited_Data_Plan
	,COUNT(*) AS Total_Customers
	,SUM(CAST(Churned AS INT)) AS Churned_Customers
	,CAST(SUM(CAST(Churned AS INT)) * 100.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 2)) AS Churn_Rate
FROM dbo.vw_CustomerChurnAnalysis
GROUP BY Unlimited_Data_Plan
ORDER BY Churn_Rate DESC;

/* ============================================================
   10. CHURN BY DEVICE PROTECTION / ONLINE BACKUP
   Business Question:
   Does having additional protection or backup services
   influence churn?
   ============================================================ */
SELECT Device_Protection_Online_Backup
	,COUNT(*) AS Total_Customers
	,SUM(CAST(Churned AS INT)) AS Churned_Customers
	,CAST(SUM(CAST(Churned AS INT)) * 100.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 2)) AS Churn_Rate
FROM dbo.vw_CustomerChurnAnalysis
GROUP BY Device_Protection_Online_Backup
ORDER BY Churn_Rate DESC;

/* ============================================================
   11. CHURN BY CUSTOMER SERVICE CALLS
   Business Question:
   Are customers making more service calls more likely to churn?
   ============================================================ */
SELECT  Service_Call_Group
	,COUNT(*) AS Total_Customers
	,SUM(CAST(Churned AS INT)) AS Churned_Customers
	,CAST(SUM(CAST(Churned AS INT)) * 100.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 2)) AS Churn_Rate
FROM dbo.vw_CustomerChurnAnalysis
GROUP BY Service_Call_Group
ORDER BY Churn_Rate DESC;

/* Business Insight:
   Customers making repeated service calls should be identified
   as potential high-risk customers.

   Recommendation:
   Investigate unresolved service issues and improve
   first-contact resolution.
*/
/* ============================================================
   12. CHURN BY MONTHLY CHARGE
   Business Question:
   Are customers paying higher monthly charges more likely
   to churn?
   ============================================================ */
SELECT  Monthly_Charge_Group,
	COUNT(*) AS Total_Customers
	,SUM(CAST(Churned AS INT)) AS Churned_Customers
	,CAST(SUM(CAST(Churned AS INT)) * 100.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 2)) AS Churn_Rate
FROM dbo.vw_CustomerChurnAnalysis
GROUP BY Monthly_Charge_Group
ORDER BY Churn_Rate DESC;

/* Business Insight:
   The £50-£69 monthly charge group has the highest churn rate.

   Recommendation:
   Review whether higher-paying customers perceive sufficient
   value for the price and investigate whether pricing,
   service quality or service availability is contributing
   to churn.
*/
/* ============================================================
   13. MONTHLY CHARGE + DEVICE PROTECTION / ONLINE BACKUP
   Business Question:
   Does the availability of additional services affect churn
   among higher-paying customers?
   ============================================================ */
WITH CustomerGroups
AS (
	SELECT  Monthly_Charge_Group
		,Device_Protection_Online_Backup
		,Churned
	FROM dbo.vw_CustomerChurnAnalysis
	)
SELECT Monthly_Charge_Group
	,Device_Protection_Online_Backup
	,COUNT(*) AS Total_Customers
	,SUM(CAST(Churned AS INT)) AS Churned_Customers
	,CAST(SUM(CAST(Churned AS INT)) * 100.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 2)) AS Churn_Rate
FROM CustomerGroups
GROUP BY Monthly_Charge_Group
	,Device_Protection_Online_Backup
ORDER BY Monthly_Charge_Group
	,Churn_Rate DESC;

/* Business Insight:
   Customers paying £50-£69 without Device Protection /
   Online Backup have particularly high churn.

   Customers in the same price range with the additional
   service have lower churn.

   This suggests that additional services may be associated
   with higher perceived value and lower churn among
   higher-paying customers.

   Note:
   This is an association and does not prove that the service
   itself causes lower churn.
*/
/* ============================================================
   14. CHURN BY TOTAL CHARGES
   Business Question:
   Does cumulative customer spending relate to churn?
   ============================================================ */
SELECT  Total_Charges_Group
	,COUNT(*) AS Total_Customers
	,SUM(CAST(Churned AS INT)) AS Churned_Customers
	,CAST(SUM(CAST(Churned AS INT)) * 100.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 2)) AS Churn_Rate
FROM dbo.vw_CustomerChurnAnalysis
GROUP BY Total_Charges_Group
ORDER BY Churn_Rate DESC;

/* ============================================================
   15. CHURN BY MONTHLY CHARGE + TOTAL CHARGES + TENURE
   Business Question:
   Which customer segments combining price, cumulative charges
   and tenure have the highest churn?
   ============================================================ */
WITH Customer_Groups
AS (
	select Monthly_Charge_Group
		,Tenure_Group
		, Total_Charges_Group
		,Churned
	FROM dbo.vw_CustomerChurnAnalysis
	)
SELECT Monthly_Charge_Group
	,Total_Charges_Group
	,Tenure_Group
	,COUNT(*) AS Total_Customers
	,SUM(CAST(Churned AS INT)) AS Churned_Customers
	,CAST(SUM(CAST(Churned AS INT)) * 100.0 / NULLIF(COUNT(*), 0) AS DECIMAL(10, 2)) AS Churn_Rate
FROM dbo.vw_CustomerChurnAnalysis
GROUP BY Monthly_Charge_Group
	,Total_Charges_Group
	,Tenure_Group
HAVING COUNT(*) >= 30
ORDER BY Churn_Rate DESC;
	/* Business Insight:
   Higher-paying customers who are early in their relationship
   show substantially higher churn than established customers.

   The highest-risk segment identified was customers paying
   £50-£69 per month, with under £1,000 in total charges
   and 0-12 months of tenure.

   This segment should be investigated further for potential
   pricing, onboarding, service-value and retention issues.
*/
	/* ============================================================
   END OF CUSTOMER CHURN ANALYSIS
   ============================================================ */