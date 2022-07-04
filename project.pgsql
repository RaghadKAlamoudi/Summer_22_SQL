/*Create View forestation */
CREATE VIEW forestation AS
SELECT a.country_code, a.country_name, re.region, 
	a.forest_area_sqkm,(la.total_area_sq_mi * 2.59) AS total_area_sqkm, 		
	(100.0* a.forest_area_sqkm / 
    (la.total_area_sq_mi * 2.59)) AS presentage_of_land,
    re.income_group, a.year
FROM forest_area a
JOIN land_area la
	ON a.country_code = la.country_code
	    AND a.year = la.year 
JOIN regions re
	ON re.country_code = a.country_code;

--PART 1: Global Situation 

--a- What was the total forest area (in sq km) of the world in 1990? 
--Please keep in mind that you can use the country record denoted as
--“World" in the region table.

SELECT a.forest_area_sqkm
		FROM forest_area a
        WHERE a.country_name = 'World'
        	AND a.year = 1990;

--b-What was the total forest area (in sq km) of the world in 2016? 
--Please keep in mind that you can use the country record
--in the table is denoted as "World"?
SELECT a.forest_area_sqkm
		FROM forest_area a
        WHERE a.country_name = 'World'
        	AND a.year = 2016;

-- c. What was the change (in sq km) in the forest area 
-- of the world from 1990 to 2016?
SELECT sub1.forest_area_sqkm - sub2.forest_area_sqkm AS deff_forest_area_sq_km
      FROM (SELECT a.country_code AS cc, a.forest_area_sqkm
      	    FROM forest_area a
              WHERE a.country_name = 'World'
              	AND a.year = 1990) AS sub1
      JOIN (SELECT a.country_code AS cc,a.forest_area_sqkm
      		FROM forest_area a
              WHERE a.country_name = 'World'
              	AND a.year = 2016) AS sub2
      ON sub1 = sub2;

-- d. What was the percent change in forest area of 
-- the world between 1990 and 2016?
SELECT ((sub1.forest_area_sqkm-sub2.forest_area_sqkm)/sub1.forest_area_sqkm)*100  AS 
		percantage_change_forest_area
      FROM (SELECT a.country_code AS cc, a.forest_area_sqkm
      	    FROM forest_area amount
              WHERE a.country_name = 'World'
              	AND a.year = 1990) AS sub1
      JOIN (SELECT a.country_code AS a.forest_area_sqkm
      		FROM forest_area a
              WHERE a.country_name = 'World'
              	AND a.year = 2016) AS sub2
      ON sub1 = sub2;

-- e. If you compare the amount of forest area lost between 1990 and 2016, 
-- to which country's total area in 2016 is it closest to?
SELECT la.country_name,
       la.total_area_sq_mi*2.59 AS total_area_sqkm,
       ABS((la.total_area_sq_mi*2.59)- (SELECT sub1.forest_area_sqkm - sub2.forest_area_sqkm AS 
			deff_forest_area_sq_km
                                       FROM (SELECT a.country_code AS cc, a.forest_area_sqkm
      	                                     FROM forest_area a
                                             WHERE a.country_name = 'World'
              	                             AND a.year = 1990) AS sub1
                                       JOIN (SELECT a.country_code AS cc,a.forest_area_sqkm
      		                                   FROM forest_area a
                                             WHERE a.country_name = 'World'
              	                              AND a.year = 2016) AS sub2
                                        ON sub1.cc = sub2.cc)) AS deff_forest_land_sqkm
    FROM land_area la
    WHERE l.year = 2016
    ORDER BY 3 LIMIT 1;

--Part 2: Regional Outlook

-- Create a table that shows the Regions and their percent forest area
-- (sum of forest area divided by sum of land area) in 1990 and 2016. 
-- (Note that 1 sq mi = 2.59 sq km). Based on the table you created, ....
CREATE VIEW regional 
AS
SELECT r.region,
       la.year,
       SUM(a.forest_area_sqkm) total_forest_area_sqkm,
       SUM(la.total_area_sq_mi*2.59) AS total_area_sqkm,
        (SUM(a.forest_area_sqkm)/SUM(la.total_area_sq_mi*2.59))*100 AS percentage_forest_area_region
      FROM forest_area a
      JOIN land_area la
      ON a.country_code = la.country_code AND a.year = la.year
      JOIN regions re
      ON la.country_code = re.country_code
      GROUP BY 1,2
      ORDER BY 1,2;

-- a. What was the percent forest of the entire world in 2016? 
-- Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, 
-- to 2 decimal places?
SELECT ROUND(CAST(percentage_forest_area_region AS numeric),2) AS percentage_forest_area_region
	   FROM regional
     WHERE year = 2016 AND region = 'World';

