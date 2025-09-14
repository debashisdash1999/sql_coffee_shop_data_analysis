# Monday Coffee Business Expansion Analysis

## Overview (follow the .sql file along with this readme for better understanding)
This project is focused on helping **Monday Coffee**, an online coffee and merchandise retailer, analyze its historical data to recommend expansion locations.  
Monday Coffee, founded in January 2023, has experienced rapid growth and now plans to open three new outlets in major cities across India.  

The objective of this project is to analyze customer behavior, sales trends, and city demographics using data from their existing store. Based on this analysis, recommendations will be provided for the top 3 cities where the company should expand its presence.

---

## Dataset Description

The data is structured across four main tables:

### `city`
Stores information about cities where customers are based.
- `city_id` (INT, Primary Key)
- `city_name` (VARCHAR)
- `population` (BIGINT)
- `estimated_rent` (FLOAT)
- `city_rank` (INT)

### `customers`
Stores information about customers.
- `customer_id` (INT, Primary Key)
- `customer_name` (VARCHAR)
- `city_id` (INT, Foreign Key referencing `city`)

### `products`
Stores details of products sold.
- `product_id` (INT, Primary Key)
- `product_name` (VARCHAR)
- `price` (FLOAT)

### `sales`
Stores transaction records.
- `sale_id` (INT, Primary Key)
- `sale_date` (DATE)
- `product_id` (INT, Foreign Key referencing `products`)
- `customer_id` (INT, Foreign Key referencing `customers`)
- `total` (FLOAT)
- `rating` (INT)

## ERD
![ERD](https://github.com/user-attachments/assets/9fc14cc5-af90-40a9-9259-77f15ca998b6)

---

## Key Business Questions

1. **Coffee Consumers Count**  
   Estimate the number of coffee consumers in each city assuming 25% of the population consumes coffee.

2. **Total Revenue from Coffee Sales**  
   Calculate total revenue from coffee sales in the last quarter of 2023.

3. **Sales Count for Each Product**  
   Determine how many units of each coffee product have been sold.

4. **Average Sales Amount per City**  
   Find the average sales amount per customer in each city.

5. **City Population and Coffee Consumers**  
   List cities with their population and estimated coffee consumers.

6. **Top Selling Products by City**  
   Identify the top 3 selling products in each city based on sales volume.

7. **Customer Segmentation by City**  
   Count the unique customers in each city who have purchased coffee products.

8. **Average Sale vs Rent**  
   Compare average sales per customer and average rent per customer for each city.

9. **Monthly Sales Growth**  
   Calculate the percentage growth or decline in monthly sales.

10. **Market Potential Analysis**  
   Identify the top 3 cities with the highest market potential based on total sales, total rent, total customers, and estimated coffee consumers.

---

## Implementation

1. **Database Setup**  
   - Tables will be created using SQL based on the schema provided above.
   - Data from Excel files will be uploaded into the database.

2. **Analysis**  
   - SQL queries will be used to answer the key business questions.
   - Aggregations, joins, window functions, and conditional logic will be applied for deeper insights.

3. **Outcome**  
   The final output will include actionable insights and recommendations for expanding into the best cities, considering both market potential and operational feasibility.

---

## Tools Used
- pgAdmin4 (Postgres SQL)
- Excel for dataset preparation
- SQL queries for data analysis

---

## Recommendations for Expansion

Based on the analysis of population, customer base, revenue, and rent affordability, the following top 3 cities are recommended for expanding Monday Coffee’s outlets:

### City 1: Pune
- The average rent per customer is very low, making it cost-effective.
- It has the highest total revenue, indicating strong demand for coffee products.
- The average sales per customer are also high, showing good purchasing behavior.

### City 2: Delhi
- It has the highest estimated coffee consumers at **7.7 million**, offering a large potential market.
- The highest total number of customers at **68**, reflecting strong customer engagement.
- The average rent per customer is **₹330**, which is still affordable and sustainable for expansion.

### City 3: Jaipur
- It has the highest number of customers at **69**, indicating good market traction.
- The average rent per customer is very low at **₹156**, making it an attractive and cost-efficient location.
- The average sales per customer is **₹11,600**, suggesting good sales potential and profitability.


This project will help **Monday Coffee** make data-driven decisions while planning their expansion strategy.
