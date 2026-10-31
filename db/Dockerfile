FROM postgres:16

COPY schema.sql /docker-entrypoint-initdb.d/01_schema.sql
COPY seed_data.sql /docker-entrypoint-initdb.d/02_seed_data.sql