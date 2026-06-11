select * from ecommerce_orders;
describe ecommerce_orders;

-- BUSINESS QUESTION 1:
-- "Which city and category earns us the most?"

select city,category,
count(distinct order_id) as total_orders, 
sum(total_amount) as revenue,
avg(total_amount) as avg_order_value from ecommerce_orders 
where returned = 0 #o-false,1-true
group by city,category
order by revenue desc
limit 20;
# WHY WHERE returned = 0?
--   Returned orders are not real revenue.
--   Excluding them gives accurate figures.

-- WHY GROUP BY city, category?
--   We want one row per city+category combination.
--   Without GROUP BY, SUM/COUNT would add up EVERYTHING.

#BUSINESS QUESTION 2:
-- "Who are our most valuable customers?"
select customer_id,count(order_id) as total_orders,
sum(total_amount) as revenue ,MIN(STR_TO_DATE(order_date,'%d-%m-%Y')) AS first_purchase,
    MAX(STR_TO_DATE(order_date,'%d-%m-%Y')) AS last_purchase,
    DATEDIFF(
        MAX(STR_TO_DATE(order_date,'%d-%m-%Y')),
        MIN(STR_TO_DATE(order_date,'%d-%m-%Y'))
    ) AS no_of_days from ecommerce_orders
where returned = 0
group by customer_id
order by revenue desc
limit 20;
#here we used str_to_date where the date column is in text format firstly changed it to date format then used datediff which give no of days

#BUSINESS QUESTION 3:
-- "What is our monthly revenue trend?"
select date_format(STR_TO_DATE(order_date,'%d-%m-%Y'),'%Y-%m') as month,
count(distinct customer_id) as total_customers,
count(distinct order_id) as total_orders,
sum(total_amount) as revenue,avg(total_amount) as avg_amount,
round(100*(sum(total_amount)-lag(sum(total_amount)) 
over (order by date_format(STR_TO_DATE(order_date,'%d-%m-%Y'),'%Y-%m')))/ LAG(SUM(total_amount))
over (order by date_format(STR_TO_DATE(order_date,'%d-%m-%Y'),'%Y-%m')),1) as growth_pct from ecommerce_orders
where returned = 0
group by month
order by month;
# Growth% = Current Revenue − Previous Revenue /Previous Revenue  × 100
# based on tha growth_pct - how much the revenue increased or decreased compared to the previous month
# Revenue increased 354.5% compared to February

# -- BUSINESS QUESTION 4:
-- "Which products have the highest return rate?"
select category, product_name, count(*) as total_orders,
sum(case when returned = 'true' then 1 else 0 end) as returned_orders,
round(100.0*sum(case when returned = 'true' then 1 else 0 end)/count(*),2) as returned_rate from ecommerce_orders
group by category, product_name
having total_orders > 10  -- only products with enough data
order by returned_rate desc;

#BUSINESS QUESTION 5:
-- "What payment method is most popular by city?"
-- highest payment_method by city?

select city,payment_method,count(*) as orders,
round(100.0 *count(*)/sum(count(*)) over (partition by city),1) as pay_in_city from ecommerce_orders
group by city,payment_method
order by city,orders desc;

-- PARTITION BY city = reset the window for each city
-- This gives us the % of orders for each payment method WITHIN each city

