
-- DIMENSION TABLES

CREATE TABLE DimProduct (
    ProductKey INT PRIMARY KEY,
    ProductAltKey VARCHAR(50),
    ProductName VARCHAR(100),
    ProductCost DECIMAL(10,2)
);

CREATE TABLE DimCustomer (
    CustomerID INT PRIMARY KEY,
    CustomerAltID VARCHAR(50),
    CustomerName VARCHAR(100),
    Gender VARCHAR(10)
);

CREATE TABLE DimStores (
    StoreID INT PRIMARY KEY,
    StoreAltID VARCHAR(50),
    StoreName VARCHAR(100),
    StoreLocation VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100)
);

CREATE TABLE DimSalesPerson (
    SalesPersonID INT PRIMARY KEY,
    SalesPersonAltID VARCHAR(50),
    SalesPersonName VARCHAR(100),
    StoreID INT,
    City VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100)
);

CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,
    Date DATE,
    DayName VARCHAR(20),
    Month INT,
    MonthName VARCHAR(20),
    Quarter INT,
    Year INT,
    WeekOfYear INT,
    IsWeekday BOOLEAN
);

CREATE TABLE DimTime (
    TimeKey INT PRIMARY KEY,
    HourNumber INT,
    DayTimeBucket VARCHAR(50)
);



-- FACT TABLE


