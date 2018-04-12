FROM openjdk:8-jre-alpine
ENV PATH="/druid/bin:$PATH"
RUN apk upgrade --no-cache && \
    apk add --no-cache 'su-exec>=0.2' && \
    addgroup -S druid && adduser -S -G druid druid
RUN apk add --no-cache --virtual .install-deps curl && \
    mkdir /tmp/druid /druid && \
    # download druid
    curl -L http://static.druid.io/artifacts/releases/druid-0.12.0-bin.tar.gz | tar zx --strip-components=1 -C /tmp/druid && \
    mv /tmp/druid/conf/druid /druid/conf && \
    mv /tmp/druid/lib /druid/lib && \
    mv /tmp/druid/extensions /druid/extensions && \
    rm -rf /tmp/druid && \
    # download hadoop native
    mkdir -p /druid/lib/native && \
    curl -L https://github.com/gofly/docker-build/releases/download/hadoop-2.7.5/hadoop-native-2.7.5_musl_x86_64.tar.gz | tar zx --strip-components=1 -C /druid/lib/native && \
    # download mysql-metadata-storage
    mkdir -p /druid/extensions/mysql-metadata-storage && \
    curl -L http://static.druid.io/artifacts/releases/mysql-metadata-storage-0.12.0.tar.gz | tar zx --strip-components=1 -C /druid/extensions/mysql-metadata-storage && \
    apk del --purge .install-deps
COPY bin /druid/bin/
COPY docker-entrypoint.sh /
RUN chmod 755 /druid/bin/* /docker-entrypoint.sh && \
    mkdir -p conf /data && \
    chown -R druid:druid /data
WORKDIR /druid
ENTRYPOINT ["/docker-entrypoint.sh"]

