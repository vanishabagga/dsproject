
/* Drill Down Query (total number of deaths for the month of January 2023*/

SELECT D.year, D.weekday, D.month, D.day, SUM(F.num_deaths) as total_number_of_deaths
FROM incident_fact_table as F
INNER JOIN date_dimension as D ON F.date_primary_key = D.date_primary_key
WHERE D.month = 3
GROUP BY D.year, D.weekday, D.month, D.day;


/*Roll Up Query (total deaths cases rollup to region and city)*/

SELECT L.state AS region, L.city AS city, SUM(F.num_deaths) AS total_death_cases
FROM incident_fact_table AS F
INNER JOIN location_dimension AS L ON F.location_primary_key = L.location_primary_key
GROUP BY ROLLUP(L.state, L.city)
HAVING L.city IS NOT NULL 
ORDER BY L.state, L.city;


/* Slice Query (total Cases in shootings that occurred in schools) */

SELECT F.case_primary_key,
       L.location, 
       SUM(F.num_injured) AS total_injured_cases, 
       SUM(F.num_deaths) AS total_death_cases 
FROM incident_fact_table AS F 
INNER JOIN location_dimension L ON F.location_primary_key = L.location_primary_key 
INNER JOIN participant_dimension P ON F.participant_primary_key = P.participant_primary_key
WHERE L.location = 'school'
GROUP BY F.case_primary_key, L.location;


/* Dice Query (total number of injured cases by gender and race) */

SELECT gender, race, SUM(num_injured) AS total_injured_cases
FROM incident_fact_table AS F
INNER JOIN participant_dimension AS P ON F.participant_primary_key = P.participant_primary_key
GROUP BY gender, race;


/* Dice Query (total number of video games that meet genre and year conditions with also considering the correlation between year of shooting and year of game release) */

SELECT gd.year,
       gd.genre,
       gd.platform,
       COUNT(*) AS game_count
FROM game_dimension gd
INNER JOIN game_sales_fact_table gs ON gd.game_primary_key = gs.game_primary_key
INNER JOIN game_date_association gda ON gs.video_game_primary_key = gda.game_sales_key
INNER JOIN date_dimension dd ON gda.date_primary_key = dd.date_primary_key
WHERE (gd.genre = 'shooter' OR gd.genre = 'action')
AND gd.year BETWEEN 2000 AND 2023
GROUP BY gd.year, gd.genre, gd.platform;


/* Combining OLAP Operations - 3 Queries*/
/* Aggregates incident data by state, year, and month for California, Texas, and Florida,
   counting total incidents and summing up the injuries and deaths. Calculates the average age of participants
   in these incidents */

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
    ld.state IN ('california', 'texas', 'florida')
GROUP BY 
    ld.state, vd.year, vd.month;


/* Incidents, injuries, deaths, participant demographics, and video game genres 
   grouped by state and year. Calculates the number of action and shooter games associated with
   these incidents */

SELECT 
    ld.state,
    vd.year,
    COUNT(ift.case_primary_key) AS total_incidents,
    COUNT(DISTINCT ift.participant_primary_key) AS total_participants,
    SUM(ift.num_injured) AS total_injured,
    SUM(ift.num_deaths) AS total_deaths,
    AVG(pd.age) AS avg_age,
    SUM(CASE WHEN gd.genre IN ('action', 'shooter') THEN 1 ELSE 0 END) AS action_shooter_games
FROM 
    incident_fact_table ift
JOIN 
    location_dimension ld ON ift.location_primary_key = ld.location_primary_key
JOIN 
    date_dimension vd ON ift.date_primary_key = vd.date_primary_key
LEFT JOIN 
    participant_dimension pd ON ift.participant_primary_key = pd.participant_primary_key
LEFT JOIN 
    game_date_association gda ON vd.date_primary_key = gda.date_primary_key
LEFT JOIN 
    game_sales_fact_table gsft ON gda.game_sales_key = gsft.video_game_primary_key
LEFT JOIN 
    game_dimension gd ON gsft.game_primary_key = gd.game_primary_key
GROUP BY 
    ld.state, vd.year;


/* Yearly incident data by race, counting distinct participants and categorizing
   them by gender and health status. Also sums regional and global video game sales */

SELECT 
    pd.race,
    vd.year,
    COUNT(id.case_primary_key) AS total_incidents,
    COUNT(DISTINCT pd.participant_primary_key) AS total_participants,
    AVG(pd.age) AS avg_age,
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
    game_date_association gda ON vd.date_primary_key = gda.date_primary_key
LEFT JOIN 
    game_sales_fact_table gs ON gda.game_sales_key = gs.video_game_primary_key
GROUP BY 
    pd.race, vd.year
ORDER BY
	vd.year;

/* Video game titles, genres, release years, injuries, and deaths */

SELECT 
    gd.title,
    gd.genre,
    gd.year,
    ift.num_injured,
    ift.num_deaths
FROM 
    game_dimension gd
JOIN 
    game_sales_fact_table gsft ON gd.game_primary_key = gsft.game_primary_key
JOIN 
    game_date_association gda ON gsft.video_game_primary_key = gda.game_sales_key
JOIN 
    date_dimension dd ON gda.date_primary_key = dd.date_primary_key
LEFT JOIN 
    incident_fact_table ift ON dd.date_primary_key = ift.date_primary_key;


/* Iceberg Query (Top-N for Total Deaths on a Date) */

SELECT D.date_primary_key, D.month, D.day, D.year, SUM(F.num_deaths) AS total_deaths
FROM incident_fact_table AS F, date_dimension AS D
WHERE F.date_primary_key = D.date_primary_key
GROUP BY D.date_primary_key, D.month, D.day, D.year
ORDER BY total_deaths DESC
LIMIT 5;


/*Windowing Query (Total Cases partitioned by age_group, ranked by total and by acquisition group) */

SELECT
       p.age_group,
       COUNT(*) AS total_cases,
       RANK() OVER (
              ORDER BY COUNT(*) DESC) AS rank
FROM incident_fact_table f
JOIN participant_dimension p ON f.participant_primary_key = p.participant_primary_key
GROUP BY
       p.age_group;


/*Window Clause Query (Number of deaths in the year 2023 compared previous years) */

SELECT
    year,
    total_casualties,
    MAX(total_casualties) OVER w AS previous_year_casualties
FROM (
    SELECT
        year,
        SUM(num_injured + num_deaths) AS total_casualties
    FROM
        incident_fact_table f
    JOIN
        date_dimension d ON f.date_primary_key = d.date_primary_key
    WHERE
        year <= 2023
    GROUP BY
        year
) AS yearly_casualties
WINDOW w AS (ORDER BY year ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING);





