FROM imatia/docker-postgis
ADD app/sg-rest-shp2pgsql-postgis-docker-0.0.1.jar app.jar
RUN sh -c 'touch /app.jar'
RUN sh -c 'java -Djava.security.egd=file:/dev/./urandom -jar /app.jar'
