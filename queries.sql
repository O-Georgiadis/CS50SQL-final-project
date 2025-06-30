-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database

--List all movies of a given genre
SELECT movie_id, title, release_year, genre FROM movies WHERE genre = 'Drama' ORDER BY  release_year DESC;

--Find the 10 most recent episodes watched by a particular user
SELECT wh.watched_at, e.title AS episode_title, s.season_number, sn.title AS series_title FROM watch_history wh JOIN episodes e ON wh.content_type = 'episodes' AND wh.content_id = e.episode_id JOIN seasons s ON e.season_id = s.season_id JOIN series sn ON s.series_id = sn.series_id WHERE wh.user_id = 15 ORDER BY wh.watched_at DESC LIMIT 10;

--Find the top 10 recommended items for a user
SELECT content_type, content_id, recom_score FROM recommendations WHERE user_id = 15 ORDER BY recom_score DESC LIMIT 10;

--Update a subscription status to canceled when a user cancels
UPDATE subscriptions SET status = 'canceled', end_date = CURRENT_DATE WHERE subscription_id = 15;

--Insert a new user into the platform
INSERT INTO users (email, name) VALUES ('abcs@example.com', 'John Wick');

--Find the most popular genres by total views
SELECT m.genre, COUNT(*) AS total_views FROM watch_history wh JOIN movies m ON wh.content_type = 'movies' AND wh.content_id = m.movie_id GROUP BY m.genre ORDER BY total_views DESC LIMIT 5;
