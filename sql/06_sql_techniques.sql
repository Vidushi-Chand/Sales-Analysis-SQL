/*
=========================================================
SQL TECHNIQUES
=========================================================

Purpose:
- Demonstrate filtering and aggregation
- Demonstrate pattern matching
- Demonstrate multi-table joins
- Understand the difference between GROUP BY and
  window functions
*/


/*
---------------------------------------------------------
1. WHERE + GROUP BY + HAVING

Find the average customer score for each country,
considering only customers with a score not equal to 0,
and return only countries with an average score
greater than 430.
---------------------------------------------------------
*/

SELECT
    Country,
    AVG(Score) AS Average_Score
FROM Sales.Customers
WHERE Score <> 0
GROUP BY Country
HAVING AVG(Score) > 430
ORDER BY Average_Score DESC;


/*
---------------------------------------------------------
2. SEARCH OPERATORS - LIKE

Find customers whose first name:
- Starts with 'M'
- Ends with 'n'
- Contains 'r'
- Has 'r' in the third position
---------------------------------------------------------
*/

-- Starts with 'M'
SELECT *
FROM Sales.Customers
WHERE FirstName LIKE 'M%';


-- Ends with 'n'
SELECT *
FROM Sales.Customers
WHERE FirstName LIKE '%n';


-- Contains 'r'
SELECT *
FROM Sales.Customers
WHERE FirstName LIKE '%r%';


-- Has 'r' in the third position
SELECT *
FROM Sales.Customers
WHERE FirstName LIKE '__r%';


/*
---------------------------------------------------------
3. MULTI-TABLE JOIN

Retrieve order information along with the related
customer, product, and salesperson details.

For each order:
- OrderID
- Customer name
- Product name
- Sales amount
- Product price
- Salesperson name
---------------------------------------------------------
*/

SELECT
    O.OrderID,
    C.FirstName AS Customer,
    P.Product,
    O.Sales,
    P.Price,
    E.FirstName AS Salesperson
FROM Sales.Orders AS O
LEFT JOIN Sales.Customers AS C
    ON O.CustomerID = C.CustomerID
LEFT JOIN Sales.Employees AS E
    ON O.SalesPersonID = E.EmployeeID
LEFT JOIN Sales.Products AS P
    ON O.ProductID = P.ProductID;


/*
---------------------------------------------------------
4. WHY WINDOW FUNCTIONS?
GROUP BY vs. Window Functions
---------------------------------------------------------
*/


/*
A. Total sales across all orders
Returns one aggregated value.
*/

SELECT
    SUM(Sales) AS Total_Sales
FROM Sales.Orders;


/*
B. Total sales for each product
GROUP BY reduces the number of rows and returns
one row per product.
*/

SELECT
    ProductID,
    SUM(Sales) AS Total_Sales_By_Product
FROM Sales.Orders
GROUP BY ProductID;


/*
C. GROUP BY limitation

If we try to include OrderID and OrderDate while
aggregating by ProductID, SQL requires those columns
to be included in GROUP BY.

This changes the level of aggregation.
*/

SELECT
    OrderID,
    OrderDate,
    ProductID,
    SUM(Sales) AS Total_Sales_By_Product
FROM Sales.Orders
GROUP BY
    OrderID,
    OrderDate,
    ProductID;


/*
D. Window function

A window function allows us to calculate the total
sales for each product while keeping the individual
order-level details.
*/

SELECT
    OrderID,
    OrderDate,
    ProductID,
    Sales,
    SUM(Sales) OVER (PARTITION BY ProductID) AS Total_Sales_By_Product
FROM Sales.Orders;
