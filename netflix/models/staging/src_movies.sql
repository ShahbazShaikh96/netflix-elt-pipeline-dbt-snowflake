WITH raw_movies AS (
    SELECT * FROM {{source('netflix', 'r_movies')}}  
)

SELECT 
    MOVIEID AS movie_id,
    TITLE AS title,
    GENRES AS genres
FROM raw_movies