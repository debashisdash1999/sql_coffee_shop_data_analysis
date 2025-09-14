-- Business problems

SELECT * FROM city;
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM sales;

/* 1.Coffee Consumers Count
How many people in each city are estimated to consume coffee, given that 25% of the population does? */
SELECT city_name, 
       ROUND((population * 0.25) / 1000000, 2) AS coffee_consumers_in_millions, 
	   city_rank
FROM city
ORDER BY population DESC;

/* 2.Total Revenue from Coffee Sales
Calculate total revenue from coffee sales in the last quarter of 2023. */
SELECT 
      SUM(total) AS total_revenue
FROM sales
WHERE
    EXTRACT(YEAR FROM sale_date) = 2023
	AND
	EXTRACT(quarter FROM sale_date) = 4
;
-- OR
--find each city and their revenue from coffee sales in the last quarter of 2023.
SELECT 
      ci.city_name,
      SUM(s.total) AS total_revenue
FROM sales AS s
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city AS ci
ON ci.city_id = c.city_id
WHERE
    EXTRACT(YEAR FROM s.sale_date) = 2023
	AND
	EXTRACT(quarter FROM s.sale_date) = 4
GROUP BY city_name	
ORDER BY total_revenue DESC
;

/* 3.Sales Count for Each Product
Determine how many units of each coffee product have been sold. */
SELECT 
     p.product_name,
	 COUNT(s.sale_id) AS no_of_total_orders
FROM products AS p
LEFT JOIN sales AS s
ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY no_of_total_orders DESC;

/* 4.Average Sales Amount per City
Find the average sales amount per customer in each city.(Need - city and total_sale, no of customers in each city) */
SELECT 
      ci.city_name,
      SUM(s.total) AS total_revenue,
	  COUNT(DISTINCT s.customer_id) AS no_of_unique_cust,
	  ROUND(
	        SUM(s.total) :: numeric / 
			COUNT(DISTINCT s.customer_id) :: numeric, 2)
			AS avg_sale_pr_cust_by_city
FROM sales AS s
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city AS ci
ON ci.city_id = c.city_id
GROUP BY city_name	
ORDER BY total_revenue DESC

/* 5. City Population and Coffee Consumers (25%)
Provide a list of cities along with their populations and estimated coffee consumers.
(Need - return city_name, total current cust, estimated coffee consumers (25%) ) */
WITH city_table AS 
(
	SELECT 
		city_name,
		ROUND((population * 0.25)/1000000, 2) as coffee_consumers
	FROM city
),
customers_table
AS
(
	SELECT 
		ci.city_name,
		COUNT(DISTINCT c.customer_id) as unique_cust
	FROM sales as s
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY ci.city_name
)
SELECT 
	customers_table.city_name,
	city_table.coffee_consumers as coffee_consumer_in_millions,
	customers_table.unique_cust
FROM city_table
JOIN 
customers_table
ON city_table.city_name = customers_table.city_name

/* 6. Top Selling Products by City
What are the top 3 selling products in each city based on sales volume? */
SELECT * 
FROM
(
	SELECT 
	      ci.city_name,
		  p.product_name,
		  COUNT(s.sale_id) AS total_orders,
		  DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id)DESC) as rank
	FROM sales AS s
	JOIN products AS p
	ON s.product_id = p.product_id
	JOIN customers AS c
	ON c.customer_id = s.customer_id
	JOIN city AS ci
	ON ci.city_id = c.city_id
	GROUP BY  ci.city_name, p.product_name
	-- ORDER BY ci.city_name, total_orders DESC
) AS t1
WHERE rank <= 3;

/* 7. Customer Segmentation by City
How many unique customers are there in each city who have purchased coffee products? */
SELECT * FROM products;

SELECT 
	ci.city_name,
	COUNT(DISTINCT c.customer_id) as unique_cust
FROM city as ci
LEFT JOIN
customers as c
ON c.city_id = ci.city_id
JOIN sales as s
ON s.customer_id = c.customer_id
WHERE 
	s.product_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
GROUP BY ci.city_name
ORDER BY unique_cust DESC;

/* 8. Average Sale vs Rent
Find each city and their average sale per customer and avg rent per customer. 
To find avg rent we need city and their total rent / total cust. */
WITH city_table AS (
	SELECT 
		ci.city_name,
		SUM(s.total) AS total_revenue,
		COUNT(DISTINCT s.customer_id) AS total_customers,
		ROUND(SUM(s.total)::numeric / COUNT(DISTINCT s.customer_id)::numeric, 2) AS avg_sale_per_customer
	FROM sales AS s
	JOIN customers AS c
		ON s.customer_id = c.customer_id
	JOIN city AS ci
		ON ci.city_id = c.city_id
	GROUP BY ci.city_name
	ORDER BY total_revenue DESC
),
city_rent AS (
	SELECT 
		city_name, 
		estimated_rent
	FROM city
)
-- inner join these 2 cte
SELECT 
	cr.city_name,
	cr.estimated_rent,
	ct.total_customers,
	ct.avg_sale_per_customer,
	ROUND(cr.estimated_rent::numeric / ct.total_customers::numeric, 2) AS avg_rent_per_customer
