USE [Customer Churn]
GO

/****** Object:  View [dbo].[vw_CustomerRiskAnalysis]    Script Date: 05/09/2026 17:12:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   VIEW [dbo].[vw_CustomerRiskAnalysis]
AS

WITH RiskAnalysis AS
(
    SELECT
        Customer_ID,
        Contract_Type,
        Account_Length_in_Months,
        Monthly_Charge,
        Age_Group,
        payment_method,
        Churned,

      
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


