USE [Customer Churn];

-- =====================================================
-- 1. ROW COUNT
-- =====================================================

-- Row count
SELECT COUNT(*) AS Row_Count
FROM CustomerChurnAnalysis_New;


-- =====================================================
-- 2. OVERALL CUSTOMER & CHURN COUNT
-- =====================================================

SELECT
    COUNT(*) AS Row_Count,
    COUNT(customer_id) AS Total_Customers,
    SUM(CAST(churned AS INT)) AS Total_Churned_Customer
FROM CustomerChurnAnalysis_New;


-- =====================================================
-- 3. DUPLICATE CUSTOMER IDs
-- =====================================================

SELECT
    customer_id,
    COUNT(customer_id) AS Total_Customers
FROM CustomerChurnAnalysis_New
GROUP BY customer_id
HAVING COUNT(customer_id) > 1;


-- =====================================================
-- 4. DUPLICATE PHONE NUMBERS
-- =====================================================

SELECT
    phone_number,
    COUNT(phone_number) AS Total_Customers
FROM CustomerChurnAnalysis_New
GROUP BY phone_number
HAVING COUNT(phone_number) > 1;


-- =====================================================
-- 5. VERIFY DUPLICATE RECORDS
-- =====================================================

SELECT *
FROM CustomerChurnAnalysis_New
WHERE phone_number = '390-3401';


-- =====================================================
-- 6. NULL VALUE CHECK — ALL IMPORTANT COLUMNS
-- =====================================================

SELECT 
    COUNT(*) AS Row_Count,
    SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS State_Nulls,
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS Age_Nulls,
    SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS Gender_Nulls,
    SUM(CASE WHEN Contract_Type IS NULL THEN 1 ELSE 0 END) AS Contract_Type_Nulls,
    SUM(CASE WHEN Payment_Method IS NULL THEN 1 ELSE 0 END) AS Payment_Method_Nulls,
    SUM(CASE WHEN Churn_Category IS NULL THEN 1 ELSE 0 END) AS Churn_Category_Nulls,
    SUM(CASE WHEN Churn_Reason IS NULL THEN 1 ELSE 0 END) AS Churn_Reason_Nulls,
    SUM(CASE WHEN Intl_Active IS NULL THEN 1 ELSE 0 END) AS Intl_Active_Nulls,
    SUM(CASE WHEN Intl_Plan IS NULL THEN 1 ELSE 0 END) AS Intl_Plan_Nulls,
    SUM(CASE WHEN Unlimited_Data_Plan IS NULL THEN 1 ELSE 0 END) AS Unlimited_Data_Plan_Nulls
FROM CustomerChurnAnalysis_New;


-- =====================================================
-- 7. NULL CHECK — CHURN CATEGORY & REASON BY CHURN STATUS
-- =====================================================

SELECT
    churned,
    COUNT(*) AS Customer_Count,
    SUM(CASE WHEN churn_category IS NULL THEN 1 ELSE 0 END) AS Churn_Category_Nulls,
    SUM(CASE WHEN churn_reason IS NULL THEN 1 ELSE 0 END) AS Churn_Reason_Nulls
FROM CustomerChurnAnalysis_New
GROUP BY churned;


-- =====================================================
-- 8. CHURNED CUSTOMERS WITH MISSING CHURN CATEGORY
-- =====================================================

SELECT *
FROM CustomerChurnAnalysis_New
WHERE churned = 1
  AND Churn_Category IS NULL;


-- =====================================================
-- 9. CHECK CURRENT DATA TYPES — CALLS & MINUTES
-- =====================================================

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CustomerChurnAnalysis_New'
  AND COLUMN_NAME IN (
      'Local_Mins',
      'Intl_Mins',
      'Extra_International_Charges'
  );


-- =====================================================
-- 10. SAMPLE VALUES — CALLS & MINUTES
-- =====================================================

SELECT TOP 20
    Local_Mins,
    Intl_Mins,
    Extra_International_Charges
FROM CustomerChurnAnalysis_New;


-- =====================================================
-- 11. CHANGE DATA TYPES TO DECIMAL
-- =====================================================

ALTER TABLE CustomerChurnAnalysis_New
ALTER COLUMN Local_Mins DECIMAL(10,2);

ALTER TABLE CustomerChurnAnalysis_New
ALTER COLUMN Intl_Mins DECIMAL(10,2);

ALTER TABLE CustomerChurnAnalysis_New
ALTER COLUMN Extra_International_Charges DECIMAL(10,2);


-- =====================================================
-- 12. CHECK NON-NULL VALUES AFTER DATA TYPE CHANGE
-- =====================================================

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(Local_Mins) AS Local_Mins_NonNull,
    COUNT(Intl_Mins) AS Intl_Mins_NonNull,
    COUNT(Extra_International_Charges) AS Extra_Charges_NonNull
