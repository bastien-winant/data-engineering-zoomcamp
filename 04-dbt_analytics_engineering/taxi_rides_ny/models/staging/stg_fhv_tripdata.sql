with source as (
    select * from {{ source('raw', 'fhv_tripdata') }}
),

renamed AS (
    SELECT
      	-- identifiers
        unique_row_id,
        filename,
        dispatching_base_number,
        affiliated_base_number,
        CAST(pulocationid AS INT) AS pickup_location_id,
        CAST(dolocationid AS INT) AS dropoff_location_id,

        -- timestamps
        CAST(pickup_datetime AS TIMESTAMP) AS pickup_datetime,
        CAST(dropoff_datetime AS TIMESTAMP) AS dropoff_datetime,

        -- trip info
        CAST(sr_flag AS INT) AS sr_flag

    FROM source
)

select * from renamed
