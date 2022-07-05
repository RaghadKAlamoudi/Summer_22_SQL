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
--a
SELECT a.forest_area_sqkm
		FROM forest_area a
        WHERE a.country_name = 'World'
        	AND a.year = 1990;
--b
SELECT a.forest_area_sqkm
		FROM forest_area a
        WHERE a.country_name = 'World'
        	AND a.year = 2016;
-- c
SELECT s1.forest_area_sqkm - s2.forest_area_sqkm AS forest_area_sq_km
      FROM (SELECT a.country_code AS contry_code, a.forest_area_sqkm
      	    FROM forest_area a
              WHERE a.country_name = 'World'
              	AND a.year = 1990) AS s1
      JOIN (SELECT a.country_code AS country_code,a.forest_area_sqkm
      		FROM forest_area a
              WHERE a.country_name = 'World'
              	AND a.year = 2016) AS s2
      ON s1 = s2;
-- d
-- s1 stand for sub1
-- s2 stand for sub2
SELECT ((s1.forest_area_sqkm-s2.forest_area_sqkm)/s1.forest_area_sqkm)*100  AS 
		percantage_change_forest_area
      FROM (SELECT a.country_code AS cc, a.forest_area_sqkm
      	    FROM amount_of_forest_area
              WHERE a.country_name = 'World'
              	AND a.year = 1990) AS s1
      JOIN (SELECT a.country_code AS a.forest_area_sqkm
      		FROM forest_area a
              WHERE a.country_name = 'World'
              	AND a.year = 2016) AS s2
      ON s1 = s2;
-- e
-- s1 stand for sub1
-- s2 stand for sub2
SELECT la.country_name,
       la.total_area_sq_mi*2.59 AS total_forest_area_sqkm,
       ABS((la.total_area_sq_mi*2.59)- (SELECT s1.forest_area_sqkm - s2.forest_area_sqkm AS 
			forest_area_sq_km
     FROM (SELECT a.country_code AS country_code, a.forest_area_sqkm
     FROM forest_area a
     WHERE a.country_name = 'World'
     AND a.year = 1990) AS s1
    JOIN (SELECT a.country_code AS country_code,a.forest_area_sqkm
      	FROM forest_area a
        WHERE a.country_name = 'World'
        AND a.year = 2016) AS s2
        ON s1.country_code = s2.country_code)) AS forest_land_sqkm
    FROM land_area la
    WHERE la.year = 2016
    ORDER BY 3 LIMIT 1;

--Part 2: Regional Outlook
-- Create a table that shows the Regions and their percent forest area
-- (sum of forest area divided by sum of land area) in 1990 and 2016. 
-- (Note that 1 sq mi = 2.59 sq km). Based on the table you created, ....
CREATE VIEW Regional
AS
SELECT re.region,
       la.year,
       SUM(a.forest_area_sqkm) total_forest_area_sqkm,
       SUM(la.total_area_sq_mi*2.59) AS total_area_sqkm,
        (SUM(a.forest_area_sqkm)/SUM(la.total_area_sq_mi*2.59))*100 AS percentage_fa_region
      FROM forest_area a
      JOIN land_area la
      ON a.country_code = la.country_code AND a.year = la.year
      JOIN regions re
      ON la.country_code = re.country_code
      GROUP BY 1,2
      ORDER BY 1,2;
-- a
-- fa stand for forest area
SELECT ROUND(CAST(percentage_fa_region AS numeric),2) AS percentage_fa_region
	   FROM Regional
     WHERE year = 2016 AND region = 'World';
SELECT region,
       ROUND(CAST(total_area_sqkm AS NUMERIC),2) AS total_area_sqkm,
       ROUND(CAST(percentage_fa_region AS NUMERIC),2) AS percentage_fa_region
       FROM Regional
       WHERE ROUND(CAST(percentage_fa_region AS NUMERIC),2) = (SELECT MAX( ROUND(
		CAST(percentage_fa_region AS numeric),2)) AS max_percentage
        FROM Regional
        WHERE year = 2016) AND year=2016;
SELECT region,
      ROUND(CAST(total_area_sqkm AS NUMERIC),2) AS total_area_sqkm,
      ROUND(CAST(percentage_fa_region AS NUMERIC),2) AS percentage_fa_region
      FROM Regional
      WHERE ROUND(CAST(percentage_fa_region AS NUMERIC),2) = (SELECT MIN(ROUND(
        CAST(percentage_fa_region AS numeric),2)) AS max_percentage
        	FROM Regional
            WHERE year = 2016) AND year = 2016;

