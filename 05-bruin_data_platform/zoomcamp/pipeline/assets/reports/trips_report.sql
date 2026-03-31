/* @bruin

# Docs:
# - SQL assets: https://getbruin.com/docs/bruin/assets/sql
# - Materialization: https://getbruin.com/docs/bruin/assets/materialization
# - Quality checks: https://getbruin.com/docs/bruin/quality/available_checks

name: reports.trips_report
type: duckdb.sql

depends:
  - staging.trips

materialization:
  type: table

columns:
  - name: trip_date
    type: date
    primary_key: true
  - name: taxi_type
    type: varchar
    primary_key: true
  - name: payment_type_name
    type: varchar
  - name: trip_count
    type: bigint
    checks:
      - name: positive
  - name: total_passengers
    type: bigint
    checks:
      - name: non_negative
  - name: total_distance
    type: double
    checks:
      - name: non_negative
  - name: total_fare
    type: double
    checks:
      - name: non_negative
  - name: total_tips
    type: double
    checks:
      - name: non_negative
  - name: total_revenue
    type: double
    checks:
      - name: non_negative
  - name: avg_fare
    type: double
    checks:
      - name: non_negative
  - name: avg_trip_distance
    type: double
    checks:
      - name: non_negative
  - name: avg_passengers
    type: double
    checks:
      - name: non_negative

custom_checks:
  - name: row_count_positive
    query: SELECT COUNT(*) > 0 FROM reports.trips_report
    value: 1
@bruin */

-- Purpose of reports:
-- - Aggregate staging data for dashboards and analytics
-- Required Bruin concepts:
-- - Filter using `{{ start_datetime }}` / `{{ end_datetime }}` for incremental runs
-- - GROUP BY your dimension + date columns

SELECT
	CAST(pickup_datetime AS DATE) AS trip_date,
	taxi_type,
	payment_type_name,
	COUNT(*) AS trip_count,
	SUM(COALESCE(passenger_count, 0)) AS total_passengers,
	SUM(COALESCE(trip_distance, 0)) AS total_distance,
	SUM(COALESCE(fare_amount, 0)) AS total_fare,
	SUM(COALESCE(tip_amount, 0)) AS total_tips,
	SUM(COALESCE(total_amount, 0)) AS total_revenue,
	AVG(COALESCE(fare_amount, 0)) AS avg_fare,
	AVG(COALESCE(trip_distance, 0)) AS avg_trip_distance,
	AVG(COALESCE(passenger_count, 0)) AS avg_passenger_count
FROM staging.trips
WHERE pickup_datetime >= '{{ start_datetime }}'
AND pickup_datetime <= '{{ end_datetime }}'
GROUP BY
	CAST(pickup_datetime AS DATE),
	taxi_type,
	payment_type_name