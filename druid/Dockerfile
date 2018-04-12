FROM openjdk:8-jre-alpine
ARG DRUID_VERSION="0.12.0"
ARG HADOOP_CLIENT_VERSION="2.7.5"
ENV DRUID_HOME=/druid
ENV PATH="$DRUID_HOME/bin:$PATH"
RUN apk upgrade --no-cache && \
    apk add --no-cache 'su-exec>=0.2' && \
    addgroup -S druid && adduser -S -G druid druid
WORKDIR /druid
RUN apk add --no-cache --virtual .install-deps curl && \
    mkdir /tmp/druid && \
    # download druid
    curl -L http://static.druid.io/artifacts/releases/druid-${DRUID_VERSION}-bin.tar.gz | tar zx --strip-components=1 -C /tmp/druid && \
    for dir in conf lib extensions; do \
        mkdir -p /druid/$dir; \
        mv /tmp/druid/$dir /druid; \
    done && \
    rm -rf /tmp/druid && \
    # download mysql metadata storage
    mkdir -p /druid/extensions/mysql-metadata-storage && \
    curl -L http://static.druid.io/artifacts/releases/mysql-metadata-storage-${DRUID_VERSION}.tar.gz | tar zx --strip-components=1 -C /druid/extensions/mysql-metadata-storage && \
    # download hadoop native
    curl -L https://github.com/gofly/docker-build/releases/download/hadoop-${HADOOP_CLIENT_VERSION}/hadoop-native-${HADOOP_CLIENT_VERSION}_musl_x86_64.tar.gz | tar zx --strip-components=1 -C /lib && \
    # download hadoop client
    HADOOP_CLASSPATH="/druid/hadoop-dependencies/hadoop-client/${HADOOP_CLIENT_VERSION}"
    mkdir -p ${HADOOP_CLASSPATH} && \
    curl -L https://github.com/gofly/docker-build/releases/download/hadoop-${HADOOP_CLIENT_VERSION}/hadoop-client-${HADOOP_CLIENT_VERSION}.tar.gz | tar zx --strip-components=1 -C ${HADOOP_CLASSPATH} && \
    # make link from hadoop client to druid-hdfs-storage
    rm /druid/extensions/druid-hdfs-storage/hadoop-* && \
    for file in $(ls ${HADOOP_CLASSPATH}); do \
        ln -s ${HADOOP_CLASSPATH}/${file} /druid/extensions/druid-hdfs-storage/${file}; \
    done && \
    # download hadoop-aws-xxx.jar
    curl -L http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_CLIENT_VERSION}/hadoop-aws-${HADOOP_CLIENT_VERSION}.jar -o /druid/extensions/druid-hdfs-storage/hadoop-aws-${HADOOP_CLIENT_VERSION}.jar && \
    #
    rm /druid/extensions/druid-kerberos/hadoop-*.jar && \
    for file in hadoop-common-${HADOOP_CLIENT_VERSION}.jar hadoop-auth-${HADOOP_CLIENT_VERSION}.jar; do \
        ln -s ${HADOOP_CLASSPATH}/${file} /druid/extensions/druid-kerberos/${file}; \
    done && \
    # download libprocname.so
    curl -L https://github.com/gofly/docker-build/releases/download/libprocname.so/libprocname-1.0.0_musl-x86_64.tar.gz | tar zx --strip-components=1 -C /lib && \
    apk del --purge .install-deps
COPY bin /druid/bin
COPY docker-entrypoint.sh /
RUN chmod 755 /druid/bin/* /docker-entrypoint.sh && \
    mkdir -p conf var/tmp && \
    chown -R druid:druid var
EXPOSE 8090 8083 8082 8081 8091 8100-8200
ENTRYPOINT ["/docker-entrypoint.sh"]

