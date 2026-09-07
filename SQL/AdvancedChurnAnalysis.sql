/*
============================================================
CUSTOMER CHURN ANALYSIS
STAGE 4 — ADVANCED SQL ANALYSIS
============================================================

Database: Customer Churn
View: dbo.vw_CustomerChurnAnalysis

Analyses:
1. Churn Rate by Contract Type and Payment Method
2. Churn Rate by Contract Type, Monthly Charge and Tenure
3. Top 3 Highest-Churn Segments Within Each Contract Type
4. Top 10 Highest-Churn Multi-Dimensional Customer Segments
5. Top 10 Churn Segments by Contract, Age, Payment and Charge
6. Top 3 Highest-Churn Contract and Monthly Charge Segments
7. Individual Customer Monthly Charge vs Overall Average
8. Churn Rate: Above-Average vs At-or-Below-Average Charge
9. Customer Value and Loyalty Segmentation
10. Customer Risk Score and Risk Classification
============================================================
*/

USE [Customer Churn];



/*
============================================================
1. CHURN RATE BY CONTRACT TYPE AND PAYMENT METHOD
============================================================

Purpose:
Compare churn rates across contract types and payment methods.

Business Recommendation:
Focus retention efforts on contract and payment-method
combinations with high churn rates. Investigate whether
payment experience, contract flexibility or customer service
issues are contributing to customer churn.
============================================================
*/

SELECT
    Contract_Type,
    Payment_Method,

    COUNT(*) AS Total_Customers,

    SUM(CAST(Churned AS INT)) AS Churned_Customers,

    ROUND(
        100.0 * SUM(CAST(Churned AS INT)) / COUNT(*),
        2
    ) AS Churn_Rate

FROM dbo.vw_CustomerChurnAnalysis

GROUP BY
    Contract_Type,
    Payment_Method

HAVING COUNT(*) >= 50

ORDER BY
    Churn_Rate DESC;



/*
============================================================
2. CHURN RATE BY CONTRACT TYPE, MONTHLY CHARGE AND TENURE
============================================================

Purpose:
Identify customer segments based on contract type,
monthly charge and tenure.

Business Recommendation:
Prioritise short-tenure customers on month-to-month contracts,
particularly those paying higher monthly charges. Improve
onboarding and introduce early retention offers to reduce
early-stage churn.
============================================================
*/

SELECT
    Contract_Type,
    Monthly_Charge_Group,
    Tenure_Group,

    COUNT(*) AS Total_Customers,

    SUM(CAST(Churned AS INT)) AS Churned_Customers,

    ROUND(
        100.0 * SUM(CAST(Churned AS INT)) / COUNT(*),
        2
    ) AS Churn_Rate

FROM dbo.vw_CustomerChurnAnalysis

GROUP BY
    Contract_Type,
    Monthly_Charge_Group,
    Tenure_Group

HAVING COUNT(*) >= 30

ORDER BY
    Churn_Rate DESC;



/*
============================================================
3. TOP 3 HIGHEST-CHURN SEGMENTS WITHIN EACH CONTRACT TYPE
============================================================

Purpose:
Use ROW_NUMBER() and PARTITION BY to identify the three
highest-churn combinations of monthly charge and tenure
within each contract type.

Business Recommendation:
Use contract-specific retention strategies. Target the
highest-risk segments within each contract type rather than
using one retention strategy for all customers.
============================================================
*/

WITH SegmentChurn AS
(
    SELECT
        Contract_Type,
        Monthly_Charge_Group,
        Tenure_Group,

        COUNT(*) AS Total_Customers,

        SUM(CAST(Churned AS INT)) AS Churned_Customers,

        ROUND(
            100.0 * SUM(CAST(Churned AS INT)) / COUNT(*),
            2
        ) AS Churn_Rate

    FROM dbo.vw_CustomerChurnAnalysis

    WHERE Contract_Type IS NOT NULL
      AND Monthly_Charge_Group IS NOT NULL
      AND Tenure_Group IS NOT NULL

    GROUP BY
        Contract_Type,
        Monthly_Charge_Group,
        Tenure_Group

    HAVING COUNT(*) >= 30
),

RankedSegment AS
(
    SELECT
        *,
        
        ROW_NUMBER() OVER
        (
            PARTITION BY Contract_Type
            ORDER BY Churn_Rate DESC
        ) AS Risk_Rank

    FROM SegmentChurn
)

SELECT *
FROM RankedSegment

WHERE Risk_Rank <= 3

ORDER BY
    Contract_Type,
    Risk_Rank;



/*
============================================================
4. TOP 10 HIGHEST-CHURN MULTI-DIMENSIONAL CUSTOMER SEGMENTS
============================================================

Purpose:
Identify the highest-churn customer segments using contract,
age, monthly charge, tenure, total charges and payment method.

Business Recommendation:
Target the highest-risk multi-dimensional segments with
personalised retention campaigns. Prioritise segments that
have both high churn rates and a meaningful customer
population rather than focusing only on the highest percentage.
============================================================
*/

