-- CREATE AN EXTERNAL TABLE FROM GCP BUCKET FILES
CREATE OR REPLACE EXTERNAL TABLE `spatial-thinker-484214-n8.zoomcamp.external_yellow_tripdata`
OPTIONS(
  format = 'PARQUET',
  uris = ['gs://zoomcamp_spatial-thinker-484214-n8/yellow_tripdata_2024-*.parquet']
);

-- CREATE REGULAR BIGQUERY TABLE FROM EXTERNAL TABLE
CREATE OR REPLACE TABLE spatial-thinker-484214-n8.zoomcamp.yellow_tripdata_non_partitioned AS
SELECT * FROM spatial-thinker-484214-n8.zoomcamp.external_yellow_tripdata;

-- Question 1. Counting records
SELECT COUNT(*) FROM spatial-thinker-484214-n8.zoomcamp.yellow_tripdata_non_partitioned;
-- 20332093

-- Question 2. Data read estimation
SELECT COUNT (DISTINCT PULocationID) FROM spatial-thinker-484214-n8.zoomcamp.external_yellow_tripdata; -- 0 MB
SELECT COUNT (DISTINCT PULocationID) FROM spatial-thinker-484214-n8.zoomcamp.yellow_tripdata_non_partitioned; -- 155.12 MB

-- Question 3. Understanding columnar storage
SELECT PULocationID FROM spatial-thinker-484214-n8.zoomcamp.yellow_tripdata_non_partitioned;
SELECT PULocationID, DOLocationID FROM spatial-thinker-484214-n8.zoomcamp.yellow_tripdata_non_partitioned;

-- Question 4. Counting zero fare trips
SELECT COUNT(*) FROM spatial-thinker-484214-n8.zoomcamp.yellow_tripdata_non_partitioned WHERE fare_amount = 0;
-- 8333

-- Question 5. Partitioning and clustering
-- Partition by tpep_dropoff_datetime and Cluster on VendorID

-- Question 6. Partition benefits
CREATE OR REPLACE TABLE spatial-thinker-484214-n8.zoomcamp.yellow_tripdata_partitioned
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID AS
SELECT * FROM spatial-thinker-484214-n8.zoomcamp.external_yellow_tripdata;

SELECT
	DISTINCT VendorID
FROM spatial-thinker-484214-n8.zoomcamp.yellow_tripdata_non_partitioned
WHERE tpep_dropoff_datetime BETWEEN '2024-03-01' AND '2024-03-15'; -- 310.24

SELECT
	DISTINCT VendorID
FROM spatial-thinker-484214-n8.zoomcamp.yellow_tripdata_partitioned
WHERE tpep_dropoff_datetime BETWEEN '2024-03-01' AND '2024-03-15'; -- 26.84

-- Question 9. Understanding table scans
SELECT count(*) FROM spatial-thinker-484214-n8.zoomcamp.yellow_tripdata_non_partitioned; -- 0