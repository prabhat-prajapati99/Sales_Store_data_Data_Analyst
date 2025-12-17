-- creating schema
create schema project;

use project;

-- createing table for data set

CREATE TABLE sales_store (
    transaction_id VARCHAR(15),
    customer_id VARCHAR(15),
    customer_name VARCHAR(30),
    customer_age INT,
    gender VARCHAR(15),
    product_id VARCHAR(15),
    product_name VARCHAR(15),
    product_category VARCHAR(15),
    qunity INT,
    prce FLOAT,
    payment_mode VARCHAR(15),
    purchase_date DATE,
    time_of_purchase TIME,
    status VARCHAR(15)
);

-- Loded data 

-- ***************************************************
-- Data Cleaning
------------------------------------------------------
-- Step 1 :- To chake for duplicate
SELECT 
    TRANSACTION_ID, COUNT(*)
FROM sales
GROUP BY TRANSACTION_ID
HAVING COUNT(TRANSACTION_ID) > 1;

-- this is duplicate values 
-- 'TXN240646' ,
-- 'TXN342128',
-- 'TXN855235',
-- 'TXN981773'

-- to show all data to duplicate
with cte as ( 
 select * ,
    ROW_NUMBER() over(partition by TRANSACTION_ID order by TRANSACTION_ID) as Row_num
from sales_store)

SELECT 
    *
FROM cte
WHERE
    TRANSACTION_ID IN ('TXN240646' , 'TXN342128', 'TXN855235', 'TXN981773'); 

-- Deleting duplicate values 
with cte as ( 
 select * ,
    ROW_NUMBER() over(partition by TRANSACTION_ID order by TRANSACTION_ID) as Row_num
from sales)

DELETE FROM cte 
WHERE
    Row_num = 2; 

---------------------------------------------------------
-- Step 2 -: Rename incorrect header
-- we have 2 header is incorrect
-- 1st is qunity
ALTER TABLE sales_store
RENAME COLUMN qunity to quantity;

-- 2nd is prce
ALTER TABLE sales_store
RENAME COLUMN prce to price;
------------------------------------------------------------
-- Step 3 -: to chake null values 
SELECT 
    *
FROM sales_store
WHERE
    transaction_id IS NULL
        OR customer_id IS NULL
        OR customer_name IS NULL
        OR customer_age IS NULL
        OR gender IS NULL
        OR product_id IS NULL
        OR product_name IS NULL
        OR product_category IS NULL
        OR quantity IS NULL
        OR price IS NULL
        OR payment_mode IS NULL
        OR purchase_date IS NULL
        OR time_of_purchase IS NULL
        OR status IS NULL;


-- here is an outlayer 
-- deleting outlayer
DELETE FROM sales_store 
WHERE
    transaction_id IS NULL;


-- replacing same name if customer in data set cust_id is avilable
SELECT 
    *
FROM sales_store
WHERE
    customer_name = 'Ehsaan Ram';-- cust_id is == CUST9494
-- filling cust_id
UPDATE sales_store 
SET 
    customer_id = 'CUST9494'
WHERE
    transaction_id = 'TXN977900'; 


-- filling null in Damini Raju customer feeld 
SELECT 
    *
FROM sales_store
WHERE
    customer_name = 'Damini Raju';-- cust_id is == CUST1401

-- Update it

UPDATE sales_store 
SET customer_id = 'CUST1401'
WHERE transaction_id = 'TXN985663'; 


-- now we are filling product info null
-- here we have cust_id and base on cust_id we filling cust_info null  - cust_id is --CUST1003
SELECT 
    *
FROM sales_store
WHERE customer_id = 'CUST1003';


UPDATE sales_store 
SET 
    customer_name = 'Mahika Saini',
    customer_age = 35,
    gender = 'Male'
WHERE
    transaction_id = 'TXN432798';

--------------------------------------------------------------------------------------
-- Step 4 :- cleaning gender column unique(M,Female,Male,M)
-- replacing male = M and Female = F
-- for male
UPDATE sales_store 
SET gender = 'M'
WHERE gender = 'Male';

-- for Female 
UPDATE sales_store 
SET gender = 'F'
WHERE gender = 'Female';



-- cleaning payment_mode column unique(UPI,Cash,EMI,Debit Card,CC,Credit Card)
-- changing cc to Credit Card
UPDATE sales_store 
SET payment_mode = 'Credit Card'
WHERE payment_mode = 'CC';


-- Completed data cleaning **********************************************

---------------------------------------------------------------------------
-- Data Analysis

-- Solving Business Insights Questions


-- Q1. - What are the top 5 most selling produers by quantity
SELECT 
    product_name, SUM(quantity) AS Total_quantity_sold
FROM sales_store
WHERE
    status = 'delivered'
GROUP BY product_name
ORDER BY Total_quantity_sold DESC
LIMIT 5;

-- Business Problem: We don't know which products are most in demand.
-- Business Impact: Helps prioritize stock and boost sales through targeted promotions.

------------------------------------------------------------------------------------------

-- Q2. - Which products are most frequently cancelled?
SELECT 
    product_name, COUNT(*) AS total_cancelled_order
FROM sales_store
WHERE
    status = 'cancelled'
