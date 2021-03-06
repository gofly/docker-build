FROM openjdk:8-jre-alpine
ARG DRUID_VERSION="0.12.0"
ENV DRUID_HOME=/druid
ENV PATH="$DRUID_HOME/bin:$PATH"
RUN apk upgrade --no-cache && \
    apk add --no-cache 'su-exec>=0.2' && \
    addgroup -S druid && adduser -S -G druid druid
WORKDIR $DRUID_HOME
RUN apk add --no-cache --virtual .install-deps curl && \
    curl -L http://static.druid.io/artifacts/releases/druid-${DRUID_VERSION}-bin.tar.gz | tar zx -C /tmp && \
    for dir in conf lib extensions hadoop-dependencies; do \
        mkdir -p $DRUID_HOME/${dir%/*}; \
        mv /tmp/druid-${DRUID_VERSION}/$dir $DRUID_HOME; \
    done && \
    curl -L http://static.druid.io/artifacts/releases/mysql-metadata-storage-${DRUID_VERSION}.tar.gz | tar zx -C $DRUID_HOME/extensions && \
    curl -L https://github.com/gofly/docker-build/releases/download/hadoop-2.6.0-cdh5.14.0/hadoop-native.tar.gz | tar zx -C hadoop-dependencies && \
    mkdir $DRUID_HOME/bin && \
    ln -s /docker-entrypoint.sh bin/druid && \
    rm -rf /tmp/* && \
    apk del --purge .install-deps
COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh && \
    mkdir -p conf var/tmp && \
    chown -R druid:druid var
VOLUME ["/druid/var"]
ENV JVM_OPTS="" \
    JAVA_OPTS=""
EXPOSE 8090 8083 8082 8081 8091 8100-8200
ENTRYPOINT ["/docker-entrypoint.sh"]