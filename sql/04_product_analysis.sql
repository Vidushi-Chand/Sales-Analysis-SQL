```sql
/*
=========================================================
PRODUCT ANALYSIS
=========================================================

Purpose:
- Identify the products generating the most sales
- Compare sales performance across categories
- Calculate category contribution to total sales
- Identify the lowest and highest sales for each product
*/


/*
---------------------------------------------------------
1. TOP-SELLING PRODUCTS
Which products sell the most?
---------------------------------------------------------
*/

SELECT
    P.Product,
    SUM(O.Sales) AS Total_Sales
FROM Sales.Products AS P
LEFT JOIN Sales.Orders AS O
    ON P.ProductID = O.ProductID
GROUP BY P.Product
ORDER BY Total_Sales DESC;


/*
---------------------------------------------------------
2. SALES BY CATEGORY
Which categories perform best?
---------------------------------------------------------
*/

SELECT
    P.Category,
    SUM(O.Sales) AS Total_Sales
FROM Sales.Products AS P
JOIN Sales.Orders AS O
    ON P.ProductID = O.ProductID
GROUP BY P.Category
ORDER BY Total_Sales DESC;


/*
---------------------------------------------------------
3. CATEGORY CONTRIBUTION
What percentage of total sales comes from each category?
---------------------------------------------------------
*/

SELECT
    P.Category,
    SUM(O.Sales) AS Category_Sales,
    SUM(O.Sales) * 100.0 /
        (SELECT SUM(Sales)
         FROM Sales.Orders) AS Sales_Percentage
FROM Sales.Products AS P
JOIN Sales.Orders AS O
    ON P.ProductID = O.ProductID
GROUP BY P.Category
ORDER BY Sales_Percentage DESC;


/*
---------------------------------------------------------
4. LOWEST AND HIGHEST SALES BY PRODUCT
Find the lowest and highest individual sales
for each product.
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
ORDER BY ProductID, Sales;
```
