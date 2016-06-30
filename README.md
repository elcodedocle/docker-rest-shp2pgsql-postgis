# docker-rest-shp2pgsql-postgis
shp2pgsql RESTful API on a imatia/docker-postgis container

## Deployment

`docker run -p 29060:9060 -p 25432:5432 --name imatia-postgis -e POSTGRES_PASSWORD=mysecretpassword -d elcodedocle/docker-rest-shp2psql-postgis`

## Usage
```bash
curl \
  -F "data=@/data/example.shp" \
  -F "srid=4269:2163" \
  -F "geocolumn=mycolumn" \
  -F "indexgeocolumn=true" \
  -F "pghost=localhost" \
  -F "pguser=postgres" \
  -F "pgport=5432" \
  -F "schema=myschema" \
  -F "table=mytable" \
  -F "droptable=true" \
  -F "returnsql=false" \
  localhost:29060/shp2pgsql/execute
```
