import pandas as pd
from sqlalchemy import create_engine


path = 'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow'
url = f'{path}/yellow_tripdata_2021-01.csv.gz'


dtype = {
    "VendorID": "Int64",
    "passenger_count": "Int64",
    "trip_distance": "float64",
    "RatecodeID": "Int64",
    "store_and_fwd_flag": "string",
    "PULocationID": "Int64",
    "DOLocationID": "Int64",
    "payment_type": "Int64",
    "fare_amount": "float64",
    "extra": "float64",
    "mta_tax": "float64",
    "tip_amount": "float64",
    "tolls_amount": "float64",
    "improvement_surcharge": "float64",
    "total_amount": "float64",
    "congestion_surcharge": "float64"
}


parse_dates = ["tpep_pickup_datetime", "tpep_dropoff_datetime"]


df_iter = pd.read_csv(
	url,
	dtype=dtype,
	parse_dates=parse_dates,
	iterator=True,
	chunksize=100000
)


engine = create_engine("postgresql+psycopg://root:root@localhost:5431/ny_taxi")

for index, df_chunk in enumerate(df_iter):
	if index == 0:
		# Create table schema (no data)
		df_chunk.head(0).to_sql(
			name="yellow_taxi_data",
			con=engine,
			if_exists="replace",
			index=False
		)

	# Insert chunk
	df_chunk.to_sql(
		name="yellow_taxi_data",
		con=engine,
		if_exists="append",
		index=False
	)

	print(f"Inserted {df_chunk.shape[0]} rows.")