GROUP BY product_name
ORDER BY total_cancelled_order DESC
LIMIT 5;

-- Business Problem: Frequent cancellations affect revenue and customer trust.
-- Butiness Impact: Identify poor-performing products to improve quality or remove from catalog

------------------------------------------------------------------------------------------------------------

-- Q3. What time of the day has the highest number of purchases?
with cte as ( 
select *,
	case 
		when HOUR(time_of_purchase) between 0 and 5 then 'NIGHT'
        when HOUR(time_of_purchase) between 6 and 11 then 'MORNING'
        when HOUR(time_of_purchase) between 12 and 17 then 'AFTERNOON'
        when HOUR(time_of_purchase) between 18 and 23 then 'EVENING'
	end as time_of_day 
from sales_store)
    
SELECT 
    time_of_day, COUNT(*) AS total_orders
FROM cte
GROUP BY time_of_day
ORDER BY total_orders DESC;

-- Business Problem: Find peak sales times.

-- Business Impact: Optimize staffing, promotions, and server loads.

--------------------------------------------------------------------------------

-- Q4. Who are the top 5 highest spending customers?
SELECT 
    customer_name,
    FORMAT(SUM(price * quantity), 'C0') AS total_spend
FROM sales_store
GROUP BY customer_name
ORDER BY SUM(price * quantity) DESC
LIMIT 5; 


-- Business Problem: Identify VIP customers
-- Business Impact: Personalized offers, loyalty rewards, and retention.

----------------------------------------------------------------------------------------
-- Q5. Which product categories generate the highest revenve?
SELECT 
    product_category,
    FORMAT(SUM(price * quantity), 'C0') AS Revenue
FROM sales_store
GROUP BY product_category
ORDER BY SUM(price * quantity) DESC;

-- Business Problem: Identify top-performing product categorie
-- Business Impact: Refine product strategy, supply chain, and promotions. allowing the business to invest more in high-margin or high-demand categories.
---------------------------------------------------------------------------------------------

-- Q6. What is the return/cancellation rate per product category?
-- cancellation
SELECT 
    product_category,
    FORMAT(COUNT(CASE WHEN status = 'cancelled' THEN 1 END)
    / COUNT(*) * 100,2) AS cancelled_percent
FROM sales_store
GROUP BY product_category
ORDER BY cancelled_percent DESC;


-- return
SELECT 
    product_category,
    FORMAT(COUNT(CASE WHEN status = 'returned' THEN 1 END) / COUNT(*) * 100,2) AS returned_percent
FROM sales_store
GROUP BY product_category
ORDER BY returned_percent DESC;

-- Business Problem: Monitor dissatisfaction trends per category.
-- Business Impact: Reduce returns, improve product descriptions/expectations. Helps identify and fix product or logistics issues.
 ------------------------------------------------------------------------------------------
 
 -- Q.7. what is the most preferred payment sode? 
 select payment_mode ,count(*) total_count
 from sales_store 
 group by payment_mode 
 order by total_count desc;
 
 
 -- Business Problem: Know which payment options customers prefer.
 -- Business Impact: Streamline payment processing, prioritize popular modes.
 
 ----------------------------------------------------------------------------------------
 -- Q8. How does age group affect purchasing behavior?
 with cte as (select * ,
		case
			when customer_age between 18 and 25 then '18-25'
			when customer_age between 26 and 35 then '26-35'
            when customer_age between 36 and 50 then '36-50'
            else '51+'
		end as cust_age 
        from sales_store
        )
   SELECT 
    cust_age,
    FORMAT(SUM((price * quantity)), 'C0') AS total_purches
FROM cte
GROUP BY cust_age
ORDER BY total_purches DESC;
 
 
 -- Business Problem: Understand customer demographics.
 -- Business Impact:Targeted marketing and product recommendations by age group.

---------------------------------------------------------------------------------------------------

-- Q 9. - What is the monthly sales trend?

 SELECT 
    YEAR(purchase_date) AS Years,
    MONTH(purchase_date) AS months,
    SUM(price * quantity) AS total_sales,
    SUM(quantity) AS total_quantity
FROM sales_store
GROUP BY YEAR(purchase_date) , MONTH(purchase_date)
ORDER BY years , months;  

-- Business Problem: Sales fluctuations go unnoticed.
-- Business Impact: Plan inventory and marketing according to seasonal trends.

----------------------------------------------------------------------------------------------

-- Q10. Are certain genders buying more specific product categories?
SELECT 
    gender,
    product_category,
    COUNT(product_category) AS total_purches
FROM sales_store
GROUP BY gender , product_category
ORDER BY gender;


 -- Comparison VIEW
with cte1 as (
select gender , product_category ,count(product_category) as  Male
from sales_store
where gender = 'M'
group by  gender , product_category ),

cte2 as (
select gender , product_category ,count(product_category) as Female
from sales_store
where gender = 'F'
group by  gender , product_category )

SELECT 
    product_category, Male, Female
FROM cte1 JOIN cte2 
    USING (product_category)
ORDER BY male DESC;


-- Business Problem: Gender-based product preferences.
-- Business Impact: Personalized ads, gender-focused campaigns.


