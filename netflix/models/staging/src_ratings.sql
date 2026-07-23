{{config(materialized = 'table')}}


WITH raw_ratings AS (
    SELECT * FROM MOVIELENS.RAW.RAW_RATINGS
)

SELECT 
    USERID AS user_id,
    MOVIEID AS movie_id,
    RATING AS rating,
    TO_TIMESTAMP_LTZ(TIMESTAMP) AS rating_timestamp
FROM raw_ratings