USE [Customer Churn];
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
    Churned,
    Churn_Category,
    Churn_Reason,
    Contract_Type,
    Age,
    Gender
    Unlimited_Data_Plan,
    Device_Protection_Online_Backup,
    Intl_Plan,
    Intl_Active,
    state,
    Monthly_Charge,
    Payment_Method,
    Account_Length_in_Months,
    Total_Charges,
    Customer_Service_Calls,
    Intl_Mins,

    /* --------------------------------------------------------
       AGE GROUP
       -------------------------------------------------------- */
    CASE
        WHEN Age <= 30 THEN 'Under 30'
        WHEN Age BETWEEN 31 AND 64 THEN '31-64'
        WHEN Age >= 65 THEN 'Senior'
        ELSE 'Unknown'
    END AS Age_Group,


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
		END AS Service_Call_Group

FROM dbo.CustomerChurnAnalysis_New;
GO



/* ============================================================
   2. CHECK THE VIEW
   ============================================================ */

SELECT TOP 100 *
FROM dbo.vw_CustomerChurnAnalysis;
GO



/* ============================================================
   3. OVERALL CHURN REASON
   Business Question:
   What specific reasons are customers giving for leaving?
   ============================================================ */

SELECT TOP 10
    Churn_Reason,

    COUNT(*) AS Churned_Customers,

    CAST(
        COUNT(*) * 100.0 /
        NULLIF(
            SUM(COUNT(*)) OVER (),
            0
        )
        AS DECIMAL(10,2)
    ) AS Churn_Percentage

FROM dbo.vw_CustomerChurnAnalysis

WHERE Churned = 1
  AND Churn_Reason IS NOT NULL

GROUP BY
    Churn_Reason

ORDER BY
    Churned_Customers DESC;
GO



/* ============================================================
   BUSINESS INTERPRETATION

   This analysis identifies the individual reasons customers
   provide for leaving.

   IMPORTANT:
   Churn_Percentage represents the percentage of all churned
   customers associated with each reason.

   It is NOT the overall customer churn rate.
   ============================================================ */



/* ============================================================
   4. OVERALL CHURN CATEGORY
   Business Question:
   What broad factors are driving customer churn?
   ============================================================ */

SELECT
    Churn_Category,

    COUNT(*) AS Churned_Customers,

    CAST(
        COUNT(*) * 100.0 /
        NULLIF(
            SUM(COUNT(*)) OVER (),
            0
        )
        AS DECIMAL(10,2)
    ) AS Churn_Percentage

FROM dbo.vw_CustomerChurnAnalysis

WHERE Churned = 1
  AND Churn_Category IS NOT NULL

GROUP BY
    Churn_Category

ORDER BY
    Churned_Customers DESC;
GO



/* ============================================================
   BUSINESS INTERPRETATION

   Use this analysis to identify the main broad drivers of churn.

   Typical categories may include:

   - Competitor
   - Dissatisfaction
   - Attitude
   - Price
   - Other

   The highest category should receive the greatest management
   attention.
   ============================================================ */



/* ============================================================
   5. CHURN CATEGORY BY CONTRACT TYPE

   Business Question:
   Which churn categories are most important for each
   contract type?
   ============================================================ */

SELECT
    Contract_Type,
    Churn_Category,

    COUNT(*) AS Churned_Customers,

    CAST(
        COUNT(*) * 100.0 /
        NULLIF(
            SUM(COUNT(*)) OVER (
                PARTITION BY Contract_Type
            ),
            0
        )
        AS DECIMAL(10,2)
    ) AS Churn_Percentage

FROM dbo.vw_CustomerChurnAnalysis

WHERE Churned = 1
  AND Contract_Type IS NOT NULL
  AND Churn_Category IS NOT NULL

GROUP BY
    Contract_Type,
    Churn_Category

HAVING COUNT(*) > 100

ORDER BY
    Contract_Type,
    Churn_Percentage DESC;
GO



/* ============================================================
   BUSINESS INTERPRETATION

   This analysis compares the reasons for churn within each
   contract group.

   Example interpretation:

   If Competitor represents the largest percentage for
   Month-to-Month customers, competitors may be offering
   more attractive pricing, services or contract flexibility.

   Business should therefore investigate competitor offers
   and improve retention strategies for Month-to-Month users.
   ============================================================ */