CREATE TABLE FactProductSales (
    TransactionId INT PRIMARY KEY,
    SalesInvoiceNumber VARCHAR(50),

    SalesDateKey INT,
    SalesTimeKey INT,
    StoreID INT,
    CustomerID INT,
    ProductID INT,
    SalesPersonID INT,

    Quantity INT,
    TotalAmount DECIMAL(10,2),

    FOREIGN KEY (SalesDateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (SalesTimeKey) REFERENCES DimTime(TimeKey),
    FOREIGN KEY (StoreID) REFERENCES DimStores(StoreID),
    FOREIGN KEY (CustomerID) REFERENCES DimCustomer(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES DimProduct(ProductKey),
    FOREIGN KEY (SalesPersonID) REFERENCES DimSalesPerson(SalesPersonID)
);


--Insert data

INSERT INTO DimProduct VALUES
(1,'P01','High-End Laptop',42000),
(2,'P02','Android Smartphone',13000),
(3,'P03','Graphics Tablet',11000),
(4,'P04','Noise-Canceling Headphones',1800),
(5,'P05','Fitness Smartwatch',4500),
(6,'P06','27-inch LED Monitor',7500),
(7,'P07','Mechanical Keyboard',1200);

INSERT INTO DimStores VALUES
(1,'S01','X-Mart Central','Main Rd','Ratnagiri','Maharashtra','India'),
(2,'S02','X-Mart City Mall','MG Rd','Mumbai','Maharashtra','India'),
(3,'S03','X-Mart Square','Station Rd','Pune','Maharashtra','India'),
(4,'S04','X-Mart Plaza','Market St','Ratnagiri','Maharashtra','India'),
(5,'S05','X-Mart Business Hub','Link Rd','Mumbai','Maharashtra','India'),
(6,'S06','X-Mart Express','Airport Rd','Pune','Maharashtra','India'),
(7,'S07','X-Mart Prime Store','High St','Ratnagiri','Maharashtra','India');

INSERT INTO DimCustomer VALUES
(1,'C01','Nisha','Female'),
(2,'C02','Sahil','Male'),
(3,'C03','Nitya','Female'),
(4,'C04','Revan','Male'),
(5,'C05','Veena','Female'),
(6,'C06','Pihu','Female'),
(7,'C07','Shekhar','Male');

INSERT INTO DimSalesPerson VALUES
(1,'SP01','Rohan Mehra',1,'Ratnagiri','Maharashtra','India'),
(2,'SP02','Sana Khan',2,'Mumbai','Maharashtra','India'),
(3,'SP03','Vijay Patil',3,'Pune','Maharashtra','India'),
(4,'SP04','Anjali Rao',4,'Ratnagiri','Maharashtra','India'),
(5,'SP05','Deepak Joshi',5,'Mumbai','Maharashtra','India'),
(6,'SP06','Megha Shinde',6,'Pune','Maharashtra','India'),
(7,'SP07','Suresh Bhoir',7,'Ratnagiri','Maharashtra','India');

INSERT INTO DimDate VALUES
(20260301,'2026-03-01','Sunday',3,'March',1,2026,9,FALSE),
(20260302,'2026-03-02','Monday',3,'March',1,2026,9,TRUE),
(20260303,'2026-03-03','Tuesday',3,'March',1,2026,9,TRUE),
(20260304,'2026-03-04','Wednesday',3,'March',1,2026,9,TRUE),
(20260308,'2026-03-08','Sunday',3,'March',1,2026,10,FALSE),
(20260309,'2026-03-09','Monday',3,'March',1,2026,10,TRUE),
(20260310,'2026-03-10','Tuesday',3,'March',1,2026,10,TRUE),
(20260401,'2026-04-01','Wednesday',4,'April',2,2026,14,TRUE),
(20260402,'2026-04-02','Thursday',4,'April',2,2026,14,TRUE),
(20260403,'2026-04-03','Friday',4,'April',2,2026,14,TRUE),
(20260407,'2026-04-07','Tuesday',4,'April',2,2026,15,TRUE),
(20260408,'2026-04-08','Wednesday',4,'April',2,2026,15,TRUE);

INSERT INTO DimTime VALUES
(800,8,'Morning'),
(1000,10,'Morning'),
(1200,12,'Afternoon'),
(1400,14,'Afternoon'),
(1600,16,'Afternoon'),
(1800,18,'Evening'),
(2000,20,'Evening'),
(2200,22,'Night');

INSERT INTO FactProductSales VALUES
(1001,'INV-A1',20260301,1000,1,1,1,1,1,48000),
(1002,'INV-A2',20260302,1200,1,2,2,1,1,15000),
(1003,'INV-A3',20260303,1400,2,3,3,2,1,13500),
(1004,'INV-A4',20260304,1600,2,4,4,2,2,5000),
(1005,'INV-A5',20260308,1800,3,5,5,3,1,6200),
(1006,'INV-A6',20260309,2000,3,6,6,3,1,9000),
(1007,'INV-A7',20260310,1000,4,7,7,4,2,5000),
(1008,'INV-A8',20260401,1400,4,1,2,4,1,16000),
(1009,'INV-A9',20260402,1600,5,2,3,5,1,14000),
(1010,'INV-A10',20260403,1800,5,3,4,5,1,4500),
(1011,'INV-A11',20260407,800,6,4,5,6,1,6500),
(1012,'INV-A12',20260408,1000,6,5,6,6,1,9500);


--Analytical queries

-- 1 Daily / Weekly / Monthly Profit per Store
SELECT 
    s.StoreName,
    d.Date,
    SUM(f.TotalAmount) AS Total_Sales,
    SUM(f.TotalAmount - (p.ProductCost * f.Quantity)) AS Daily_Profit
FROM FactProductSales f
JOIN DimStores s ON f.StoreID = s.StoreID
JOIN DimProduct p ON f.ProductID = p.ProductKey
JOIN DimDate d ON f.SalesDateKey = d.DateKey
GROUP BY s.StoreName, d.Date
ORDER BY d.Date, s.StoreName;

SELECT 
    s.StoreName,
    d.Year,
    d.WeekOfYear,
    SUM(f.TotalAmount) AS Total_Sales,
    SUM(f.TotalAmount - (p.ProductCost * f.Quantity)) AS Weekly_Profit
FROM FactProductSales f
JOIN DimStores s ON f.StoreID = s.StoreID
JOIN DimProduct p ON f.ProductID = p.ProductKey
JOIN DimDate d ON f.SalesDateKey = d.DateKey
GROUP BY s.StoreName, d.Year, d.WeekOfYear
ORDER BY d.Year, d.WeekOfYear, s.StoreName;

SELECT 
    s.StoreName,
    d.Year,
    d.MonthName,
    SUM(f.TotalAmount) AS Total_Sales,
    SUM(f.TotalAmount - (p.ProductCost * f.Quantity)) AS Monthly_Profit
FROM FactProductSales f
JOIN DimStores s ON f.StoreID = s.StoreID
JOIN DimProduct p ON f.ProductID = p.ProductKey
JOIN DimDate d ON f.SalesDateKey = d.DateKey
GROUP BY s.StoreName, d.Year, d.MonthName
ORDER BY d.Year, d.MonthName, s.StoreName;

-- 2 Sales by Time Band
SELECT 
t.DayTimeBucket,
SUM(f.TotalAmount) AS Sales
FROM FactProductSales f
JOIN DimTime t ON f.SalesTimeKey=t.TimeKey
GROUP BY t.DayTimeBucket
ORDER BY Sales DESC;

-- 3 Product Demand by Location
SELECT 
s.StoreName,
p.ProductName,
SUM(f.Quantity) AS UnitsSold
FROM FactProductSales f
JOIN DimStores s ON f.StoreID=s.StoreID
JOIN DimProduct p ON f.ProductID=p.ProductKey
GROUP BY s.StoreName,p.ProductName
ORDER BY UnitsSold DESC;


-- 4 Sales by Day of Week
SELECT 
d.DayName,
SUM(f.TotalAmount) AS TotalSales
FROM FactProductSales f
JOIN DimDate d ON f.SalesDateKey=d.DateKey
GROUP BY d.DayName
ORDER BY TotalSales DESC;


-- 5 Sunday Sales and Profit
SELECT 
d.Date,
SUM(f.TotalAmount) AS Sales,
SUM(f.TotalAmount-(p.ProductCost*f.Quantity)) AS Profit
FROM FactProductSales f
JOIN DimDate d ON f.SalesDateKey=d.DateKey
JOIN DimProduct p ON f.ProductID=p.ProductKey
WHERE d.DayName='Sunday'
GROUP BY d.Date;


-- 6 Sales Growth KPI
SELECT 
d.Year,
d.Month,
d.MonthName,
SUM(f.TotalAmount) AS CurrentSales,
LAG(SUM(f.TotalAmount)) OVER(ORDER BY d.Year,d.Month) AS PreviousSales
FROM FactProductSales f
JOIN DimDate d ON f.SalesDateKey=d.DateKey
GROUP BY d.Year,d.Month,d.MonthName;