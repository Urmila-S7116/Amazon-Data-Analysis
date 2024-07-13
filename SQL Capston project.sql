SELECT * FROM amazon.amazon; --  retreive all data from table

DESC amazon.amazon; -- it will show data types of dataset

-- Feature Engineering
-- 1.Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening.
--  This will help answer the question on which part of the day most sales are made.

SET SQL_SAFE_UPDATES = 0; -- disable safe update mode

ALTER TABLE amazon.amazon   -- add column timeofday in dataset
ADD COLUMN timeofday VARCHAR(20);

UPDATE amazon.amazon -- it will update table
SET timeofday = CASE  -- it sets the value of the timeofday column based on conditions specified within the CASE statement.
    -- This condition checks if the time extracted from the Time column,
    --  formatted as HH:MM:SS, falls within the range of 00:00:00 (midnight) to 11:59:59 (just before noon), 
    --  which corresponds to the morning hours.
    WHEN TIME_FORMAT(Time, '%H:%i:%s') BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
    WHEN TIME_FORMAT(Time, '%H:%i:%s') BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
    ELSE 'Evening'
END;

-- 2. Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). 
-- This will help answer the question on which week of the day each branch is busiest.

ALTER TABLE amazon.amazon   
ADD COLUMN dayname VARCHAR(10); -- add column dayname in dataset

-- UPDATE statement sets the value of the dayname column
-- based on the day of the week extracted from the Date column.
UPDATE amazon.amazon
SET dayname = CASE DAYOFWEEK(Date) 
    WHEN 1 THEN 'Sunday'
    WHEN 2 THEN 'Monday'
    WHEN 3 THEN 'Tuesday'
    WHEN 4 THEN 'Wednesday'
    WHEN 5 THEN 'Thursday'
    WHEN 6 THEN 'Friday'
    ELSE 'Saturday'
END;


-- 3. Add a new column named monthname that contains the extracted months of the year on which 
-- the given transaction took place (Jan, Feb, Mar). 
-- Help determine which month of the year has the most sales and profit.

ALTER TABLE amazon.amazon
ADD COLUMN monthname VARCHAR(20); -- add column monthname

UPDATE amazon.amazon
SET monthname = CASE MONTH(Date)
    WHEN 1 THEN 'Jan'
    WHEN 2 THEN 'Feb'
    WHEN 3 THEN 'Mar'
    WHEN 4 THEN 'Apr'
    WHEN 5 THEN 'May'
    WHEN 6 THEN 'Jun'
    WHEN 7 THEN 'Jul'
    WHEN 8 THEN 'Aug'
    WHEN 9 THEN 'Sep'
    WHEN 10 THEN 'Oct'
    WHEN 11 THEN 'Nov'
    ELSE 'Dec'
END;




-- 1.What is the count of distinct cities in the dataset?
-- count of distinct city is 3, Yangon, Naypyitaw, mandalay from Myanmar country
SELECT 
    COUNT(DISTINCT city) AS distinct_city_count
FROM
    amazon.amazon;
    


-- 2. For each branch, what is the corresponding city?
-- for branch A city is Yangon, for B city is Mandalay, and for C city is Naypyitaw

SELECT 
    branch, city
FROM
    amazon.amazon
GROUP BY branch , city;

-- 3. What is the count of distinct product lines in the dataset?
-- count of distinct product line is 6,
-- 1.Electronic accessories
-- 2. Fashion accessories
-- 3. Food and Beverages
-- 4. Health and beauty
-- 5. Home and lifestyle
-- 6. Sports and travel
SELECT 
    COUNT(DISTINCT `Product line`) AS distinct_product_lines
FROM
    amazon.amazon;


-- 4.Which payment method occurs most frequently?
SELECT 
    payment, COUNT(*) AS frequency
FROM
    amazon.amazon
GROUP BY payment
ORDER BY frequency DESC
LIMIT 1;

-- 5.Which product line has the highest sales?
-- Fashion accessories- 178
SELECT 
    `Product line`, COUNT(Total) AS total_sale
FROM
    amazon.amazon
GROUP BY `product line`
ORDER BY total_sale DESC;


