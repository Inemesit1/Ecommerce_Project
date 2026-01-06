CREATE DATABASE ecommerce_db;
USE ecommerce_db;


select * from E_Commerce

select top 200 StockCode
from E_Commerce

---Add New Columns 
ALTER TABLE E_Commerce
ADD StockCode_Numbers VARCHAR(20),
    StockCode_Letters VARCHAR(10);

---Populate the tables 
UPDATE E_Commerce
SET 
    StockCode_Numbers = TRIM(TRANSLATE(StockCode, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz', REPLICATE(' ', 52))),
    StockCode_Letters = TRIM(TRANSLATE(StockCode, '0123456789', REPLICATE(' ', 10)));

select StockCode, StockCode_Numbers, StockCode_Letters
from E_Commerce



-- Now populate split columns
UPDATE E_Commerce
SET
  StockCode_Numbers = CASE
    WHEN PATINDEX('%[^0-9]%', StockCode) = 0 THEN StockCode                       -- all digits
    WHEN PATINDEX('%[^0-9]%', StockCode) = 1 THEN NULL                              -- first char is non-digit (e.g. 'POST')
    ELSE LEFT(StockCode, PATINDEX('%[^0-9]%', StockCode) - 1)                       -- digits from start up to before first non-digit
  END,
  StockCode_Letters = CASE
    WHEN PATINDEX('%[^0-9]%', StockCode) = 0 THEN NULL                              -- no letters found
    ELSE SUBSTRING(StockCode, PATINDEX('%[^0-9]%', StockCode), LEN(StockCode))      -- remainder starting at first non-digit
  END;

---The above query couldnt populate, so i had to increase the number of letters that the ecommerce table would be able to take 
  ALTER TABLE E_Commerce
ALTER COLUMN StockCode_Letters VARCHAR(100);


SELECT DISTINCT StockCode_Letters
FROM E_Commerce
WHERE StockCode_Letters IS NOT NULL
ORDER BY StockCode_Letters;

SELECT * 
FROM E_Commerce
WHERE StockCode IS NOT NULL OR StockCode_Letters IS NOT NULL;

select stockCode_Letters , Description 
from E_Commerce 
where stockcode_letters is not null

---checking the number of occurences 
SELECT StockCode_Letters, COUNT(*) AS Occurrences
FROM E_Commerce
GROUP BY StockCode_Letters
ORDER BY Occurrences DESC;


---Archive the columns 
SELECT DISTINCT StockCode_Letters, COUNT(*) AS Occurrences
INTO StockCode_Letter_Reference
FROM E_Commerce
WHERE StockCode_Letters IS NOT NULL
group by stockcode_letters

---after archiving , drop the tables 
alter table E_Commerce 
drop column stockcode, stockcode_Letters

---rename the stockcode number to stock code 
EXEC sp_rename 'E_Commerce.StockCode_Numbers', 'StockCode', 'COLUMN';


select * from E_Commerce
WHERE StockCode IS NULL

---creating a new archive table for null rows 
SELECT *
INTO E_Commerce_Archive_Nulls
FROM E_Commerce
WHERE StockCode IS NULL;

--- Delete from main table where stock code is null 
DELETE FROM E_Commerce
WHERE StockCode IS NULL;

---- Verify 
SELECT COUNT(*) AS RemainingNulls FROM E_Commerce WHERE StockCode IS NULL;
SELECT COUNT(*) AS ArchivedRows FROM E_Commerce_Archive_Nulls;

---For The Unit Price Column

select * from E_Commerce

EXEC sp_help 'E_Commerce';

---adding a new column for unitprice
alter table E_Commerce
add unitprice_clean decimal(10,2)

---setting the new column
UPDATE E_Commerce
SET UnitPrice_Clean = ROUND(UnitPrice, 2);


--dropping the initial unitprice column
alter table E_Commerce 
drop column unitprice 

---renaming the new unitprice column
EXEC sp_rename 'E_Commerce.UnitPrice_Clean', 'UnitPrice', 'COLUMN';


---Queries
---1. Total Monthly Revenue Trend 

select sum(unitprice * quantity) as TotalSales, year(invoicedate) as year, month(invoicedate) as month
from E_Commerce
group by month(invoicedate),year(invoicedate) 
order by month


---2.Top 10 Products by Total Revenue
select top 10 Description, sum(unitprice * quantity) as TotalSales, month(invoicedate) as month
from E_Commerce
group by Description,month(invoicedate)
order by TotalSales desc

---3.Revenue by Country, Which countries generate the highest average order value?

select TOP 5  country, ROUND(AVG(unitprice * quantity),2) as AvgOrderValue
from E_Commerce
GROUP BY Country
ORDER BY AvgOrderValue DESC

---4.Repeat vs One-Time Customers. Question: How many customers made multiple purchases versus one-time buyers?


SELECT
    SUM(CASE WHEN OrdersCount = 1 THEN 1 ELSE 0 END) AS OneTimeCustomers,
    SUM(CASE WHEN OrdersCount > 1 THEN 1 ELSE 0 END) AS RepeatCustomers
FROM (
    SELECT CustomerID, COUNT(*) AS OrdersCount
    FROM E_Commerce
    GROUP BY CustomerID
) AS CustomerOrders;


---5.Average Order Value (AOV) and Quantity per Invoice. What is the average order value and items per order?

-- Average Order Value (AOV) and Average Items per Invoice
SELECT
    AVG(TotalAmount) AS AvgOrderValue,
    AVG(TotalQuantity) AS AvgItemsPerInvoice
FROM (
    SELECT
        InvoiceNo,
        SUM(UnitPrice * Quantity) AS TotalAmount,
        SUM(Quantity) AS TotalQuantity
    FROM E_Commerce
    GROUP BY InvoiceNo
) AS InvoiceTotals;


---6. Most Returned Products. Which products have the highest number of returns (negative quantities)?

-- Most Returned Products
SELECT TOP 10
    Description,
    SUM(ABS(Quantity)) AS TotalReturned
FROM E_Commerce
WHERE Quantity < 0
GROUP BY Description
ORDER BY TotalReturned DESC;

--- 7 Data Quality Check: Duplicate Invoice Lines. Are there any duplicate invoice lines (same invoice, stock code, and price)?


select InvoiceNo,StockCode,UnitPrice,count(*) as linecount
from e_commerce 
group by InvoiceNo,stockcode,UnitPrice
having count(*) > 1
order by linecount desc


---8 Month-over-Month Revenue Growth. What’s the month-over-month revenue growth percentage?


WITH MonthlyRevenue AS (
    SELECT 
        YEAR(InvoiceDate) AS Year,
        MONTH(InvoiceDate) AS Month,
        SUM(UnitPrice * Quantity) AS Revenue
    FROM E_Commerce
    GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
)
SELECT 
    Year,
    Month,
    Revenue,
    LAG(Revenue) OVER (ORDER BY Year, Month) AS PrevMonthRevenue,
    ROUND(
        ((Revenue - LAG(Revenue) OVER (ORDER BY Year, Month)) * 100.0) / 
        LAG(Revenue) OVER (ORDER BY Year, Month),
        2
    ) AS MoM_Growth_Percent
FROM MonthlyRevenue
ORDER BY Year, Month;

/* =========================================================
   MASTER CTE: Cleaned and Revenue-Ready Transactions
   Purpose:
   - Validate revenue logic
   - Inspect cleaned data before creating analytics view
   ========================================================= */

WITH CleanedTransactions AS (
    SELECT
        InvoiceNo,
        StockCode,
        Description,
        CustomerID,
        Country,
        InvoiceDate,
        Quantity,
        UnitPrice,
        (Quantity * UnitPrice) AS Revenue,
        CASE 
            WHEN Quantity < 0 THEN 1 
            ELSE 0 
        END AS IsReturn
    FROM E_Commerce
    WHERE CustomerID IS NOT NULL
)
SELECT TOP 10 *
FROM CleanedTransactions;

--- From Query 2 , top products by total revenue 
--- I grouped product + Month which answered the wrong question 

/* =========================================================
  ANALYTICS VIEW: vw_cleaned_transactions
   Purpose:
   - Centralize revenue calculations
   - Enforce data quality rules
   - Enable consistent analysis across all business questions
   ========================================================= */

CREATE VIEW vw_cleaned_transactions AS
SELECT
    InvoiceNo,
    StockCode,
    Description,
    CustomerID,
    Country,
    InvoiceDate,
    Quantity,
    UnitPrice,
    (Quantity * UnitPrice) AS Revenue,
    CASE 
        WHEN Quantity < 0 THEN 1 
        ELSE 0 
    END AS IsReturn
FROM E_Commerce
WHERE CustomerID IS NOT NULL;

/* =========================================================
   Top Products by Total Revenue
   Business Question:
   - Which products drive the largest share of revenue?
   Decision Supported:
   - Inventory prioritization
   - Marketing focus on high-impact products
   ========================================================= */

SELECT TOP 10
    Description,
    SUM(Revenue) AS TotalRevenue
FROM vw_cleaned_transactions
WHERE IsReturn = 0
GROUP BY Description
ORDER BY TotalRevenue DESC;