FROM CustomerChurnAnalysis_New;


-- =====================================================
-- 13. RANGE CHECK — LOCAL & INTERNATIONAL MINUTES
-- =====================================================

SELECT
    MIN(Local_Mins) AS Min_Local_Mins,
    MAX(Local_Mins) AS Max_Local_Mins,
    MIN(Intl_Mins) AS Min_Intl_Mins,
    MAX(Intl_Mins) AS Max_Intl_Mins
FROM CustomerChurnAnalysis_New;


-- =====================================================
-- 14. TOP CUSTOMERS BY LOCAL MINUTES
-- =====================================================

SELECT TOP 20
    customer_id,
    local_mins,
    intl_mins
FROM CustomerChurnAnalysis_New
ORDER BY local_mins DESC;


-- =====================================================
-- 15. CHECK FOR NEGATIVE VALUES
-- =====================================================

SELECT
    SUM(CASE WHEN local_mins < 0 THEN 1 ELSE 0 END) AS Negative_Local_Mins,
    SUM(CASE WHEN intl_mins < 0 THEN 1 ELSE 0 END) AS Negative_Intl_Mins,
    SUM(CASE WHEN Extra_International_Charges < 0 THEN 1 ELSE 0 END) AS Negative_Extra_International
FROM CustomerChurnAnalysis_New;


-- =====================================================
-- 16. BINARY VALUE CONSISTENCY CHECK — 0/1 COLUMNS
-- =====================================================

SELECT
    SUM(CASE WHEN Churned NOT IN (0,1) THEN 1 ELSE 0 END) AS Invalid_Churned,
    SUM(CASE WHEN Intl_Active NOT IN (0,1) THEN 1 ELSE 0 END) AS Invalid_Intl_Active,
    SUM(CASE WHEN Intl_Plan NOT IN (0,1) THEN 1 ELSE 0 END) AS Invalid_Intl_Plan,
    SUM(CASE WHEN Unlimited_Data_Plan NOT IN (0,1) THEN 1 ELSE 0 END) AS Invalid_Unlimited_Data_Plan,
    SUM(CASE WHEN Under_30 NOT IN (0,1) THEN 1 ELSE 0 END) AS Invalid_Under_30,
    SUM(CASE WHEN Senior NOT IN (0,1) THEN 1 ELSE 0 END) AS Invalid_Senior,
    SUM(CASE WHEN Device_Protection_Online_Backup NOT IN (0,1) THEN 1 ELSE 0 END) AS Invalid_Device_Protection
FROM CustomerChurnAnalysis_New;


-- =====================================================
-- 17. GROUP COLUMN — YES/NO CONSISTENCY
-- =====================================================

SELECT
    SUM(CASE WHEN [Group] NOT IN ('Yes','No') THEN 1 ELSE 0 END) AS Invalid_Group
FROM CustomerChurnAnalysis_New;


-- =====================================================
-- 18. GROUP VALUE DISTRIBUTION
-- =====================================================

SELECT
    [Group],
    COUNT(*) AS Total_Records
FROM CustomerChurnAnalysis_New
GROUP BY [Group];


-- =====================================================
-- 19. AGE RANGE CHECK
-- =====================================================

SELECT
    MIN(Age) AS Min_Age,
    MAX(Age) AS Max_Age
FROM CustomerChurnAnalysis_New;


-- =====================================================
-- 20. RANGE CHECK — ACCOUNT & CALL VARIABLES
-- =====================================================

SELECT
    MIN(Account_Length_in_months) AS Min_Account_Length,
    MAX(Account_Length_in_months) AS Max_Account_Length,
    MIN(Local_Calls) AS Min_Local_Calls,
    MAX(Local_Calls) AS Max_Local_Calls,
    MIN(Intl_Calls) AS Min_Intl_Calls,
    MAX(Intl_Calls) AS Max_Intl_Calls,
    MIN(Customer_Service_Calls) AS Min_Service_Calls,
    MAX(Customer_Service_Calls) AS Max_Service_Calls
FROM CustomerChurnAnalysis_New;


-- =====================================================
-- 21. NEGATIVE VALUE CHECK — ACCOUNT & CALL VARIABLES
-- =====================================================

SELECT *
FROM CustomerChurnAnalysis_New
WHERE Age < 0 
   OR Account_Length_in_months < 0
   OR Local_Calls < 0
   OR Local_Mins < 0
   OR Intl_Calls < 0
   OR Intl_Mins < 0
   OR Customer_Service_Calls < 0;


-- =====================================================
-- 22. UNDER 30 VS AGE CONSISTENCY
-- =====================================================

