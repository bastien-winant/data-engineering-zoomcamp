WITH all_trips AS (
	SELECT * FROM {{ ref("int_trips_union") }}
),
vendors AS (
	SELECT
		DISTINCT vendor_id,
		{{ get_vendor_name('vendor_id') }} AS vendor_name
	FROM all_trips
)
SELECT * FROM vendors