SELECT region,
       ROUND(CAST(total_area_sqkm AS NUMERIC),2) AS total_area_sqkm,
       ROUND(CAST(percentage_forest_area_region AS NUMERIC),2) AS percentage_forest_area_region
       FROM regional
       WHERE ROUND(CAST(percentage_forest_area_region AS NUMERIC),2) = (SELECT MAX( ROUND(
		CAST(percentage_forest_area_region AS numeric),2)) AS max_percentage
        FROM regional
        WHERE year = 2016)
        AND year=2016;

SELECT region,
      ROUND(CAST(total_area_sqkm AS NUMERIC),2) AS total_area_sqkm,
      ROUND(CAST(percentage_forest_area_region AS NUMERIC),2) AS percentage_forest_area_region
      FROM regional
      WHERE ROUND(CAST(percentage_forest_area_region AS NUMERIC),2) = (SELECT MIN(ROUND(
        CAST(percentage_forest_area_region AS numeric),2)) AS max_percentage
        	FROM regional
            WHERE year = 2016)
            AND year = 2016;

-- b. What was the percent forest of the entire world in 1990? 
-- Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, 
-- to 2 decimal places?
SELECT ROUND(CAST(percentage_forest_area_region AS numeric),2) AS percentage_forest_area_region
	   FROM regional
     WHERE year = 1990 AND region = 'World';

SELECT region,
	ROUND(CAST(total_area_sqkm AS NUMERIC),2) AS total_area_sqkm,
	ROUND(CAST(percentage_forest_area_region AS NUMERIC),2) AS percentage_forest_area_region
	FROM regional
		WHERE ROUND(CAST(percentage_forest_area_region AS NUMERIC),2) = (SELECT MAX( ROUND(
 		CAST(percentage_forest_area_region AS numeric),2)) AS max_percentage
        FROM regional
        WHERE year = 1990)
        AND year=1990;

  SELECT region,
        ROUND(CAST(total_area_sqkm AS NUMERIC),2) AS total_area_sqkm,
        ROUND(CAST(percentage_forest_area_region AS NUMERIC),2) AS percentage_forest_area_region
           FROM regional
           WHERE ROUND(CAST(percentage_forest_area_region AS NUMERIC),2) = (SELECT MIN(ROUND(
        	CAST(percentage_forestage_area_region AS numeric),2)) AS min_percentage
            FROM regional
            WHERE year = 1990)
        	AND year = 1990;

-- c. Based on the table you created, which regions of the world 
-- DECREASED in forest area from 1990 to 2016?
WITH table1990 AS (SELECT * FROM regional WHERE year =1990),
	   table2016 AS (SELECT * FROM regional WHERE year = 2016)
SELECT table1990.region,
       ROUND(CAST(table1990.percentage_forest_area_region AS NUMERIC),2) AS forest_area_1990,
       ROUND(CAST(table2016.percentage_forest_area_region AS NUMERIC),2) AS forest_area_2016
    FROM table1990 JOIN table2016 ON table1990.region = table2016.region
    WHERE table1990.percentage_forest_area_region > table2016.percentage_forest_area_region;


--Part 3: Country-Level Detail 
-- a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? 
-- What was the difference in forest area for each?
WITH table1990 AS (SELECT a.country_code, a.country_name,a.year, a.forest_area_sqkm
	                FROM forest_area a
                       WHERE a.year = 1990 AND a.forest_area_sqkm IS NOT NULL AND a.country_name != 'World'),
      table2016 AS (SELECT a.country_code, a.country_name, a.year, a.forest_area_sqkm
	                FROM forest_area a
                       WHERE a.year = 2016 AND a.forest_area_sqkm IS NOT NULL AND a.country_name != 'World')
 SELECT table1990.country_code,
        table1990.country_name,
        re.region,
        table1990.forest_area_sqkm AS forest_area_1990_sqkm,
        table2016.forest_area_sqkm AS forest_area_2016_sqkm,
        table1990.forest_area_sqkm-table2016.forest_area_sqkm AS deff_forest_area_sqkm
      FROM table1990
      JOIN table2016
      ON table1990.country_code = table2016.country_code
      AND (table1990.forest_area_sqkm IS NOT NULL AND table2016.forest_area_sqkm IS NOT NULL)
      JOIN regions re ON table2016.country_code = re.country_code
      ORDER BY 6 DESC
      LIMIT 5;

