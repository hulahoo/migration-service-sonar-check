FROM postgres:14-alpine
ENV POSTGRES_USER dbuser
ENV POSTGRES_PASSWORD test
ENV POSTGRES_DB db
ENV POSTGRES_HOST_AUTH_METHOD trust

ADD 2022/data/* /docker-entrypoint-initdb.d/

ADD 2022/a-schema.sql /docker-entrypoint-initdb.d/
