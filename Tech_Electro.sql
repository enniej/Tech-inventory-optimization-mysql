# preliminaries- Creation of Databases/schema
CREATE SCHEMA tech_electro;
Use tech_electro;

# Data Exploration
SELECT * FROM tech_electro.`sales data`Limit 5;
SELECT * FROM inventory_data Limit 5;
SELECT * FROM external_factors Limit 5;
SELECT * FROM Product_information Limit 5;

# understanding structure of the dataset
SHOW COLUMNS FROM external_factors;
DESCRIBE Product_information;
DESC `sales data`;

# Data Cleaning
-- Changing to the right data type for all columns 
-- External factors table

ALTER TABLE external_factors 
ADD COLUMN New_Sales_Date Date;
SELECT * FROM external_factors;
ALTER TABLE external_factors 
RENAME COLUMN `Sales Date` TO `Sales_Date`;


-- Turn off safe updates
SET SQL_SAFE_UPDATES = 0;
UPDATE external_factors 
SET New_Sales_Date = STR_TO_DATE(Sales_Date, '%d/%m/Y');

ALTER TABLE external_factors
DROP COLUMN  Sales_Date;
ALTER TABLE external_factors
CHANGE COLUMN  New_Sales_Date Sales_Date DATE;
SELECT * FROM external_factors;

-- modify GDP to make the  15 by 2
ALTER TABLE external_factors
MODIFY COLUMN GDP DECIMAL (15,2);
-- rename infation rate column
ALTER TABLE external_factors
RENAME COLUMN `Inflation Rate` TO Inflation_Rate;

ALTER TABLE external_factors 
MODIFY COLUMN Inflation_Rate DECIMAL (15,2);

-- rename seasonal factor column
ALTER TABLE external_factors
RENAME COLUMN `Seasonal Factor`  TO Seasonal_Factor;
ALTER TABLE external_factors
MODIFY COLUMN Seasonal_Factor DECIMAL (15,2);
-- check if all the changes are implemented 
SHOW COLUMNS FROM external_Factors;

-- product 
-- Product_ID INT NOT NULL, Product _ Category TEXT, Promotions  ENUM('yes','no')
ALTER TABLE Product_Information
ADD COLUMN NewPromotions ENUM('yes','no');
UPDATE Product_Information
SET NewPromotions = CASE
WHEN Promotions ='yes' THEN 'yes'
WHEN Promotions ='no' THEN 'no'
ELSE null
END;

-- drop the initial promotions table 
ALTER TABLE Product_Information
DROP COLUMN Promotions;
-- change the new column to what you want
ALTER TABLE Product_Information
CHANGE COLUMN NewPromotions Promotions ENUM('yes','no');

-- Rename for easy understanding
ALTER TABLE Product_Information
RENAME COLUMN `Product ID` TO Product_ID;
ALTER TABLE Product_Information
RENAME COLUMN `Product Category` TO Product_Category;
select * from Product_Information;

-- sales data
-- Product _id INT NOT NULL, Sales_Date DATE, Inventory_Quantity INT, Product_Cost  DECIMAL(10,2)
-- rename the column
ALTER TABLE `sales data`
RENAME COLUMN `Sales Date` TO `Sales_Date`;
ALTER TABLE `sales data`
RENAME COLUMN  `Inventory Quantity` TO  Inventory_Quantity;
ALTER TABLE `sales data`
RENAME COLUMN  `Product Cost` TO  Product_Cost;
ALTER TABLE `sales data`
RENAME COLUMN  `Product ID` TO  Product_ID;
-- Add new column
ALTER TABLE `sales data`
ADD COLUMN New_Sales_Date Date;
-- update the new column
UPDATE `sales data` 
SET New_Sales_Date = STR_TO_DATE(Sales_Date, '%d/%m/%Y');
-- drop the initial column
ALTER TABLE `sales data`
DROP COLUMN  Sales_Date;
-- change  new column to what you want it to be 
ALTER TABLE `sales data`
CHANGE COLUMN  New_Sales_Date Sales_Date DATE;
SELECT * FROM `sales data`;
SHOW COLUMNS FROM `sales data`;

