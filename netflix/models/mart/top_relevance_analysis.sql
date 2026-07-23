{{ config(materialized='view') }}

SELECT
  t.tag_name,
  AVG(gs.relevance_score) AS average_relevance,
  COUNT(DISTINCT gs.movie_id) AS movies_tagged
FROM {{ ref('fct_genome_score') }} gs
JOIN {{ ref('dim_genome_tags') }} t ON gs.tag_id = t.tag_id
GROUP BY t.tag_name
ORDER BY average_relevance DESC