FROM city_rent AS cr
JOIN city_table AS ct
	ON cr.city_name = ct.city_name
ORDER BY avg_rent_per_customer DESC;

/* 9. Monthly Sales Growth by City
Analyze month-over-month sales growth (percentage increase or decline) for each city */
WITH
monthly_city_sales AS
(
	SELECT 
		ci.city_name,
		EXTRACT(MONTH FROM s.sale_date) AS month,
		EXTRACT(YEAR FROM s.sale_date) AS year,
		SUM(s.total) AS total_sales
	FROM sales AS s
	JOIN customers AS c
		ON c.customer_id = s.customer_id
	JOIN city AS ci
		ON ci.city_id = c.city_id
	GROUP BY ci.city_name, year, month
	ORDER BY ci.city_name, year, month
),
sales_growth AS
(
	SELECT
		city_name,
		month,
		year,
		total_sales AS current_month_sales,
		LAG(total_sales, 1) OVER(PARTITION BY city_name ORDER BY year, month) AS previous_month_sales
	FROM monthly_city_sales
)
SELECT
	city_name,
	month,
	year,
	current_month_sales,
	previous_month_sales,
	ROUND(
		(current_month_sales - previous_month_sales)::numeric / previous_month_sales::numeric * 100, 2
	) AS growth_percentage
FROM sales_growth
WHERE previous_month_sales IS NOT NULL;
-- Detailed Explanation – Monthly Sales Growth by City
/*
✅ Objective

The purpose of this query is to analyze how sales change month by month for each city. It helps the business understand whether sales are growing, declining, or staying flat, which is crucial when recommending expansion or tracking performance.

✅ Step 1 – Aggregate Monthly Sales per City
WITH
monthly_city_sales AS
(
	SELECT 
		ci.city_name,
		EXTRACT(MONTH FROM s.sale_date) AS month,
		EXTRACT(YEAR FROM s.sale_date) AS year,
		SUM(s.total) AS total_sales
	FROM sales AS s
	JOIN customers AS c
		ON c.customer_id = s.customer_id
	JOIN city AS ci
		ON ci.city_id = c.city_id
	GROUP BY ci.city_name, year, month
	ORDER BY ci.city_name, year, month
)


What it does:

It groups all the sales data by city, year, and month.

For each group, it calculates the total sales.

Example: If Pune had ₹500,000 in sales in January 2024 and ₹600,000 in February 2024, those will be grouped and shown separately.

Why it's needed:

To track how much each city sold in each month.

This aggregated data becomes the base to calculate how sales are changing month over month.

✅ Step 2 – Find Previous Month’s Sales
sales_growth AS
(
	SELECT
		city_name,
		month,
		year,
		total_sales AS current_month_sales,
		LAG(total_sales, 1) OVER(PARTITION BY city_name ORDER BY year, month) AS previous_month_sales
	FROM monthly_city_sales
)


What it does:

It takes the monthly_city_sales data.

Using the LAG() window function, it looks at the previous month’s sales for each city.

Example: For Pune in February 2024, it will pull in Pune’s January 2024 sales so you can compare.

Why it's needed:

We can’t calculate growth unless we have the previous month’s data for comparison.

This function allows us to compare each month’s performance against the month before it.

✅ Step 3 – Calculate Growth Percentage
SELECT
	city_name,
	month,
	year,
	current_month_sales,
	previous_month_sales,
	ROUND(
		(current_month_sales - previous_month_sales)::numeric / previous_month_sales::numeric * 100, 2
	) AS growth_percentage
FROM sales_growth
WHERE previous_month_sales IS NOT NULL;


What it does:

It subtracts the previous month’s sales from the current month’s to find the difference.

Then, it divides that difference by the previous month’s sales to find the percentage change.

It rounds the result to two decimal places for clarity.

Only months where the previous month’s data exists are included (hence WHERE previous_month_sales IS NOT NULL).

Why it's needed:

This shows how much the sales increased or decreased as a percentage, which is a clearer way to understand performance than raw numbers.

It helps decision-makers easily spot trends and areas needing improvement.

✅ Key Concepts Used

Window Functions (LAG) – Used to compare rows within a partitioned set of data without needing a self-join.

Aggregate Functions (SUM) – Used to total monthly sales.

Date Functions (EXTRACT) – Used to break down sales data by month and year.

Filtering (WHERE) – Ensures that incomplete data (first month for each city) doesn’t skew the results.

Rounding (ROUND) – Makes results more readable and practical for reporting.

✅ Business Impact

Cities with consistent or growing sales can be prioritized for expansion.

Cities with declining sales can be investigated to understand customer behavior or external factors.

This analysis supports strategic decision-making by showing how demand is evolving over time.
*/

