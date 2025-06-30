-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it



--1) Users who stream content
CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    signup_date DATE NOT NULL DEFAULT CURRENT_DATE

);


--2) Subscription Plans (Basic, Standard, Premium...)
CREATE TABLE IF NOT EXISTS subscription_plans (
    plan_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    price_cents INTEGER NOT NULL
);


--3) User subscriptions to plans
CREATE TABLE IF NOT EXISTS subscriptions (
    subscription_id SERIAL PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    user_id INTEGER NOT NULL REFERENCES users(user_id),
    plan_id INTEGER NOT NULL REFERENCES subscription_plans(plan_id)

);


--4) Subscription Payments
CREATE TABLE IF NOT EXISTS payments (
    payment_id SERIAL PRIMARY KEY,
    amount_cents INTEGER NOT NULL,
    method VARCHAR(50) NOT NULL,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    subscription_id INTEGER NOT NULL REFERENCES subscriptions(subscription_id)
);


--5) Standalone Movies
CREATE TABLE IF NOT EXISTS movies (
    movie_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    duration_min INT,
    release_year INTEGER,
    genre VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP


);



--6) Series
CREATE TABLE IF NOT EXISTS series (
    series_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    start_year INTEGER,
    end_year INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);



--7) Seasons within a series
CREATE TABLE IF NOT EXISTS seasons (
    season_id SERIAL PRIMARY KEY,
    season_number INTEGER NOT NULL,
    release_year INTEGER,
    series_id INTEGER NOT NULL REFERENCES series(series_id) ON DELETE CASCADE,
    UNIQUE (series_id, season_number)
);


--8) Episodes within a season
CREATE TABLE IF NOT EXISTS episodes (
    episode_id SERIAL PRIMARY KEY,
    episode_number INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    duration_min INTEGER,
    release_date DATE,
    season_id INTEGER NOT NULL REFERENCES seasons(season_id) ON DELETE CASCADE,
    UNIQUE (season_id, episode_number)
);



--9) Users whatch history
CREATE TABLE IF NOT EXISTS watch_history (
    history_id SERIAL PRIMARY KEY,
    watched_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    content_type VARCHAR(50) NOT NULL CHECK(content_type IN ('movies', 'episodes')),
    content_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL REFERENCES users(user_id),
    UNIQUE (user_id, content_type, content_id, watched_at)
);


--10) Rating of movies and series
CREATE TABLE IF NOT EXISTS ratings (
    rating_id SERIAL PRIMARY KEY,
    rated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    rating INTEGER NOT NULL CHECK(rating BETWEEN 1 AND 5),
    content_type VARCHAR(50) NOT NULL CHECK(content_type IN ('movies', 'episodes')),
    content_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL REFERENCES users(user_id),
    UNIQUE (user_id, content_type, content_id)
);


--11) Recommendations on movies and series
CREATE TABLE IF NOT EXISTS recommendations (
    recommendation_id SERIAL PRIMARY KEY,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    recom_score DECIMAL(3,2) NOT NULL CHECK (recom_score >= 0.00 AND recom_score <= 1.00),
    content_type VARCHAR(50) NOT NULL CHECK(content_type IN ('movies', 'episodes')),
    content_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL REFERENCES users(user_id),
    UNIQUE (user_id, content_type, content_id)
);


--Episodes lookup by season and order
CREATE INDEX idx_episodes_season ON episodes(season_id, episode_number);

--Which episode belongs to a series
CREATE INDEX idx_seasons_series ON seasons(series_id, season_number);

--Quering movies by release year / genre
CREATE INDEX idx_movies_year_genre ON movies(release_year, genre);


--Create view: Top 10 most watched movies overall
CREATE OR REPLACE VIEW vw_top_movies AS SELECT m.movie_id, m.title, COUNT(*) AS total_views FROM watch_history wh JOIN movies m ON wh.content_type = 'movies' AND wh.content_id = m.movie_id GROUP BY m.movie_id, m.title ORDER BY total_views DESC LIMIT 10;


--Create view: Top 10 most watched series overall
CREATE OR REPLACE VIEW vw_top_series AS SELECT s.series_id, s.title, COUNT(*) AS total_views FROM watch_history wh JOIN episodes e ON wh.content_type = 'episodes' AND wh.content_id = e.episode_id JOIN seasons sn ON e.season_id = sn.season_id JOIN series s ON sn.series_id = s.series_id GROUP BY s.series_id, s.title ORDER BY total_views DESC LIMIT 10;