-- Identify Missing Values using IS NULL function 
-- External Factors
SELECT 
	SUM(CASE WHEN sales_date IS NULL THEN 1 ELSE 0 END) AS missing_sales_date,
	SUM(CASE WHEN GDP IS NULL THEN 1 ELSE 0 END) AS missing_GDP,
    SUM(CASE WHEN Inflation_Rate IS NULL THEN 1 ELSE 0 END) AS missing_Inflation_Rate,
    SUM(CASE WHEN Seasonal_Factor IS NULL THEN 1 ELSE 0 END) AS missing_Seasonal_Factor
    FROM External_Factors;

-- Identify Missing Values using IS NULL function 
-- Product_information
SELECT 
	SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS missing_Product_ID,
	SUM(CASE WHEN Product_Category IS NULL THEN 1 ELSE 0 END) AS missing_Product_Category,
    SUM(CASE WHEN Promotions IS NULL THEN 1 ELSE 0 END) AS missing_Promotions
    FROM Product_information;
select * from Product_information;

-- Identify Missing Values using IS NULL function 
-- Sales_Data
SELECT 
	SUM(CASE WHEN sales_date IS NULL THEN 1 ELSE 0 END) AS missing_sales_date,
	SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS missing_Product_ID,
    SUM(CASE WHEN Inventory_Quantity IS NULL THEN 1 ELSE 0 END) AS missing_Inventory_Quantity,
    SUM(CASE WHEN Product_Cost IS NULL THEN 1 ELSE 0 END) AS missing_Product_Cost
    FROM `Sales data`;
select*   FROM `Sales data`;


-- Investigating duplicates using groupby and "having" clauses and remove them if there are 
-- External_ Factors (using sales date as the pointer )
SELECT Sales_date, count(*) AS count
FROM External_Factors
group by Sales_date
having count > 1;

-- determine the entire number of duplicates 
SELECT COUNT(*) FROM (SELECT Sales_date, count(*) AS count
FROM External_Factors
group by Sales_date
having count > 1) AS dup;

-- product_information 
SELECT Product_id, product_category, COUNT(*) AS count
FROM product_information
group by Product_id, product_category
having count > 1;

-- determine the entire number of duplicates 
SELECT COUNT(*) FROM (SELECT Product_id, product_category, COUNT(*) AS count
FROM product_information
group by Product_id, product_category
having count > 1) AS dup;

--  `Sales data`
SELECT Product_id, Sales_Date, COUNT(*) AS count
FROM `Sales data`
group by Product_id, Sales_Date
having count > 1;

select * from `Sales data`;

-- Dealing with duplicates for external_factors and products_data
-- external factor
DELETE e1 FROM external_factors e1
INNER JOIN (
SELECT  Sales_Date,
ROW_NUMBER() OVER (PARTITION BY Sales_Date ORDER BY Sales_Date) AS rn
FROM external_factors
) e2 ON e1.Sales_Date = e2.Sales_Date
WHERE e2.rn > 1;

-- product_information

DELETE p1 FROM product_information p1
INNER JOIN (
SELECT  Product_ID,
ROW_NUMBER() OVER (PARTITION BY Product_ID ORDER BY Product_ID) AS rn
FROM product_information
) p2 ON p1.Product_ID = p2.Product_ID
WHERE p2.rn > 1;

select * from product_information;

-- DATA INTEGRATION(combining all the useful tables, all are useful in this case)

-- First, rename the table
RENAME TABLE `Sales data` TO sales_data;

-- sales_data and product_information first
CREATE OR REPLACE VIEW  sales_product_data AS
SELECT
s.Product_ID, 
s.Sales_Date,
s.Inventory_Quantity, 
s.Product_Cost, 
p.Product_Category,
p.Promotions
FROM sales_data s
JOIN  product_information p 
ON s.Product_ID = p.Product_ID;