-- b
-- fa stand for forest area
SELECT ROUND(CAST(percentage_fa_region AS numeric),2) AS percentage_fa_region
	   FROM Regional
     WHERE year = 1990 AND region = 'World';
SELECT region,
	ROUND(CAST(total_area_sqkm AS NUMERIC),2) AS total_area_sqkm,
	ROUND(CAST(percentage_fa_region AS NUMERIC),2) AS percentage_fa_region
	FROM Regional
		WHERE ROUND(CAST(percentage_fa_region AS NUMERIC),2) = (SELECT MAX( ROUND(
 		CAST(percentage_fa_region AS numeric),2)) AS max_percentage
        FROM regional
        WHERE year = 1990)AND year=1990;
  SELECT region,
        ROUND(CAST(total_area_sqkm AS NUMERIC),2) AS total_area_sqkm,
        ROUND(CAST(percentage_fa_region AS NUMERIC),2) AS percentage_fa_region
           FROM Regional
           WHERE ROUND(CAST(percentage_fa_region AS NUMERIC),2) = (SELECT MIN(ROUND(
        	CAST(percentage_fa_region AS numeric),2)) AS min_percentage
            FROM Regional
            WHERE year = 1990) AND year = 1990;
-- c
WITH table_of_1990 AS (SELECT * FROM Regional WHERE year =1990),
	   table_of_2016 AS (SELECT * FROM Regional WHERE year = 2016)
SELECT table_of_1990.region,
       ROUND(CAST(table_of_1990.percentage_fa_region AS NUMERIC),2) AS forest_area_1990,
       ROUND(CAST(table_of_2016.percentage_fa_region AS NUMERIC),2) AS forest_area_2016
    FROM table_of_1990 JOIN table_of_2016 ON table_of_1990.region = table_of_2016.region
    WHEREtable_of_1990.percentage_fa_region > table_of_2016.percentage_fa_region;


--Part 3: Country-Level Detail 
-- a
WITH table_of_1990 AS (SELECT a.country_code, a.country_name,a.year, a.forest_area_sqkm
	                FROM forest_area a
                       WHERE a.year = 1990 AND a.forest_area_sqkm IS NOT NULL AND a.country_name != 'World'),
      table_of_2016 AS (SELECT a.country_code, a.country_name, a.year, a.forest_area_sqkm
	                FROM forest_area a
                       WHERE a.year = 2016 AND a.forest_area_sqkm IS NOT NULL AND a.country_name != 'World')
 SELECT table_of_1990.country_code,table_of_1990.country_name,
        re.region,
        table_of_1990.forest_area_sqkm AS forest_area_1990_sqkm,
        table_of_2016.forest_area_sqkm AS forest_area_2016_sqkm,
        table_of_1990.forest_area_sqkm-table_of_2016.forest_area_sqkm AS forest_area_sqkm
      FROM table_of_1990
      JOIN table_of_2016
      ON table_of_1990.country_code = table_of_2016.country_code
      AND (table_of_1990.forest_area_sqkm IS NOT NULL AND table_of_2016.forest_area_sqkm IS NOT NULL)
      JOIN regions re ON table_of_2016.country_code = re.country_code
      ORDER BY 6 DESC
      LIMIT 5;
-- b
WITH table_of_1990 AS (SELECT a.country_code, a.country_name, a.year, a.forest_area_sqkm
	                     FROM forest_area a
                       WHERE a.year = 1990 AND a.forest_area_sqkm IS NOT NULL AND a.country_name != 'World'),

      table_of_2016 AS (SELECT a.country_code, a.country_name, a.year, a.forest_area_sqkm
	                     FROM forest_area a
                       WHERE a.year = 2016 AND a.forest_area_sqkm IS NOT NULL AND a.country_name != 'World')
 SELECT table_of_1990.country_code, table_of_1990.country_name,
        re.region,
        table_of_1990.forest_area_sqkm AS fa_1990_sqkm,
        table_of_2016.forest_area_sqkm AS fa_2016_sqkm,
        table_of_1990.forest_area_sqkm-table_of_2016.forest_area_sqkm AS forest_area_sqkm,
        ABS(ROUND(CAST(((table_of_2016.forest_area_sqkm-table_of_1990.forest_area_sqkm)/table_of_1990.forest_area_sqkm*100) 
        AS NUMERIC),2)) AS percantage_change
      FROM table_of_1990
      JOIN table_of_2016
      ON table_of_1990.country_code = table_of_2016.country_code
      AND (table_of_1990.forest_area_sqkm IS NOT NULL AND table_of_2016.forest_area_sqkm IS NOT NULL) 
      JOIN regions re ON table_of_2016.country_code = re.country_code
      ORDER BY ROUND(CAST(((table_of_2016.forest_area_sqkm-table_of_1990.forest_area_sqkm)/table_of_1990.forest_area_sqkm*100) 
      AS NUMERIC),2)
      LIMIT 5;
