FROM imatia/docker-postgis
ENV SHP_TEMP_STORAGE_PATH /tmp
ENV REMOTE_PGHOST localhost
ENV REMOTE_PGPORT 5432
ENV REMOTE_PGDB gistest
ENV POSTGRES_USER docker
ENV POSTGRES_PASSWORD docker
ENV REMOTE_PGUSER $POSTGRES_USER
ENV REMOTE_PGPASSWORD $POSTGRES_PASSWORD
ENV PGPASSWORD $POSTGRES_PASSWORD
ENV SHP2PGSQL_KEYSTORE_PATH /keystore.jks
ENV SHP2PGSQL_KEYSTORE_PASSWORD password
ENV SHP2PGSQL_KEY_PASSWORD password
ENV SG_OAUTH2_DISABLE_SECURIZATION false
ENV SG_OAUTH2_APP_SECRET oauth2sgappsecret
ENV SG_OAUTH2_CLIENT_ID sgclientapp
ENV SG_OAUTH2_ACCESS_TOKEN_URI https://localhost:8080/oauth/token
ENV SG_OAUTH2_USER_AUTHORIZATION_URI https://localhost:8080/oauth/authorize
ENV SG_OAUTH2_TOKEN_NAME oauth2sgappsecret
ENV SG_OAUTH2_AUTHENTICATION_SCHEME query
ENV SG_OAUTH2_CLIENT_AUTHENTICATION_SCHEME form
ENV SG_OAUTH2_LOGIN_ENDPOINT https://localhost:8080/login
ENV SG_OAUTH2_USER_INFO_URI https://localhost:8080/me
ENV SHP2PGSQL_REMOTE_DEBUG false 
ENV SHP2PGSQL_ENABLE_CORS true
ENV SHP2PGSQL_DISABLE_CSRF_PROTECTION true
EXPOSE 9643
EXPOSE 8000
# OpenJDK 8
RUN echo "deb http://ftp.de.debian.org/debian jessie-backports main" | tee /etc/apt/sources.list.d/webupd8team-java.list && apt-get update && apt-get install -y openjdk-8-jdk
# Oracle JDK 8
#RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list && deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 && \apt-get update && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && apt-get install -y oracle-java8-installer && apt-get install -y oracle-java8-set-default && apt-get clean

# get the specified app build from imatia public artifactory
#RUN apt-get install -y curl
#RUN curl -o app.jar https://artifactory.imatia.com/public-artifactory/sg-releases-local/com/imatia/sg/sg-rest-shp2pgsql-postgis-docker/0.0.3/sg-rest-shp2pgsql-postgis-docker-0.0.3.jar

# get the specified app build from the project's maven target folder
ADD sg-rest-shp2pgsql-postgis-docker-0.0.3.jar app.jar
ADD keystore.jks keystore.jks

RUN sh -c 'touch /app.jar'
RUN echo "[ \"\$SHP2PGSQL_REMOTE_DEBUG\" = true ] && export SHP2PGSQL_REMOTE_DEBUG_STR=\"-agentlib:jdwp=transport=dt_socket,server=y,address=8000,suspend=n\" || export SHP2PGSQL_REMOTE_DEBUG_STR=\"\"" > init_app.sh
# app.jar start script with optional JVM remote debug on port 8000
RUN echo "sh -c 'java \$SHP2PGSQL_REMOTE_DEBUG_STR -Djava.security.egd=file:/dev/./urandom -jar /app.jar --keystore=\$SHP2PGSQL_KEYSTORE_PATH --tmppath=\$SHP_TEMP_STORAGE_PATH --pghost=\$REMOTE_PGHOST --pgport=\$REMOTE_PGPORT --pgdb=\$REMOTE_PGDB --pguser=\$REMOTE_PGUSER --oauth2clientid=\$SG_OAUTH2_CLIENT_ID --oauth2accesstokenuri=\$SG_OAUTH2_ACCESS_TOKEN_URI --oauth2userauthorizationuri=\$SG_OAUTH2_USER_AUTHORIZATION_URI --oauth2tokenname=\$SG_OAUTH2_TOKEN_NAME --oauth2authenticationscheme=\$SG_OAUTH2_AUTHENTICATION_SCHEME --oauth2clientauthenticationscheme=\$SG_OAUTH2_CLIENT_AUTHENTICATION_SCHEME --oauth2loginendpoint=\$SG_OAUTH2_LOGIN_ENDPOINT --oauth2userinfouri=\$SG_OAUTH2_USER_INFO_URI --oauth2disablesecurization=\$SG_OAUTH2_DISABLE_SECURIZATION --enablecors=\$SHP2PGSQL_ENABLE_CORS --disablecsrfprotection=\$SHP2PGSQL_DISABLE_CSRF_PROTECTION'" >> init_app.sh
RUN chmod 777 init_app.sh
RUN mv init_app.sh /docker-entrypoint-initdb.d
