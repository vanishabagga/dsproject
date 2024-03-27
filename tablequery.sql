create table participant_dimension(
    participant_primary_key int,
    participant_name varchar,
    race varchar,
    age int,
    age_group varchar,
    gender varchar,
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
    holiday_flag varchar,
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
    na_sales INT,
    eu_sales INT,
    jp_sales INT,
    other_sales INT,
    global_sales INT,
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
