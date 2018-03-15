FROM openjdk:8-jre-alpine
ARG HADOOP_VERSION=2.6.0
ARG CDH_VERSION=5.14.0
ENV HADOOP_HOME=/hadoop
ENV PATH=$HADOOP_HOME/bin:$PATH
RUN apk upgrade --no-cache && \
    apk add --no-cache bash 'su-exec>=0.2' && \
    addgroup -S hadoop && adduser -S -G hadoop hadoop
WORKDIR $HADOOP_HOME
RUN apk add --no-cache --virtual .install-deps curl && \
    curl -L https://archive.cloudera.com/cdh${CDH_VERSION:0:1}/cdh/${CDH_VERSION:0:1}/hadoop-${HADOOP_VERSION}-cdh${CDH_VERSION}.tar.gz | tar zx -C /tmp && \
    for dir in etc/hadoop bin lib libexec share/hadoop; do \
        dest="./"; \
        if [[ "${dir%/*}" != "$dir" ]]; then \
            dest="./${dir%/*}/"; \
            mkdir -p $dest; \
        fi; \
        mv /tmp/hadoop-${HADOOP_VERSION}-cdh${CDH_VERSION}/$dir $dest; \
    done; \
    chmod +x bin/* && \
    mkdir -p var/tmp && \
    chown -R hadoop:hadoop var && \
    rm -rf /tmp/* bin/*.cmd libexec/*.cmd etc/hadoop/*.cmd share/hadoop/mapreduce1 share/hadoop/mapreduce && \
    mv share/hadoop/mapreduce2 share/hadoop/mapreduce && \
    curl -L https://github.com/gofly/docker-build/releases/download/hadoop-${HADOOP_VERSION}-cdh${CDH_VERSION}/hadoop-native.tar.gz | tar zx -C lib && \
    find ./share -name sources | xargs rm -rf && \
    apk del --purge .install-deps
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
VOLUME ["/hadoop/etc", "/hadoop/var", "/hadoop/var/tmp"]
ENTRYPOINT ["/docker-entrypoint.sh"]
