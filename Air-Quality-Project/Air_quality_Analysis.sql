use aqi;

CREATE TABLE aqi_cleaned LIKE aqi_raw;

SET SQL_SAFE_UPDATES = 0;

UPDATE aqi_cleaned
SET 
    PM_Ratio = ROUND(PM_Ratio, 4),
    NO2_NOx_Ratio = ROUND(NO2_NOx_Ratio, 4),
    CO_O3_Ratio = ROUND(CO_O3_Ratio, 4),
    SO2_NO2_Ratio = ROUND(SO2_NO2_Ratio, 4);
    
-- SELECT 
--     a.City,
--     a.Date,
--     a.AQI,
--     a.Month,
--     a.Year,
--     round(m.Monthly_AQI,2)
-- FROM aqi_cleaned a
-- JOIN (
--     SELECT 
--         City,
--         Year,
--         Month,
--         AVG(AQI) AS Monthly_AQI
--     FROM aqi_cleaned
--     GROUP BY City, Year, Month
-- ) m
-- ON a.City = m.City 
-- AND a.Year = m.Year 
-- AND a.Month = m.Month;

SELECT 
    a.City,
    a.Date,
    a.AQI,
    a.Month,
    a.Year,
    a.Monthly_AQI
FROM aqi_cleaned AS a;


SELECT City, round(AVG(AQI),2) AS Avg_AQI
FROM aqi_cleaned
GROUP BY City
HAVING Avg_AQI > (
    SELECT AVG(AQI) FROM aqi_cleaned
);

SELECT City, Year, AVG(AQI) as avg_aqi,
RANK() OVER (PARTITION BY Year ORDER BY AVG(AQI) DESC) as rank_city
FROM aqi_cleaned
GROUP BY City, Year;


SELECT 
    City,
    AQI,
    AVG(AQI) OVER (
        PARTITION BY City
        ORDER BY Date
    ) AS Moving_Avg_AQI
FROM aqi_cleaned;


CREATE TABLE IF NOT EXISTS aqi_city_summary (
    City           VARCHAR(100) PRIMARY KEY,
    Avg_AQI        FLOAT,
    Max_AQI        FLOAT,
    Min_AQI        FLOAT,
    Dominant_Bucket VARCHAR(50),
    Total_Days     INT
);

INSERT INTO aqi_city_summary
SELECT
    City,
    ROUND(AVG(AQI), 2),
    MAX(AQI),
    MIN(AQI),
    -- Most frequent AQI bucket
    (SELECT AQI_Bucket
     FROM aqi_cleaned c2
     WHERE c2.City = c1.City AND AQI_Bucket IS NOT NULL
     GROUP BY AQI_Bucket ORDER BY COUNT(*) DESC LIMIT 1),
    COUNT(DISTINCT Date)
FROM aqi_cleaned c1
GROUP BY City;