# docker-rest-shp2pgsql-postgis
shp2pgsql RESTful API on a imatia/docker-postgis container

## Deployment

`docker run -p 29643:9643 -p 25432:5432 --name imatia-postgis -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=mysecretpassword -d elcodedocle/docker-rest-shp2psql-postgis`

You can also provide the following env vars:

```bash
-e REMOTE_PGHOST=remotepostgresservicehost
-e REMOTE_PGPORT=remotepostgresserviceport
-e REMOTE_PGUSER=remotepostgresserviceuser
-e REMOTE_PGPASSWORD=remotepostgresservicepassword
```

Otherwise the generated SQL will be imported on the postgres+postgis deployed on the container.

## Usage

This service expects a `.zip` file with containing a `shp` layer definition and its related resources. It will execute the shp2pgsql command on the container with the provided parameters. 

### SwaggerUI

Open a browser on the docker host and navigate to https://localhost:29643/swagger-ui.html

### curl

```bash
curl -k \
  -F "data=@/data/exampleshp.zip" \
  -F "srid=4269:2163" \
  -F "geocolumn=mycolumn" \
  -F "indexgeocolumn=true" \
  -F "schema=myschema" \
  -F "table=mytable" \
  -F "droptable=true" \
  -F "returnsql=false" \
  https://localhost:29060/shp2pgsql/execute
```

## Notes

At this development stage the service is not secured, nor the input parameters are validated. Since the command is being executed inside the docker container there is not a lot of damage to be done if the service is accidentally exposed where it shouldn't, but do not deploy it on production environments!