-- b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? 
-- What was the percent change to 2 decimal places for each?
WITH table1990 AS (SELECT a.country_code, a.country_name, a.year, a.forest_area_sqkm
	                     FROM forest_area a
                       WHERE a.year = 1990 AND a.forest_area_sqkm IS NOT NULL AND a.country_name != 'World'),

      table2016 AS (SELECT a.country_code, a.country_name, a.year, a.forest_area_sqkm
	                     FROM forest_area a
                       WHERE a.year = 2016 AND a.forest_area_sqkm IS NOT NULL AND a.country_name != 'World')
 SELECT table1990.country_code,
        table1990.country_name,
        re.region,
        table1990.forest_area_sqkm AS fa_1990_sqkm,
        table2016.forest_area_sqkm AS fa_2016_sqkm,
        table1990.forest_area_sqkm-table2016.forest_area_sqkm AS deff_forest_area_sqkm,
        ABS(ROUND(CAST(((table2016.forest_area_sqkm-table1990.forest_area_sqkm)/table1990.forest_area_sqkm*100) 
        AS NUMERIC),2)) AS percantage_change
      FROM table1990
      JOIN table2016
      ON table1990.country_code = table2016.country_code
      AND (table1990.forest_area_sqkm IS NOT NULL AND table2016.forest_area_sqkm IS NOT NULL) 
      JOIN regions re ON table2016.country_code = re.country_code
      ORDER BY ROUND(CAST(((table2016.forest_area_sqkm-table1990.forest_area_sqkm)/table1990.forest_area_sqkm*100) 
      AS NUMERIC),2)
      LIMIT 5;

-- c. If countries were grouped by percent forestation in quartiles, 
-- which group had the most countries in it in 2016?
With table1 AS (SELECT a.country_code, a.country_name, a.year, a.forest_area_sqkm,
                    la.total_area_sq_mi*2.59 AS total_area_sqkm,
                        (a.forest_area_sqkm/(la.total_area_sq_mi*2.59))*100 AS percentage_forest_area
                        FROM forest_area a
                        JOIN land_area la
                        ON a.country_code = la.country_code
                        AND (a.country_name != 'World' AND a.forest_area_sqkm IS NOT NULL AND la.total_area_sq_mi IS NOT NULL)
                        AND (a.year=2016 AND la.year = 2016)
                        ORDER BY 6 DESC),
      table2 AS (SELECT table1.country_code, table1.country_name, table1.year,table1.percentage_forest_area,
                         CASE WHEN table1.percentage_forest_area >= 75 THEN 4
                              WHEN table1.percentage_forest_area < 75 AND table1.percentage_forest_area >= 50 THEN 3
                              WHEN table1.percentage_forest_area < 50 AND table1.percentage_forest_area >=25 THEN 2
                              ELSE 1
                         END AS centile
                         FROM table1 ORDER BY 5 DESC)
                         
SELECT table2.centile,
       COUNT(table2.percentile)
       FROM table2
       GROUP BY 1
       ORDER BY 2 DESC;

-- d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.
With table1 AS (SELECT a.country_code, a.country_name, a.year, a.forest_area_sqkm,
                    la.total_area_sq_mi*2.59 AS total_area_sqkm,
                        (a.forest_area_sqkm/(la.total_area_sq_mi*2.59))*100 AS percentage_forest_area
                        FROM forest_area a
                        JOIN land_area la
                        ON a.country_code = la.country_code
                        AND (a.country_name != 'World' AND a.forest_area_sqkm IS NOT NULL AND la.total_area_sq_mi IS NOT NULL)
                        AND (a.year=2016 AND l.year = 2016)
                        ORDER BY 6 DESC),
      table2 AS (SELECT table1.country_code, table1.country_name, table1.year,
                         table1.percentage_forest_area,
                         CASE WHEN table1.percentage_forest_area >= 75 THEN 4
                              WHEN table1.percentage_forest_area < 75 AND table1.percentage_forest_area >= 50 THEN 3
                              WHEN table1.percentage_forest_area < 50 AND table1.percentage_forest_area >=25 THEN 2
                              ELSE 1
                         END AS centile
                         FROM table1 ORDER BY 5 DESC)
SELECT table2.country_name, re.region,
       ROUND(CAST(table2.percentage_forest_area AS NUMERIC),2) AS percentage_forest_area,
       table2.centile
       FROM table2
       JOIN regions re
       ON table2.country_code = re.country_code
       WHERE table2.centile = 4
       ORDER BY 1;

-- e. How many countries had a percent forestation higher than the United States in 2016?
With table1 AS (SELECT a.country_code, a.country_name, a.year, a.forest_area_sqkm,
                       la.total_area_sq_mi*2.59 AS total_area_sqkm,
                        (a.forest_area_sqkm/(la.total_area_sq_mi*2.59))*100 AS percentage_forest_area
                        FROM forest_area a
                        JOIN land_area la
                        ON a.country_code = la.country_code
                        AND (a.country_name != 'World' AND a.forest_area_sqkm IS NOT NULL AND la.total_area_sq_mi IS NOT NULL)
                        AND (a.year=2016 AND l.year = 2016)
                        ORDER BY 6 DESC)
SELECT COUNT(table1.country_name)
      FROM table1
      WHERE table1.percentage_forest_area > (SELECT table1.percentage_forest_area
                                     FROM table1
                                     WHERE table1.country_name = 'United States')