SELECT * FROM sales_product_data;

-- sales_data and External_factors
CREATE OR REPLACE VIEW Inventory_view AS
SELECT
sp.Product_ID, 
sp.Sales_Date,
sp.Inventory_Quantity, 
sp.Product_Cost, 
sp.Promotions,
sp.Product_Category,
e.GDP,
e.Inflation_Rate,
e.Seasonal_factor
FROM sales_product_data sp
LEFT JOIN external_factors e 
ON sp.Sales_Date = e.Sales_Date;

SELECT * FROM Inventory_view;

-- Descriptive Analysis
-- Basic statistics
-- Average sales (calculated as the product of 'inventory quantity' and 'product cost')
SELECT 
	Product_ID,
	AVG(Inventory_Quantity * Product_Cost) AS avg_sales
FROM Inventory_view
GROUP BY Product_ID
ORDER BY avg_sales DESC;


-- Product performance metrics() total sales per product
SELECT Product_ID,
ROUND(SUM(Inventory_Quantity * Product_Cost)) as total_sales
FROM Inventory_view
GROUP BY Product_ID
ORDER BY total_sales DESC;

-- Identify high demand products
WITH HighDemandProducts AS (
SELECT Product_ID, AVG(Inventory_Quantity)
 as avg_sales
 FROM Inventory_view
 GROUP BY Product_ID
 HAVING avg_sales > (SELECT AVG(Inventory_Quantity)* 0.95 FROM sales_data)
 )
 
 -- calculate stockout frequency for high demand products
 SELECT s.Product_ID, COUNT(*) as stockout_frequency
 FROM Inventory_view s
 WHERE s.Product_ID IN (SELECT Product_ID FROM HighDemandProducts)
 AND s.Inventory_Quantity = 0
 GROUP BY s.Product_ID;
# Highdemand products are instock from the observation

-- Influence of external factors 
-- start with GDP
SELECT Product_ID,
AVG (CASE WHEN `GDP` > 0 THEN Inventory_Quantity ELSE NULL END) AS avg_sales_positive_gdp,
AVG (CASE WHEN `GDP` <= 0 THEN Inventory_Quantity ELSE NULL END) AS avg_sales_non_positive_gdp
FROM Inventory_view
GROUP BY  Product_ID
HAVING avg_sales_positive_gdp IS NOT NULL;

-- DO same for inflation
SELECT Product_ID,
AVG (CASE WHEN Inflation_Rate > 0 THEN Inventory_Quantity ELSE NULL END) AS avg_sales_positive_Inflation,
AVG (CASE WHEN Inflation_Rate <= 0 THEN Inventory_Quantity ELSE NULL END) AS avg_sales_non_positive_Inflation
FROM Inventory_view
GROUP BY  Product_ID
HAVING avg_sales_positive_Inflation IS NOT NULL;

-- Inventory Optimisation
-- Determine the optimal reorder point for each product based on historical sales data and external factors
-- Reorder Poibt = Lead Time Demand + Saftey Stock
-- saftey stock = Zx Lead Time^-2 xStandard deviation of demand
-- Z= 1.645
-- A constant lead time of 7 daya for all products
-- We aim for a 95% service level

