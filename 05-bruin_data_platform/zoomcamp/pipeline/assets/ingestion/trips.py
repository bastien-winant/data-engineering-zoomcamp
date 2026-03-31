"""@bruin

# - Convention in this module: use an `ingestion.` schema for raw ingestion tables.
name: ingestion.trips

# Docs: https://getbruin.com/docs/bruin/assets/python
type: python
image: python:3.11

connection: duckdb-default

# Bruin feature: Python materialization lets you return a DataFrame (or list[dict]) and Bruin loads it into your destination.
# This is usually the easiest way to build ingestion assets in Bruin.
# Alternative (advanced): you can skip Bruin Python materialization and write a "plain" Python asset that manually writes
# into DuckDB (or another destination) using your own client library and SQL. In that case:
# - you typically omit the `materialization:` block
# - you do NOT need a `materialize()` function; you just run Python code
# Docs: https://getbruin.com/docs/bruin/assets/python#materialization
materialization:
  type: table
  strategy: append

@bruin"""

# - Put dependencies in the nearest `requirements.txt` (this template has one at the pipeline root).
# Docs: https://getbruin.com/docs/bruin/assets/python
import json
import os
from datetime import datetime
from typing import List, Tuple
import pandas as pd
from dateutil.relativedelta import relativedelta

BASE_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data"

def generate_months_to_ingest(start_date: datetime, end_date: datetime) -> List[Tuple[int, int]]:
    pass

def build_parquet_url(taxi_type: str, year: int, month: int) -> str:
    return ""

def fetch_trip_data(taxi_type: str, year: int, month: int) -> pd.DataFrame:
    return pd.DataFrame()

# If you choose the manual-write approach (no `materialization:` block), remove this function and implement ingestion
# as a standard Python script instead.
def materialize() -> pd.DataFrame:
    """
    Required Bruin concepts to use here:
    - Built-in date window variables:
      - BRUIN_START_DATE / BRUIN_END_DATE (YYYY-MM-DD)
      - BRUIN_START_DATETIME / BRUIN_END_DATETIME (ISO datetime)
      Docs: https://getbruin.com/docs/bruin/assets/python#environment-variables
    - Pipeline variables:
      - Read JSON from BRUIN_VARS, e.g. `taxi_types`
      Docs: https://getbruin.com/docs/bruin/getting-started/pipeline-variables

    Design TODOs (keep logic minimal, focus on architecture):
    - Use start/end dates + `taxi_types` to generate a list of source endpoints for the run window.
    - Fetch data for each endpoint, parse into DataFrames, and concatenate.
    - Add a column like `extracted_at` for lineage/debugging (timestamp of extraction).
    - Prefer append-only in ingestion; handle duplicates in staging.
    """
    final_dataframe = pd.DataFrame()
    return final_dataframe


