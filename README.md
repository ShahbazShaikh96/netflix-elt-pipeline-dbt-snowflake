# Netflix ELT Data Pipeline — S3 + Snowflake + dbt

> A production-style ELT pipeline that extracts raw Netflix data, stages it in Amazon S3, loads it into Snowflake, and transforms it into clean analytics-ready models using dbt — built to mirror real-world data engineering workflows used at companies like Lyft, Comcast, and JPMorgan.

![AWS S3](https://img.shields.io/badge/Amazon_S3-FF9900?style=for-the-badge&logo=amazons3&logoColor=white)
![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)
![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-4479A1?style=for-the-badge&logo=postgresql&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)

---

## Project Overview

This project simulates an end-to-end data engineering pipeline for Netflix data. The architecture follows the modern **ELT pattern** — data is extracted and loaded first, then transformed inside the warehouse using dbt's layered modeling approach.

The pipeline moves data through three distinct systems:
- **Amazon S3** — acts as the raw data landing zone and external stage
- **Snowflake** — cloud data warehouse that stores both raw and transformed data
- **dbt** — handles all transformation logic through staging, intermediate, and mart layers

---

## Full Pipeline Architecture

```
╔══════════════════════════════════════════════════════════════════╗
║                        DATA SOURCE                               ║
║                  Raw Netflix / MovieLens Files                   ║
║                    (CSV / JSON format)                           ║
╚══════════════════════════════╦═══════════════════════════════════╝
                               ║  EXTRACT
                               ▼
╔══════════════════════════════════════════════════════════════════╗
║                        AMAZON S3                                 ║
║                                                                  ║
║         s3://netflix-pipeline-bucket/raw/movies/                 ║
║         s3://netflix-pipeline-bucket/raw/ratings/                ║
║         s3://netflix-pipeline-bucket/raw/users/                  ║
║                                                                  ║
║   Acts as the raw data landing zone and Snowflake external stage ║
╚══════════════════════════════╦═══════════════════════════════════╝
                               ║  LOAD via COPY INTO
                               ▼
╔══════════════════════════════════════════════════════════════════╗
║                        SNOWFLAKE                                 ║
║                                                                  ║
║   Database : NETFLIX_DB                                          ║
║   Warehouse: COMPUTE_WH                                          ║
║   Schema   : RAW  →  DBT_DEV  →  ANALYTICS                      ║
║                                                                  ║
║   External Stage (S3) → COPY INTO → Raw Tables                  ║
╚══════════════════════════════╦═══════════════════════════════════╝
                               ║  TRANSFORM
                               ▼
╔══════════════════════════════════════════════════════════════════╗
║                        dbt LAYERS                                ║
║                                                                  ║
║  ┌──────────────┐   ┌─────────────────┐   ┌─────────────────┐  ║
║  │   STAGING    │──▶│  INTERMEDIATE   │──▶│     MARTS       │  ║
║  │              │   │                 │   │                 │  ║
║  │ stg_movies   │   │ int_ratings     │   │ dim_movies      │  ║
║  │ stg_ratings  │   │ __grouped_by    │   │ dim_users       │  ║
║  │ stg_users    │   │ _genre          │   │ fct_ratings     │  ║
║  │              │   │                 │   │                 │  ║
║  │ Clean + Cast │   │ Join + Aggregate│   │ dim_ + fct_     │  ║
║  │ Rename cols  │   │ Business logic  │   │ Star Schema     │  ║
║  └──────────────┘   └─────────────────┘   └─────────────────┘  ║
║                                                                ║
║           dbt Tests + Documentation at every layer             ║
╚══════════════════════════════╦═════════════════════════════════╝
                               ║
                               ▼
╔══════════════════════════════════════════════════════════════════╗
║                   ANALYTICS / BI LAYER                           ║
║         Clean Snowflake Tables → Reports / Dashboards            ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## dbt Lineage Graph

> Every arrow below represents a `{{ ref() }}` dependency — dbt uses this to build the full DAG and execute models in the correct order automatically.

```
[S3 External Stage]
        │
        ▼
[Raw Snowflake Tables]          [Seeds / Lookup Tables]
        │                               │
        ▼                               ▼
[stg_netflix__movies]    [stg_netflix__ratings]    [stg_netflix__users]
        │                       │                        │
        └───────────────────────┼────────────────────────┘
                                ▼
                  [int_ratings__grouped_by_genre]
                                │
                ┌───────────────┴───────────────┐
                ▼                               ▼
          [dim_movies]                    [dim_users]
                │                               │
                └───────────────┬───────────────┘
                                ▼
                          [fct_ratings]
                                │
                                ▼
                    [Analytics / BI Dashboards]
```

<!-- Replace with your actual dbt lineage screenshot -->
> **Screenshot:** Add your dbt Cloud lineage DAG screenshot here — `assets/lineage_graph.png`

---

## Tech Stack

| Layer | Tool | Purpose |
|-------|------|---------|
| **Storage** | Amazon S3 | Raw data landing zone + Snowflake external stage |
| **Warehouse** | Snowflake | Stores raw and transformed data, runs SQL compute |
| **Transform** | dbt Core | Staging → Intermediate → Mart model layers |
| **Language** | SQL | All transformation logic |
| **Version Control** | GitHub | Full pipeline code versioned and documented |

---

## Project Structure

```
NETFLIXDBT/
│
├── models/
│   │
│   ├── staging/                         # Layer 1 — 1:1 with raw sources
│   │   └── netflix/
│   │       ├── _netflix__sources.yml    # Declares S3-loaded Snowflake raw tables
│   │       ├── stg_netflix__movies.sql
│   │       ├── stg_netflix__ratings.sql
│   │       └── stg_netflix__users.sql
│   │
│   ├── intermediate/                    # Layer 2 — Business logic buffer
│   │   └── int_ratings__grouped_by_genre.sql
│   │
│   └── marts/                           # Layer 3 — Final analytics tables
│       └── core/
│           ├── _core__models.yml        # Tests + documentation
│           ├── dim_movies.sql           # Dimension: movie attributes
│           ├── dim_users.sql            # Dimension: user attributes
│           └── fct_ratings.sql          # Fact: rating events + metrics
│
├── seeds/                               # Static CSV lookup tables
├── snapshots/                           # SCD Type 2 historical tracking
├── tests/                               # Custom singular data quality tests
├── macros/                              # Reusable Jinja SQL functions
├── .gitignore                           # Excludes credentials + generated files
├── dbt_project.yml                      # Project configuration
└── README.md
```

---

## dbt Layer Breakdown

### Layer 1 — Staging (`stg_`)
One model maps to exactly one raw Snowflake table (loaded from S3).
Only cleans, renames, and casts — never joins or aggregates.

```sql
-- stg_netflix__movies.sql
with source as (
    select * from {{ source('netflix', 'raw_movies') }}
),
renamed as (
    select
        movie_id::integer       as movie_id,
        lower(title)            as movie_title,
        release_year::integer   as release_year,
        genre                   as genre
    from source
)
select * from renamed
```

### Layer 2 — Intermediate (`int_`)
Joins multiple staging models and applies business logic.
Materialized as **views** — never permanent tables — to save Snowflake credits.

```sql
-- int_ratings__grouped_by_genre.sql
with ratings as (
    select * from {{ ref('stg_netflix__ratings') }}
),
movies as (
    select * from {{ ref('stg_netflix__movies') }}
),
joined as (
    select
        movies.genre,
        count(ratings.rating_id)    as total_ratings,
        avg(ratings.rating_value)   as avg_rating
    from ratings
    left join movies using (movie_id)
    group by 1
)
select * from joined
```

### Layer 3 — Marts (`dim_` + `fct_`)
Final tables consumed by BI tools and analysts.
Materialized as **tables** for fast query performance.

| Model | Type | Description |
|-------|------|-------------|
| `dim_movies` | Dimension | Movie attributes — title, genre, release year |
| `dim_users` | Dimension | User attributes — location, age group, join date |
| `fct_ratings` | Fact | Rating events — foreign keys + numeric metrics |

---

## Data Quality Testing

Automated tests run at every layer via dbt:

```yaml
# _core__models.yml
models:
  - name: fct_ratings
    columns:
      - name: rating_id
        tests:
          - unique          # No duplicate ratings
          - not_null        # Every rating must have an ID
      - name: movie_id
        tests:
          - relationships:
              to: ref('dim_movies')
              field: movie_id   # Referential integrity check
      - name: rating_value
        tests:
          - accepted_values:
              values: [1, 2, 3, 4, 5]  # Rating must be 1–5
```

Run all tests:
```bash
dbt test
```

---

## How to Run This Project

### Prerequisites
- AWS account with S3 bucket configured
- Snowflake account (free trial works)
- Python 3.8+ installed
- dbt Core installed

### Installation

**1. Clone the repo**
```bash
git clone https://github.com/ShahbazShaikh96/dbt-snowflake-pipeline.git
cd dbt-snowflake-pipeline
```

**2. Install dbt Snowflake adapter**
```bash
pip install dbt-snowflake
```

**3. Set up credentials — create `~/.dbt/profiles.yml` on your machine**
> Never commit this file — it contains your Snowflake credentials

```yaml
netflix_dbt:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: your_snowflake_account
      user: your_username
      password: your_password
      role: TRANSFORMER
      database: NETFLIX_DB
      warehouse: COMPUTE_WH
      schema: dbt_dev
      threads: 4
```

**4. Run the pipeline**
```bash
dbt deps        # Install dbt packages
dbt seed        # Load static lookup tables
dbt run         # Execute all models
dbt test        # Run all data quality tests
```

**5. View documentation and lineage**
```bash
dbt docs generate
dbt docs serve
```

---

## S3 to Snowflake — How Data Loads

Raw files land in S3 first, then Snowflake pulls them in via an external stage:

```sql
-- Step 1: Create external stage pointing to S3
CREATE OR REPLACE STAGE netflix_s3_stage
  URL = 's3://netflix-pipeline-bucket/raw/'
  CREDENTIALS = (
    AWS_KEY_ID = '...'
    AWS_SECRET_KEY = '...'
  )
  FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- Step 2: Load data into raw Snowflake table
COPY INTO raw_movies
FROM @netflix_s3_stage/movies/
FILE_FORMAT = (TYPE = 'CSV')
ON_ERROR = 'CONTINUE';
```


## Key Concepts Demonstrated

- ✅ **ELT pattern** — load raw into S3 + Snowflake first, transform inside the warehouse
- ✅ **Amazon S3 as external stage** — industry-standard raw data landing zone
- ✅ **COPY INTO** — Snowflake's bulk data loading from S3
- ✅ **dbt `{{ ref() }}`** — dependency management and automatic DAG building
- ✅ **Staging → Intermediate → Mart** layering (analytics engineering standard)
- ✅ **Star Schema design** — dimension and fact tables for BI performance
- ✅ **Automated data quality testing** at every model layer
- ✅ **Source freshness checks** — detecting stale upstream data

---

## What I would Improve Next

- Add **incremental models** to avoid full table refreshes on large datasets
- Add **Snapshots** to track slowly changing user data over time (SCD Type 2)
- Set up **Apache Airflow** to orchestrate dbt runs on a schedule
- Connect to a BI tool (Tableau / Looker) declared as dbt **Exposures**
- Add **GitHub Actions CI/CD** to run `dbt test` automatically on every pull request
- Add **Kafka** for real-time streaming ratings data instead of batch CSV loads

---
