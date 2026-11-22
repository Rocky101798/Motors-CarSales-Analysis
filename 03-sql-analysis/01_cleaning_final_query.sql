SELECT
-- YEAR
    CAST(TRIM(year) AS INTEGER) AS year,
-- MAKE
    COALESCE(NULLIF(UPPER(TRIM(make)), ''), 'UNKNOWN') AS make,
-- MODEL
    COALESCE(NULLIF(UPPER(TRIM(model)), ''), 'UNKNOWN') AS model,
-- TRIM LEVEL
    COALESCE(NULLIF(UPPER(TRIM(trim)), ''), 'UNKNOWN') AS trim_level,
-- BODY TYPE
    CASE
        WHEN UPPER(TRIM(body)) = 'SUV' THEN 'SUV'
        WHEN UPPER(TRIM(body)) = 'SEDAN'THEN 'SEDAN'
        WHEN UPPER(TRIM(body)) LIKE '%COUPE%' THEN 'COUPE'
        WHEN UPPER(TRIM(body)) LIKE '%CONVERTIBLE%' THEN 'CONVERTIBLE'
        WHEN UPPER(TRIM(body)) LIKE '%WAGON%' THEN 'WAGON'
        WHEN UPPER(TRIM(body)) LIKE '%VAN%' THEN 'VAN'
        WHEN UPPER(TRIM(body)) LIKE '%CAB%' THEN 'TRUCK/CAB'
        WHEN UPPER(TRIM(body)) = 'HATCHBACK' THEN 'HATCHBACK'
        WHEN UPPER(TRIM(body)) = 'MINIVAN' THEN 'MINIVAN'
        WHEN UPPER(TRIM(body)) = 'SUPERCREW' THEN 'TRUCK/CAB'
        WHEN body IS NULL OR TRIM(body) = '' THEN 'UNKNOWN'
        ELSE UPPER(TRIM(body))
    END AS body,
-- TRANSMISSION
    CASE
        WHEN UPPER(TRIM(transmission)) = 'AUTOMATIC' THEN 'AUTOMATIC'
        WHEN UPPER(TRIM(transmission)) = 'MANUAL' THEN 'MANUAL'
        ELSE 'UNKNOWN'
    END AS transmission,
-- VIN
    UPPER(TRIM(vin)) AS vin,
-- STATE
    UPPER(TRIM(state)) AS state,
-- COLOR
    CASE
        WHEN TRIM(color) REGEXP '^[0-9]+$'
          OR TRIM(color) = '—'
          OR TRIM(color) = ''
          OR color IS NULL THEN 'UNKNOWN'
        ELSE UPPER(TRIM(color))
    END  AS color,
-- INTERIOR
    CASE
        WHEN TRIM(interior) REGEXP '^[0-9]+$'
          OR TRIM(interior) = '—'
          OR TRIM(interior) = ''
          OR interior IS NULL THEN 'UNKNOWN'
        ELSE UPPER(TRIM(interior))
    END AS interior,
-- SELLER
    UPPER(REPLACE(TRIM(seller), '  ', ' '))  AS seller,
 -- -------------------------------------------------------
    -- METRICS — My pivot table value fields
    -- -------------------------------------------------------
-- CONDITION SCORE
    CAST(COALESCE(NULLIF(TRIM(condition), ''), '0') AS DECIMAL(4,1)) AS condition_score,
-- ODOMETER
    CAST(COALESCE(NULLIF(TRIM(odometer), ''), '0')
    AS INTEGER) AS odometer,
-- COST PRICE (mmr = wholesale price)
    CAST(COALESCE(NULLIF(TRIM(mmr), ''), sellingprice)
    AS DECIMAL(10,2)) AS cost_price,
-- SELLING PRICE
    CAST(TRIM(sellingprice) AS DECIMAL(10,2)) AS selling_price,
-- TOTAL REVENUE (one vehicle per row in this dataset)
    CAST(TRIM(sellingprice) AS DECIMAL(10,2)) * 1  AS total_revenue,
-- PROFIT (selling price minus wholesale cost)
    CAST(TRIM(sellingprice) AS DECIMAL(10,2)) -
    CAST(COALESCE(NULLIF(TRIM(mmr), ''),
        sellingprice) AS DECIMAL(10,2)) AS profit,
-- PROFIT MARGIN %
    ROUND((CAST(TRIM(sellingprice) AS DECIMAL(10,2)) -
            CAST(COALESCE(NULLIF(TRIM(mmr), ''),sellingprice) AS DECIMAL(10,2)))
        / NULLIF(CAST(TRIM(sellingprice) AS DECIMAL(10,2)), 0)
        * 100
    , 2) AS profit_margin_pct,

-- -------------------------------------------------------
-- CALCULATED CATEGORIES — slicers for dashboards incase
-- -------------------------------------------------------
-- MARGIN TIER
    CASE
        WHEN ROUND(
                (CAST(TRIM(sellingprice) AS DECIMAL(10,2)) -
                 CAST(COALESCE(NULLIF(TRIM(mmr),''),
                     sellingprice) AS DECIMAL(10,2)))
                / NULLIF(CAST(TRIM(sellingprice)
                     AS DECIMAL(10,2)),0) * 100, 2)
             >= 20 THEN 'High Margin'
        WHEN ROUND(
                (CAST(TRIM(sellingprice) AS DECIMAL(10,2)) -
                 CAST(COALESCE(NULLIF(TRIM(mmr),''),
                     sellingprice) AS DECIMAL(10,2)))
                / NULLIF(CAST(TRIM(sellingprice)
                     AS DECIMAL(10,2)),0) * 100, 2)
             >= 0 THEN 'Medium Margin'
        ELSE 'Loss'
    END AS margin_tier,
-- PRICE BAND
    CASE
        WHEN CAST(TRIM(sellingprice) AS DECIMAL(10,2)) < 10000
            THEN 'Under $10K'
        WHEN CAST(TRIM(sellingprice) AS DECIMAL(10,2))
            BETWEEN 10000 AND 20000
            THEN '$10K - $20K'
        WHEN CAST(TRIM(sellingprice) AS DECIMAL(10,2))
            BETWEEN 20001 AND 40000
            THEN '$20K - $40K'
        WHEN CAST(TRIM(sellingprice) AS DECIMAL(10,2))
            BETWEEN 40001 AND 70000
            THEN '$40K - $70K'
        ELSE 'Over $70K'
    END AS price_band,
-- MILEAGE BAND
    CASE
        WHEN CAST(COALESCE(NULLIF(TRIM(odometer),''),
             '0') AS INTEGER) < 20000
            THEN 'Low (0-20K)'
        WHEN CAST(COALESCE(NULLIF(TRIM(odometer),''),
             '0') AS INTEGER) BETWEEN 20000 AND 60000
            THEN 'Medium (20K-60K)'
        WHEN CAST(COALESCE(NULLIF(TRIM(odometer),''),
             '0') AS INTEGER) BETWEEN 60001 AND 100000
            THEN 'High (60K-100K)'
        ELSE 'Very High (100K+)'
    END AS mileage_band

FROM studies101.brightlearn.carsales
WHERE vin IS NOT NULL
  AND TRIM(vin) != ''
  AND sellingprice IS NOT NULL
  AND TRIM(sellingprice) != ''
  AND TRIM(sellingprice) != '1'
QUALIFY ROW_NUMBER() OVER (
            PARTITION BY vin
            ORDER BY saledate DESC) = 1
ORDER BY year DESC;