-- 6.How much revenue is generated each month?
-- total revenue= quantity * price
-- 2019-03 revenue 109455.51 Myanmar Kyat
-- 2019-02 revenue 97219.37 Myanmar Kyat
-- 2019-01 revenue 116291.87 Myanmar Kyat

select sum(`unit price` * quantity) from amazon.amazon;

SELECT 
    date, SUM(Total) AS Revenue
FROM
    amazon.amazon
GROUP BY date
ORDER BY date desc;

SELECT 
    DATE_FORMAT(Date, '%Y-%m') AS Month,
    ROUND(SUM(Total), 2) AS Revenue
FROM
    amazon.amazon
GROUP BY DATE_FORMAT(Date, '%Y-%m')
ORDER BY Month DESC;

-- 7.In which month did the cost of goods sold reach its peak?
-- 2019-01 month has highest cost of goods sold

SELECT 
    DATE_FORMAT(Date, '%Y-%m') AS Month,
    ROUND(SUM(cogs), 2) AS cost_goods_sold
FROM
    amazon.amazon
GROUP BY DATE_FORMAT(Date, '%Y-%m')
ORDER BY cost_goods_sold DESC
LIMIT 1;

-- 8.Which product line generated the highest revenue?
-- Food and Beverages has highest revenue as 53471.28 Myanmar Kyat
    
SELECT 
    `product line`,
    ROUND(SUM(`unit price` * quantity), 2) AS revenue
FROM
    amazon.amazon
GROUP BY `product line`
ORDER BY revenue DESC
LIMIT 1;


-- 9.In which city was the highest revenue recorded?
-- Naypyitaw city has highest revenue as 105303.53 Myanmar Kyat
SELECT 
    city,
    ROUND(SUM(`unit price` * quantity), 2) AS revenue
FROM
    amazon.amazon
GROUP BY city
ORDER BY revenue DESC
LIMIT 1;

-- 10.Which product line incurred the highest Value Added Tax?
-- Food and beverages has highest VAT i.e 2673.56 Myanmar Kyat

SELECT 
    `product line`, ROUND(SUM(`Tax 5%`), 2) AS highest_VAT
FROM
    amazon.amazon
GROUP BY `product line`
ORDER BY highest_VAT DESC
LIMIT 1;

-- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."

SELECT 
    *,
    CASE 
        WHEN Total > Avg_Sales THEN 'Good'
        ELSE 'Bad'
    END AS Sales_Status
FROM (
    SELECT 
        `Product line`,
        ROUND(SUM(Total),2) AS Total,
        ROUND(AVG(SUM(Total)) OVER(),2) AS Avg_Sales -- Aggregate function (SUM), window function OVER() 
  FROM 
        amazon.amazon
    GROUP BY 
        `Product line`
) AS subquery;

-- 12.Identify the branch that exceeded the average number of products sold.
-- for branch A total product sold- 1859
-- for branch C- 1831
-- for branch b- 1820

SELECT 
    branch, SUM(quantity) AS Total_product_sold
FROM
    amazon.amazon
GROUP BY branch
ORDER BY Total_product_sold DESC;


-- 13.Which product line is most frequently associated with each gender?

-- product line        gender  gender count
-- Health and beauty	Female	64
-- Sports and travel	Male	78
-- Home and lifestyle	Female	79
-- Home and lifestyle	Male	81
-- Fashion accessories	Male	82
-- Food and beverages	Male	84
-- Electronic accessories	Female	84
-- Electronic accessories	Male	86
-- Health and beauty	Male	88
-- Sports and travel	Female	88
-- Food and beverages	Female	90
-- Fashion accessories	Female	96

SELECT 
    `product line`, gender, COUNT(*) AS gender_count
FROM
    amazon.amazon
GROUP BY `product line`, gender
ORDER BY gender_count, gender DESC;

-- 14.Calculate the average rating for each product line.
SELECT 
    `product line`, ROUND(AVG(rating),2) AS avg_rating
FROM
    amazon.amazon
GROUP BY `product line`
ORDER BY avg_rating DESC;

-- 15.Identify the customer type contributing the highest revenue.
-- customer type   highest_revenue
-- Member	         156403.28 Myanmar Kyat
-- Normal	         151184.1 Myanmar Kyat

SELECT 
    `customer type`,
    ROUND(SUM(`unit price` * quantity), 2) AS highest_revenue
