# docker-rest-shp2pgsql-postgis
shp2pgsql RESTful API on a imatia/docker-postgis container

## Deployment

```
docker run -p 29643:9643 -p 25432:5432 --name imatia-rest-shp2pgsql-postgis \
-e POSTGRES_USER=docker \
-e POSTGRES_PASSWORD=mysecretpassword \
-e REMOTE_PGDB=gistest \
-e SHP_TEMP_STORAGE_PATH=/tmp \
-e SG_OAUTH2_APP_SECRET=oauth2sgappsecret \
-d imatia/docker-rest-shp2pgsql-postgis
```

The generated SQL will be imported on the postgres+postgis deployed on the container. 

The HTTPS certificate is taken from /keystore.jks file placed on the container.

If you want to modify these and other settings, you can also provide the following env vars:

```bash
-e REMOTE_PGHOST=localhost
-e REMOTE_PGPORT=5432
-e SHP2PGSQL_KEYSTORE_PATH=/keystore.jks 
-e SHP2PGSQL_KEYSTORE_PASSWORD=password 
-e SHP2PGSQL_KEY_PASSWORD=password 
-e SHP2PGSQL_ENABLE_CORS=true 
-e SHP2PGSQL_DISABLE_CSRF_PROTECTION=true 
-e SG_OAUTH2_DISABLE_SECURIZATION=false
-e SG_OAUTH2_CLIENT_ID=sgclientapp
-e SG_OAUTH2_ACCESS_TOKEN_URI=https://localhost:8080/oauth/token
-e SG_OAUTH2_USER_AUTHORIZATION_URI=https://localhost:8080/oauth/authorize
-e SG_OAUTH2_TOKEN_NAME=oauth2sgappsecret
-e SG_OAUTH2_AUTHENTICATION_SCHEME=query
-e SG_OAUTH2_CLIENT_AUTHENTICATION_SCHEME=form
-e SG_OAUTH2_LOGIN_ENDPOINT=https://localhost:8080/login
-e SG_OAUTH2_USER_INFO_URI=https://localhost:8080/me
-e SHP2PGSQL_REMOTE_DEBUG=false
```

If you want to provide your own HTTPS certificate without rebuilding the container you can use the `-v` flag to mount a host keystore location on the container, then specify its path and access credentials using the available env vars. e.g.:

```bash
docker run \
...
-v /path/to/keystore:/usr/share/keystores \
-e SHP2PGSQL_KEYSTORE_PATH=/usr/share/keystores/keystore.jks \
-e SHP2PGSQL_KEYSTORE_PASSWORD=password \
-e SHP2PGSQL_KEY_PASSWORD=password \
...
```

## Usage

This service expects a `.zip` file with containing a `shp` layer definition and its related resources. It will execute the `shp2pgsql` command on the container with the provided parameters. 

### SwaggerUI

 1. Open a browser on the docker host and navigate to https://localhost:29643/swagger-ui.html
 2. Provide the authorization credentials, when required
 3. Fill the provided HTML form as the embedded documentation indicates to send a request and display its response
![Imatia shp2pgsql service SwaggerUI invocation](https://cloud.githubusercontent.com/assets/3731026/17036960/faa460bc-4f8e-11e6-8e70-35ef621cb916.png)

### curl
OAuth Service Invocation (gets an access token):
```bash
curl -X POST -d "client_id=oauth2clientid&amp;client_secret=secret&amp;grant_type=password&amp;username=myuser&amp;password=mypass" http://myoauth2authorizationservicehost:port/path/to/token
```
 - client_id must match --oauth2clientid app.jar command line parameter (defaults to sgclientapp)
Service Invocation:
```bash
curl -k \
  --header "Authorization: Bearer my-oauth-access-token" \
  -F "shpzipfile=@/data/exampleshp.zip" \
  -F "srid=4269:2163" \
  -F "geocolumn=mycolumn" \
  -F "indexgeocolumn=true" \
  -F "schemaandtable=myschema.mytable" \
  -F "droptable=true" \
  -F "returnsql=false" \
  -F "importsql=true" \
  -F "metadata={\"test\":\"This is a test\"}" \
  https://localhost:29643/shp2pgsql/execute
```

## Notes

- You can run the service without requiring authentication using the env var `-e SG_OAUTH2_DISABLE_SECURIZATION=true` 

- Metadata is a *required* parameter but it only serves logging purposes. Any valid JSON string will do.

- Basic input parameter validation *is being tested*. Try not to rely on it for production deployments.

- *Destination database and schema are not created by the service*. They must exist and be write accessible with the provided credentials.

- All non user/admin fixable errors give a 50X server error response with little to no further info. This is by design. For better error tracing you can enable JVM TI remote debugging on port 8000: `-p 8000:8000 -e SHP2PGSQL_REMOTE_DEBUG=true`

## Changelog

###v0.0.3

 - OAuth2 authentication
 - Param `data` is now named `shpzipfile`
 - `database` moved from request parameter to service configuration parameter
 - `srid`, `geocolumn`, `indexgeocolumn` request parameters are now optional
 - New parameter `metadata`: JSON object providing information on the request
 - Issue an error if the provided schema does not exist
 - Allow/disallow CORS through `SHP2PGSQL_ENABLE_CORS` env var
 - Enable/disable CSRF protection through `SHP2PGSQL_DISABLE_CSRF_PROTECTION` env var
 - Enable/disable JVM TI remote debugging through `SHP2PGSQL_REMOTE_DEBUG` env var

###v0.0.2

 - Allow providing the keystore on container deployment by using the environment variable `SHP2PGSQL_KEYSTORE_PATH`
 - Basic input parameter validation (*This feature is being tested. Try not to rely on it for production deployments.*)
 - Use Spring MVC Handler Interceptors to cleanup generated temporary files after serving requests

## See also

 - https://github.com/imatia/docker-postgis