SELECT
    Age,
    Under_30
FROM CustomerChurnAnalysis_New
WHERE (Age < 30 AND Under_30 <> 1)
   OR (Age >= 30 AND Under_30 <> 0);


-- =====================================================
-- 23. SENIOR VS AGE — DISTRIBUTION
-- =====================================================

SELECT
    Age,
    Senior,
    COUNT(*) AS Customer_Count
FROM CustomerChurnAnalysis_New
WHERE Age BETWEEN 60 AND 70
GROUP BY Age, Senior
ORDER BY Age, Senior;


-- =====================================================
-- 24. SENIOR VS AGE — CONSISTENCY CHECK
-- =====================================================

SELECT
    Age,
    Senior,
    COUNT(*) AS Invalid_Senior_Records
FROM CustomerChurnAnalysis_New
WHERE (Age >= 65 AND Senior <> 1)
   OR (Age < 66 AND Senior <> 0)
GROUP BY Age, Senior
ORDER BY Age, Senior;


-- =====================================================
-- 25. CHURNED VS CHURN LABEL CONSISTENCY
-- =====================================================

SELECT COUNT(*) AS Mismatched_Records
FROM CustomerChurnAnalysis_New
WHERE Churn_Label <> Churned;


-- =====================================================
-- 26. SENIOR CLEANING LOGIC
-- =====================================================

SELECT
    Customer_ID,
    Age,
    Senior,
    CASE
        WHEN Age >= 65 THEN 1
        ELSE 0
    END AS Senior_Cleaned
FROM CustomerChurnAnalysis_New;


-- =====================================================
-- 27. CHURN CATEGORY & REASON CONSISTENCY
-- =====================================================

SELECT
    Churned,
    Churn_Category,
    Churn_Reason
FROM CustomerChurnAnalysis_New
WHERE Churned = 1
  AND (Churn_Category IS NULL OR Churn_Reason IS NULL);


-- =====================================================
-- 28. CONTRACT TYPE DISTRIBUTION
-- =====================================================

SELECT
    Contract_Type,
    COUNT(*) AS Customer_Count
FROM CustomerChurnAnalysis_New
GROUP BY Contract_Type;


-- =====================================================
-- 29. PAYMENT METHOD DISTRIBUTION
-- =====================================================

SELECT
    Payment_Method,
    COUNT(*) AS Customer_Count
FROM CustomerChurnAnalysis_New
GROUP BY Payment_Method;


-- =====================================================
-- 30. GENDER DISTRIBUTION
-- =====================================================

SELECT
    Gender,
    COUNT(*) AS Customer_Count
FROM CustomerChurnAnalysis_New
GROUP BY Gender;


-- =====================================================
-- 31. GENDER VALIDATION
-- =====================================================

SELECT
    SUM(
        CASE
            WHEN Gender NOT IN ('Male', 'Female', 'Prefer not to say')
            THEN 1
            ELSE 0
        END
    ) AS Invalid_Gender_Values
FROM CustomerChurnAnalysis_New;


-- =====================================================
-- 32. DISTINCT GENDER VALUES
-- =====================================================

SELECT DISTINCT Gender
FROM CustomerChurnAnalysis_New;


-- =====================================================
-- 33. MONTHLY CHARGE VS EXPECTED TOTAL CHARGES
-- =====================================================

SELECT TOP 20
    Customer_ID,
    Account_Length_in_months,
    Monthly_Charge,
    Total_Charges,
    Monthly_Charge * Account_Length_in_months AS Expected_Total
FROM CustomerChurnAnalysis_New;


-- =====================================================
-- 34. CHECK ACCOUNT LENGTH DATA TYPE
-- =====================================================

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CustomerChurnAnalysis_New'
  AND COLUMN_NAME = 'Account_Length_in_months';


-- =====================================================
-- 35. ACCOUNT LENGTH RANGE CHECK
-- =====================================================

SELECT
    MIN(Account_Length_in_months) AS Min_Months,
    MAX(Account_Length_in_months) AS Max_Months
FROM CustomerChurnAnalysis_New;


-- =====================================================
-- 36. TOP CUSTOMERS BY TOTAL CHARGES
-- =====================================================

SELECT TOP 20
    Customer_ID,
    Local_Mins,
    Intl_Mins,
    Monthly_Charge,
    Total_Charges
FROM CustomerChurnAnalysis_New
ORDER BY Total_Charges DESC;


-- =====================================================
-- 37. INTERNATIONAL ACTIVITY CONSISTENCY
-- =====================================================

SELECT *
FROM CustomerChurnAnalysis_New
WHERE Intl_Active = 0
  AND (Intl_Calls > 0 OR Intl_Mins > 0);