#  Retail Sales Analysis SQL Project

## Project Overview

**Project Title:** Retail Sales Analysis
**Level:** Beginner
**Database:** 'p1_retail_db'

The retail_sales database provide insights into customer purchasing behavior, product performance, and revenue generation. This database supports in-depth exploratory and diagnostic analysis to identify key business trends and opportunities. With fields capturing age, gender, category, price, and time of sale, it enables the development of metrics like average order value, customer lifecycle, conversion rate, and sales seasonality.

## Objectives

1. **Database Setup-** Created and structured the retail_sales database using SQL. 
2. **Data Cleaning-** Identified and handled missing or null values, especially in key columns like age, category, and total sales, ensuring data integrity and accuracy for analysis.
3. **Exploratory Data Analysis (EDA)-** Conducted initial analysis to understand data distribution, customer demographics, sales trends, and category performance using SQL queries and visual summaries.
4. **Business Analysis Using SQL-** Developed a series of SQL queries to address key business questions examining customer behavior, identifying top-performing products, analyzing shifts in buying patterns, and comparing revenue against COGS to assess profitability across categories.
5. **Insights & Recommendations-** Findings from the SQL analysis were used to derive actionable business insights for decision-makers in marketing, sales strategy, and inventory planning.

## Project Structure

1. **Database Setup**

•	**Database Creation:** The project starts by creating a database named sql_query_p1.
•	**Table Creation:** A table named retail_sales is created to store the sales data. The table includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS) and total sale amount.

'''sql
create database sql_project_p1

create table retail_sales
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
'''

2. **Data Handling & Cleaning**

'''sql
select * from retail_sales
where transactions_id is null
or sale_date is null or sale_time is null or customer_id is null or gender is null 
or category is null or quantity is null or price_per_unit is null or cogs is null 
or total_sale is null;

delete  from retail_sales
where transactions_id is null
or sale_date is null or sale_time is null or customer_id is null or gender is null 
or category is null or quantity is null or price_per_unit is null or cogs is null 
or total_sale is null;
'''

3. **Data Analysis & Findings**

The SQL queries below were designed to address key business questions and find insights.

1. **Show the total number of sales transactions made by each gender.**
'''sql
Select gender, count(transactions_id) as total_transactions from retail_sales
group by gender;
'''

2. **Show the total number of sales transactions per age group (e.g., <25, 25–40, >40)?**
'''sql
Select case 
when age<25 then '<25'
when age between 25 and 40 then '25-40'
when age>40 then '>40'
end as age_group, count(transactions_id) as total_transactions from retail_sales
where age is not null
group by age_group;
'''

3. **List all transactions where the total sale amount was more than ₹1000.**
'''sql
select * from retail_sales
where total_sale> 1000;
'''

4. **Find the number of unique customers who made purchases in each category.**
'''sql
select category, count(distinct customer_id) from retail_sales
group by category;
'''

5. **List all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022.**
'''sql
select * from retail_sales
where category = 'Clothing' 
and quantity >3 
and to_char(sale_date,'YYYY-MM') = '2022-11';
'''

6. **Find the average age of customers who purchased items from the 'Beauty' category.**
'''sql
select round(avg(age),2) as avg_age from retail_sales
where category = 'Beauty';
'''

7. **Identify the top 5 customers who spent the most overall.**
 '''sql
Select customer_id, sum(total_sale) as total_spent from retail_sales
group by customer_id
order by total_sale desc 
limit 5;
'''

8. **How many order purchased during each shift in each category (Morning <12, Afternoon 12–17, Evening >17)?**
'''sql
select case
when extract(hour from sale_time)< 12 then 'Morning'
when extract(hour from sale_time) between 12 and 17 then 'Afternoon'
else 'evening' end as shift,
category, count(*) as total_pruchase from retail_sales
group by shift, category
order by shift, category;
'''

9. **Identify which day of the week has the lowest sales.**
'''sql
select to_char(sale_date, 'Day') AS day_of_week,
sum(total_sale) AS total_sales from retail_sales
group by to_char(sale_date, 'Day')
order by total_sales asc;
'''

10. **Calculate average total sale amount for each month, and which month had the highest sales each year?**
'''sql
select year, month , avg_sale from (
select extract(year from sale_date) as year,
extract(month from sale_date) as month,
avg(total_sale) as avg_sale,
Rank() over(partition by  extract(year from sale_date) order by avg(total_sale) desc) as rank
from retail_sales 
group by year, month) as t1
where rank = 1;
'''

11. **Find the average number of days between consecutive purchases for each customer.**
'''sql
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
'''

12. **What is the total revenue and COGS for each category, and which categories generate the highest profit margins?**
'''sql
select category, sum(total_sale) as total_revenue,
sum(cogs) as total_cogs, sum(total_sale - cogs) as total_profit,
case when 
sum(total_sale) > 0 then
(sum(total_sale - cogs)/ sum(total_sale)) * 100
end as profit_margin_percentage
from retail_sales
group by category
order by profit_margin_percentage desc;
'''

 
## Findings & Insights

1. **Sales Demographics**
•	The total number of transactions made by female customers slightly more those than males.
•	A large share of sales is driven by customers age group >40, positioning them as the most profitable target audience.

2. **Time-Based Sales Insights**
•	The evening (after 5 PM) is the busiest shopping time.
•	Sundays usually have the highest number of sales.

3. **Customer Purchase Behavior**
•	Many customers buy more than once, which shows strong customer retention and loyalty.
•	Younger customers (especially under 25) tend to buy more beauty products.


## Conclusion
The analysis of the retail_sales database provides key insights into customer purchasing behavior and business performance. The 25–40 age group is the most profitable segment, while clothing is the top-selling category. Most purchases occur in the morning and afternoon, with Monday being the slowest day for sales. Gender distribution is fairly balanced, and repeat purchases highlight strong customer loyalty. Category-wise revenue and profit margin comparisons help identify the most profitable product lines. Overall, these insights enable better targeting, inventory planning, and marketing strategies to improve sales performance and customer engagement.