WITH InventoryCalculations AS (
SELECT Product_ID,
AVG(rolling_avg_sales) as avg_rolling_sales,
AVG(rolling_variance) as avg_rolling_variance
FROM(
SELECT Product_ID,
AVG(daily_sales) OVER (PARTITION BY Product_ID ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as rolling_avg_sales,
AVG(squared_diff) OVER (PARTITION BY Product_ID ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as rolling_variance
FROM(
SELECT Product_ID,
Sales_Date, Inventory_Quantity * Product_Cost as daily_sales,
(Inventory_Quantity * Product_Cost - AVG(Inventory_Quantity * Product_Cost) OVER (PARTITION BY Product_ID ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW))
* (Inventory_Quantity * Product_Cost - AVG(Inventory_Quantity * Product_Cost) OVER (PARTITION BY Product_ID ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS squared_diff
FROM Inventory_view
) subquery
 ) subquery2
   GROUP BY Product_ID
)
SELECT Product_ID,
avg_rolling_sales * 7 as lead_time_demand,
 1.645 * (avg_rolling_variance * 7) as safety_stock,
(avg_rolling_sales * 7 ) + ( 1.645 * (avg_rolling_variance * 7))as reorder_point
FROM InventoryCalculations;

-- step 1 Create the inventort_optimisation table 
CREATE TABLE Inventory_optimisation (
Product_ID INT,
Reorder_Point DOUBLE
);

-- step 2: Create the stored procedure to recalculate the reorder_point

DELIMITER //
CREATE PROCEDURE  RecalculateReorderPoint(productID INT)
BEGIN
 DECLARE avgRollingSales Double;
 DECLARE avgRollingVariance Double;
 DECLARE leadTimeDemand Double;
 DECLARE safetyStock Double;
 DECLARE reorderPoint Double;
SELECT 
AVG(rolling_avg_sales), 
AVG(rolling_variance)
INTO avgRollingSales, avgRollingVariance
FROM(
SELECT Product_ID,
AVG(daily_sales) OVER (PARTITION BY Product_ID ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as rolling_avg_sales,
AVG(squared_diff) OVER (PARTITION BY Product_ID ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as rolling_variance
FROM(
SELECT Product_ID,
Sales_Date, Inventory_Quantity * Product_Cost as daily_sales,
(Inventory_Quantity * Product_Cost - AVG(Inventory_Quantity * Product_Cost) OVER (PARTITION BY Product_ID ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW))
* (Inventory_Quantity * Product_Cost - AVG(Inventory_Quantity * Product_Cost) OVER (PARTITION BY Product_ID ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS squared_diff
FROM Inventory_view
) InnerDerived
 ) OuterDerived;

	SET leadTimeDemand = avgRollingSales  * 7;
	SET safetyStock = 1.645 * SQRT(avgRollingVariance * 7);
	SET reorderPoint = leadTimeDemand + safetyStock;

INSERT INTO Inventory_optimisation  ( Product_ID, Reorder_Point)
VALUES (productID, reorderPoint)
ON DUPLICATE KEY UPDATE Reorder_Point = reorderPoint;
END //
DELIMITER ;

-- step 3 make inventory_view a permanent table
CREATE TABLE Inventory_table  AS SELECT * FROM Inventory_view;

select * from  Inventory_table;

-- step 4 Create the trigger
DELIMITER //
CREATE TRIGGER AfterInsertUnifiedTable
AFTER INSERT ON Inventory_table
FOR EACH ROW
BEGIN
 CALL RecalculateReorderPoint(NEW.Product_ID);
 END//
 DELIMITER ;

-- OVERSTOCKING AND UNDERSTOCKING
WITH RollingSales AS (
SELECT Product_ID,
Sales_Date,
AVG(Inventory_Quantity * Product_Cost) OVER (PARTITION BY Product_ID ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as rolling_avg_sales
FROM Inventory_table
),
 
 -- calculate the number of days a product was out of stock
 StockoutDays AS (
 SELECT Product_ID,
 COUNT(*) as stockout_days
 FROM Inventory_table
 WHERE Inventory_Quantity = 0
 GROUP BY Product_ID
 )
 -- join the above CTEs with the main table to get results
 SELECT f.Product_ID,
 AVG(f.Inventory_Quantity * f.Product_Cost) as avg_inventory_value,
 AVG(rs.rolling_avg_sales) as avg_rolling_sales,
  COALESCE(sd.stockout_days, 0) as stockout_days
FROM Inventory_table f
JOIN RollingSales rs ON f.Product_ID = rs.Product_ID AND f.Sales_Date = rs.Sales_Date
LEFT JOIN StockoutDays sd ON f.Product_ID = sd.Product_ID
GROUP BY f.Product_ID,  sd.Stockout_days;

-- create a stored procedure to monitor and adjust
-- monitor inventory levels
 DELIMITER //
CREATE PROCEDURE MonitorInventoryLevels()
BEGIN
SELECT Product_ID, AVG(Inventory_Quantity) as AvgInventory
FROM Inventory_table
GROUP BY Product_ID
ORDER BY AvgInventory DESC;
END//
DELIMITER ;
 
 -- monitor sales trend
 
  DELIMITER //
CREATE PROCEDURE MonitorSalesTrend()
BEGIN
SELECT Product_ID, Sales_Date, AVG(Inventory_Quantity * Product_Cost) OVER (PARTITION BY Product_ID ORDER BY Sales_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as rolling_avg_sales
FROM Inventory_table
ORDER BY Product_ID, Sales_Date ;
END//
DELIMITER ;
 
-- monitor stock out frequencies
   DELIMITER //
CREATE PROCEDURE MonitorStockouts()
BEGIN
SELECT Product_ID, COUNT(*) as StockoutDays 
FROM Inventory_table
WHERE Inventory_Quantity = 0
ORDER BY StockoutDays DESC;
END//
DELIMITER ;
 
-- FEEDBACK LOOP

-- Feedback Loop Establishment;
-- Feedback Portal: Develop an online platform for stakeholders to easily submit feedback on inventory performance and challenges.
-- Review Meetings: Organize periodic sessions to discuss inventory system performance and gather direct insights.
-- System Monitoring: Use established SQL procedures to track system metrics, with deviations from expectations flagged for review.

-- Refinement Based on Feedback:
-- Feedback Analysis: Regularly compile and scrutinize feedback to identify recurring themes or pressing issues.
-- Action Implementation: Prioritize and act on the feedback to adjust reorder points, safety stock levels, or overall processes.
-- Change Communication: Inform stakeholders about changes, underscoring the value of their feedback and ensuring transparency.
 
 
 
 -- General Insights:

-- Inventory Discrepancies: The initial stages of the analysis revealed significant discrepancies in inventory levels, with instances of both overstocking and understocking.
--  These inconsistencies were contributing to capital inefficiencies and customer dissatisfaction.

-- Sales Trends and External Influences: The analysis indicated that sales trends were notably influenced by various external factors.
--  Recognizing these patterns provides an opportunity to forecast demand more accurately.

-- Suboptimal Inventory Levels: Through the inventory optimization analysis, it was evident that the existing inventory levels were not optimized for current sales trends.
-- Products was identified that had either close excess inventory.


-- Recommendations:

-- 1. Implement Dynamic Inventory Management: The company should transition from a static to a dynamic inventory management system,
--  adjusting inventory levels based on real-time sales trends, seasonality, and external factors.

-- 2. Optimize Reorder Points and Safety Stocks: Utilize the reorder points and safety stocks calculated during the analysis to minimize stockouts and reduce excess inventory.
-- Regularly review these metrics to ensure they align with current market conditions.

-- 3. Enhance Pricing Strategies: Conduct a thorough review of product pricing strategies, especially for products identified as unprofitable.
-- Consider factors such as competitor pricing, market demand, and product acquisition costs.

-- 4. Reduce Overstock: Identify products that are consistently overstocked and take steps to reduce their inventory levels.
-- This could include promotional sales, discounts, or even discontinuing products with low sales performance.

-- 5. Establish a Feedback Loop: Develop a systematic approach to collect and analyze feedback from various stakeholders.
-- Use this feedback for continuous improvement and alignment with business objectives.

-- 6. Regular Monitoring and Adjustments: Adopt a proactive approach to inventory management by regularly monitoring key metrics
-- and making necessary adjustments to inventory levels, order quantities, and safety stocks.
 













