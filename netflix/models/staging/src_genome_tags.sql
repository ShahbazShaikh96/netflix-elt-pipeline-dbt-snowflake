WITH raw_genome_tags AS (
    SELECT * FROM MOVIELENS.RAW.RAW_GENOME_TAGS
)

SELECT 
    tagID AS tag_id,
    tag AS tag
FROM raw_genome_tags