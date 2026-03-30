WITH trip_data AS (
	SELECT * FROM {{ ref("fct_trips") }}
),

monthly_revenue_by_location AS (
	SELECT
		pickup_location_id AS location_id,
		DATE_TRUNC(pickup_datetime, MONTH) AS revenue_month,

		-- Revenue breakdown (summed by location, month)
		SUM(fare_amount) AS monthly_revenue_fare,
    SUM(extra) AS monthly_revenue_extra,
    SUM(mta_tax) AS monthly_revenue_mta_tax,
    SUM(tip_amount) AS monthly_revenue_tip_amount,
    SUM(tolls_amount) AS monthly_revenue_tolls_amount,
    SUM(ehail_fee) AS monthly_revenue_ehail_fee,
    SUM(improvement_surcharge) AS monthly_revenue_improvement_surcharge,
    SUM(total_amount) AS monthly_revenue_total_amount,

    -- Additional metrics for operational analysis
    COUNT(trip_id) AS total_monthly_trips,
    AVG(passenger_COUNT) AS AVG_monthly_passenger_COUNT,
    AVG(trip_distance) AS AVG_monthly_trip_distance
	FROM trip_data
	GROUP BY 1, 2
)

SELECT * FROM monthly_revenue_by_location