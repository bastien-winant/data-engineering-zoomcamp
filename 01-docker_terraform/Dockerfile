FROM python:3.13.9-slim
LABEL authors="bastienwinant"

RUN pip install pandas pyarrow

WORKDIR /code
COPY pipeline.py pipeline.py

ENTRYPOINT ["python", "pipeline.py"]