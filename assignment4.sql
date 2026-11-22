CREATE DATABASE RetailDB;
USE RetailDB;

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    City VARCHAR(50),
    LoyaltyScore INT
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    UnitPrice DECIMAL(10,2),
    UnitsInStock INT
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT REFERENCES Customers(CustomerID),
    OrderDate DATE,
    TotalAmount DECIMAL(12,2)
);

CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY,
    OrderID INT REFERENCES Orders(OrderID),
    ProductID INT REFERENCES Products(ProductID),
    Quantity INT,
    UnitPrice DECIMAL(10,2)
);

INSERT INTO Customers VALUES (1, 'Anna', 'Smith', 'New York', 90);
INSERT INTO Customers VALUES (2, 'Bob', 'Stone', 'Boston', 45);
INSERT INTO Customers VALUES (3, 'Carla', 'Diaz', 'New York', 60);
INSERT INTO Customers VALUES (4, 'David', 'Sharma', 'Chicago', 85);
INSERT INTO Customers VALUES (5, 'Emma', 'Brown', 'Seattle', 30);
INSERT INTO Customers VALUES (6, 'Frank', 'Sullivan', 'Austin', 70);

INSERT INTO Products VALUES (1, 'Laptop', 'Electronics', 899.99, 15);
INSERT INTO Products VALUES (2, 'Headphones', 'Electronics', 45.00, 60);
INSERT INTO Products VALUES (3, 'Python Basics', 'Books', 25.00, 40);
INSERT INTO Products VALUES (4, 'SQL Guide', 'Books', 30.00, 0);
INSERT INTO Products VALUES (5, 'Desk Lamp', 'Home', 22.50, 80);
INSERT INTO Products VALUES (6, 'Novel', 'Books', 15.00, 100);
INSERT INTO Products VALUES (7, 'Smart Watch', 'Electronics', 250.00, 0);
INSERT INTO Products VALUES (8, 'Notebook', 'Stationery', 8.00, 120);

INSERT INTO Orders VALUES (1, 1, '2023-02-10', 112.50);
INSERT INTO Orders VALUES (2, 2, '2023-05-14', 899.99);
INSERT INTO Orders VALUES (3, 3, '2023-07-01', 50.00);
INSERT INTO Orders VALUES (4, 4, '2024-01-20', 1149.99);
INSERT INTO Orders VALUES (5, 5, '2023-09-09', 40.00);
INSERT INTO Orders VALUES (6, 6, '2024-03-15', 1799.98);
INSERT INTO Orders VALUES (7, 1, '2024-06-30', 55.00);
INSERT INTO Orders VALUES (8, 4, '2023-11-11', 45.00);

INSERT INTO OrderItems VALUES (1, 1, 2, 2, 45.00);
INSERT INTO OrderItems VALUES (2, 1, 5, 1, 22.50);
INSERT INTO OrderItems VALUES (3, 2, 1, 1, 899.99);
INSERT INTO OrderItems VALUES (4, 3, 3, 2, 25.00);
INSERT INTO OrderItems VALUES (5, 4, 1, 1, 899.99);
INSERT INTO OrderItems VALUES (6, 4, 7, 1, 250.00);
INSERT INTO OrderItems VALUES (7, 5, 8, 5, 8.00);
INSERT INTO OrderItems VALUES (8, 6, 1, 2, 899.99);
INSERT INTO OrderItems VALUES (9, 7, 3, 1, 25.00);
INSERT INTO OrderItems VALUES (10, 7, 6, 2, 15.00);
INSERT INTO OrderItems VALUES (11, 8, 2, 1, 45.00);

SELECT Orders.OrderID, Orders.OrderDate,
       Orders.TotalAmount / SUM(OrderItems.Quantity) AS AverageItemPrice
FROM Orders
JOIN OrderItems ON Orders.OrderID = OrderItems.OrderID
GROUP BY Orders.OrderID, Orders.OrderDate, Orders.TotalAmount;

SELECT * FROM Products
WHERE UnitPrice BETWEEN 20 AND 50
  AND UnitsInStock > (SELECT AVG(UnitsInStock) FROM Products);

SELECT * FROM Customers
WHERE (City = 'New York' OR LoyaltyScore > 80)
  AND LastName LIKE 'S%';

SELECT CustomerID,
       CONCAT(FirstName, ' ', LastName) AS FullName,
       CONCAT(LEFT(City, 3), '***') AS MaskedCity
FROM Customers;

SELECT ProductID FROM OrderItems
UNION
SELECT ProductID FROM Products WHERE UnitsInStock = 0;

SELECT * FROM Orders
WHERE YEAR(OrderDate) = 2023
  AND CustomerID NOT IN (SELECT CustomerID FROM Customers WHERE LoyaltyScore < 50);

SELECT OrderID, TotalAmount
FROM Orders
WHERE TotalAmount BETWEEN
      (SELECT MIN(TotalAmount)
       FROM (SELECT TotalAmount,
                    PERCENT_RANK() OVER (ORDER BY TotalAmount) AS pr
             FROM Orders) AS ranked
       WHERE pr >= 0.9)
  AND (SELECT MAX(TotalAmount) FROM Orders);

SELECT CustomerID, FirstName
FROM Customers
WHERE EXISTS (
    SELECT 1
    FROM Orders
    JOIN OrderItems ON Orders.OrderID = OrderItems.OrderID
    JOIN Products ON OrderItems.ProductID = Products.ProductID
    WHERE Orders.CustomerID = Customers.CustomerID
      AND Products.Category = 'Electronics'
);

SELECT ProductID, ProductName,
       UnitPrice > ALL (SELECT UnitPrice FROM Products WHERE Category = 'Books') AS CostlierThanAllBooks
FROM Products;

SELECT OrderID, TotalAmount,
       CASE
           WHEN TotalAmount > 1000 THEN 'High'
           WHEN TotalAmount BETWEEN 500 AND 1000 THEN 'Medium'
           ELSE 'Low'
       END AS OrderStatus
FROM Orders;