create Database supermarket;
use supermarket;

CREATE TABLE sales (
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    city VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(150),
    sales FLOAT,
    quantity INT,
    discount FLOAT,
    profit FLOAT
);

select * from sales;
SHOW COLUMNS FROM sales;
ALTER TABLE sales 
RENAME COLUMN `Product line` TO product_line,
RENAME COLUMN `Invoice ID` TO invoice_id,
RENAME COLUMN `Customer type` TO customer_type,
RENAME COLUMN `Unit price` TO unit_price,
RENAME COLUMN `Tax 5%` TO tax_5_percent,
RENAME COLUMN `gross margin percentage` TO gross_margin_percentage,
RENAME COLUMN `gross income` TO gross_income;

select * from sales;
-- SALES PERFORMANCE
-- 1.Which product lines generate the highest revenue and sales volume?
SELECT 
    product_line,
    ROUND(SUM(sales), 2) AS total_sales,
    SUM(quantity) AS total_units_sold
FROM sales
GROUP BY product_line
ORDER BY total_sales DESC;
 
 -- insight - “Food and Beverages generate the highest revenue and sales volume, indicating strong customer demand. 
 -- This category should be prioritized for inventory and promotional strategies.”
 
 -- 2.At what time of day (morning, afternoon, evening) do sales peak?
SELECT 
    CASE 
        WHEN TIME(Time) BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
        WHEN TIME(Time) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day,
    round(SUM(Sales) )AS total_sales
FROM sales
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- insight - “Sales peak during the evening hours, indicating higher customer activity after working hours. 
-- The business should increase staffing, ensure product availability.

-- 3.Which days/months show the highest sales trends?
SELECT 
    MONTHNAME(STR_TO_DATE(Date, '%m/%d/%Y')) AS month,
    ROUND(SUM(Sales), 2) AS total_sales
FROM sales
GROUP BY month
ORDER BY total_sales DESC;

-- insight - “January records the highest sales, suggesting increased consumer spending at the start of the year.
--  Businesses can capitalize on this trend by strengthening inventory and promotional campaigns during this period.”

select * from sales;
-- 👥 CUSTOMER BEHAVIOR
-- 4.Which customer type (Member vs Normal) contributes more to total sales?
select customer_type ,
			round(sum(sales),2) as total_sales
from sales
group by customer_type 
order by total_sales desc;
-- “Member customers contribute significantly more to total sales compared to normal customers,
--  indicating that loyalty programs are effective in driving higher revenue.”

-- 5.Is there a difference in spending behavior between male and female customers?
SELECT 
    gender,
    ROUND(AVG(Sales), 2) AS avg_spending
FROM sales
GROUP BY gender
ORDER BY avg_spending DESC;
-- insights - average spending of females are more than males

-- 6.. Which customer segment gives higher average transaction value?
SELECT DISTINCT
    customer_type,
    ROUND(AVG(Sales) OVER (PARTITION BY customer_type), 2) AS avg_transaction_value
FROM sales
ORDER BY avg_transaction_value DESC;
-- “Female customers have a higher average transaction value than male customers, indicating stronger per-purchase spending behavior.”

-- PAYMENT ANALYSIS
-- 7. Which payment method is most preferred by customers?
select payment as payment_method ,count(*) as total_used
from sales
group by payment;
-- Payment usage is nearly evenly distributed, with a slight preference for E-wallet, indicating no strong customer bias toward any single method.

-- 8. Does payment method influence purchase amount?
select payment as payment_method ,round(avg(sales),2) as avg_sales
from sales
group by payment
order by avg_sales desc;
-- Average purchase value is nearly similar across payment methods, indicating that payment choice has minimal influence on spending behavior.”

-- CUSTOMER SATISFACTION
-- 9.Which product lines have the highest and lowest customer ratings?
select product_line ,round(avg(rating),2) as avg_rating
from sales
group by product_line
order by avg_rating desc;
-- Food and Beverages have the highest ratings, while Home and Lifestyle ranks lowest, indicating slight variation in customer satisfaction across product lines.

-- 10.Is there any relationship between sales amount and customer rating?
SELECT 
    CASE 
        WHEN Rating <= 4 THEN 'Low Rating'
        WHEN Rating <= 7 THEN 'Medium Rating'
        ELSE 'High Rating'
    END AS rating_category,
    ROUND(AVG(Sales), 2) AS avg_sales
FROM sales
GROUP BY rating_category;
-- Higher spending does not lead to higher ratings, indicating that purchase value does not directly influence customer satisfaction.”


-- 11.Which combination of product line + customer type generates the highest revenue?
SELECT 
    product_line,
    customer_type,
    ROUND(SUM(Sales), 2) AS total_sales,
    RANK() OVER (ORDER BY SUM(Sales) DESC) AS ranking
FROM sales
GROUP BY product_line, customer_type;
-- Revenue is dominated by member customers across all product lines, with Food and Beverages leading, indicating loyalty-driven sales

-- 12.What is the average basket size (quantity per transaction), and how does it vary across product lines?
SELECT 
    ROUND(AVG(total_qty), 2) AS avg_basket_size
FROM (
    SELECT 
        invoice_id,
        SUM(Quantity) AS total_qty
    FROM sales
    GROUP BY invoice_id
) t;
-- “The average basket size is 5.51 items per transaction, indicating customers typically purchase multiple items per visit.”