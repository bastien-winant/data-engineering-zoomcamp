WITH trip_data AS (
	SELECT * FROM {{ ref("int_trips_union") }}
),

monthly_revenue_by_location AS (
	SELECT
		pickup_location_id AS location_id,
		DATE_TRUNC(pickup_datetime, MONTH) AS month,
		SUM(total_amount) AS revenue
	FROM trip_data
	GROUP BY 1, 2
)

SELECT * FROM monthly_revenue_by_location