/* ============================================================
   6. CHURN REASON BY CONTRACT TYPE

   Business Question:
   What specific reasons are driving churn within each contract?
   ============================================================ */

SELECT
    Contract_Type,
    Churn_Category,
    Churn_Reason,

    COUNT(*) AS Churned_Customers,

    CAST(
        COUNT(*) * 100.0 /
        NULLIF(
            SUM(COUNT(*)) OVER (
                PARTITION BY Contract_Type
            ),
            0
        )
        AS DECIMAL(10,2)
    ) AS Churn_Percentage

FROM dbo.vw_CustomerChurnAnalysis

WHERE Churned = 1
  AND Contract_Type IS NOT NULL
  AND Churn_Category IS NOT NULL
  AND Churn_Reason IS NOT NULL

GROUP BY
    Contract_Type,
    Churn_Category,
    Churn_Reason

ORDER BY
    Contract_Type,
    Churn_Percentage DESC;
GO



/* ============================================================
   7. CHURN REASON BY MONTHLY CHARGE GROUP

   Business Question:
   What are the main churn reasons among different
   monthly charge segments?
   ============================================================ */

SELECT
    Monthly_Charge_Group,
    Churn_Category,
    Churn_Reason,

    COUNT(*) AS Churned_Customers,

    CAST(
        COUNT(*) * 100.0 /
        NULLIF(
            SUM(COUNT(*)) OVER (
                PARTITION BY Monthly_Charge_Group
            ),
            0
        )
        AS DECIMAL(10,2)
    ) AS Percentage_of_Group_Churn

FROM dbo.vw_CustomerChurnAnalysis

WHERE Churned = 1
  AND Churn_Category IS NOT NULL
  AND Churn_Reason IS NOT NULL

GROUP BY
    Monthly_Charge_Group,
    Churn_Category,
    Churn_Reason

HAVING COUNT(*) > 50

ORDER BY
    Monthly_Charge_Group,
    Churned_Customers DESC;
GO



/* ============================================================
   BUSINESS INTERPRETATION

   This analysis helps determine whether churn drivers change
   depending on how much customers pay each month.

   Examples:

   Lower-value customers:
       Price/value may be important.

   Mid-value customers:
       Competitor pricing or service may be important.

   Higher-value customers:
       Dissatisfaction may indicate that customers expect
       better service for the amount they pay.
   ============================================================ */



/* ============================================================
   8. CHURN CATEGORY BY AGE GROUP

   Business Question:
   What are the main churn categories for different age groups?
   ============================================================ */

SELECT
    Age_Group,
    Churn_Category,

    COUNT(*) AS Churned_Customers,

    CAST(
        COUNT(*) * 100.0 /
        NULLIF(
            SUM(COUNT(*)) OVER (
                PARTITION BY Age_Group
            ),
            0
        )
        AS DECIMAL(10,2)
    ) AS Reason_Percentage

FROM dbo.vw_CustomerChurnAnalysis

WHERE Churned = 1
  AND Churn_Category IS NOT NULL

GROUP BY
    Age_Group,
    Churn_Category

ORDER BY
    Age_Group,
    Reason_Percentage DESC;
GO



/* ============================================================
   BUSINESS INTERPRETATION

   This analysis identifies whether different age groups have
   different churn drivers.

   Example:

   If Senior customers show a high proportion of
   dissatisfaction-related churn, the company could provide
   additional customer support or tailored service.

   If younger customers show more competitor-related churn,
   competitive pricing and flexible plans may be more important.
   ============================================================ */



/* ============================================================
   9. HIGH-RISK CUSTOMER SEGMENT

   Business Question:
   Why are high-risk customers churning?

   High-risk definition:

   - Monthly Charge £50-£69
   - Tenure <= 12 months
   - Total Charges < £1,000
   - Age >= 65
   ============================================================ */

SELECT
    Churn_Category,
    Churn_Reason,

    COUNT(*) AS Churned_Customers

FROM dbo.vw_CustomerChurnAnalysis

WHERE Churned = 1
  AND Risk_Segment = 'High Risk'
  AND Churn_Category IS NOT NULL
  AND Churn_Reason IS NOT NULL

