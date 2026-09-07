USE [Customer Churn]
GO

/****** Object:  View [dbo].[vw_CustomerChurnAnalysis]    Script Date: 02/09/2026 15:50:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/* ============================================================
   CUSTOMER CHURN ANALYSIS
   STAGE 6 — CHURN REASONS & BUSINESS ANALYSIS
   ============================================================

   Purpose:
   1. Create a reusable analytical view
   2. Analyse overall churn reasons
   3. Analyse churn categories
   4. Analyse churn by contract type
   5. Analyse churn by monthly charge
   6. Analyse churn by age group
   7. Analyse high-risk customer churn
   8. Provide business findings
   9. Provide business recommendations

   ============================================================ */


---------------------------------------------------------------
-- 1. CREATE REUSABLE ANALYTICAL VIEW
---------------------------------------------------------------

CREATE OR ALTER VIEW dbo.vw_CustomerChurnAnalysis
AS
SELECT
    Customer_ID,
    churned,
    Churn_Category,
    Churn_Reason,
    Contract_Type,
    Age,
    Gender,
    [group],
    number_of_customers_in_group,
    Unlimited_Data_Plan,
    Device_Protection_Online_Backup,
    Intl_Plan,
    Avg_Monthly_GB_download,
    Intl_Active,
    state,
    Monthly_Charge,
    Payment_Method,
    Account_Length_in_Months,
    Total_Charges,
    Customer_Service_Calls,
    Intl_Mins,
    Local_Calls,
    Local_Mins ,
    Intl_Calls,
    extra_data_charges,
  
   churn_label,

    CASE
    WHEN Intl_Calls <= 100 THEN '0–100'
    WHEN Intl_Calls <= 200 THEN '101–200'
    WHEN Intl_Calls <= 400 THEN '201–400'
    WHEN Intl_Calls <= 600 THEN '401–600'
    WHEN Intl_Calls <= 800 THEN '601–800'
    WHEN Intl_Calls <= 1000 THEN '801–1000'
    ELSE '1001+'
END AS Intl_Calls_Group,

CASE
        WHEN Avg_Monthly_GB_download < 10 THEN '0-10 GB'
        WHEN Avg_Monthly_GB_download < 20 THEN '10-20 GB'
        WHEN Avg_Monthly_GB_download < 30 THEN '20-30 GB'
        ELSE '>30 GB'
    END AS Data_Usage_Band,

    case 
        when [group] ='yes' then 'In Group'
        when [group] ='no' then 'No Group'
        else 'Unknown'
    end as Group_status,

    
    CASE 
        WHEN Unlimited_Data_Plan = 1 THEN 'Yes'
        WHEN Unlimited_Data_Plan = 0 THEN 'No'
    END AS Unlimited_Data_Plan_status,

      CASE 
        WHEN Intl_Plan = 1 THEN 'Yes'
        WHEN Intl_Plan = 0 THEN 'No'
    END AS Intl_Plan_status,

       CASE 
        WHEN Device_Protection_Online_Backup = 1 THEN 'Yes'
        WHEN Device_Protection_Online_Backup = 0 THEN 'No'
    END AS Device_Protection_Online_Backup_status,

    
    case 
        when  [number_of_customers_in_group] =0 then 'No Group'
        when  [number_of_customers_in_group] =1 then '1 member group'
        when  [number_of_customers_in_group] =2 then '2 member Group'
        when  [number_of_customers_in_group] =3 then '3 member group'
        when  [number_of_customers_in_group] =4 then '4 member group'
        when  [number_of_customers_in_group] =5 then '5 member group'
        when  [number_of_customers_in_group] =6 then '6 member group'
        else 'Unknown'
    end as Group_size,
        
    /* --------------------------------------------------------
       AGE GROUP
       -------------------------------------------------------- */
    CASE
        WHEN Age <= 30 THEN 'Under 30'
        WHEN Age BETWEEN 31 AND 64 THEN '31-64'
        WHEN Age >= 65 THEN 'Senior'
        ELSE 'Unknown'
    END AS Age_Group,

    CASE
    WHEN Age BETWEEN 18 AND 30 THEN '18-30'
    WHEN Age BETWEEN 31 AND 50 THEN '31-50'
    WHEN Age BETWEEN 51 AND 65 THEN '51-65'
    WHEN Age > 65 THEN '65+'
    ELSE 'Unknown'
