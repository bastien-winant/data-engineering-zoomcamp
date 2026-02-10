from sqlalchemy import create_engine
import argparse
import pandas as pd

def run_pipeline(user, password, host, port, db, table, chunk_size, replace=False):
	url = f"https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv"

	df_iter = pd.read_csv(
		url,
		iterator=True,
		chunksize=chunk_size
	)

	engine = create_engine(f"postgresql+psycopg://{user}:{password}@{host}:{port}/{db}")

	for index, df_chunk in enumerate(df_iter):
		df_chunk.columns = map(lambda x: x.lower(), df_chunk.columns)

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
	parser.add_argument('--pg-port', default='5432', help='PostgreSQL port')
	parser.add_argument('--pg-db', default='ny_taxi', help='PostgreSQL database name')
	parser.add_argument('--chunk-size', default=100000, type=int, help='Chunk size for ingestion')
	parser.add_argument('--target-table', default='taxi_zones', help='Target table name')
	parser.add_argument('--replace', default=True, help='Whether to drop the target table')

	args = parser.parse_args()

	pg_user = args.pg_user
	pg_pass = args.pg_pass
	pg_host = args.pg_host
	pg_port = args.pg_port
	pg_db = args.pg_db
	chunk_size = args.chunk_size
	target_table = args.target_table
	replace_table = args.replace

	run_pipeline(pg_user, pg_pass, pg_host, pg_port, pg_db, target_table, chunk_size, replace_table)