GROUP BY
    Churn_Category,
    Churn_Reason

ORDER BY
    Churned_Customers DESC;
GO



/* ============================================================
   BUSINESS INTERPRETATION

   These customers are particularly important because they
   combine several potentially vulnerable characteristics:

   - Senior customer
   - New customer
   - Relatively high monthly charge
   - Low accumulated charges

   The business should investigate their churn reasons and
   consider proactive retention measures.
   ============================================================ */



/* ============================================================
   10. HIGH-RISK CUSTOMER SUMMARY
   ============================================================ */

SELECT
    Risk_Segment,

    COUNT(*) AS Total_Customers,

    SUM(CAST(Churned AS INT)) AS Churned_Customers,

    COUNT(*) -
        SUM(CAST(Churned AS INT)) AS Active_Customers,

    CAST(
        SUM(CAST(Churned AS INT)) * 100.0 /
        NULLIF(COUNT(*),0)
        AS DECIMAL(10,2)
    ) AS Churn_Rate

FROM dbo.vw_CustomerChurnAnalysis

GROUP BY
    Risk_Segment

ORDER BY
    Churn_Rate DESC;
GO



/* ============================================================
   11. TOP CHURN REASONS FOR SENIOR CUSTOMERS
   ============================================================ */

SELECT TOP 10
    Churn_Reason,

    COUNT(*) AS Churned_Customers,

    CAST(
        COUNT(*) * 100.0 /
        NULLIF(
            SUM(COUNT(*)) OVER (),
            0
        )
        AS DECIMAL(10,2)
    ) AS Churn_Percentage

FROM dbo.vw_CustomerChurnAnalysis

WHERE Churned = 1
  AND Age_Group = 'Senior'
  AND Churn_Reason IS NOT NULL

GROUP BY
    Churn_Reason

ORDER BY
    Churned_Customers DESC;
GO



/* ============================================================
   12. TOP CHURN REASONS FOR NEW CUSTOMERS
   ============================================================ */

SELECT TOP 10
    Churn_Reason,

    COUNT(*) AS Churned_Customers,

    CAST(
        COUNT(*) * 100.0 /
        NULLIF(
            SUM(COUNT(*)) OVER (),
            0
        )
        AS DECIMAL(10,2)
    ) AS Churn_Percentage

FROM dbo.vw_CustomerChurnAnalysis

WHERE Churned = 1
  AND Tenure_Group = 'New Customer'
  AND Churn_Reason IS NOT NULL

GROUP BY
    Churn_Reason

ORDER BY
    Churned_Customers DESC;
GO



/* ============================================================
   13. TOP CHURN REASONS FOR MONTH-TO-MONTH CUSTOMERS
   ============================================================ */

SELECT TOP 10
    Churn_Category,
    Churn_Reason,

    COUNT(*) AS Churned_Customers,

    CAST(
        COUNT(*) * 100.0 /
        NULLIF(
            SUM(COUNT(*)) OVER (),
            0
        )
        AS DECIMAL(10,2)
    ) AS Churn_Percentage

FROM dbo.vw_CustomerChurnAnalysis

WHERE Churned = 1
  AND Contract_Type = 'Month-to-Month'
  AND Churn_Category IS NOT NULL
  AND Churn_Reason IS NOT NULL

GROUP BY
    Churn_Category,
    Churn_Reason

ORDER BY
    Churned_Customers DESC;
GO



