/* @bruin

name: staging.trips
type: duckdb.sql

depends:
  - ingestion.trips
  - ingestion.payment_lookup

materialization:
  type: table
  strategy: create+replace

columns:
  - name: pickup_datetime
    type: timestamp
    description: "When the meter was engaged"
    primary_key: true
    checks:
      - name: not_null
  - name: dropoff_datetime
    type: timestamp
    description: "When the meter was disengaged"
    primary_key: true
    checks:
      - name: not_null
  - name: pickup_location_id
    type: integer
    description: "TLC taxi zone where the meter was engaged"
    primary_key: true
    checks:
      - name: not_null
  - name: dropoff_location_id
    type: integer
    description: "TLC taxi zone where the meter was disengaged"
    primary_key: true
    checks:
      - name: not_null
  - name: fare_amount
    type: float
    description: "Base fare charged by the meter"
    primary_key: true
    checks:
      - name: not_null
  - name: taxi_type
    type: string
    description: "Taxi type (yellow or green)"
    checks:
      - name: not_null
      - name: accepted_values
        value: ["yellow", "green"]
  - name: passenger_count
    type: integer
    description: "Number of passengers"
    checks:
      - name: non_negative
  - name: trip_distance
    type: float
    description: "Trip distance in miles"
    checks:
      - name: non_negative
  - name: total_amount
    type: float
    description: "Total amount charged to the passenger"
  - name: payment_type_name
    type: string
    description: "Payment method name from lookup"

custom_checks:
  - name: no_duplicate_trips
    description: "Composite key should be unique after deduplication"
    query: |
      SELECT COUNT(*) FROM (
        SELECT pickup_datetime, dropoff_datetime, pickup_location_id, dropoff_location_id, fare_amount
        FROM staging.trips
        GROUP BY 1, 2, 3, 4, 5
        HAVING COUNT(*) > 1
      )
    value: 0

@bruin */

WITH deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY pickup_datetime, dropoff_datetime, pulocationid, dolocationid, fare_amount
            ORDER BY extracted_at DESC
        ) AS _row_num
    FROM ingestion.trips
    WHERE pickup_datetime  IS NOT NULL
      AND dropoff_datetime IS NOT NULL
      AND pulocationid     IS NOT NULL
      AND dolocationid     IS NOT NULL
      AND fare_amount      IS NOT NULL
)

SELECT
    d.pickup_datetime,
    d.dropoff_datetime,
    d.pulocationid  AS pickup_location_id,
    d.dolocationid  AS dropoff_location_id,
    d.passenger_count,
    d.trip_distance,
    d.ratecodeid    AS rate_code_id,
    d.store_and_fwd_flag,
    d.payment_type,
    p.payment_type_name,
    d.fare_amount,
    d.extra,
    d.mta_tax,
    d.tip_amount,
    d.tolls_amount,
    d.improvement_surcharge,
    d.congestion_surcharge,
    d.total_amount,
    d.taxi_type,
    d.extracted_at
FROM deduplicated d
LEFT JOIN ingestion.payment_lookup p
    ON d.payment_type = p.payment_type_id
WHERE d._row_num = 1
