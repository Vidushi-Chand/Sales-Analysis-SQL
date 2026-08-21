/*
=========================================================
WINDOW FUNCTIONS
=========================================================

Purpose:
- Perform Top-N and Bottom-N analysis
- Identify duplicate records
- Segment data using NTILE()
- Calculate values from previous and subsequent rows
*/


/*
---------------------------------------------------------
1.1 TOP-N ANALYSIS

Highest sales for each product.
---------------------------------------------------------
*/

SELECT
    ProductID,
    Sales
FROM
    (SELECT
     ProductID,
     Sales,
     ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY Sales DESC) AS Row_Number
    FROM Sales.Orders) AS T
WHERE Row_Number = 1;


/*
---------------------------------------------------------
1.2 BOTTOM-N ANALYSIS

Two customers with the lowest total sales.
---------------------------------------------------------
*/

SELECT TOP 2
    CustomerID,
    Total_Sales
FROM
    (SELECT
    CustomerID,
    SUM(Sales) AS Total_Sales,
    ROW_NUMBER() OVER (ORDER BY SUM(Sales)) AS Row_Number
    FROM Sales.Orders
    GROUP BY CustomerID) AS T
ORDER BY Total_Sales;


/*
---------------------------------------------------------
2. IDENTIFY DUPLICATE RECORDS

For duplicate OrderIDs in OrdersArchive, assign a 
sequential number based on CreationTime.

Row_Number = 1 represents the earliest record for
each OrderID.
---------------------------------------------------------
*/

SELECT
    OrderID,
    CreationTime,
    ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY CreationTimE) AS Row_Number
FROM Sales.OrdersArchive;


/*
---------------------------------------------------------
3. REMOVE DUPLICATE RECORDS

Return one record for each OrderID by keeping the
earliest record based on CreationTime.
---------------------------------------------------------
*/

SELECT
    OrderID,
    CreationTime
FROM
    (SELECT OrderID,
           CreationTime,
           ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY CreationTime) AS Row_Number
    FROM Sales.OrdersArchive) AS T
WHERE Row_Number = 1;


/*
---------------------------------------------------------
4. NTILE - DATA SEGMENTATION

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
    (SELECT
     Sales,
     NTILE(3) OVER (ORDER BY Sales DESC) AS Buckets
     FROM Sales.Orders) AS T;
