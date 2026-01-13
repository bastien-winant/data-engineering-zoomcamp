FROM python:3.13.9-slim
LABEL authors="bastienwinant"

COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/

#set up a UV project
WORKDIR /code
RUN uv init
RUN uv add pandas pyarrow

#add python installation to the path
ENV PATH="/code/.venv/bin:$PATH"

#copy the pipeline script file
COPY pipeline.py pipeline.py

#execute the script
ENTRYPOINT ["python", "pipeline.py"]