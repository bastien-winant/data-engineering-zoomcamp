FROM python:3.13.9-slim
LABEL authors="bastienwinant"

COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/

WORKDIR /code
RUN uv init
RUN uv add pandas pyarrow

ENV PATH="/code/.venv/bin:$PATH"

COPY pipeline.py pipeline.py

ENTRYPOINT ["python", "pipeline.py"]