/* 10. Market Potential Analysis by City
Identify the top 3 cities based on highest sales and return relevant details such as city name, total sales, total rent, total customers, estimated coffee consumers, and average sale per customer */
WITH city_sales_analysis AS
(
	SELECT 
		ci.city_name,
		SUM(s.total) AS total_sales,
		COUNT(DISTINCT s.customer_id) AS total_customers,
		ROUND(
			SUM(s.total)::numeric / COUNT(DISTINCT s.customer_id)::numeric
			, 2) AS avg_sale_per_customer
	FROM sales AS s
	JOIN customers AS c
		ON s.customer_id = c.customer_id
	JOIN city AS ci
		ON ci.city_id = c.city_id
	GROUP BY ci.city_name
	ORDER BY total_sales DESC
),
city_market_data AS
(
	SELECT 
		city_name, 
		estimated_rent AS total_rent,
		ROUND((population * 0.25) / 1000000, 3) AS estimated_coffee_consumers_in_millions
	FROM city
)
SELECT 
	cm.city_name,
	csa.total_sales,
	cm.total_rent,
	csa.total_customers,
	cm.estimated_coffee_consumers_in_millions,
	csa.avg_sale_per_customer,
	ROUND(
		cm.total_rent::numeric / csa.total_customers::numeric
		, 2) AS avg_rent_per_customer
FROM city_market_data AS cm
JOIN city_sales_analysis AS csa
	ON cm.city_name = csa.city_name
ORDER BY csa.total_sales DESC
LIMIT 3;
/* ✅ Goal of the Query

Helping Monday Coffee figure out the top 3 cities where they can expand their business. I want to recommend cities based on:

How much they already sell there

How many customers they have

How much rent they’d pay

How many people might be coffee lovers there

This query combines all of that information in one place so that you can easily compare the cities.

✅ Breaking Down the Query
Step 1 – city_sales_analysis

This part looks at how much coffee is being sold in each city and gathers useful information about customers.

WITH city_sales_analysis AS
(
	SELECT 
		ci.city_name,
		SUM(s.total) AS total_sales,                     -- Total money earned from sales in the city
		COUNT(DISTINCT s.customer_id) AS total_customers, -- How many unique customers bought something
		ROUND(SUM(s.total)::numeric / COUNT(DISTINCT s.customer_id)::numeric, 2) AS avg_sale_per_customer -- Average money each customer spends
	FROM sales AS s
	JOIN customers AS c ON s.customer_id = c.customer_id
	JOIN city AS ci ON ci.city_id = c.city_id
	GROUP BY ci.city_name
	ORDER BY total_sales DESC
)


Why this is useful:

You can see which city earns the most from coffee.

Cities with more customers are likely better options.

The average sale per customer shows how engaged customers are.

Step 2 – city_market_data

This part looks at market conditions in each city like rent and potential coffee drinkers.

city_market_data AS
(
	SELECT 
		city_name, 
		estimated_rent AS total_rent, -- How much rent they’ll pay if they open a store
		ROUND((population * 0.25) / 1000000, 3) AS estimated_coffee_consumers_in_millions -- Estimating coffee lovers (25% of population)
	FROM city
)


Why this is useful:

Cities with lower rent are cheaper to expand into.

Knowing how many people might be potential customers helps in planning.

Step 3 – Combining the Data

Now, we bring both sets of information together.

SELECT 
	cm.city_name,
	csa.total_sales,
	cm.total_rent,
	csa.total_customers,
	cm.estimated_coffee_consumers_in_millions,
	csa.avg_sale_per_customer,
	ROUND(cm.total_rent::numeric / csa.total_customers::numeric, 2) AS avg_rent_per_customer -- Shows how affordable the rent is per customer
FROM city_market_data AS cm
JOIN city_sales_analysis AS csa ON cm.city_name = csa.city_name
ORDER BY csa.total_sales DESC
LIMIT 3;


What this final part does:

It shows all the important data for each city in one table.

The cities are sorted by total sales – meaning the cities where customers are already buying the most coffee are prioritized.

It calculates how much rent each customer “costs,” helping to see which city is cheaper to expand into.

✅ What You Get at the End

For each of the top 3 cities:

The total sales (how much business they’re already doing)

The total rent they’d need to pay

The number of unique customers

How many coffee drinkers live there

How much each customer spends on average

How affordable rent is per customer

✅ Why This Matters for Monday Coffee

Cities with high sales and lots of customers are safer bets for expansion.

Lower rent cities are cheaper to start in.

Cities with more coffee lovers have more growth potential.

You give the company a full picture so they can make data-backed decisions.
*/