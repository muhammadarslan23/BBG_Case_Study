-- Create a temporary table for sales data
CREATE OR REPLACE TEMPORARY VIEW sales_data AS
SELECT * FROM sales_and_traffic_data;

-- Create a temporary table for shop mapping data
CREATE OR REPLACE TEMPORARY VIEW shop_mapping AS
SELECT * FROM amazon_shop_mapping;

-- Define a User-Defined Function (UDF) to convert currency
CREATE OR REPLACE FUNCTION convert_to_euro(amount FLOAT, currency STRING)
RETURNS FLOAT
BEGIN
  DECLARE exchange_rate FLOAT;
  
  SET exchange_rate = 0.85;
  
  -- Convert currency to Euro
  IF currency IS NULL THEN
    RETURN 0.0;
  ELSE
    RETURN ROUND(amount * exchange_rate, 2);
  END IF;
END;

-- Register the UDF for conversion

-- Join the sales_data with shop_mapping to get currency information
CREATE OR REPLACE TEMPORARY VIEW joined_data AS
SELECT s.*, m.currency
FROM sales_data s
LEFT JOIN shop_mapping m
ON s.shop_name = m.shop_name;

-- Perform currency conversion using the UDF
CREATE OR REPLACE TEMPORARY VIEW sales_data_with_euro AS
SELECT *,
       convert_to_euro(ordered_products_sale, currency) AS ordered_products_sale_euro
FROM joined_data;

-- Calculate the total revenue
SELECT ROUND(SUM(ordered_products_sale_euro), 2) AS total_revenue
FROM sales_data_with_euro;

-- Total revenue per country
SELECT country, ROUND(SUM(ordered_products_sale_euro), 2) AS total_revenue_per_country
FROM sales_data_with_euro
GROUP BY country;

-- Total revenue per shop
SELECT shop_name, ROUND(SUM(ordered_products_sale_euro), 2) AS total_revenue_per_shop
FROM sales_data_with_euro
GROUP BY shop_name;


-- We can extract month from the report_date

-- Total revenue per month
SELECT month, ROUND(SUM(ordered_products_sale_euro), 2) AS total_revenue_per_month
FROM sales_data_with_euro
GROUP BY month;