SELECT TOP 10
    Contract_Type,
    Age_Group,
    Monthly_Charge_Group,
    Tenure_Group,
    Total_Charges_Group,
    Payment_Method,

    COUNT(*) AS Total_Customers,

    SUM(CAST(Churned AS INT)) AS Churned_Customers,

    ROUND(
        100.0 * SUM(CAST(Churned AS INT)) / COUNT(*),
        2
    ) AS Churn_Rate

FROM dbo.vw_CustomerChurnAnalysis

GROUP BY
    Contract_Type,
    Age_Group,
    Monthly_Charge_Group,
    Tenure_Group,
    Total_Charges_Group,
    Payment_Method

HAVING COUNT(*) >= 40

ORDER BY
    Churn_Rate DESC;



/*
============================================================
5. TOP 10 CHURN SEGMENTS BY CONTRACT, AGE,
   PAYMENT METHOD AND MONTHLY CHARGE
============================================================

Purpose:
Examine how contract type, age group, payment method and
monthly charge interact to identify specific high-risk
customer profiles.

Business Recommendation:
Develop targeted retention strategies for high-risk customer
profiles. Use these findings together with churn reasons to
understand why these particular customer groups are leaving.
============================================================
*/

SELECT TOP 10
    Contract_Type,
    Age_Group,
    Payment_Method,
    Monthly_Charge_Group,

    COUNT(*) AS Total_Customers,

    SUM(CAST(Churned AS INT)) AS Churned_Customers,

    ROUND(
        100.0 * SUM(CAST(Churned AS INT)) / COUNT(*),
        2
    ) AS Churn_Rate

FROM dbo.vw_CustomerChurnAnalysis

GROUP BY
    Contract_Type,
    Age_Group,
    Payment_Method,
    Monthly_Charge_Group

HAVING COUNT(*) >= 40

ORDER BY
    Churn_Rate DESC;



/*
============================================================
6. TOP 3 HIGHEST-CHURN CONTRACT AND MONTHLY CHARGE SEGMENTS
============================================================

Purpose:
Use the RANK() window function to identify the three
highest-churn combinations of contract type and monthly
charge group.

Business Recommendation:
Prioritise the highest-ranked contract and charge combinations
for retention campaigns. Investigate whether high charges,
contract flexibility or perceived value are contributing
to churn.
============================================================
*/

WITH ContractChurn AS
(
    SELECT
        Contract_Type,
        Monthly_Charge_Group,

        COUNT(*) AS Total_Customers,

        SUM(CAST(Churned AS INT)) AS Churned_Customers,

        ROUND(
            100.0 * SUM(CAST(Churned AS INT)) / COUNT(*),
            2
        ) AS Churn_Rate

    FROM dbo.vw_CustomerChurnAnalysis

    GROUP BY
        Contract_Type,
        Monthly_Charge_Group

    HAVING COUNT(*) >= 50
),

ChurnRank AS
(
    SELECT
        Contract_Type,
        Monthly_Charge_Group,
        Total_Customers,
        Churned_Customers,
        Churn_Rate,

        RANK() OVER
        (
            ORDER BY Churn_Rate DESC
        ) AS Churn_Rank

    FROM ContractChurn
)

SELECT *
FROM ChurnRank

WHERE Churn_Rank <= 3

ORDER BY
    Churn_Rank;



/*
============================================================
7. INDIVIDUAL CUSTOMER MONTHLY CHARGE VS OVERALL AVERAGE
============================================================

Purpose:
Compare each customer's monthly charge with the overall
average monthly charge using a window function.

Business Recommendation:
Customers paying significantly above the average represent
potentially higher revenue exposure if they churn. Consider
personalised retention offers for high-value customers.
============================================================
*/

SELECT
    Customer_ID,
    Monthly_Charge,

    ROUND(
        AVG(Monthly_Charge) OVER (),
        2
    ) AS Average_Monthly_Charge,

    ROUND(
        Monthly_Charge
        - AVG(Monthly_Charge) OVER (),
        2
    ) AS Difference_From_Average

FROM dbo.vw_CustomerChurnAnalysis;



/*
============================================================
8. CHURN RATE: ABOVE-AVERAGE VS AT-OR-BELOW-AVERAGE
   MONTHLY CHARGE
============================================================

Purpose:
Compare churn rates between customers paying above the
overall average monthly charge and customers paying at or
below the average.

Business Recommendation:
If above-average customers have higher churn, investigate
price sensitivity and perceived value. Consider targeted
discounts, plan adjustments or additional benefits.
============================================================
*/

WITH ChargeComparison AS
(
    SELECT
        *,
        
        ROUND(
            AVG(Monthly_Charge) OVER (),
            2
        ) AS Avg_Charge

    FROM dbo.vw_CustomerChurnAnalysis
)

SELECT
    CASE
        WHEN Monthly_Charge > Avg_Charge
            THEN 'Above Average'
        ELSE 'At or Below Average'
    END AS Charge_Group,

    COUNT(*) AS Total_Customers,

    SUM(CAST(Churned AS INT)) AS Churned_Customers,

    ROUND(
        100.0 * SUM(CAST(Churned AS INT)) / COUNT(*),
        2
    ) AS Churn_Rate

