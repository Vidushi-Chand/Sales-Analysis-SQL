```sql
/*
=========================================================
CUSTOMER ANALYSIS
=========================================================

Purpose:
- Identify customers generating the most sales
- Analyze customer order activity
- Identify countries generating the most sales
- Analyze customer ordering frequency
- Identify customers with the lowest total sales
*/


/*
---------------------------------------------------------
1. TOP CUSTOMERS BY SALES
Which customers generate the most sales?
---------------------------------------------------------
*/

SELECT
    C.CustomerID,
    C.FirstName,
    C.LastName,
    SUM(O.Sales) AS Total_Sales
FROM Sales.Customers AS C
JOIN Sales.Orders AS O
    ON C.CustomerID = O.CustomerID
GROUP BY
    C.CustomerID,
    C.FirstName,
    C.LastName
ORDER BY Total_Sales DESC;


/*
---------------------------------------------------------
2. ORDERS BY CUSTOMER
How many orders does each customer have?
---------------------------------------------------------
*/

SELECT
    C.CustomerID,
    C.FirstName,
    C.LastName,
    COUNT(O.OrderID) AS Number_of_Orders
FROM Sales.Customers AS C
LEFT JOIN Sales.Orders AS O
    ON C.CustomerID = O.CustomerID
GROUP BY
    C.CustomerID,
    C.FirstName,
    C.LastName
ORDER BY Number_of_Orders DESC;


/*
---------------------------------------------------------
3. SALES BY COUNTRY
Which countries generate the most sales?
---------------------------------------------------------
*/

SELECT
    C.Country,
    SUM(O.Sales) AS Total_Sales
FROM Sales.Customers AS C
JOIN Sales.Orders AS O
    ON C.CustomerID = O.CustomerID
GROUP BY C.Country
ORDER BY Total_Sales DESC;


/*
---------------------------------------------------------
4. CUSTOMER ORDERING FREQUENCY
Analyze customer loyalty by ranking customers based
on their average number of days between orders.
---------------------------------------------------------
*/

SELECT
    CustomerID,
    AVG(Difference) AS Avg_Days_Between_Orders,
    RANK() OVER (
        ORDER BY COALESCE(AVG(Difference), 99999)
    ) AS Loyalty_Rank
FROM
(
    SELECT
        CustomerID,
        OrderDate,
        LEAD(OrderDate) OVER (
            PARTITION BY CustomerID
            ORDER BY OrderDate
        ) AS Next_OrderDate,
        DATEDIFF(
            DAY,
            OrderDate,
            LEAD(OrderDate) OVER (
                PARTITION BY CustomerID
                ORDER BY OrderDate
            )
        ) AS Difference
    FROM Sales.Orders
) AS T
GROUP BY CustomerID
ORDER BY Loyalty_Rank;


/*
---------------------------------------------------------
5. BOTTOM 2 CUSTOMERS BY SALES
Which customers have the lowest total sales?
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
```
