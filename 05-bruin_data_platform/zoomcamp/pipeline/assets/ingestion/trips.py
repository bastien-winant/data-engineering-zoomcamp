"""@bruin

name: ingestion.trips

type: python
image: python:3.11

connection: duckdb-default

materialization:
  type: table
  strategy: append
@bruin"""

import json
import os
from datetime import datetime

import pandas as pd
from dateutil.relativedelta import relativedelta

TLC_BASE_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data"


def _month_range(start_date: str, end_date: str):
    """Yield (year, month) tuples covering the run window."""
    current = datetime.strptime(start_date, "%Y-%m-%d").replace(day=1)
    end = datetime.strptime(end_date, "%Y-%m-%d").replace(day=1)
    while current <= end:
        yield current.year, current.month
        current += relativedelta(months=1)


def materialize():
    start_date = os.environ["BRUIN_START_DATE"]
    end_date = os.environ["BRUIN_END_DATE"]

    bruin_vars = json.loads(os.environ.get("BRUIN_VARS", "{}"))
    taxi_types = bruin_vars.get("taxi_types", ["yellow"])

    frames = []
    for taxi_type in taxi_types:
        for year, month in _month_range(start_date, end_date):
            url = f"{TLC_BASE_URL}/{taxi_type}_tripdata_{year}-{month:02d}.parquet"
            print(f"Fetching {url}")
            try:
                df = pd.read_parquet(url)
                df["taxi_type"] = taxi_type
                frames.append(df)
            except Exception as exc:
                print(f"Skipping {url}: {exc}")

    if not frames:
        return pd.DataFrame()

    result = pd.concat(frames, ignore_index=True)
    result.columns = result.columns.str.lower()

    # Normalize the pickup/dropoff column names across yellow and green taxi schemas
    rename_map = {
        "tpep_pickup_datetime": "pickup_datetime",
        "tpep_dropoff_datetime": "dropoff_datetime",
        "lpep_pickup_datetime": "pickup_datetime",
        "lpep_dropoff_datetime": "dropoff_datetime",
    }
    result.rename(columns={k: v for k, v in rename_map.items() if k in result.columns}, inplace=True)

    result["extracted_at"] = datetime.utcnow()

    return result