/*
=========================================================
PRODUCT ANALYSIS
=========================================================

Purpose:
- Identify the lowest and highest sales for each product
- Compare sales performance across categories

*/


/*
---------------------------------------------------------
1. LOWEST AND HIGHEST SALES BY PRODUCT
Find the lowest and highest individual sales
for each product.
---------------------------------------------------------
*/

SELECT
    ProductID,
    Sales,
    FIRST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales) AS Lowest_Sales_By_Product,
    LAST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS Highest_Sales_By_Product
FROM Sales.Orders
ORDER BY ProductID, Sales;


/*
---------------------------------------------------------
2. SALES BY CATEGORY
Which categories perform best?
---------------------------------------------------------
*/

SELECT  
    P.Category,
    P.Product,
    SUM(O.Sales) AS Total_Sales
FROM Sales.Products AS P
LEFT JOIN Sales.Orders AS O
    ON P.ProductID = O.ProductID
GROUP BY P.Category, P.Product
ORDER BY Total_Sales DESC;
