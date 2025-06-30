
DATA PREPARATION AND MODELING

-- SQL script for table creation, data import, and star schema modeling
-- Project: Global Superstore Sales Dashboard
-- Author: Aarthi V.
-- Date: 2025

-- ----------------------------------------
-- STEP 1: Create Raw Orders Table
-- ----------------------------------------
CREATE TABLE orders(
  row_id INT PRIMARY KEY,
  order_id VARCHAR(50),
  order_date DATE,
  ship_date DATE,
  ship_mode VARCHAR(50),
  customer_id VARCHAR(50),
  customer_name VARCHAR(100),
  segment VARCHAR(50),
  city VARCHAR(100),
  state VARCHAR(100),
  country VARCHAR(100),
  market VARCHAR(50),
  region VARCHAR(50),
  product_id VARCHAR(50),
  category VARCHAR(100),
  sub_category VARCHAR(100),
  product_name VARCHAR(255),
  sales DECIMAL(10,2),
  quantity INT,
  discount DECIMAL(5,4),
  profit DECIMAL(10,2),
  shipping_cost DECIMAL(10,2),
  order_priority VARCHAR(50)
);

-- ----------------------------------------
-- STEP 2: Import Data
-- ----------------------------------------

LOAD DATA INFILE 'order_cleaned.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(row_id, order_id, order_date, ship_date, ship_mode,
 customer_id, customer_name, segment, city, state, country,
 market, region, product_id, category, sub_category, product_name,
 sales, quantity, discount, profit, shipping_cost, order_priority);

-- ----------------------------------------
-- STEP 3: Create Dimension Tables
-- ----------------------------------------
CREATE TABLE Dim_products(
product_id VARCHAR(100) PRIMARY KEY,
product_name VARCHAR(255),
category VARCHAR (200),
sub_category VARCHAR(200)
);

INSERT INTO dim_products(product_id,product_name,category,sub_category)
SELECT product_id,
	MAX(product_name),
    MAX(category),
    MAX(sub_category)
from orders
GROUP BY product_id;


CREATE TABLE Dim_customers(
customer_id varchar(100)  PRIMARY KEY,
customer_name varchar(100),
segment VARCHAR(100)
);

INSERT INTO Dim_customers(customer_id,customer_name,segment)
SELECT DISTINCT customer_id,customer_name,segment
from orders;

-- for duplicate check
SELECT customer_id,count(*)
FROM dim_customers
GROUP BY customer_id
HAVING count(*)>1;

CREATE TABLE Dim_geography(
geography_id INT AUTO_INCREMENT PRIMARY KEY,
city VARCHAR(100),
state VARCHAR(100),
country VARCHAR(100),
region VARCHAR(100),
market VARCHAR(100)
);

INSERT INTO dim_geography(city,state,country,region,market)
SELECT DISTINCT city,state,country,region,market
FROM orders;

ALTER TABLE orders ADD COLUMN geography_id INT;

ALTER TABLE dim_geography 
ADD INDEX idx_geo (city, state, country, region, market);

UPDATE orders o
JOIN dim_geography g
  ON o.city = g.city 
     AND o.state = g.state 
     AND o.country = g.country 
     AND o.region = g.region 
     AND o.market = g.market
SET o.geography_id = g.geography_id
where o.geography_id is NULL;

-- ----------------------------------------
-- STEP 4: Create Fact Table
-- ----------------------------------------
CREATE TABLE fact_orders(
row_id INT PRIMARY KEY,
order_id VARCHAR(100),
order_date DATE,
ship_date DATE,
ship_mode VARCHAR(100),
customer_id VARCHAR(100),
product_id VARCHAR(100),
geography_id INT,
sales DECIMAL(10,2),
quantity INT,
discount DECIMAL(5,4),
profit DECIMAL(10,2),
shipping_cost DECIMAL(10,2),
order_priority VARCHAR(100),

FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id),
FOREIGN KEY (product_id) REFERENCES dim_products(product_id),
FOREIGN KEY (geography_id) REFERENCES dim_geography(geography_id)
);

 
INSERT INTO fact_orders          (row_id,order_id,order_date,ship_date,ship_mode,customer_id,product_id,geography_id,
	  sales,quantity,discount,profit,shipping_cost,order_priority)
SELECT DISTINCT                        row_id,order_id,order_date,ship_date,ship_mode,customer_id,product_id,geography_id,
         sales,quantity,discount,profit,shipping_cost,order_priority
FROM orders;

-- ----------------------------------------
-- Import table Returns,people
-- ----------------------------------------
CREATE TABLE Returns(
 order_id VARCHAR(100) PRIMARY KEY,
 returned VARCHAR(50)
 );

LOAD DATA INFILE 'Returns.csv'
INTO TABLE Returns
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_id,returned);

CREATE TABLE People(
person VARCHAR(100) PRIMARY KEY,
region VARCHAR(100)
);

LOAD DATA INFILE 'people.csv'
INTO TABLE people
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(person,region);

-- ----------------------------------------
-- END OF SCRIPT
-- ----------------------------------------

