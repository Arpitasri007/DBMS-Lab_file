-- 1. REMOVE OLD TABLES
DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Suppliers;
DROP TABLE IF EXISTS Sales_1NF;

-- 2. ORIGINAL TABLE IN 1NF
CREATE TABLE Sales_1NF (
    OrderID INTEGER,
    OrderDate TEXT,
    CustomerID VARCHAR(20),
    CustomerName TEXT,
    ProductID VARCHAR(20),
    ProductName TEXT,
    UnitPrice REAL,
    SupplierID VARCHAR(20),
    SupplierName TEXT,
    Quantity INTEGER,
    PRIMARY KEY (OrderID, ProductID)
);

INSERT INTO Sales_1NF VALUES
(101,'2026-01-10','C01','Amit','P01','Laptop',50000,'S01','TechSupply',1),
(101,'2026-01-10','C01','Amit','P02','Mouse',500,'S02','OfficeMart',2),
(102,'2026-01-11','C02','Neha','P02','Mouse',500,'S02','OfficeMart',1),
(103,'2026-01-12','C01','Amit','P03','Keyboard',1500,'S01','TechSupply',1);

-- 3. CREATE BCNF TABLES
CREATE TABLE Customers (
    CustomerID VARCHAR(20) PRIMARY KEY,
    CustomerName TEXT NOT NULL
);

CREATE TABLE Suppliers (
    SupplierID VARCHAR(20) PRIMARY KEY,
    SupplierName TEXT NOT NULL
);

CREATE TABLE Orders (
    OrderID INTEGER PRIMARY KEY,
    OrderDate TEXT NOT NULL,
    CustomerID VARCHAR(20) NOT NULL,
    FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID)
);

CREATE TABLE Products (
    ProductID VARCHAR(20) PRIMARY KEY,
    ProductName TEXT NOT NULL,
    UnitPrice REAL NOT NULL,
    SupplierID VARCHAR(20) NOT NULL,
    FOREIGN KEY (SupplierID)
        REFERENCES Suppliers(SupplierID)
);

CREATE TABLE OrderItems (
    OrderID INTEGER,
    ProductID VARCHAR(20),
    Quantity INTEGER NOT NULL CHECK (Quantity > 0),
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- 4. POPULATE NORMALIZED TABLES
INSERT INTO Customers
SELECT DISTINCT CustomerID, CustomerName
FROM Sales_1NF;

INSERT INTO Suppliers
SELECT DISTINCT SupplierID, SupplierName
FROM Sales_1NF;

INSERT INTO Orders
SELECT DISTINCT OrderID, OrderDate, CustomerID
FROM Sales_1NF;

INSERT INTO Products
SELECT DISTINCT ProductID, ProductName, UnitPrice, SupplierID
FROM Sales_1NF;

INSERT INTO OrderItems
SELECT OrderID, ProductID, Quantity
FROM Sales_1NF;

-- 5. DISPLAY NORMALIZED SALES DATA
SELECT
    O.OrderID,
    O.OrderDate,
    C.CustomerID,
    C.CustomerName,
    P.ProductID,
    P.ProductName,
    P.UnitPrice,
    S.SupplierID,
    S.SupplierName,
    I.Quantity
FROM Orders O
JOIN Customers C ON O.CustomerID = C.CustomerID
JOIN OrderItems I ON O.OrderID = I.OrderID
JOIN Products P ON I.ProductID = P.ProductID
JOIN Suppliers S ON P.SupplierID = S.SupplierID
ORDER BY O.OrderID, P.ProductID;

-- 6. VERIFY LOSSLESS JOIN
-- Expected: 0 rows in both queries
SELECT * FROM Sales_1NF
EXCEPT
SELECT
    O.OrderID, O.OrderDate,
    C.CustomerID, C.CustomerName,
    P.ProductID, P.ProductName,
    P.UnitPrice, S.SupplierID,
    S.SupplierName, I.Quantity
FROM Orders O
JOIN Customers C ON O.CustomerID = C.CustomerID
JOIN OrderItems I ON O.OrderID = I.OrderID
JOIN Products P ON I.ProductID = P.ProductID
JOIN Suppliers S ON P.SupplierID = S.SupplierID;

SELECT
    O.OrderID, O.OrderDate,
    C.CustomerID, C.CustomerName,
    P.ProductID, P.ProductName,
    P.UnitPrice, S.SupplierID,
    S.SupplierName, I.Quantity
FROM Orders O
JOIN Customers C ON O.CustomerID = C.CustomerID
JOIN OrderItems I ON O.OrderID = I.OrderID
JOIN Products P ON I.ProductID = P.ProductID
JOIN Suppliers S ON P.SupplierID = S.SupplierID
EXCEPT
SELECT * FROM Sales_1NF;

-- 7. VERIFY FUNCTIONAL DEPENDENCIES
-- Expected: 0 rows in each query
SELECT CustomerID
FROM Customers
GROUP BY CustomerID
HAVING COUNT(DISTINCT CustomerName) > 1;

SELECT OrderID
FROM Orders
GROUP BY OrderID
HAVING COUNT(DISTINCT OrderDate) > 1
    OR COUNT(DISTINCT CustomerID) > 1;

SELECT SupplierID
FROM Suppliers
GROUP BY SupplierID
HAVING COUNT(DISTINCT SupplierName) > 1;

SELECT ProductID
FROM Products
GROUP BY ProductID
HAVING COUNT(DISTINCT ProductName) > 1
    OR COUNT(DISTINCT UnitPrice) > 1
    OR COUNT(DISTINCT SupplierID) > 1;

SELECT OrderID, ProductID
FROM OrderItems
GROUP BY OrderID, ProductID
HAVING COUNT(DISTINCT Quantity) > 1;

-- 8. DISPLAY FINAL TABLE COUNTS
SELECT 'Customers' AS TableName, COUNT(*) AS TotalRows
FROM Customers
UNION ALL
SELECT 'Suppliers', COUNT(*) FROM Suppliers
UNION ALL
SELECT 'Orders', COUNT(*) FROM Orders
UNION ALL
SELECT 'Products', COUNT(*) FROM Products
UNION ALL
SELECT 'OrderItems', COUNT(*) FROM OrderItems;
