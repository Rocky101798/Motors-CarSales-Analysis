--View the data
SELECT *  FROM studies101.brightlearn.carsales;

--Counting the total rows
SELECT COUNT(*) AS Total_rows
FROM studies101.brightlearn.carsales;

--Checking the unique makes of the cars
SELECT DISTINCT(make)
FROM studies101.brightlearn.carsales;

--Checking for unique states(regions)
---unique states
SELECT DISTINCT state,
        COUNT(*) AS count
FROM studies101.brightlearn.carsales
GROUP BY state
ORDER BY count DESC;

--checking for unique colors
SELECT DISTINCT(color)
FROM studies101.brightlearn.carsales

--checking for unique interiors
SELECT DISTINCT(interior)
FROM studies101.brightlearn.carsales

--checking for unique body types
SELECT DISTINCT body,
        COUNT(*) AS count
FROM studies101.brightlearn.carsales
GROUP BY body
ORDER BY count DESC;

--Checking both Coupe and coupe
SELECT * 
FROM studies101.brightlearn.carsales
WHERE body LIKE '%oupe%';

---unique transmission 
SELECT DISTINCT transmission,
        COUNT(*) AS count
FROM studies101.brightlearn.carsales
GROUP BY transmission
ORDER BY count DESC;

--simple filtering 
SELECT * 
FROM studies101.brightlearn.carsales
WHERE year > 2014;

--Seeing the expensive cars
SELECT * 
FROM studies101.brightlearn.carsales
WHERE sellingprice > 80000;

--Seeing the low mileage cars
SELECT * 
FROM studies101.brightlearn.carsales
WHERE odometer < 10000;

--looking at specific models: 
SELECT *
FROM studies101.brightlearn.carsales
WHERE make = 'BMW';


--Revenue by make 
SELECT make, 
    COUNT(*) AS Total_sales,
    SUM(sellingprice) AS total_revenue
FROM studies101.brightlearn.carsales
GROUP BY make
ORDER BY total_revenue DESC;

--Top models
SELECT make, 
      model,
      COUNT(*) AS sales_count, 
      SUM(sellingprice) AS total_revenue
FROM studies101.brightlearn.carsales
GROUP BY make, model
ORDER BY total_revenue DESC;

--sales by region 
SELECT state,
      COUNT(*) AS sales_count, 
      SUM(sellingprice) AS total_revenue 
FROM studies101.brightlearn.carsales
GROUP BY state
ORDER BY total_revenue DESC;

--looking at the price vs the mileage
SELECT ROUND(AVG(odometer),2) AS average_mileage, 
      ROUND(AVG(sellingprice),2) AS average_price
FROM studies101.brightlearn.carsales

--condition analysis
SELECT condition, 
   COUNT(*) AS total_cars,
    ROUND(AVG(sellingprice), 2) AS average_price
FROM studies101.brightlearn.carsales
GROUP BY condition
ORDER BY average_price DESC;

---the difference between the profit and price 
SELECT make,
      model,
      ROUND(AVG(sellingprice - mmr),2) AS average_profit
FROM studies101.brightlearn.carsales
GROUP BY make, model
ORDER BY average_profit DESC;

--this is to see the profit margins
SELECT *,
       ROUND(((sellingprice - mmr) / sellingprice) * 100, 2) AS profit_margin_pct
FROM studies101.brightlearn.carsales

---Time trend to see which year was the most profitable  
SELECT 
    EXTRACT(YEAR FROM SAFE.PARSE_TIMESTAMP('%a %b %d %Y %H:%M:%S', saledate)) AS year,
    COUNT(*) AS sales_count,
    AVG(sellingprice) AS avg_price
FROM studies101.brightlearn.carsales
GROUP BY year
ORDER BY year;

---Checking for NULLS and blanks within the dataset
SELECT
    COUNT(*) - COUNT(NULLIF(TRIM(year), '')) AS missing_year,
    COUNT(*) - COUNT(NULLIF(TRIM(make), '')) AS missing_make,
    COUNT(*) - COUNT(NULLIF(TRIM(model), '')) AS missing_model,
    COUNT(*) - COUNT(NULLIF(TRIM(body), '')) AS missing_body,
    COUNT(*) - COUNT(NULLIF(TRIM(transmission), '')) AS missing_transmission,
    COUNT(*) - COUNT(NULLIF(TRIM(condition), '')) AS missing_condition,
    COUNT(*) - COUNT(NULLIF(TRIM(odometer), '')) AS missing_odometer,
    COUNT(*) - COUNT(NULLIF(TRIM(color), '')) AS missing_color,
    COUNT(*) - COUNT(NULLIF(TRIM(interior), '')) AS missing_interior,
    COUNT(*) - COUNT(NULLIF(TRIM(mmr), '')) AS missing_mmr,
    COUNT(*) - COUNT(NULLIF(TRIM(sellingprice), '')) AS missing_sellingprice,
    COUNT(*) - COUNT(NULLIF(TRIM(saledate), '')) AS missing_saledate
FROM studies101.brightlearn.carsales;

---Top 10 makes by volume
SELECT make, 
    COUNT(*) AS count
FROM studies101.brightlearn.carsales
GROUP BY make
ORDER BY count DESC
LIMIT 10;

---checking price ranges 
SELECT MIN(CAST(sellingprice AS DECIMAL(10,2))) AS lowest_price,
    MAX(CAST(sellingprice AS DECIMAL(10,2))) AS highest_price, 
    ROUND(AVG(CAST(sellingprice AS DECIMAL(10,2))),2) AS avg_price
