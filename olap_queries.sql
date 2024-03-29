
/* Drill Down Query (total number of deaths for the month of January 2023*/
SELECT D.year, D.weekday, D.month, D.day, SUM(F.num_deaths) as total_number_of_deaths
FROM incident_fact_table as F
INNER JOIN date_dimension as D ON F.date_primary_key = D.date_primary_key
WHERE D.year = 2023 AND D.month = 1
GROUP BY D.year, D.weekday, D.month, D.day;



/*Roll Up Query (total deaths cases rollup to region and city)*/
SELECT L.state AS region, L.city AS city, SUM(F.num_deaths) AS total_death_cases
FROM incident_fact_table AS F
INNER JOIN location_dimension AS L ON F.location_primary_key = L.location_primary_key
GROUP BY ROLLUP(L.state, L.city)
ORDER BY L.state, L.city;


/* Slice Query (total Cases in shootings that occurred in schools) */
SELECT L.location, 
       SUM(F.num_injured) AS total_injured_cases, 
       SUM(F.num_deaths) AS total_death_cases, 
       COUNT(P.participant_primary_key) AS total_cases
FROM incident_fact_table AS F 
INNER JOIN location_dimension L ON F.location_primary_key = L.location_primary_key 
INNER JOIN participant_dimension P ON F.participant_primary_key = P.participant_primary_key
WHERE L.location = 'school'
GROUP BY L.location;


/* Dice Query (total number of injured cases by gender and race) */
SELECT gender, race, SUM(num_injured) AS total_injured_cases
FROM incident_fact_table AS F
INNER JOIN participant_dimension AS P ON F.participant_primary_key = P.participant_primary_key
GROUP BY gender, race;

/* Dice Query (total sales of video games by genre, platform, publisher, and year with conditions */
SELECT V.genre, V.platform, V.publisher, V.year, SUM(G.global_sales) AS total_sales
FROM game_sales_fact_table AS G
INNER JOIN video_game_dimension AS V ON G.video_game_primary_key = V.video_game_primary_key
WHERE V.genre IN ('Shooter', 'Action') 
AND V.platform IN ('PS3', 'X360')
GROUP BY V.genre, V.platform, V.publisher, V.year;

/* Combining OLAP Operations - 3 Queries*/

/*a. Iceberg Query*/


/* Iceberg Query (Top-N for Total Deaths on a Date) */

SELECT D.date_primary_key, D.month, D.day, D.year, SUM(F.num_deaths) AS total_deaths
FROM incident_fact_table AS F
JOIN date_dimension AS D ON F.date_primary_key = D.date_primary_key
GROUP BY D.date_primary_key, D.month, D.day, D.year
ORDER BY total_deaths DESC
LIMIT 5;



