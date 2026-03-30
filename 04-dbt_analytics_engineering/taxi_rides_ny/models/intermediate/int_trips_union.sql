WITH green_tripdata AS (
	SELECT *, 'Green' AS service_type FROM {{ ref("stg_green_tripdata") }}
),
yellow_tripdata AS (
	SELECT *, 'Yellow' AS service_type FROM {{ ref("stg_yellow_tripdata") }}
),
trips_union AS (
	SELECT * FROM green_tripdata
	UNION ALL
	SELECT * FROM yellow_tripdata
)
SELECT * FROM trips_union