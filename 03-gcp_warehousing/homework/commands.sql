-- CREATE AN EXTERNAL TABLE FROM GCP BUCKET FILES
CREATE OR REPLACE EXTERNAL TABLE `spatial-thinker-484214-n8.zoomcamp.external_yellow_tripdata`
OPTIONS(
  format = 'CSV',
  uris = ['gs://zoomcamp_spatial-thinker-484214-n8/yellow_tripdata_2019-*.csv', 'gs://zoomcamp_spatial-thinker-484214-n8/yellow_tripdata_2020-*.csv']
);

SELECT * FROM spatial-thinker-484214-n8.zoomcamp.external_yellow_tripdata LIMIT 10;

-- CREATE REGULAR BIGQUERY TABLE FROM EXTERNAL TABLE
CREATE OR REPLACE TABLE spatial-thinker-484214-n8.zoomcamp.yellow_tripdata_non_partitioned AS
SELECT * FROM spatial-thinker-484214-n8.zoomcamp.external_yellow_tripdata;

-- CREATE PARTITIONED TABLE
CREATE OR REPLACE TABLE spatial-thinker-484214-n8.zoomcamp.yellow_tripdata_partitioned
PARTITION BY DATE(tpep_pickup_datetime) AS
SELECT * FROM spatial-thinker-484214-n8.zoomcamp.external_yellow_tripdata;


SELECT DISTINCT(VendorID)
FROM spatial-thinker-484214-n8.zoomcamp.yellow_tripdata_non_partitioned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

-- CREATE PARTITIONED TABLE
SELECT DISTINCT(VendorID)
FROM spatial-thinker-484214-n8.zoomcamp.yellow_tripdata_partitioned
WHERE DATE(tpep_pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

-- INSPECT PARTITIONS
SELECT table_name, partition_id, total_rows
FROM `zoomcamp.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = 'yellow_tripdata_partitioned'
ORDER BY total_rows DESC;

-- CREATE CLUSTERED TABLE (ARRANGE WITHIN PARTITION)
CREATE OR REPLACE TABLE spatial-thinker-484214-n8.zoomcamp.yellow_tripdata_partitioned_clustered
PARTITION BY DATE(tpep_pickup_datetime)
CLUSTER BY VendorID AS
SELECT * FROM spatial-thinker-484214-n8.zoomcamp.external_yellow_tripdata;