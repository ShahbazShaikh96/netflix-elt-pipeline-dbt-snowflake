{{ config(materialized='view') }}

SELECT
  genre.value::string AS genre,
  AVG(r.rating) AS average_rating,
  COUNT(DISTINCT m.movie_id) AS total_movies
FROM {{ ref('dim_movies') }} m
JOIN {{ ref('fct_ratings') }} r ON m.movie_id = r.movie_id,
LATERAL FLATTEN(input => m.genre_array) genre
GROUP BY genre.value::string
ORDER BY average_rating DESC