/* ============================================================
   14. BUSINESS FINDINGS
   ============================================================

   Based on the churn analysis, the following business areas
   should be investigated:

   1. COMPETITOR
      Competitor-related churn is a major reason customers leave.

      Business implication:
      Customers may perceive competitors as offering better
      pricing, services, network quality or contract flexibility.


   2. MONTH-TO-MONTH CONTRACTS
      Month-to-Month customers are more vulnerable to switching.

      Business implication:
      Customers have fewer contractual barriers to leaving.


   3. DISSATISFACTION
      Dissatisfaction is another important churn driver.

      Business implication:
      Service quality, customer support and customer experience
      may require improvement.


   4. ATTITUDE
      Attitude-related churn represents another significant
      customer experience issue.

      Business implication:
      Customer interactions and support experiences should
      be investigated.


   5. PRICE
      Price-related churn indicates that some customers may
      believe the service does not provide sufficient value.

      Business implication:
      Pricing and value propositions should be reviewed.


   6. NEW CUSTOMERS
      Customers within their first year can be particularly
      vulnerable.

      Business implication:
      Early customer experience is critical for retention.


   7. SENIOR CUSTOMERS
      Senior customers may have different churn drivers from
      younger customers.

      Business implication:
      Retention strategies should be segmented rather than
      treating all customers the same.


   8. HIGH-VALUE / HIGH-RISK CUSTOMERS
      Customers paying relatively high monthly charges but with
      short tenure represent an important retention opportunity.

      Business implication:
      Losing these customers early can reduce future customer
      lifetime value.

   ============================================================ */



/* ============================================================
   15. BUSINESS RECOMMENDATIONS
   ============================================================

   RECOMMENDATION 1 — COMPETITOR CHURN
   ------------------------------------
   Introduce targeted retention offers for customers showing
   competitor-related churn risk.

   Actions:
   - Review competitor pricing
   - Offer personalised retention incentives
   - Improve value proposition
   - Highlight unique service benefits


   RECOMMENDATION 2 — MONTH-TO-MONTH CUSTOMERS
   --------------------------------------------
   Encourage suitable Month-to-Month customers to move to
   longer contracts.

   Actions:
   - Offer incentives for 1-year contracts
   - Provide discounts for longer commitments
   - Explain benefits of longer-term plans


   RECOMMENDATION 3 — DISSATISFACTION
   -----------------------------------
   Investigate the root causes of customer dissatisfaction.

   Actions:
   - Analyse customer complaints
   - Improve support response times
   - Monitor service quality
   - Introduce post-support satisfaction surveys


   RECOMMENDATION 4 — NEW CUSTOMER RETENTION
   -------------------------------------------
   Create an early-life customer retention programme.

   Actions:
   - 30-day customer check-in
   - 60-day satisfaction review
   - 90-day retention campaign
   - Identify early signs of dissatisfaction


   RECOMMENDATION 5 — SENIOR CUSTOMER SUPPORT
   -------------------------------------------
   Develop tailored support for senior customers where the
   analysis indicates elevated churn.

   Actions:
   - Simplified customer support
   - Proactive service checks
   - Dedicated support options
   - Clear communication of plan benefits


   RECOMMENDATION 6 — PRICE/VALUE
   --------------------------------
   Review pricing for customers with high price sensitivity.

   Actions:
   - Personalised offers
   - Value-based packages
   - Loyalty discounts
   - Bundle relevant services


   RECOMMENDATION 7 — HIGH-RISK CUSTOMER RETENTION
   ------------------------------------------------
   Prioritise high-risk customers for proactive intervention.

   Actions:
   - Identify high-risk customers regularly
   - Contact customers before they churn
   - Offer relevant retention incentives
   - Monitor changes in behaviour and satisfaction


   RECOMMENDATION 8 — DATA-DRIVEN RETENTION
   -----------------------------------------
   Do not use the same retention strategy for every customer.

   Segment customers using:

   - Age
   - Contract type
   - Monthly charge
   - Tenure
   - Churn category
   - Churn reason
   - Customer value
   - Risk level

   This allows the company to target the right customer with
   the right retention action.

   ============================================================ */



/* ============================================================
   16. PORTFOLIO BUSINESS SUMMARY

   Suggested portfolio conclusion:

   "The churn analysis identified competitor-related factors
   as a major driver of customer churn, with dissatisfaction,
   attitude and price also contributing to customer loss.

   Month-to-Month customers require particular attention because
   they have lower contractual commitment and may be more likely
   to switch providers.

   The analysis also demonstrates that churn drivers vary across
   customer segments such as age, monthly charge and tenure.

   The recommended strategy is therefore to implement a
   segmented retention programme that prioritises high-risk and
   high-value customers, improves the early customer experience,
   addresses service dissatisfaction and provides targeted
   incentives for customers vulnerable to competitor offers."

   ============================================================ */


/* ============================================================
   END OF STAGE 6
   ============================================================ */