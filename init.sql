CREATE TYPE mpaa_rating AS ENUM ('G', 'PG', 'PG-13', 'R', 'NC-17');
CREATE TYPE profession AS ENUM ('Actor', 'Director');


CREATE TABLE persons (
    guid UUID PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE
);


CREATE TABLE genres (
    guid UUID PRIMARY KEY,
    genre VARCHAR(50) NOT NULL
);


CREATE TABLE films (
    guid UUID PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    director_id UUID REFERENCES persons(guid),
    year_released INTEGER,
    rating_mpaa mpaa_rating,
    runtime INTEGER,
    summary TEXT
);

CREATE TABLE users (
    guid UUID PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    birth_date DATE NOT NULL
);
ALTER TABLE users ADD CONSTRAINT valid_email CHECK (email LIKE '%@%.%');

CREATE TABLE film_rating (
    guid UUID PRIMARY KEY,
    film_guid UUID REFERENCES films(guid) NOT NULL,
    user_guid UUID REFERENCES users(guid),
    rating INTEGER NOT NULL,
     rating_date TIMESTAMP NOT NULL,
    review TEXT
);
TRUNCATE TABLE fil
ALTER TABLE film_rating ADD CONSTRAINT valid_rate CHECK (rating BETWEEN 1 AND 10); 

CREATE TABLE film_person (
    guid UUID PRIMARY KEY,
    film_guid UUID REFERENCES films(guid),
    person_guid UUID REFERENCES persons(guid),
    profession profession NOT NULL

);

CREATE TABLE film_genre (
    film_guid UUID REFERENCES films(guid),
    genre_guid UUID REFERENCES genres(guid),
    PRIMARY KEY (film_guid, genre_guid)
);


CREATE TABLE film_lists (
    guid UUID PRIMARY KEY,
    title VARCHAR(100) NOT NULL
);

CREATE TABLE fl_films (
    list_guid UUID REFERENCES film_lists(guid) ,
    film_guid UUID REFERENCES films(guid),
    PRIMARY KEY (list_guid, film_guid)
);

-- Партиционированная таблица пользовательских списков
CREATE TABLE user_lists (
    user_guid UUID REFERENCES users(guid),
    film_guid UUID REFERENCES films(guid),
    title VARCHAR(20) NOT NULL
) PARTITION BY LIST (title);

CREATE TABLE viewed PARTITION OF user_lists
    FOR VALUES IN ('Viewed');

ALTER TABLE viewed ADD CONSTRAINT viewed_pk PRIMARY KEY (user_guid, film_guid);
CREATE TABLE watch_later PARTITION OF user_lists
    FOR VALUES IN ('Watch Later');

ALTER TABLE watch_later ADD CONSTRAINT watch_later_pk PRIMARY KEY (user_guid, film_guid);


-- View для вычисления средней оценки фильма
CREATE VIEW film_score AS
SELECT title, score, rates_cnt
FROM (
	SELECT film_guid, round(avg(rating), 2) as score, count(user_guid) AS rates_cnt
	FROM film_rating
	GROUP BY film_guid
    ) AS ratings
INNER JOIN films ON ratings.film_guid = films.guid
ORDER BY score DESC;




TRUNCATE TABLE persons  DELETE CASCADE;