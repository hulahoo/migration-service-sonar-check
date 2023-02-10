FROM python:3.10.8-slim as deps
WORKDIR /app
COPY . ./
RUN apt-get update -y && apt-get -y install gcc
RUN pip --no-cache-dir install -r requirements.txt 
RUN pip --no-cache-dir install -r requirements.setup.txt 
RUN pip install -e .

FROM deps as build
ARG ARTIFACT_VERSION=local
RUN python setup.py sdist bdist_wheel
RUN ls -ll /app/
RUN ls -ll /app/dist/


FROM python:3.10.8-slim as runtime
COPY --from=build /app/dist/*.whl /app/
RUN apt-get update -y && apt-get -y install gcc
RUN pip --no-cache-dir install /app/*.whl
ENTRYPOINT ["postgres-db-migrations"]
