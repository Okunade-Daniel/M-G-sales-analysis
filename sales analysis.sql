SELECT *
  FROM sales
 ORDER BY date
	  
	  --SALES OVERVIEW
SELECT SUM(order_quantity) AS total_quantity_of_products_sold,
	   SUM(cost) AS total_cost, SUM(revenue) as total_sales,
	   SUM(profit) AS total_profit
  FROM sales;
		--The total quantity sold between 2011 and 2016 is 1345316, the total cost is 53049908,
		--the total sales is 85271008 and total profits made by the sales company is 32221100.
		
		

	   -- max quantity purchased by a customer at a time, and max sales made to a customer at a time
SELECT MAX(order_quantity) as max_quantity_sold_at_once,
	   MAX(revenue) as max_sales_made_at_once
  FROM sales;
	   --maximum quantity sold at once is 32, maximum sales made at once is 58074



  	   -- sales by year
SELECT DATE_PART('year', date) AS year, SUM(revenue) AS total_sales
  FROM sales
 GROUP BY year
 ORDER BY year;
       --There is a consistent rise in the total sales made between 2011 and 2013 then a dip in 2014
	   --There is a huge rise in sales by 2015 and then followed by a huge dip in 2016.
	   
	   
  	 
	   --investigating why there is a sudden dip in 2014 and 2016 after a consistent rise
SELECT DATE_PART('year', date) AS year, SUM(revenue) AS total_sales,
	   SUM(order_quantity) AS total_quantity_of_products_sold
  FROM sales
 GROUP BY year
 ORDER BY year;
 	   --We see that there is a dip despite having sold more quantity than their previous year respectively
	   
	   
	   
	   --we investigate further to find out the top product of each year and their price
	   --and their quantity ordered.
SELECT DATE_PART('year', date) as year, product_category,
	   SUM(order_quantity) AS total_quantity_sold, ROUND(AVG(unit_price),2) average_price
	   --K() OVER(PARTITION by DATE_PART('year', date) ORDER BY SUM(order_quantity) DESC)
  FROM sales
 WHERE DATE_PART('year', date) BETWEEN 2013 AND 2016
 GROUP BY year, product_category
 ORDER BY year, product_category;
	   --we see that although more quantity of products were bought in 2014 and 2016 the 
	   --average price for which they are bought were lesser than the previous year.
	   
	   
	   
	   --checking for seasonality in sales
SELECT DATE_PART('year', date) as year, 
	   DATE_PART('month', date) as month_no,
       To_CHAR(date, 'month') as month_name, SUM(revenue) as total_sales
  FROM sales
 GROUP BY year, month_no, month_name
 ORDER BY year, month_no;
 	   -- WOW!!! THERE IS an sudden increase in sales ever july and august
 	   --and a crazy increase in sales by december
	   --we see that in 2014 and 2016 sales were only recorded for January to July. This may have 
	   --contributed to why there is a dip in both years
	   
	   
	   
	   --Now we find out the top product category sold in december
SELECT product_category, RANK() OVER(ORDER BY SUM(order_quantity) DESC)
  FROM sales
 WHERE date_part('month', date) = 12
 GROUP BY product_category;
 	   --No Surprise, December is a festive period, this can explain why accessories and clothing
	   --are ordered more than bikes.
	   
	   
	   
	   --what is the relationship between quantity ordered and profit for each product category
	   --accessories
SELECT corr(order_quantity, profit) as accessories_corr,
	   (SELECT corr(order_quantity, profit)
  		  FROM sales
         WHERE product_category = 'Bikes') as bikes_corr,
		 	   (SELECT corr(order_quantity, profit)
  			    FROM sales
 			    WHERE product_category = 'Clothing') as clothing_corr
  FROM sales
 WHERE product_category = 'Accessories';
	   --There is moderate positive correlation between quantity purchased by a customer
	   --and profit made for accessories and bikes and a slightly weak correlation for clothing
	   --we can recommend that the company can introduce a discount program so customers who purchase
	   --certain quantity will get certain percentage discount.


		--CUSTOMER DEMOGRAPHY
SELECT min(customer_age) as youngest_customer,
	   max(customer_age) as eldest_customer,
	   count(*) as total_customers
  FROM sales;
  --Our youngest custome is 17 years old and the oldest is 87 and a total number of 113,036
  
  
  
	   --count of abe by age bins
  WITH bins AS(
SELECT GENERATE_SERIES(MIN(customer_age), MAX(customer_age), 20) as lower,
	   GENERATE_SERIES(MIN(customer_age)+20, 	MAX(customer_age)+20, 20) as higher
  FROM sales)
  
SELECT lower, higher, COUNT(customer_age) AS number_of_people
  FROM bins
 INNER JOIN sales
    ON lower <= customer_age
	   AND higher > customer_age
 GROUP BY lower, higher
 ORDER BY lower, higher;
 	   --About 54 percent of our customers fall within the age of 17 and 37 and fewer customers are betweer
	   --77 and 97
	   
	   
	   
	   --sales by age group
  WITH bins AS(
SELECT GENERATE_SERIES(MIN(customer_age), MAX(customer_age), 20) as lower,
	   GENERATE_SERIES(MIN(customer_age)+20, 	MAX(customer_age)+20, 20) as higher
  FROM sales)
  
SELECT lower, higher, SUM(revenue) as total_sales
  FROM bins
 INNER JOIN sales
    ON lower <= customer_age
	   AND higher > customer_age
 GROUP BY lower, higher
 ORDER BY lower, higher;
 	   --Majority of the sales were also to customers between age 17 and 37.
	     
	   

	   --total sales by gender
SELECT customer_gender, SUM(revenue) AS total_sales
  FROM sales
 GROUP BY customer_gender;
       --Most of the sales were made to Male customers



	   --does selling to male customers mean most of our profits were from male customers
SELECT customer_gender, SUM(revenue) as total_sales, SUM(profit) as total_profit
  FROM sales
 GROUP BY customer_gender;
       --we made more profit from male customers also.
	   
	   
	   --find out which product category is purchased most by each customer gender
  WITH product_ranking AS(
SELECT customer_gender, product_category, 
	   RANK() OVER(PARTITION BY customer_gender ORDER BY SUM(order_quantity) DESC)
  FROM sales
 GROUP BY customer_gender, product_category)
 
SELECT customer_gender, product_category
  FROM product_ranking
 WHERE rank = 1;
  	   -- both gender seems to like Accessories alot.
	 
	   
	   
SELECT corr(customer_age, order_quantity) AS accessories,
	   (SELECT corr(customer_age, order_quantity) as bikes
  	   FROM sales
 	   WHERE product_category = 'Bikes'),
	   		 (SELECT corr(customer_age, order_quantity) as clothing
  	   		 FROM sales
 	   		 WHERE product_category = 'Clothing')
  FROM sales
 WHERE product_category = 'Accessories';
  --There is no relationship between age and order_quantity as increase in age tells us 
  --nothing about quantity of product ordered.  
  --recommendation can be made that customers under 57 years of age should be targeted more with the
  --the company's promotional/advertisement strategies
	   

  
	--GEOGRAPHICAL ANALYSIS
	-- total sales by customer location
SELECT country, sum(revenue) as total_sales
  FROM sales
 GROUP BY country
 ORDER BY total_sales desc
 
	   -- most sales are made in the United States.

	   --since most sales were made in the united states whats the most popular product in the US
SELECT product, SUM(order_quantity) AS quantity_purchased
  FROM sales
 WHERE country = 'United States'
 GROUP BY product
 ORDER BY quantity_purchased DESC
 LIMIT 5;
	   -- Water Bottle is the most purchased product in the united states



	


