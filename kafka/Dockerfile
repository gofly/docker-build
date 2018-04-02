FROM openjdk:8-jre-alpine
ARG KAFKA_SCALA_VERSION="2.12"
ARG KAFKA_JAVA_VERSION="1.0.1"
ARG KAFKA_DOWNLOAD_HOST="http://apache.mesi.com.ar"
ENV KAFKA_HOME=/kafka
ENV PATH="$KAFKA_HOME/bin:$PATH"
RUN apk upgrade --no-cache && \
    apk add --no-cache 'su-exec>=0.2' && \
    addgroup -S kafka && adduser -S -G kafka kafka
WORKDIR $KAFKA_HOME
RUN apk add --no-cache --virtual .install-deps curl && \
    curl -L $KAFKA_DOWNLOAD_HOST/kafka/${KAFKA_JAVA_VERSION}/kafka_${KAFKA_SCALA_VERSION}-${KAFKA_JAVA_VERSION}.tgz | tar zx -C /tmp && \
    for dir in libs config; do \
        mv /tmp/kafka_${KAFKA_SCALA_VERSION}-${KAFKA_JAVA_VERSION}/$dir $KAFKA_HOME; \
    done && \
    rm -rf /tmp/* && \
    apk del --purge .install-deps
COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh && \
    mkdir -p bin var/logs && \
    for cmd in $(/docker-entrypoint.sh commands); do \
        ln -s /docker-entrypoint.sh bin/$cmd; \
    done
ENV JAVA_OPTS="" \
    JVM_OPTS=""
VOLUME ["/kafka/var"]
ENTRYPOINT ["/docker-entrypoint.sh"]
