

-- Create schemas
CREATE SCHEMA hq_db;
CREATE SCHEMA sales_db;
CREATE SCHEMA dw_schema;


-- Create HQ tables
CREATE TABLE hq_db.Customer (
    Customer_id INT PRIMARY KEY,
    Customer_name VARCHAR(100),
    City_id INT,
    First_order_date DATE
);

CREATE TABLE hq_db.Walk_in_customers (
    Customer_id INT REFERENCES hq_db.Customer(Customer_id),
    tourism_guide VARCHAR(100),
    event_time TIMESTAMP
);

CREATE TABLE hq_db.Mail_order_customers (
    Customer_id INT REFERENCES hq_db.Customer(Customer_id),
    post_address TEXT,
    event_time TIMESTAMP
);


-- Create sales tables
CREATE TABLE sales_db.Headquarters (
    City_id INT PRIMARY KEY,
    City_name VARCHAR(50),
    Headquarter_addr TEXT,
    State VARCHAR(50),
    event_time TIMESTAMP
);

CREATE TABLE sales_db.Stores (
    Store_id INT PRIMARY KEY,
    City_id INT REFERENCES sales_db.Headquarters(City_id),
    Phone VARCHAR(15),
    event_time TIMESTAMP
);

CREATE TABLE sales_db.Items (
    Item_id INT PRIMARY KEY,
    Description TEXT,
    Size VARCHAR(20),
    Weight DECIMAL,
    Unit_price DECIMAL,
    event_time TIMESTAMP
);

CREATE TABLE sales_db.Stored_items (
    Store_id INT REFERENCES sales_db.Stores(Store_id),
    Item_id INT REFERENCES sales_db.Items(Item_id),
    Quantity_held INT,
    event_time TIMESTAMP
);

CREATE TABLE sales_db.Orders (
    Order_no INT PRIMARY KEY,
    Order_date DATE,
    Customer_id INT
);

CREATE TABLE sales_db.Ordered_item (
    Order_no INT REFERENCES sales_db.Orders(Order_no),
    Item_id INT REFERENCES sales_db.Items(Item_id),
    Quantity_ordered INT,
    Ordered_price DECIMAL,
    event_time TIMESTAMP
);


-- Insert headquarters
INSERT INTO sales_db.Headquarters VALUES
(1,'Ratnagiri','Maruti Mandir Road','Maharashtra',NOW()),
(2,'Baramati','Bhigwan Road','Maharashtra',NOW()),
(3,'Satara','Powai Naka','Maharashtra',NOW()),
(4,'Sindhudurg','Kudal Main Road','Maharashtra',NOW());


-- Insert customers
INSERT INTO hq_db.Customer VALUES
(101,'Mrudula',1,'2025-10-10'),
(102,'Aditya',2,'2025-11-12'),
(103,'Namrata',3,'2026-01-05'),
(104,'Rakesh',4,'2026-02-20'),
(105,'Sneha',1,'2026-02-15'),
(106,'Amit',2,'2026-02-18');


-- Insert customer types
INSERT INTO hq_db.Walk_in_customers VALUES
(101,'Guide_Konkan',NOW()),
(103,'Guide_Satara',NOW()),
(105,'Guide_Ratnagiri',NOW());

INSERT INTO hq_db.Mail_order_customers VALUES
(101,'Ratnagiri PO',NOW()),
(102,'Baramati Apt',NOW()),
(104,'Malvan House',NOW()),
(106,'Pune Road',NOW());


-- Insert items
INSERT INTO sales_db.Items VALUES
(501,'Smartphone','Small',0.2,15000,NOW()),
(502,'Laptop','Medium',2.0,60000,NOW()),
(503,'Tablet','Medium',0.5,20000,NOW()),
(504,'Headphones','Small',0.3,3000,NOW());


-- Insert stores
INSERT INTO sales_db.Stores VALUES
(901,1,'02352-222111',NOW()),
(902,2,'02112-555111',NOW()),
(903,3,'02162-444333',NOW()),
(904,4,'02362-333222',NOW());


