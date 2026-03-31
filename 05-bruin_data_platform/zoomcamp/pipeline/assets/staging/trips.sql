/* @bruin

# Docs:
# - Materialization: https://getbruin.com/docs/bruin/assets/materialization
# - Quality checks (built-ins): https://getbruin.com/docs/bruin/quality/available_checks
# - Custom checks: https://getbruin.com/docs/bruin/quality/custom

name: staging.trips
# Docs: https://getbruin.com/docs/bruin/assets/sql
# suggested type: duckdb.sql
type: duckdb.sql

depends:
  - ingestion.trips
  - ingestion.payment_lookup

# - This module expects you to use `time_interval` to reprocess only the requested window.
materialization:
  type: table

columns:
   - name: pickup_datetime
   	 type: timestamp
   	 primary_key: true

   - name: dropoff_datetime
   	 type: timestamp
   	 primary_key: true

   - name: pickup_location_id
   	 type: integer
   	 primary_key: true

   - name: dropoff_location_id
   	 type: integer
   	 primary_key: true

   - name: fare_amount
   	 type: double
     primary_key: true
     checks:
   		- name: non_negative

   - taxi_type
   	 type: varchar
     checks:
      - name: not_null
   		- name: accepted_values
   			values: ['yellow', 'green']

   - name: payment_type_name
   	 type: varchar

   - name: passenger_count
     type: integer
   	 checks:
   		- name: non_negative

   - name: trip_distance
   	 type: double
   	 checks:
   		- name: non_negative

   - name: total_amount
   	 type: double
   	 checks:
   		- name: non_negative



# Docs: https://getbruin.com/docs/bruin/quality/custom
custom_checks:
  - name: row_count_positive
    description: Ensure the table is not empty
    query: |
      SELECT COUNT(*) > 0 FROM staging.trips
    value: 1

@bruin */

-- Purpose of staging:
-- - Clean and normalize schema from ingestion
-- - Deduplicate records (important if ingestion uses append strategy)
-- - Enrich with lookup tables (JOINs)
-- - Filter invalid rows (null PKs, negative values, etc.)
--
-- Why filter by {{ start_datetime }} / {{ end_datetime }}?
-- When using `time_interval` strategy, Bruin:
--   1. DELETES rows where `incremental_key` falls within the run's time window
--   2. INSERTS the result of your query
-- Therefore, your query MUST filter to the same time window so only that subset is inserted.
-- If you don't filter, you'll insert ALL data but only delete the window's data = duplicates.

WITH source_data AS (
	SELECT
		tpep_pickup_datetime AS pickup_datetime,
		tpep_dropoff_datetime AS dropoff_datetime,
		pu_location_id AS pickup_location_id,
		do_location_id AS dropoff_location_id,
		taxi_type,
		passenger_count,
		trip_distance,
		payment_type,
		fare_amount,
		extra,
		mta_tax,
		tip_amount,
		tolls_amount,
		improvement_surcharge,
		total_amount,
		extracted_at
	FROM ingestion.trips
	WHERE 1=1
	AND tpep_pickup_datetime IS NOT NULL
	AND fare_amount >= 0
	AND total_amount >= 0
),
deduplicated AS (
	SELECT
		*,
		ROW_NUMBER() OVER (
			PARTITION BY
				pickup_datetime,
				dropoff_datetime,
				pickup_location_id,
				dropoff_location_id,
				fare_amount
			ORDER BY extracted_at DESC
		) AS row_num
	FROM source_data
)
SELECT
	d.pickup_datetime,
	d.dropoff_datetime,
	d.pickup_location_id,
	d.dropoff_location_id,
	d.taxi_type,
	d.passenger_count,
	d.trip_distance,
	d.payment_type,
	COALESCE(p.payment_type_name, 'unknown') AS payment_type_name,
	d.fare_amount,
	d.extra,
	d.mta_tax,
	d.tip_amount,
	d.tolls_amount,
	d.improvement_surcharge,
	d.total_amount,
	d.extracted_at
FROM deduplicated d
LEFT JOIN ingestion.payment_lookup p
	ON d.payment_type = p.payment_type_id
WHERE d.row_num = 1