END AS Age_Band,


    /* --------------------------------------------------------
       MONTHLY CHARGE GROUP
       -------------------------------------------------------- */
    CASE
        WHEN Monthly_Charge < 30 THEN 'Under £30'
        WHEN Monthly_Charge < 50 THEN '£30-£49'
        WHEN Monthly_Charge < 70 THEN '£50-£69'
        WHEN Monthly_Charge >= 70 THEN '£70+'
        ELSE 'Unknown'
    END AS Monthly_Charge_Group,


    /* --------------------------------------------------------
       TENURE GROUP
       -------------------------------------------------------- */
    CASE
        WHEN Account_Length_in_Months <= 12
            THEN 'New Customer'

        WHEN Account_Length_in_Months <= 24
            THEN '1-2 Years'

        WHEN Account_Length_in_Months <= 48
            THEN '2-4 Years'

        WHEN Account_Length_in_Months > 48
            THEN '4+ Years'

        ELSE 'Unknown'
    END AS Tenure_Group,


    /* --------------------------------------------------------
       HIGH-RISK CUSTOMER SEGMENT
       -------------------------------------------------------- */
    CASE
        WHEN Monthly_Charge >= 50
             AND Monthly_Charge < 70
             AND Account_Length_in_Months <= 12
             AND Total_Charges < 1000
             AND Age >= 65
        THEN 'High Risk'

        ELSE 'Other'
    END AS Risk_Segment,
    CASE 
		WHEN Intl_Mins = 0
			THEN 'No Usage'
		WHEN Intl_Mins BETWEEN 1
				AND 50
			THEN '1-50 Minutes'
		WHEN Intl_Mins BETWEEN 51
				AND 100
			THEN '51-100 Minutes'
		ELSE 'High Usage'
		END AS Intl_Mins_Group,
        CASE 
			WHEN Total_Charges < 1000
				THEN 'Under £1,000'
			WHEN Total_Charges < 3000
				THEN '£1,000-£2,999'
			WHEN Total_Charges < 5000
				THEN '£3,000-£4,999'
			ELSE '£5,000+'
			END AS Total_Charges_Group,
        CASE 
		WHEN Customer_Service_Calls = 0
			THEN '0 Calls'
		WHEN Customer_Service_Calls BETWEEN 1
				AND 2
			THEN '1-2 Calls'
		WHEN Customer_Service_Calls BETWEEN 3
				AND 5
			THEN '3-5 Calls'
		ELSE '6+ Calls'
		END AS Service_Call_Group,
        CASE
    WHEN Local_Calls < 100 THEN '0-99 Calls'
    WHEN Local_Calls < 200 THEN '100-199 Calls'
    WHEN Local_Calls < 300 THEN '200-299 Calls'
    WHEN Local_Calls < 400 THEN '300-399 Calls'
    WHEN Local_Calls < 500 THEN '400-499 Calls'
    WHEN Local_Calls < 600 THEN '500-599 Calls'
    WHEN Local_Calls < 700 THEN '600-699 Calls'
    WHEN Local_Calls < 800 THEN '700-799 Calls'
    WHEN Local_Calls < 900 THEN '800-899 Calls'
    ELSE '900+ Calls'
END AS Local_Call_Group,

CASE
    WHEN Local_Mins < 100 THEN '0-99 Mins'
    WHEN Local_Mins < 200 THEN '100-199 Mins'
    WHEN Local_Mins < 300 THEN '200-299 Mins'
    WHEN Local_Mins < 400 THEN '300-399 Mins'
    WHEN Local_Mins < 500 THEN '400-499 Mins'
    WHEN Local_Mins < 600 THEN '500-599 Mins'
    WHEN Local_Mins < 700 THEN '600-699 Mins'
    WHEN Local_Mins < 800 THEN '700-799 Mins'
    WHEN Local_Mins < 900 THEN '800-899 Mins'
    ELSE '900+ Mins'
END AS Local_Min_Group,
  CASE
        WHEN extra_data_charges = 0 THEN '0'
        WHEN extra_data_charges > 0 AND extra_data_charges <= 10 THEN '1-10'
        WHEN extra_data_charges > 10 AND extra_data_charges <= 20 THEN '11-20'
        WHEN extra_data_charges > 20 AND extra_data_charges <= 50 THEN '21-50'
        ELSE '50+'
    END AS extra_charge_group,

    WITH RiskAnalysis AS
    (
    

      

    CASE
                WHEN Contract_Type = 'Month-to-Month'
                    THEN 1
                ELSE 0
            END

            +

            CASE
                WHEN Tenure_Group = "New Customer" 
                    THEN 1
                ELSE 0
            END

            +

            CASE
                WHEN Monthly_Charge_group ="£50-£69"
                    THEN 1
                ELSE 0
            END

            +

            CASE
                WHEN Age_Group = 'Senior'
                    THEN 1
                ELSE 0
            End
              +

            CASE
                WHEN payment_method ='paper check'
                    THEN 1
                ELSE 0
            END
            +
             CASE
                WHEN Service_Call_Group = '3-5 Calls'
                    THEN 1
                ELSE 0
            End

             +
             CASE
                WHEN intl_mins_group = '1-50 Minutes'
                    THEN 1
                ELSE 0
            End

            +
             CASE
                WHEN intl_plan_status = 'No'
                    THEN 1
                ELSE 0
            End

        ) AS Risk_Score

    FROM dbo.vw_CustomerChurnAnalysis
)

SELECT
    *,
    
    CASE
        WHEN Risk_Score >= 5 THEN 'High Risk'
        WHEN Risk_Score >= 3 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS Risk_Level

FROM RiskAnalysis;
GO

 
 

FROM dbo.CustomerChurnAnalysis_New;

