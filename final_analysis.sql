---Sales & Revenue Analysis
--1What are the total sales and profit for each year?
select  EXTRACT(YEAR FROM order_date) AS year
,sum(sales) as sales_year,sum(profit) as profit_year
from customer
group by year order by sales_year desc;
--2 Which month generates the highest revenue on average?
select EXTRACT(MONTH FROM order_date) as month,avg(sales) as avg_sales
from customer
group by EXTRACT(MONTH FROM order_date) 
order by avg(sales)
Limit  1;
--3 What is the month-over-month sales growth rate?
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales) AS total_sales
    FROM customer
    GROUP BY DATE_TRUNC('month', order_date)
)

SELECT
    month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY month) AS previous_month_sales,
    ROUND(
        (
            (total_sales - LAG(total_sales) OVER (ORDER BY month))
            / LAG(total_sales) OVER (ORDER BY month) * 100
        )::numeric,
        2
    ) AS growth_rate_percent
FROM monthly_sales
ORDER BY month;

--4 Which top 10 products contribute the most to total revenue?
select product_name,
sum(sales) as  total_revenue from customer
group by product_name
order by total_revenue desc
limit 10;

--5 What is the average order value per segment?
WITH order_values AS (
    SELECT
        order_id,
        segment,
        SUM(sales) AS order_value
    FROM customer
    GROUP BY order_id, segment
)

SELECT
    segment,
    ROUND(AVG(order_value)::numeric, 2) AS avg_order_value
FROM order_values
GROUP BY segment;
--Customer Analysis

--1Who are the top 10 customers by total purchase value?
select customer_name,sum(sales)
from customer
group by customer_name
order by sum(sales) desc
Limit 10;
--How many unique customers placed orders each year?
select Distinct customer_name,EXTRACT(YEAR FROM order_date) AS year ,
count(order_id) as order 
from customer
group by Distinct customer_name,EXTRACT(YEAR FROM order_date)
;

--3 Which customer segment (Consumer, Corporate, Home Office) is most profitable?
select segment , sum(profit) as profit  
from customer
group by segment
order by profit desc
limit 1;
--4 What is the average number of orders per customer?
SELECT
    AVG(order_count) AS avg_orders_per_customer
FROM (
    SELECT
        customer_name,
        COUNT(DISTINCT order_id) AS order_count
    FROM customer
    GROUP BY customer_name
) t;
--5 Which customers have placed only a single order (one-time buyers)
SELECT
    customer_name
FROM customer
GROUP BY customer_name
HAVING COUNT(DISTINCT order_id) = 1;

--Regional & Geographic Analysis
--1Which region generates the highest profit margin?
select region,sum(profit) 
from customer group by region
order by sum(profit) desc
limit 1;

--2 What are the top 5 cities by total sales?
select city,sum(sales) 
from customer group by city
order by sum(sales) desc
limit 5;



--3 Which state has the highest number of orders but lowest profit?
select state,sum(profit) as profit
,count(profit) as number_of_order
from customer group by state 
order by profit ,number_of_order desc
Limit 5;

--4 How does sales performance vary across regions over the years?
SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    region,
    SUM(sales) AS total_sales,
    RANK() OVER (
        PARTITION BY EXTRACT(YEAR FROM order_date)
        ORDER BY SUM(sales) DESC
    ) AS sales_rank
FROM customer
GROUP BY EXTRACT(YEAR FROM order_date), region;

--Shipping Analysis
--1 Which ship mode is used most frequently per segment?
WITH ship_counts AS (
    SELECT
        segment,
        ship_mode,
        COUNT(*) AS usage_count,
        RANK() OVER (
            PARTITION BY segment
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM customer
    GROUP BY segment, ship_mode
)

SELECT
    segment,
    ship_mode,
    usage_count
FROM ship_counts
WHERE rnk = 1;
--2 What is the average shipping delay (order date to ship date) per ship mode?
SELECT
    ship_mode,
    AVG(ship_date - order_date) AS avg_shipping_delay_days
FROM customer
GROUP BY ship_mode;
--3 Does a longer shipping time correlate with lower customer re-orders?
ans-- is yes 
WITH customer_stats AS (
    SELECT
        customer_name,
        AVG(ship_date - order_date) AS avg_shipping_delay,
        COUNT(DISTINCT order_id) AS total_orders
    FROM customer
    GROUP BY customer_name
)

SELECT *
FROM customer_stats
ORDER BY avg_shipping_delay desc,total_orders;
--4 Which ship mode has the highest associated profit?
select ship_mode,sum(profit) as profit from customer 
group by ship_mode
order by profit desc
limit 1;

-- Product & Category Analysis

-- Which category has the highest discount rate on average?
select  category,sum(discount) as discount 
from customer 
group by category
order by discount desc
limit 1
-- What are the top 3 sub-categories by quantity sold?

-- Which products are sold at a loss (negative profit)?
SELECT
    product_name,
    SUM(profit) AS total_profit
FROM customer
GROUP BY product_name
HAVING SUM(profit) < 0
ORDER BY total_profit;
-- Is there a correlation between discount and profit across categories?
SELECT
    category,
    CORR(discount, profit) AS discount_profit_correlation
FROM customer
GROUP BY category;
-- Which product has the highest price but lowest quantity sold?
SELECT
    product_name,
    ROUND((SUM(sales) / SUM(quantity))::numeric, 2) AS avg_unit_price,
    SUM(quantity) AS total_quantity_sold
FROM customer
GROUP BY product_name
ORDER BY avg_unit_price DESC, total_quantity_sold ASC
LIMIT 1;

--  Profitability & Discount Analysis

--1 What is the profit margin per category?
SELECT
    category,
    ROUND(
        (SUM(profit) / SUM(sales) * 100)::numeric,
        2
    ) AS profit_margin_percent
FROM customer
GROUP BY category
ORDER BY profit_margin_percent DESC;
--2 Which orders have a discount greater than 30% — are they profitable?
SELECT
    order_id,
    product_name,
    sales,
    discount,
    profit,
    CASE
        WHEN profit > 0 THEN 'Profitable'
        WHEN profit < 0 THEN 'Loss'
        ELSE 'Break-even'
    END AS profit_status
FROM customer
WHERE discount > 0.30
ORDER BY discount DESC;
--3 What discount threshold starts causing negative profit?
SELECT
    discount,
    ROUND(AVG(profit)::numeric, 2) AS avg_profit
FROM customer
GROUP BY discount
ORDER BY discount;
--4 Which region offers the highest average discount?
SELECT
    region,
    ROUND(AVG(discount)::numeric, 3) AS avg_discount
FROM customer
GROUP BY region
ORDER BY avg_discount DESC;

