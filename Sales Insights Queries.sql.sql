
SALES INSIGHTS QUERIES.sql

-- -------------------------------------------------------
-- SQL Insight Queries for Power BI Dashboard
-- Project: Global Superstore Sales Analysis
-- Author: Aarthi V.
-- Description: KPIs, Trends, and Business Insights
-- Date: 2025
-- -------------------------------------------------------


-- KPIs
-- TOTAL SALES
SELECT concat(round(sum(sales)/1000,2),'M') AS TOTAL_SALES from fact_orders;

-- TOTAL PROFIT
SELECT concat(round(sum(profit)/1000000,2),'M') AS total_profit from fact_orders;

-- TOTAL ORDERS
SELECT count(order_id) from fact_orders;

-- TOTAL CUSTOMERS
SELECT count(customer_id) from dim_customers;


-- RETURN RATE
SELECT 
     count(distinct r.order_id) AS returned_order,
     count(distinct o.order_id) AS total_order,
     round(count(distinct r.order_id) *100.0/count(distinct o.order_id),2) AS return_rate
FROM fact_orders o
LEFT JOIN RETURNS r ON o.order_id = r.order_id;     

-- Trends& business insights

-- profit by region

SELECT g.region,
       concat(round(sum(o.profit)/1000,1),'k') AS total_profit
FROM fact_orders o
JOIN dim_geography g ON g.geography_id = o.geography_id
GROUP BY g.region; 


-- sales by category and sub_category

SELECT 
     p.category,p.sub_category,
     concat(round(sum(o.sales)/100000,2),'M') AS total_sales
FROM fact_orders o
JOIN dim_products p
ON p.product_id=o.product_id
GROUP BY p.category, p.sub_category;

-- sale by country

SELECT
     g.country,
     concat(round(sum(o.sales)/1000,1),'k') AS total_sales
FROM fact_orders o
JOIN dim_geography g
ON g.geography_id= o.geography_id
GROUP BY g.country
order by total_sales desc
limit 10;

-- return_rate by market

SELECT g.market,
       count(distinct r.order_id) AS returned_orders,
       count(distinct o.order_id) AS total_orders,
       ROUND(count(distinct r.order_id)*100.0 /count(distinct o.order_id),2) AS Return_rate_percent
FROM fact_orders o
join dim_geography g ON o.geography_id=g.geography_id
LEFT JOIN returns r ON o.order_id=r.order_id
GROUP BY g.market;

-- sales trend over time

SELECT
  MONTH(order_date) AS month_number,
  MONTHNAME(order_date) AS month,
  SUM(sales) AS total_sales
FROM fact_orders
GROUP BY MONTH(order_date), MONTHNAME(order_date)
ORDER BY month_number;

-- top 10 products by sales

SELECT P.product_name,
	   ROUND(sum(o.sales)/1000,2) as total_sales
FROM orders o
JOIN dim_products p
ON p.product_id = o.product_id
GROUP BY p.product_name
order by total_sales DESC
LIMIT 10;

-- sales by segment 
SELECT c.segment,
	  sum(o.sales) AS total_sales
FROM fact_orders o
JOIN dim_customers c 
ON o.customer_id = c.customer_id
GROUP BY c.segment;

-- sales by ship_mode
SELECT ship_mode,
       sum(sales) AS total_sales
FROM fact_orders
GROUP BY ship_mode;

-- average discount vs profit trend

SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month_year,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(discount), 4) AS avg_discount
FROM fact_orders
GROUP BY month_year
ORDER BY month_year;
   

-- top 5 salesperson over the region

SELECT 
    p.person,
    g.region,
    sum(o.sales) AS total_sales
FROM fact_orders o
JOIN dim_geography g ON g.geography_id = o.geography_id
JOIN people p ON p.region=g.region
GROUP BY p.person,g.region    
ORDER BY total_sales desc
LIMIT 5;
