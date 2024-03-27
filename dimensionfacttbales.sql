create table participant_dimension(
    participant_primary_key int,
    participant_name varchar,
    race varchar,
    age float,
    age_group varchar,
    gender varchar,
    health_flag boolean,
    incident_description varchar,
    primary key (participant_primary_key)
);

create table date_dimension(
    date_primary_key int,
    month int,
    day int,
    weekday varchar,
    year int,
    season varchar,
    holiday_flag boolean,
    primary key (date_primary_key)
);

create table gun_dimension(
    gun_primary_key int,
    gun_type varchar,
    gun_status varchar,
    primary key (gun_primary_key)
);

create table location_dimension(
    location_primary_key int,
	state varchar,
    city varchar,
    location varchar,
    latitude float,
    longitute float,
    primary key (location_primary_key)
);

create table video_game_dimension(
    video_game_primary_key int,
    title varchar,
    genre varchar,
    platform varchar,
    publisher varchar,
    year int,
    primary key (video_game_primary_key)
);

CREATE TABLE incident_fact_table (
    case_primary_key INT,
    participant_primary_key INT,
    date_primary_key INT,
    location_primary_key INT,
    video_game_primary_key INT,
	num_injured INT,
    num_deaths INT,
	gun_primary_key INT,
    PRIMARY KEY (case_primary_key),
    FOREIGN KEY (participant_primary_key) REFERENCES participant_dimension(participant_primary_key),
    FOREIGN KEY (date_primary_key) REFERENCES date_dimension(date_primary_key),
    FOREIGN KEY (location_primary_key) REFERENCES location_dimension(location_primary_key),
    FOREIGN KEY (video_game_primary_key) REFERENCES video_game_dimension(video_game_primary_key),
	FOREIGN KEY (gun_primary_key) REFERENCES gun_dimension(gun_primary_key)
);

CREATE TABLE game_sales_fact_table (
    game_primary_key INT,
	video_game_primary_key INT,
    na_sales float,
    eu_sales float,
    jp_sales float,
    other_sales float,
    global_sales float,
    PRIMARY KEY (game_primary_key),
	FOREIGN KEY (video_game_primary_key) REFERENCES video_game_dimension(video_game_primary_key)
);

CREATE TABLE game_date_association (
    game_sales_key INT,
    date_primary_key INT,
    FOREIGN KEY (game_sales_key) REFERENCES game_sales_fact_table(game_primary_key),
    FOREIGN KEY (date_primary_key) REFERENCES date_dimension(date_primary_key),
    PRIMARY KEY (game_sales_key, date_primary_key)
);

COPY participant_dimension (participant_primary_key, participant_name, race, age, age_group, gender, incident_description)
FROM '/Users/vanishabagga/Documents/dsproject/participant.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY date_dimension (date_primary_key, month, day, weekday, year, season, holiday_flag)
FROM '/Users/vanishabagga/Documents/dsproject/date.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY gun_dimension (gun_primary_key, gun_type, gun_status)
FROM '/Users/vanishabagga/Documents/dsproject/type_of_gun.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY location_dimension (location_primary_key, state, city, location, latitude, longitute)
FROM '/Users/vanishabagga/Documents/dsproject/location.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY video_game_dimension (video_game_primary_key, title, genre, platform, publisher, year)
FROM '/Users/vanishabagga/Documents/dsproject/gamedata.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY incident_fact_table (case_primary_key, participant_primary_key, date_primary_key, location_primary_key, video_game_primary_key, num_injured, num_deaths, gun_primary_key)
FROM '/Users/vanishabagga/Documents/dsproject/incidentfacttable.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY game_sales_fact_table (game_primary_key, video_game_primary_key, na_sales, eu_sales, jp_sales, other_sales, global_sales)
FROM '/Users/vanishabagga/Documents/dsproject/gamesalesfacttable.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY game_date_association (game_sales_key, date_primary_key)
FROM '/Users/vanishabagga/Documents/dsproject/game_date_association_cleaned.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