FROM ChargeComparison

GROUP BY
    CASE
        WHEN Monthly_Charge > Avg_Charge
            THEN 'Above Average'
        ELSE 'At or Below Average'
    END

ORDER BY
    Churn_Rate DESC;



/*
============================================================
9. CUSTOMER VALUE AND LOYALTY SEGMENTATION
============================================================

Purpose:
Segment customers using tenure and monthly charge into:
New High Value
New Low Value
Loyal High Value
Loyal Low Value

Business Recommendation:
Pay particular attention to New High Value customers if
their churn rate is high. They represent valuable customers
who have not yet developed long-term loyalty. Early
engagement and personalised retention offers could help
protect future revenue.
============================================================
*/

WITH CustomerSegments AS
(
    SELECT
        Customer_ID,

        CASE
            WHEN Account_Length_in_Months < 12
                 AND Monthly_Charge >= 70
                THEN 'New High Value'

            WHEN Account_Length_in_Months < 12
                 AND Monthly_Charge < 70
                THEN 'New Low Value'

            WHEN Account_Length_in_Months >= 12
                 AND Monthly_Charge >= 70
                THEN 'Loyal High Value'

            ELSE 'Loyal Low Value'
        END AS Customer_Segment,

        Churned

    FROM dbo.vw_CustomerChurnAnalysis
)

SELECT
    Customer_Segment,

    COUNT(*) AS Total_Customers,

    SUM(CAST(Churned AS INT)) AS Churned_Customers,

    COUNT(*) - SUM(CAST(Churned AS INT))
        AS Active_Customers,

    ROUND(
        100.0 * SUM(CAST(Churned AS INT)) / COUNT(*),
        2
    ) AS Churn_Rate

FROM CustomerSegments

GROUP BY
    Customer_Segment

ORDER BY
    Churn_Rate DESC;



/*
============================================================
10. CUSTOMER RISK SCORE AND RISK CLASSIFICATION
============================================================

Purpose:
Create a rule-based customer risk score using:
- Month-to-Month contract = 2 points
- Tenure below 12 months = 2 points
- Monthly charge >= £70 = 1 point
- Senior customer = 2 points

Risk Classification:
5+ points  = High Risk
3-4 points = Medium Risk
0-2 points = Low Risk

Business Recommendation:

High Risk:
Prioritise immediate retention campaigns, proactive contact
and personalised offers.

Medium Risk:
Monitor customers closely and introduce targeted engagement
before their risk increases.

Low Risk:
Maintain service quality and encourage customer loyalty.

Portfolio Note:
This is a rule-based customer risk scoring model, not a
predictive machine-learning model.
============================================================
*/

WITH RiskAnalysis AS
(
    SELECT
        Customer_ID,
        Contract_Type,
        Account_Length_in_Months,
        Monthly_Charge,
        Age_Group,
        Churned,

        (
            /* Contract Risk */
            CASE
                WHEN Contract_Type = 'Month-to-Month'
                    THEN 2
                ELSE 0
            END

            +

            /* Tenure Risk */
            CASE
                WHEN Account_Length_in_Months < 12
                    THEN 2
                ELSE 0
            END

            +

            /* Monthly Charge Risk */
            CASE
                WHEN Monthly_Charge >= 70
                    THEN 1
                ELSE 0
            END

            +

            /* Age Risk */
            CASE
                WHEN Age_Group = 'Senior'
                    THEN 2
                ELSE 0
            END

        ) AS Risk_Score

    FROM dbo.vw_CustomerChurnAnalysis
),

RiskGroups AS
(
    SELECT
        *,

        CASE
            WHEN Risk_Score >= 5
                THEN 'High Risk'

            WHEN Risk_Score >= 3
                THEN 'Medium Risk'

            ELSE 'Low Risk'
        END AS Risk_Level

    FROM RiskAnalysis
)

SELECT
    Risk_Level,

    COUNT(*) AS Total_Customers,

    SUM(CAST(Churned AS INT)) AS Churned_Customers,

    ROUND(
        100.0 * SUM(CAST(Churned AS INT)) / COUNT(*),
        2
    ) AS Churn_Rate

FROM RiskGroups

GROUP BY
    Risk_Level

ORDER BY
    CASE
        WHEN Risk_Level = 'High Risk' THEN 1
        WHEN Risk_Level = 'Medium Risk' THEN 2
        WHEN Risk_Level = 'Low Risk' THEN 3
    END;



/*
============================================================
END OF STAGE 4 — ADVANCED SQL ANALYSIS
============================================================

SQL Skills Demonstrated:
- GROUP BY
- HAVING
- CASE expressions
- CTEs
- ROW_NUMBER()
- RANK()
- PARTITION BY
- Window functions
- Aggregations
- Customer segmentation
- Risk scoring
- Multi-dimensional analysis
- Business recommendations
============================================================
*/