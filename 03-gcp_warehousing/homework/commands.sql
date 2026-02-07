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