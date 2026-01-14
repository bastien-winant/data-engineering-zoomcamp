import pandas as pd
from sqlalchemy import create_engine
import argparse

def run_pipeline(user, password, host, port, db, table, year, month, chunk_size, replace=False):
	path = 'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow'
	url = f'{path}/yellow_tripdata_{year}-{month:02d}.csv.gz'

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
		chunksize=chunk_size
	)

	engine = create_engine(f"postgresql+psycopg://{user}:{password}@{host}:{port}/{db}")

	for index, df_chunk in enumerate(df_iter):
		if index == 0 and replace:
			# Create table schema (no data)
			df_chunk.head(0).to_sql(
				name=table,
				con=engine,
				if_exists="replace",
				index=False
			)

		# Insert chunk
		df_chunk.to_sql(
			name=table,
			con=engine,
			if_exists="append",
			index=False
		)

		print(f"Inserted {df_chunk.shape[0]} rows.")


if __name__=="__main__":
	parser = argparse.ArgumentParser(
		prog="NYC taxi ingestion pipeline",
		description="Extract, transform, and load selected NYC taxi trips data into a postgres database"
	)


	parser.add_argument('--pg-user', default='root', help='PostgreSQL username')
	parser.add_argument('--pg-pass', default='root', help='PostgreSQL password')
	parser.add_argument('--pg-host', default='localhost', help='PostgreSQL host')
	parser.add_argument('--pg-port', default='5431', help='PostgreSQL port')
	parser.add_argument('--pg-db', default='ny_taxi', help='PostgreSQL database name')
	parser.add_argument('--year', default=2021, type=int, help='Year of the data')
	parser.add_argument('--month', default=1, type=int, help='Month of the data')
	parser.add_argument('--chunk_size', default=100000, type=int, help='Chunk size for ingestion')
	parser.add_argument('--target-table', default='yellow_taxi_data', help='Target table name')
	parser.add_argument('--replace', default=False, help='Whether to drop the target table')

	args = parser.parse_args()

	pg_user = args.pg_user
	pg_pass = args.pg_pass
	pg_host = args.pg_host
	pg_port = args.pg_port
	pg_db = args.pg_db
	year = args.year
	month = args.month
	chunk_size = args.chunk_size
	target_table = args.target_table
	replace_table = args.replace

	run_pipeline(pg_user, pg_pass, pg_host, pg_port, pg_db, target_table, year, month, chunk_size, replace_table)

	print(target_table)