-- Insert stored items
INSERT INTO sales_db.Stored_items VALUES
(901,501,50,NOW()),
(901,504,80,NOW()),
(902,502,20,NOW()),
(903,503,40,NOW()),
(904,501,30,NOW()),
(904,502,15,NOW());


-- Insert orders
INSERT INTO sales_db.Orders VALUES
(10001,'2026-03-01',101),
(10002,'2026-03-02',102),
(10003,'2026-03-03',103),
(10004,'2026-03-04',104),
(10005,'2026-03-05',105),
(10006,'2026-03-06',106);


-- Insert ordered items
INSERT INTO sales_db.Ordered_item VALUES
(10001,501,1,15000,NOW()),
(10002,502,1,60000,NOW()),
(10003,503,2,20000,NOW()),
(10004,504,3,3000,NOW()),
(10005,501,1,15000,NOW()),
(10006,502,1,60000,NOW());


-- Create warehouse dimension tables
CREATE TABLE dw_schema.Dim_Customer (
    Customer_SK SERIAL PRIMARY KEY,
    Customer_id INT,
    Customer_name VARCHAR(100),
    City_name VARCHAR(50),
    Customer_Type VARCHAR(20)
);

CREATE TABLE dw_schema.Dim_Store (
    Store_SK SERIAL PRIMARY KEY,
    Store_id INT,
    City_name VARCHAR(50),
    State VARCHAR(50),
    Phone VARCHAR(15),
    HQ_Address TEXT
);

CREATE TABLE dw_schema.Dim_Item (
    Item_SK SERIAL PRIMARY KEY,
    Item_id INT,
    Description TEXT,
    Size VARCHAR(20),
    Weight DECIMAL,
    Unit_price DECIMAL
);

CREATE TABLE dw_schema.Fact_Orders (
    Fact_ID SERIAL PRIMARY KEY,
    Order_no INT,
    Order_date DATE,
    Customer_SK INT,
    Store_SK INT,
    Item_SK INT,
    Qty_Ordered INT,
    Qty_In_Stock INT
);


-- Load Dim_Customer
INSERT INTO dw_schema.Dim_Customer
(Customer_id,Customer_name,City_name,Customer_Type)

SELECT c.Customer_id,c.Customer_name,h.City_name,
CASE
WHEN w.Customer_id IS NOT NULL AND m.Customer_id IS NOT NULL THEN 'Dual'
WHEN w.Customer_id IS NOT NULL THEN 'Walk-in'
ELSE 'Mail-order'
END

FROM hq_db.Customer c
JOIN sales_db.Headquarters h ON c.City_id=h.City_id
LEFT JOIN hq_db.Walk_in_customers w ON c.Customer_id=w.Customer_id
LEFT JOIN hq_db.Mail_order_customers m ON c.Customer_id=m.Customer_id;


-- Load Dim_Store
INSERT INTO dw_schema.Dim_Store
(Store_id,City_name,State,Phone,HQ_Address)

SELECT s.Store_id,h.City_name,h.State,s.Phone,h.Headquarter_addr
FROM sales_db.Stores s
JOIN sales_db.Headquarters h ON s.City_id=h.City_id;


-- Load Dim_Item
INSERT INTO dw_schema.Dim_Item
(Item_id,Description,Size,Weight,Unit_price)

SELECT Item_id,Description,Size,Weight,Unit_price
FROM sales_db.Items;


-- Load Fact Table
INSERT INTO dw_schema.Fact_Orders
(Order_no,Order_date,Customer_SK,Store_SK,Item_SK,Qty_Ordered,Qty_In_Stock)

SELECT o.Order_no,o.Order_date,
dc.Customer_SK,
ds.Store_SK,
di.Item_SK,
oi.Quantity_ordered,
si.Quantity_held

FROM sales_db.Orders o
JOIN sales_db.Ordered_item oi ON o.Order_no=oi.Order_no
JOIN dw_schema.Dim_Customer dc ON o.Customer_id=dc.Customer_id
JOIN dw_schema.Dim_Item di ON oi.Item_id=di.Item_id
JOIN sales_db.Stored_items si ON di.Item_id=si.Item_id
JOIN dw_schema.Dim_Store ds ON si.Store_id=ds.Store_id;


