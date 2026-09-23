# Postgres 17 com Apache AGE (grafo) + pgvector (vetor) + PostGIS (geo) no
# mesmo banco.
#
# Base: imagem oficial apache/age, que já traz o Postgres 17 + AGE compilados
# e o repositório PGDG configurado. pgvector e PostGIS vêm do próprio PGDG —
# não precisa compilar nada, só instalar os pacotes .deb oficiais. Testado ao
# vivo: as 3 extensões coexistem sem conflito no mesmo banco.
FROM apache/age:release_PG17_1.7.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       postgresql-17-pgvector \
       postgresql-17-postgis-3 \
    && rm -rf /var/lib/apt/lists/*
