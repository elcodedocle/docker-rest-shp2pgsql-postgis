FROM imatia/docker-postgis
ADD app/sg-rest-shp2pgsql-postgis-docker-0.0.1.jar app.jar
ENV SHP_TEMP_STORAGE_PATH=/tmp
ENV REMOTE_PGHOST=localhost
ENV REMOTE_PGPORT=5432
ENV REMOTE_PGUSER=$POSTGRES_USER
ENV REMOTE_PGPASSWORD=$POSTGRES_PASSWORD
RUN sh -c 'touch /app.jar'
RUN sh -c 'java -Djava.security.egd=file:/dev/./urandom -jar /app.jar --tmppath=$SHP_TEMP_STORAGE_PATH --pghost=$REMOTE_PGHOST --pgport=$REMOTE_PORT --pguser=$REMOTE_PORT --pgpassword=$REMOTE_PASSWORD'
