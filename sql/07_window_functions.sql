```sql
/*
=========================================================
WINDOW FUNCTIONS
=========================================================

Purpose:
- Rank and compare rows without losing row-level detail
- Perform Top-N and Bottom-N analysis
- Identify duplicate records
- Segment data using NTILE()
- Calculate values from previous and subsequent rows
*/


/*
---------------------------------------------------------
1. INTEGER-BASED RANKING

Rank orders based on sales from highest to lowest.

ROW_NUMBER()  -> assigns a unique sequential number
RANK()        -> assigns the same rank to tied values
                and skips the next rank
DENSE_RANK()  -> assigns the same rank to tied values
                without skipping ranks
NTILE()       -> divides rows into approximately equal groups
---------------------------------------------------------
*/

SELECT
    OrderID,
    Sales,
    ROW_NUMBER() OVER (
        ORDER BY Sales DESC
    ) AS Row_Number,
    RANK() OVER (
        ORDER BY Sales DESC
    ) AS Rank_Number,
    DENSE_RANK() OVER (
        ORDER BY Sales DESC
    ) AS DenseRank_Number,
    NTILE(2) OVER (
        ORDER BY Sales DESC
    ) AS Ntile_2,
    NTILE(3) OVER (
        ORDER BY Sales DESC
    ) AS Ntile_3,
    NTILE(4) OVER (
        ORDER BY Sales DESC
    ) AS Ntile_4
FROM Sales.Orders;


/*
---------------------------------------------------------
2. TOP-N ANALYSIS

Find the highest sales for each product.
---------------------------------------------------------
*/

SELECT
    ProductID,
    Sales
FROM
(
    SELECT
        ProductID,
        Sales,
        ROW_NUMBER() OVER (
            PARTITION BY ProductID
            ORDER BY Sales DESC
        ) AS Row_Number
    FROM Sales.Orders
) AS T
WHERE Row_Number = 1;


/*
---------------------------------------------------------
3. BOTTOM-N ANALYSIS

Find the two customers with the lowest total sales.
---------------------------------------------------------
*/

SELECT TOP 2
    CustomerID,
    Total_Sales
FROM
(
    SELECT
        CustomerID,
        SUM(Sales) AS Total_Sales,
        ROW_NUMBER() OVER (
            ORDER BY SUM(Sales)
        ) AS Row_Number
    FROM Sales.Orders
    GROUP BY CustomerID
) AS T
ORDER BY Total_Sales;


/*
---------------------------------------------------------
4. IDENTIFY DUPLICATE RECORDS

For duplicate OrderIDs in OrdersArchive, assign a
sequential number based on CreationTime.

Row_Number = 1 represents the earliest record for
each OrderID.
---------------------------------------------------------
*/

SELECT
    OrderID,
    CreationTime,
    ROW_NUMBER() OVER (
        PARTITION BY OrderID
        ORDER BY CreationTime
    ) AS Row_Number
FROM Sales.OrdersArchive;


/*
---------------------------------------------------------
5. REMOVE DUPLICATE RECORDS

Return one record for each OrderID by keeping the
earliest record based on CreationTime.
---------------------------------------------------------
*/

SELECT
    OrderID,
    CreationTime
FROM
(
    SELECT
        OrderID,
        CreationTime,
        ROW_NUMBER() OVER (
            PARTITION BY OrderID
            ORDER BY CreationTime
        ) AS Row_Number
    FROM Sales.OrdersArchive
) AS T
WHERE Row_Number = 1;


/*
---------------------------------------------------------
6. NTILE - DATA SEGMENTATION

Segment orders into three groups based on sales:

1 = High
2 = Medium
3 = Low

The bucket is calculated first and then converted
into a meaningful category.
---------------------------------------------------------
*/

SELECT
    Sales,
    Buckets,
    CASE
        WHEN Buckets = 1 THEN 'High'
        WHEN Buckets = 2 THEN 'Medium'
        ELSE 'Low'
    END AS Sales_Category
FROM
(
    SELECT
        Sales,
        NTILE(3) OVER (
            ORDER BY Sales DESC
        ) AS Buckets
    FROM Sales.Orders
) AS T;


/*
---------------------------------------------------------
7. NTILE - EQUALIZING LOAD

Divide orders into two approximately equal groups
for data processing/export purposes.
---------------------------------------------------------
*/

SELECT
    NTILE(2) OVER (
        ORDER BY OrderID
    ) AS Bucket,
    *
FROM Sales.Orders;


/*
---------------------------------------------------------
8. LAG - PREVIOUS VALUE

Retrieve the previous month's sales to support
month-over-month analysis.

Note:
The full business analysis is included in
02_sales_analysis.sql.
---------------------------------------------------------
*/

SELECT
    MONTH(OrderDate) AS Month_Number,
    DATENAME(MONTH, OrderDate) AS Month,
    SUM(Sales) AS Monthly_Sales,
    LAG(SUM(Sales)) OVER (
        ORDER BY MONTH(OrderDate)
    ) AS Previous_Month_Sales
FROM Sales.Orders
GROUP BY
    MONTH(OrderDate),
    DATENAME(MONTH, OrderDate)
ORDER BY Month_Number;


/*
---------------------------------------------------------
9. LEAD - NEXT ORDER

Retrieve the next order date for each customer.
---------------------------------------------------------
*/

SELECT
    CustomerID,
    OrderDate,
    LEAD(OrderDate) OVER (
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS Next_OrderDate
FROM Sales.Orders
ORDER BY
    CustomerID,
    OrderDate;


/*
---------------------------------------------------------
10. FIRST_VALUE AND LAST_VALUE

Find the lowest and highest individual sales for
each product.
---------------------------------------------------------
*/

SELECT
    ProductID,
    Sales,
    FIRST_VALUE(Sales) OVER (
        PARTITION BY ProductID
        ORDER BY Sales
    ) AS Lowest_Sales_By_Product,
    LAST_VALUE(Sales) OVER (
        PARTITION BY ProductID
        ORDER BY Sales
        ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
    ) AS Highest_Sales_By_Product
FROM Sales.Orders
ORDER BY
    ProductID,
    Sales;
```
