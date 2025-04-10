--- SQL Retail Sales Analysis - P1

Create table retail_sales
(transactions_id int PRIMARY KEY,	
sale_date date,
sale_time time,	
customer_id	int,
gender varchar(15),
age	int,
category VARCHAR(15),
quantity INT,
price_per_unit FLOAT,
cogs FLOAT,
total_sale FLOAT
);

SELECT * FROM retail_sales;

-- Data Cleaning

select * from retail_sales
where transactions_id is null
or sale_date is null 
or sale_time is null 
or customer_id is null 
or gender is null 
or category is null 
or quantity is null 
or price_per_unit is null 
or cogs is null 
or total_sale is null;

delete  from retail_sales
where transactions_id is null
or sale_date is null 
or sale_time is null 
or customer_id is null 
or gender is null 
or category is null 
or quantity is null 
or price_per_unit is null 
or cogs is null 
or total_sale is null;

-- Data Analysis and Business Key Problems

-- Q.1 Show the total number of sales transactions made by each gender.
-- Q.2 Show the total number of sales transactions per age group (e.g., <25, 25–40, >40)?
-- Q.3 List all transactions where the total sale amount was more than ₹1000.
-- Q.4 Find the number of unique customers who made purchases in each category.
-- Q.5 List all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022
-- Q.6 Find the average age of customers who purchased items from the 'Beauty' category.
-- Q.7 Identify the top 5 customers who spent the most overall.
-- Q.8 How many order purchased during each shift in each category (Morning <12, Afternoon 12–17, Evening >17)?
-- Q.9 Identify which day of the week has the lowest sales.
-- Q.10 Calculate average total sale amount for each month, and which month had the highest sales each year?
-- Q.11 Find the customer lifecycle — how many days pass between a customer’s first and last purchase.
-- Q.12 What is the total revenue and COGS for each category, and which categories generate the highest profit margins?


-- Analysis and Findings

-- Q.1 Show the total number of sales transactions made by each gender.

Select gender, count(transactions_id) as total_transactions from retail_sales
group by gender;

-- Q.2 Show the total number of sales transactions per age group (e.g., <25, 25–40, >40)?

Select case 
when age<25 then '<25'
when age between 25 and 40 then '25-40'
when age>40 then '>40'
end as age_group, count(transactions_id) as total_transactions from retail_sales
where age is not null
group by age_group;

-- Q.3 List all transactions where the total sale amount was more than ₹1000.

select * from retail_sales
where total_sale> 1000;

-- Q.4 Find the number of unique customers who made purchases in each category.

select category, count(distinct customer_id) from retail_sales
group by category;

-- Q.5 List all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022.

select * from retail_sales
where category = 'Clothing' 
and quantity >3 
and to_char(sale_date,'YYYY-MM') = '2022-11';

-- Q.6 Find the average age of customers who purchased items from the 'Beauty' category.

select round(avg(age),2) as avg_age from retail_sales
where category = 'Beauty';

-- Q.7 Identify the top 5 customers who spent the most overall.

Select customer_id, sum(total_sale) as total_spent from retail_sales
group by customer_id
order by total_sale desc 
limit 5;

-- Q.8 How many order purchased during each shift in each category (Morning <12, Afternoon 12–17, Evening >17)?

select case
when extract(hour from sale_time)< 12 then 'Morning'
when extract(hour from sale_time) between 12 and 17 then 'Afternoon'
else 'evening' end as shift,
category, count(*) as total_pruchase from retail_sales
group by shift, category
order by shift, category;

-- Q.9 Identify which day of the week has the lowest sales.

select to_char(sale_date, 'Day') AS day_of_week,
sum(total_sale) AS total_sales from retail_sales
group by to_char(sale_date, 'Day')
order by total_sales asc;

-- Q.10 Calculate average total sale amount for each month, and which month had the highest sales each year?

select year, month , avg_sale from (
select extract(year from sale_date) as year,
extract(month from sale_date) as month,
avg(total_sale) as avg_sale,
Rank() over(partition by  extract(year from sale_date) order by avg(total_sale) desc) as rank
from retail_sales 
group by year, month) as t1
where rank = 1;

-- Q.11 Find the average number of days between consecutive purchases for each customer.

with purchase_intervals as( 
select 
customer_id, sale_date,
lag(sale_date) over (partition by customer_id order by sale_date) as previous_purchase_date
from retail_sales),interval_calculations as(
select 
customer_id, sale_date, previous_purchase_date,
(sale_date - previous_purchase_date) as days_between_purchases
from purchase_intervals
where previous_purchase_date is not null)
select 
customer_id, round(avg(days_between_purchases),2) as average_days_between_purchases
from interval_calculations
group by customer_id
order by customer_id;

-- Q.12 What is the total revenue and COGS for each category, and which categories generate the highest profit margins?

select category, sum(total_sale) as total_revenue,
sum(cogs) as total_cogs, sum(total_sale - cogs) as total_profit,
case when 
sum(total_sale) > 0 then
(sum(total_sale - cogs)/ sum(total_sale)) * 100
end as profit_margin_percentage
from retail_sales
group by category
order by profit_margin_percentage desc;


-- End of Project


