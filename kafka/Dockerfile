FROM openjdk:8-jre-alpine
ENV KAFKA_HOME=/kafka
ENV PATH="/kafka/bin:$PATH"
RUN apk upgrade --no-cache && \
    apk add --no-cache 'su-exec>=0.2' && \
    addgroup -S kafka && adduser -S -G kafka kafka
WORKDIR /kafka
RUN apk add --no-cache --virtual .install-deps curl && \
    curl -L http://apache.mesi.com.ar/kafka/1.0.1/kafka_2.12-1.0.1.tgz | tar zx -C /tmp && \
    mv /tmp/kafka_2.12-1.0.1/libs /kafka/ && \
    mv /tmp/kafka_2.12-1.0.1/config /kafka/ && \
    rm -rf /tmp/kafka* && \
    apk del --purge .install-deps
COPY bin /kafka/bin/
COPY docker-entrypoint.sh /
RUN chmod 755 /kafka/bin/* /docker-entrypoint.sh && \
    mkdir -p /data
VOLUME ["/data"]
ENTRYPOINT ["/docker-entrypoint.sh"]