FROM
    amazon.amazon
GROUP BY `customer type`
ORDER BY highest_revenue DESC

-- 16.Determine the city with the highest VAT percentage.
-- Naypyitaw has highest VAT percentage i.e 5265.18 Myanmar Kyat
SELECT 
    City, ROUND(SUM(`Tax 5%`), 2) AS highest_VAT
FROM
    amazon.amazon
GROUP BY city
ORDER BY highest_VAT DESC;

-- 17.Identify the customer type with the highest VAT payments.
-- member customer type is having highest VAT payment i.e. 7820.16 Myanmar Kyat

SELECT 
    `customer type`, ROUND(SUM(`Tax 5%`), 2) AS highest_VAT
FROM
    amazon.amazon
GROUP BY `customer type`
ORDER BY highest_VAT DESC;

-- 18 What is the count of distinct customer types in the dataset?
-- count od distinct customer type is 2
SELECT 
    COUNT(DISTINCT `customer type`) AS Dist_cust_type
FROM
    amazon.amazon
    
-- 19.What is the count of distinct payment methods in the dataset?
-- count of distinct payment method is 3

SELECT 
    COUNT(DISTINCT Payment) AS Dist_pay_method
FROM
    amazon.amazon
    
-- 20.Which customer type occurs most frequently?
-- member customer type has occured most frequently

SELECT 
    `customer type`, COUNT(quantity) AS frequency
FROM
    amazon.amazon
GROUP BY `customer type`
ORDER BY frequency DESC;

-- 21.Identify the customer type with the highest purchase frequency
-- member customer type has highest purchase frequency as 164223.44  Myanmar Kyat

SELECT 
    `customer type`, ROUND(SUM(total),2) AS highest_pur_frequency
FROM
    amazon.amazon
GROUP BY `customer type`
ORDER BY highest_pur_frequency DESC

-- 22.Determine the predominant gender among customers.
-- predominant gender among customers in dataset is female.
-- gender          total_customer
-- female          501
-- male            499

SELECT 
    gender, COUNT(*) AS total_customer
FROM
    amazon.amazon
GROUP BY gender
ORDER BY total_customer DESC;

-- 23.Examine the distribution of genders within each branch.
-- gender  Branch dist_of_ gender
-- Female	C	   178
-- Female	B	   162
-- Female	A	   161
-- Male	    A	   179
-- Male 	B	   170
-- Male	    C	   150

SELECT 
    gender, branch, COUNT(*) AS dist_of_gender
FROM
    amazon.amazon
GROUP BY gender, branch
ORDER BY gender,dist_of_gender DESC

-- 24.Count the sales occurrences for each time of day on every weekday.

SELECT 
    timeofday, dayname, COUNT(*) AS sales_occurences
FROM
    amazon.amazon
GROUP BY timeofday , dayname
ORDER BY sales_occurences DESC;

-- 25.Identify the time of day when customers provide the most ratings.
-- In afternoon time customer provides most ratings i.e 528

SELECT 
    timeofday, count(*) as rating_count
FROM
    amazon.amazon
GROUP BY timeofday
ORDER BY rating_count DESC
limit 5;

-- 26.Determine the time of day with the highest customer ratings for each branch

-- timeofday   Branch rating_count
-- Afternoon	A	   185
-- Evening	    A	   82
-- Morning  	A	   73
-- Afternoon	B	   162
-- Evening	    B	   111

SELECT 
    timeofday, branch, count(*) as rating_count
FROM
    amazon.amazon
GROUP BY timeofday,branch
ORDER BY branch,rating_count DESC
limit 5;

-- 27.Identify the day of the week with the highest average ratings.

-- dayname     avg_rating
-- Saturday	   164
-- Tuesday	   158
-- Wednesday	143
-- Friday	   139
-- Thursday	   138

SELECT 
    dayname, count(*) as avg_rating
FROM
    amazon.amazon
GROUP BY dayname
ORDER BY avg_rating DESC
limit 5;

-- 28.Determine the day of the week with the highest average ratings for each branch.

SELECT 
    dayname, branch, count(*) as avg_rating
FROM
    amazon.amazon
GROUP BY dayname,branch
ORDER BY branch,avg_rating DESC