FROM studies101.brightlearn.carsales
WHERE sellingprice IS NOT NULL
AND TRIM(sellingprice) != '';

------CLEANING THE DATASET NOW UNSING TRIM, UPPER, CAST, COALESCE, CASE

SELECT
 -- YEAR
    CAST(TRIM(year) AS INTEGER) AS year,
-- MAKE
    COALESCE(NULLIF(UPPER(TRIM(make)), ''), 'UNKNOWN') AS make,
-- MODEL
    COALESCE(NULLIF(UPPER(TRIM(model)), ''), 'UNKNOWN') AS model,
-- TRIM LEVEL (renamed to avoid conflict with TRIM function)
    COALESCE(NULLIF(UPPER(TRIM(trim)), ''), 'UNKNOWN') AS trim_level,
-- BODY TYPE (consolidated into clean categories)
    CASE
        WHEN UPPER(TRIM(body)) = 'SUV' THEN 'SUV'
        WHEN UPPER(TRIM(body)) = 'SEDAN' THEN 'SEDAN'
        WHEN UPPER(TRIM(body)) LIKE '%COUPE%' THEN 'COUPE'
        WHEN UPPER(TRIM(body)) LIKE '%CONVERTIBLE%' THEN 'CONVERTIBLE'
        WHEN UPPER(TRIM(body)) LIKE '%WAGON%' THEN 'WAGON'
        WHEN UPPER(TRIM(body)) LIKE '%VAN%' THEN 'VAN'
        WHEN UPPER(TRIM(body)) LIKE '%CAB%' THEN 'TRUCK/CAB'
        WHEN UPPER(TRIM(body)) = 'HATCHBACK'THEN 'HATCHBACK'
        WHEN UPPER(TRIM(body)) = 'MINIVAN' THEN 'MINIVAN'
        WHEN UPPER(TRIM(body)) = 'SUPERCREW' THEN 'TRUCK/CAB'
        WHEN body IS NULL OR TRIM(body) = ''THEN 'UNKNOWN'
        ELSE UPPER(TRIM(body))
    END AS body,
 -- TRANSMISSION (fix nulls and misplaced values)
    CASE
        WHEN UPPER(TRIM(transmission)) = 'AUTOMATIC' THEN 'AUTOMATIC'
        WHEN UPPER(TRIM(transmission)) = 'MANUAL' THEN 'MANUAL'
        ELSE 'UNKNOWN'
    END AS transmission,
 -- VIN (uppercase for consistency)
    UPPER(TRIM(vin)) AS vin,
-- STATE (uppercase for consistency)
    UPPER(TRIM(state)) AS state,
-- CONDITION SCORE (replace blanks with 0)
    CAST(COALESCE(NULLIF(TRIM(condition), ''), '0')AS DECIMAL(4,1)) AS condition_score,
 -- ODOMETER (replace blanks with 0)
    CAST(COALESCE(NULLIF(TRIM(odometer), ''), '0')
    AS INTEGER) AS odometer,
-- COLOR (reject numeric codes and symbols)
    CASE
        WHEN TRIM(color) REGEXP '^[0-9]+$'
          OR TRIM(color) = '—'
          OR TRIM(color) = ''
          OR color IS NULL THEN 'UNKNOWN'
        ELSE UPPER(TRIM(color))
    END AS color,
 -- INTERIOR (same treatment as color)
    CASE
        WHEN TRIM(interior) REGEXP '^[0-9]+$'
          OR TRIM(interior) = '—'
          OR TRIM(interior) = ''
          OR interior IS NULL THEN 'UNKNOWN'
        ELSE UPPER(TRIM(interior))
    END AS interior,
 -- SELLER (collapse double spaces)
    UPPER(REPLACE(TRIM(seller), '  ', ' '))  AS seller,
-- COST PRICE (mmr = Manheim Market Report = wholesale price)
    CAST(COALESCE(NULLIF(TRIM(mmr), ''), sellingprice)
    AS DECIMAL(10,2)) AS cost_price,
-- SELLING PRICE
    CAST(TRIM(sellingprice) AS DECIMAL(10,2)) AS selling_price,
-- SALE DATE (parse manually due to Spark 3.0+ DateTimeFormatter limitations)
    TO_TIMESTAMP(
        CONCAT(
            SPLIT(TRIM(saledate), ' ')[3], '-',
            CASE SPLIT(TRIM(saledate), ' ')[1]
                WHEN 'Jan' THEN '01'
                WHEN 'Feb' THEN '02'
                WHEN 'Mar' THEN '03'
                WHEN 'Apr' THEN '04'
                WHEN 'May' THEN '05'
                WHEN 'Jun' THEN '06'
                WHEN 'Jul' THEN '07'
                WHEN 'Aug' THEN '08'
                WHEN 'Sep' THEN '09'
                WHEN 'Oct' THEN '10'
                WHEN 'Nov' THEN '11'
                WHEN 'Dec' THEN '12'
            END, '-',
            LPAD(SPLIT(TRIM(saledate), ' ')[2], 2, '0'), ' ',
            SPLIT(TRIM(saledate), ' ')[4]
        ),
        'yyyy-MM-dd HH:mm:ss'
    ) AS sale_timestamp

FROM studies101.brightlearn.carsales
WHERE vin IS NOT NULL
  AND TRIM(vin) != ''
  AND sellingprice IS NOT NULL
  AND TRIM(sellingprice) != ''
  AND TRIM(sellingprice) != '1'
QUALIFY ROW_NUMBER() OVER (
            PARTITION BY vin
            ORDER BY saledate DESC)     = 1
LIMIT 10;
