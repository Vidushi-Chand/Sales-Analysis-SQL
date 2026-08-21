/*
=========================================================
DATA PROFILING & DATA QUALITY CHECKS
=========================================================

Purpose:
- Understand the size of each table
- Identify NULL values
- Identify duplicate OrderIDs in OrdersArchive
- Investigate duplicate records
*/


/*
---------------------------------------------------------
1. DATA PROFILING
How many records are in each table?
---------------------------------------------------------
*/

SELECT
    'Customers' AS Table_Name,
    COUNT(*) AS Total_Rows
FROM Sales.Customers

UNION ALL

SELECT
    'Employees',
    COUNT(*)
FROM Sales.Employees

UNION ALL

SELECT
    'Products',
    COUNT(*)
FROM Sales.Products

UNION ALL

SELECT
    'Orders',
    COUNT(*)
FROM Sales.Orders

UNION ALL

SELECT
    'OrdersArchive',
    COUNT(*)
FROM Sales.OrdersArchive;


/*
---------------------------------------------------------
2. DATA QUALITY CHECKS - NULL VALUES
Are there NULL values in the Customers table?
---------------------------------------------------------
*/

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(*) - COUNT(CustomerID) AS NULLs_CustomerID,
    COUNT(*) - COUNT(FirstName) AS NULLs_FirstName,
    COUNT(*) - COUNT(LastName) AS NULLs_LastName,
    COUNT(*) - COUNT(Country) AS NULLs_Country,
    COUNT(*) - COUNT(Score) AS NULLs_Score
FROM Sales.Customers;


/*
Result:
LastName and Score each contain 1 NULL value.
*/


/*
---------------------------------------------------------
3. DATA QUALITY CHECKS - NULL VALUES
Are there NULL values in the Employees table?
---------------------------------------------------------
*/

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(*) - COUNT(EmployeeID) AS NULLs_EmployeeID,
    COUNT(*) - COUNT(FirstName) AS NULLs_FirstName,
    COUNT(*) - COUNT(LastName) AS NULLs_LastName,
    COUNT(*) - COUNT(Department) AS NULLs_Department,
    COUNT(*) - COUNT(BirthDate) AS NULLs_BirthDate,
    COUNT(*) - COUNT(Gender) AS NULLs_Gender,
    COUNT(*) - COUNT(Salary) AS NULLs_Salary,
    COUNT(*) - COUNT(ManagerID) AS NULLs_ManagerID
FROM Sales.Employees;


/*
---------------------------------------------------------
4. DATA QUALITY CHECKS - DUPLICATES
Are there duplicate OrderIDs in OrdersArchive?
---------------------------------------------------------
*/

SELECT
    OrderID,
    COUNT(*) OVER (PARTITION BY OrderID) AS Duplicate_Count
FROM Sales.OrdersArchive
WHERE OrderID IN
(
    SELECT OrderID
    FROM Sales.OrdersArchive
    GROUP BY OrderID
    HAVING COUNT(*) > 1
);


/*
---------------------------------------------------------
5. INVESTIGATE DUPLICATE RECORDS
Examine the duplicate OrderIDs in detail.
---------------------------------------------------------
*/

SELECT *
FROM Sales.OrdersArchive
WHERE OrderID IN (4, 6)
ORDER BY
    OrderID,
    CreationTime;