-- Query 1
SELECT s.Store_id,h.City_name,h.State,s.Phone,
i.Description,i.Size,i.Weight,i.Unit_price
FROM sales_db.Stored_items si
JOIN sales_db.Stores s ON si.Store_id=s.Store_id
JOIN sales_db.Headquarters h ON s.City_id=h.City_id
JOIN sales_db.Items i ON si.Item_id=i.Item_id
WHERE i.Description='Smartphone';


-- Query 2
SELECT DISTINCT o.Order_no,c.Customer_name,o.Order_date
FROM sales_db.Orders o
JOIN sales_db.Ordered_item oi ON o.Order_no=oi.Order_no
JOIN sales_db.Stored_items si ON oi.Item_id=si.Item_id
JOIN sales_db.Stores s ON si.Store_id=s.Store_id
JOIN hq_db.Customer c ON o.Customer_id=c.Customer_id
WHERE s.Store_id=901;


-- Query 3
SELECT DISTINCT s.Store_id,h.City_name,s.Phone
FROM hq_db.Customer c
JOIN sales_db.Orders o ON c.Customer_id=o.Customer_id
JOIN sales_db.Ordered_item oi ON o.Order_no=oi.Order_no
JOIN sales_db.Stored_items si ON oi.Item_id=si.Item_id
JOIN sales_db.Stores s ON si.Store_id=s.Store_id
JOIN sales_db.Headquarters h ON s.City_id=h.City_id
WHERE c.Customer_name='Mrudula';


-- Query 4
SELECT DISTINCT h.Headquarter_addr,h.City_name,h.State
FROM sales_db.Stored_items si
JOIN sales_db.Stores s ON si.Store_id=s.Store_id
JOIN sales_db.Headquarters h ON s.City_id=h.City_id
WHERE si.Quantity_held>10;


-- Query 5
SELECT o.Order_no,i.Description,s.Store_id,h.City_name
FROM sales_db.Orders o
JOIN sales_db.Ordered_item oi ON o.Order_no=oi.Order_no
JOIN sales_db.Items i ON oi.Item_id=i.Item_id
JOIN sales_db.Stored_items si ON i.Item_id=si.Item_id
JOIN sales_db.Stores s ON si.Store_id=s.Store_id
JOIN sales_db.Headquarters h ON s.City_id=h.City_id;


-- Query 6
SELECT c.Customer_name,h.City_name,h.State
FROM hq_db.Customer c
JOIN sales_db.Headquarters h ON c.City_id=h.City_id
WHERE c.Customer_name='Aditya';


-- Query 7
SELECT s.Store_id,h.City_name,i.Description,si.Quantity_held
FROM sales_db.Stored_items si
JOIN sales_db.Items i ON si.Item_id=i.Item_id
JOIN sales_db.Stores s ON si.Store_id=s.Store_id
JOIN sales_db.Headquarters h ON s.City_id=h.City_id
WHERE i.Description='Smartphone'
AND h.City_name='Ratnagiri';


-- Query 8
SELECT o.Order_no,i.Description,oi.Quantity_ordered,
c.Customer_name,s.Store_id,h.City_name
FROM sales_db.Orders o
JOIN hq_db.Customer c ON o.Customer_id=c.Customer_id
JOIN sales_db.Ordered_item oi ON o.Order_no=oi.Order_no
JOIN sales_db.Items i ON oi.Item_id=i.Item_id
JOIN sales_db.Stored_items si ON i.Item_id=si.Item_id
JOIN sales_db.Stores s ON si.Store_id=s.Store_id
JOIN sales_db.Headquarters h ON s.City_id=h.City_id;


-- Query 9
SELECT c.Customer_name,
CASE
WHEN w.Customer_id IS NOT NULL AND m.Customer_id IS NOT NULL THEN 'Dual'
WHEN w.Customer_id IS NOT NULL THEN 'Walk-in'
WHEN m.Customer_id IS NOT NULL THEN 'Mail-order'
END AS Customer_Type
FROM hq_db.Customer c
LEFT JOIN hq_db.Walk_in_customers w ON c.Customer_id=w.Customer_id
LEFT JOIN hq_db.Mail_order_customers m ON c.Customer_id=m.Customer_id;