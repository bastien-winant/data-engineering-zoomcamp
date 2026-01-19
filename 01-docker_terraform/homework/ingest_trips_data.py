from sqlalchemy import create_engine
import argparse
import duckdb

def run_pipeline(user, password, host, port, db, table, vehicle_type, year, month, chunk_size, replace=False):
	url = f"https://d37ci6vzurychx.cloudfront.net/trip-data/{vehicle_type}_tripdata_{year}-{month:02d}.parquet"

	with duckdb.connect(':memory:') as con:
		engine = create_engine(f"postgresql+psycopg://{user}:{password}@{host}:{port}/{db}")

		results = con.sql(f"SELECT * FROM '{url}'").fetch_record_batch(chunk_size)
		first = True

		while True:
			try:
				df = results.read_next_batch().to_pandas()

				if df.empty:
					break

				df.columns = map(lambda x: x.lower(), df.columns)

				if replace and first:
					df.head(0).to_sql(
						name=table,
						con=engine,
						if_exists="replace",
						index=False
					)

					first = False

				df.to_sql(
					name=table,
					con=engine,
					if_exists="append",
					index=False
				)

				print(f"Inserted {df.shape[0]} rows.")
			except StopIteration:
				break

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
	parser.add_argument('--type', default='green', help='Type of vehicle')
	parser.add_argument('--year', default=2021, type=int, help='Year of the data')
	parser.add_argument('--month', default=1, type=int, help='Month of the data')
	parser.add_argument('--chunk-size', default=100000, type=int, help='Chunk size for ingestion')
	parser.add_argument('--target-table', default='green_taxi_data', help='Target table name')
	parser.add_argument('--replace', default=True, help='Whether to drop the target table')

	args = parser.parse_args()

	pg_user = args.pg_user
	pg_pass = args.pg_pass
	pg_host = args.pg_host
	pg_port = args.pg_port
	pg_db = args.pg_db
	vehicle_type = args.type
	year = args.year
	month = args.month
	chunk_size = args.chunk_size
	target_table = args.target_table
	replace_table = args.replace

	run_pipeline(pg_user, pg_pass, pg_host, pg_port, pg_db, target_table, vehicle_type, year, month, chunk_size, replace_table)