/* ============================================================
   CUSTOMER CHURN ANALYSIS
   STAGE 6 — CHURN REASONS

   Source:
   dbo.vw_CustomerChurnAnalysis

   Business Objective:
   Understand why customers are leaving and identify
   which customer segments are most affected.
   ============================================================ */

USE [Customer Churn];
GO


/* ============================================================
   1. OVERALL CHURN REASONS

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


/*
Business Interpretation:

This identifies the most common specific reasons given by
customers for leaving.

A high percentage for a particular reason indicates that the
business should investigate that area as a potential retention
priority.
*/


/* ============================================================
   2. OVERALL CHURN CATEGORIES

   Business Question:
   What broad categories are driving customer churn?
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


/*
Business Interpretation:

This provides a high-level view of the major churn drivers.

For example, if Competitor is the largest category, the business
should investigate competitor pricing, offers, service quality
and customer value perception.
*/


/* ============================================================
   3. CHURN CATEGORY BY CONTRACT TYPE

   Business Question:
   What are the main churn categories within each contract type?
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


/*
Business Interpretation:

This shows how churn drivers differ by contract type.

For example, if Competitor-related churn represents 45.73%
of Month-to-Month churn, competitor offers may be an important
retention issue for this customer group.

Recommendation:

Focus retention campaigns on Month-to-Month customers and
investigate competitor pricing, service quality and flexibility.
*/


/* ============================================================
   4. CHURN REASON BY MONTHLY CHARGE GROUP

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


/*
Business Interpretation:

This identifies whether the reasons for churn change according
to the customer's monthly charge.

For example:

£50-£69 customers
→ investigate whether price, competitor offers or service
  dissatisfaction is driving churn.

Higher-paying customers may represent a greater revenue risk,
so their churn reasons should receive particular attention.
*/


/* ============================================================
   5. CHURN REASON BY CONTRACT TYPE

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


/*
Business Interpretation:

This provides a more detailed explanation of why customers
within each contract type are leaving.

It can be used to design contract-specific retention strategies.
*/


/* ============================================================
   6. CHURN REASONS — HIGH-RISK CUSTOMER SEGMENT

   Business Question:
   Why are high-risk customers churning?

   High Risk is already defined in the view as:

   - Age >= 65
   - Monthly Charge £50-£69
   - Tenure <= 12 months
   - Total Charges < £1,000
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


/*
Business Interpretation:

These customers combine several potentially vulnerable
characteristics:

- Senior
- New customer
- Relatively high monthly charge
- Low accumulated charges

Understanding their churn reasons can help the business
prioritise early retention activity.
*/


/* ============================================================
   7. CHURN CATEGORY BY AGE GROUP

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


/*
Business Interpretation:

This identifies whether different age groups have different
churn drivers.

For example, if Senior customers have a high percentage of
Competitor or Dissatisfaction-related churn, the business
could investigate tailored service and support.
*/


/* ============================================================
   8. TOP CHURN REASONS — SENIOR CUSTOMERS

   Business Question:
   What are the most common churn reasons among Senior customers?
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


/* ============================================================
   9. TOP CHURN REASONS — NEW CUSTOMERS

   Business Question:
   What are the most common churn reasons among new customers?
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
  AND Tenure_Group = '0-12 Months'
  AND Churn_Reason IS NOT NULL

GROUP BY
    Churn_Reason

ORDER BY
    Churned_Customers DESC;


/* ============================================================
   10. TOP CHURN REASONS — MONTH-TO-MONTH CUSTOMERS

   Business Question:
   What are the main reasons Month-to-Month customers leave?
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


/* ============================================================
   11. HIGH-RISK CUSTOMER SUMMARY

   Business Question:
   How many customers are classified as High Risk?
   ============================================================ */

SELECT
    Risk_Segment,

    COUNT(*) AS Total_Customers,

    SUM(CAST(Churned AS INT)) AS Churned_Customers,

    COUNT(*) -
        SUM(CAST(Churned AS INT)) AS Active_Customers,

    CAST(
        SUM(CAST(Churned AS INT)) * 100.0 /
        NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS Churn_Rate

FROM dbo.vw_CustomerChurnAnalysis

GROUP BY
    Risk_Segment

ORDER BY
    Churn_Rate DESC;


/* ============================================================
   BUSINESS RECOMMENDATIONS
   ============================================================

   1. COMPETITOR CHURN
   -------------------
   If competitor-related churn is the largest category:

   - Review competitor pricing.
   - Introduce targeted retention offers.
   - Improve communication of service benefits.
   - Identify customers showing competitor-related risk.


   2. MONTH-TO-MONTH CUSTOMERS
   ----------------------------
   Month-to-Month customers should receive greater retention
   attention because of their lower contractual commitment.

   Actions:
   - Offer suitable longer-term contract incentives.
   - Provide personalised offers.
   - Identify high-risk customers before they churn.


   3. DISSATISFACTION
   ------------------
   Investigate the root causes of dissatisfaction.

   Actions:
   - Analyse complaints.
   - Improve customer support.
   - Improve first-contact resolution.
   - Monitor customer satisfaction.


   4. NEW CUSTOMER RETENTION
   -------------------------
   Customers within their first 12 months should receive
   proactive onboarding and engagement.

   Actions:
   - 30-day check-in.
   - 60-day satisfaction review.
   - 90-day retention campaign.
   - Monitor early service problems.


   5. SENIOR CUSTOMER RETENTION
   ----------------------------
   If Senior customers show elevated churn:

   - Investigate their main churn reasons.
   - Improve customer support.
   - Provide clearer service communication.
   - Develop targeted retention strategies.


   6. HIGH-VALUE / HIGH-RISK CUSTOMERS
   -----------------------------------
   Customers paying £50-£69 per month with short tenure and
   low accumulated charges should be investigated carefully.

   Actions:
   - Proactive retention contact.
   - Review onboarding experience.
   - Investigate pricing/value concerns.
   - Monitor competitor-related churn.


   7. DATA-DRIVEN RETENTION
   -----------------------
   The business should not use one retention strategy for every
   customer.

   Retention should consider:

   - Contract Type
   - Age Group
   - Tenure
   - Monthly Charge
   - Total Charges
   - Churn Category
   - Churn Reason
   - Customer Service Calls
   - International Usage
   - Risk Segment

   ============================================================ */


/* ============================================================
   END OF STAGE 6 — CHURN REASONS
   ============================================================ */