-- c
-- t1 stand for table1
-- t2 stand for table2
-- fa stand for forest area
With t1 AS (SELECT a.country_code, a.country_name, a.year, a.forest_area_sqkm,
                    la.total_area_sq_mi*2.59 AS total_area_sqkm,
                        (a.forest_area_sqkm/(la.total_area_sq_mi*2.59))*100 AS percentage_fa
                        FROM forest_area a
                        JOIN land_area la
                        ON a.country_code = la.country_code
                        AND (a.country_name != 'World' AND a.forest_area_sqkm IS NOT NULL AND la.total_area_sq_mi IS NOT NULL)
                        AND (a.year=2016 AND la.year = 2016)
                        ORDER BY 6 DESC),
      t2 AS (SELECT t1.country_code, t1.country_name, t1.year,t1.percentage_fa,
                         CASE WHEN t1.percentage_fa >= 75 THEN 4
                              WHEN t1.percentage_fa < 75 AND t1.percentage_fa >= 50 THEN 3
                              WHEN t1.percentage_fa < 50 AND t1.percentage_fa >=25 THEN 2
                              ELSE 1
                         END AS percentile
                         FROM t1 ORDER BY 5 DESC)                         
SELECT t2.percentile,
       COUNT(t2.percentile)
       FROM t2
       GROUP BY 1
       ORDER BY 2 DESC;
-- d
-- t1 stand for table1
-- t2 stand for table2
-- fa stand for forest area
With t1 AS (SELECT a.country_code, a.country_name, a.year, a.forest_area_sqkm,
                    la.total_area_sq_mi*2.59 AS total_area_sqkm,
                        (a.forest_area_sqkm/(la.total_area_sq_mi*2.59))*100 AS percentage_fa
                        FROM forest_area a
                        JOIN land_area la
                        ON a.country_code = la.country_code
                        AND (a.country_name != 'World' AND a.forest_area_sqkm IS NOT NULL AND la.total_area_sq_mi IS NOT NULL)
                        AND (a.year=2016 AND la.year = 2016)
                        ORDER BY 6 DESC),
      t2 AS (SELECT t1.country_code, t1.country_name, t1.year,
                         t1.percentage_fa,
                         CASE WHEN t1.percentage_fa >= 75 THEN 4
                              WHEN t1.percentage_fa < 75 AND t1.percentage_fa >= 50 THEN 3
                              WHEN t1.percentage_fa < 50 AND t1.percentage_fa >=25 THEN 2
                              ELSE 1
                         END AS percentile
                         FROM t1 ORDER BY 5 DESC)
SELECT t2.country_name, re.region,
       ROUND(CAST(t2.percentage_fa AS NUMERIC),2) AS percentage_fa,
       t2.percentile
       FROM t2
       JOIN regions re
       ON t2.country_code = re.country_code
       WHERE t2.percentile = 4
       ORDER BY 1;
-- e
-- t1 stand for table1
-- fa stand for forest area
With t1 AS (SELECT a.country_code, a.country_name, a.year, a.forest_area_sqkm,
                       la.total_area_sq_mi*2.59 AS total_area_sqkm,
                        (a.forest_area_sqkm/(la.total_area_sq_mi*2.59))*100 AS percentage_fa
                        FROM forest_area a
                        JOIN land_area la
                        ON a.country_code = la.country_code
                        AND (a.country_name != 'World' AND a.forest_area_sqkm IS NOT NULL AND la.total_area_sq_mi IS NOT NULL)
                        AND (a.year=2016 AND la.year = 2016)
                        ORDER BY 6 DESC)
SELECT COUNT(t1.country_name)
      FROM t1
      WHERE t1.percentage_fa > (SELECT t1.percentage_fa
                                     FROM t1
                                     WHERE t1.country_name = 'United States')