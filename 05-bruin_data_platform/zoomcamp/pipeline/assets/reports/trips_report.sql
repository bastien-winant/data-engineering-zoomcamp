/* @bruin

name: reports.trips_report
type: duckdb.sql

depends:
  - staging.trips

materialization:
  type: table
  strategy: create+replace

columns:
  - name: trip_date
    type: date
    description: "Date of the trip (derived from pickup_datetime)"
    primary_key: true
    checks:
      - name: not_null
  - name: taxi_type
    type: string
    description: "Taxi type (yellow or green)"
    primary_key: true
    checks:
      - name: not_null
  - name: payment_type_name
    type: string
    description: "Payment method name"
    primary_key: true
    checks:
      - name: not_null
  - name: trip_count
    type: integer
    description: "Number of trips"
    checks:
      - name: positive
  - name: total_passengers
    type: integer
    description: "Sum of passenger counts"
    checks:
      - name: non_negative
  - name: avg_trip_distance
    type: float
    description: "Average trip distance in miles"
    checks:
      - name: non_negative
  - name: avg_fare_amount
    type: float
    description: "Average base fare in USD"
    checks:
      - name: non_negative
  - name: avg_passenger_count
    type: float
    description: "Average number of passengers per trip"
    checks:
      - name: non_negative
  - name: total_distance
    type: float
    description: "Sum of trip distances in miles"
    checks:
      - name: non_negative
  - name: total_tips
    type: float
    description: "Sum of tip amounts in USD"
    checks:
      - name: non_negative
  - name: total_revenue
    type: float
    description: "Sum of total_amount across all trips"
    checks:
      - name: non_negative

@bruin */

SELECT
    CAST(pickup_datetime AS DATE)                        AS trip_date,
    taxi_type,
    COALESCE(payment_type_name, 'unknown')               AS payment_type_name,
    COUNT(*)                                             AS trip_count,
    COALESCE(SUM(COALESCE(passenger_count, 0)), 0)       AS total_passengers,
    
    ROUND(AVG(COALESCE(passenger_count, 0)), 2)          AS avg_passenger_count,
    ROUND(AVG(COALESCE(trip_distance, 0)), 2)            AS avg_trip_distance,
    ROUND(SUM(COALESCE(trip_distance, 0)), 2) AS total_distance,
    ROUND(AVG(COALESCE(fare_amount, 0)), 2)              AS avg_fare_amount,
    ROUND(SUM(COALESCE(tip_amount, 0)), 2) AS total_tips,
    ROUND(SUM(COALESCE(total_amount, 0)), 2) AS total_revenue
FROM staging.trips
GROUP BY 1, 2, 3
