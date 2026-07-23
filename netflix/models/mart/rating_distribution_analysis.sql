{{ config(materialized='view') }}

SELECT
  rating,
  COUNT(*) AS number_of_ratings,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_ratings
FROM {{ ref('fct_ratings') }}
GROUP BY rating
ORDER BY rating
