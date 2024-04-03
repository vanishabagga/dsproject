
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

SELECT 
    ld.state,
    vd.year,
    vd.month,
    COUNT(id.case_primary_key) AS total_incidents,
    SUM(id.num_injured) AS total_injured,
    SUM(id.num_deaths) AS total_deaths,
    AVG(pd.age) AS avg_age
FROM 
    incident_fact_table id
JOIN 
    location_dimension ld ON id.location_primary_key = ld.location_primary_key
JOIN 
    date_dimension vd ON id.date_primary_key = vd.date_primary_key
LEFT JOIN 
    participant_dimension pd ON id.participant_primary_key = pd.participant_primary_key
WHERE 
    ld.state IN ('California', 'Texas', 'Florida')
GROUP BY 
    ld.state, vd.year, vd.month;




SELECT 
    ld.state,
    vd.year,
    COUNT(id.case_primary_key) AS total_incidents,
    COUNT(DISTINCT pd.participant_primary_key) AS total_participants,
    SUM(id.num_injured) AS total_injured,
    SUM(id.num_deaths) AS total_deaths,
    AVG(pd.age) AS avg_age,
    SUM(CASE WHEN vg.genre IN ('Action', 'Shooter') THEN 1 ELSE 0 END) AS action_shooter_games
FROM 
    incident_fact_table id
JOIN 
    location_dimension ld ON id.location_primary_key = ld.location_primary_key
JOIN 
    date_dimension vd ON id.date_primary_key = vd.date_primary_key
LEFT JOIN 
    participant_dimension pd ON id.participant_primary_key = pd.participant_primary_key
LEFT JOIN 
    video_game_dimension vg ON id.year = vg.year
GROUP BY 
    ld.state, vd.year;


SELECT 
    pd.race,
    vd.year,
    COUNT(id.case_primary_key) AS total_incidents,
    COUNT(DISTINCT pd.participant_primary_key) AS total_participants,
    AVG(pd.age) AS avg_age,
    SUM(CASE WHEN pd.gender = 'Male' THEN 1 ELSE 0 END) AS total_male_participants,
    SUM(CASE WHEN pd.gender = 'Female' THEN 1 ELSE 0 END) AS total_female_participants,
    SUM(CASE WHEN pd.health_flag = true THEN 1 ELSE 0 END) AS total_healthy_participants,
    SUM(CASE WHEN pd.health_flag = false THEN 1 ELSE 0 END) AS total_unhealthy_participants,
    SUM(gs.na_sales) AS total_na_sales,
    SUM(gs.eu_sales) AS total_eu_sales,
    SUM(gs.jp_sales) AS total_jp_sales,
    SUM(gs.other_sales) AS total_other_sales,
    SUM(gs.global_sales) AS total_global_sales
FROM 
    incident_fact_table id
JOIN 
    participant_dimension pd ON id.participant_primary_key = pd.participant_primary_key
JOIN 
    date_dimension vd ON id.date_primary_key = vd.date_primary_key
LEFT JOIN 
    game_sales_fact_table gs ON vd.year = gs.year
GROUP BY 
    pd.race, vd.year;

/*a. Iceberg Query*/


/* Iceberg Query (Top-N for Total Deaths on a Date) */

SELECT D.date_primary_key, D.month, D.day, D.year, SUM(F.num_deaths) AS total_deaths
FROM incident_fact_table AS F, date_dimension AS D
WHERE F.date_primary_key = D.date_primary_key
GROUP BY D.date_primary_key, D.month, D.day, D.year
ORDER BY total_deaths DESC
LIMIT 5;


/*Windowing Query (Total Cases partitioned by age_group, ranked by total and by acquisition group)*/

SELECT
       p.age_group,
       COUNT(*) AS total_cases,
       RANK() OVER (
              ORDER BY COUNT(*) DESC) AS rank
FROM incident_fact_table f
JOIN participant_dimension p ON f.participant_primary_key = p.participant_primary_key
GROUP BY
       p.age_group;

/*Window Clause Query (Number of deaths in the year 2023 compared perivous years)*/
SELECT
    year,
    total_casualties,
    MAX(total_casualties) OVER w AS previous_year_casualties
FROM (
    SELECT
        EXTRACT(year FROM d.date) AS year,
        SUM(num_injured + num_deaths) AS total_casualties
    FROM
        incident_fact_table f
    JOIN
        date_dimension d ON f.date_primary_key = d.date_primary_key
    WHERE
        EXTRACT(year FROM d.date) <= 2023
    GROUP BY
        EXTRACT(year FROM d.date)
) AS yearly_casualties
WINDOW w AS (ORDER BY year ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING);





