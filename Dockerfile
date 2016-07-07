FROM imatia/docker-postgis
ADD app/sg-rest-shp2pgsql-postgis-docker-0.0.1.jar app.jar
ENV SHP_TEMP_STORAGE_PATH=/tmp
ENV REMOTE_PGHOST=localhost
ENV REMOTE_PGPORT=5432
ENV POSTGRES_USER=docker
ENV POSTGRES_PASSWORD=docker
ENV REMOTE_PGUSER=$POSTGRES_USER
ENV REMOTE_PGPASSWORD=$POSTGRES_PASSWORD
EXPOSE 9643
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt-get install -y oracle-java8-set-default && \
    apt-get clean
RUN sh -c 'touch /app.jar'
RUN echo "sh -c 'java -Djava.security.egd=file:/dev/./urandom -jar /app.jar --tmppath=$SHP_TEMP_STORAGE_PATH --pghost=$REMOTE_PGHOST --pgport=$REMOTE_PGPORT --pguser=$REMOTE_PGUSER --pgpassword=$REMOTE_PGPASSWORD' > init_app.sh"
RUN chmod 777 init_app.sh
RUN mv init_app.sh /docker-entrypoint-initdb.d
