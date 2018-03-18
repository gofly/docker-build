FROM openjdk:8-jre-alpine
ARG HADOOP_VERSION=2.6.0
ARG CDH_VERSION=5.14.0
ENV HADOOP_HOME=/hadoop
ENV PATH $HADOOP_HOME/bin:$PATH
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
    mkdir -p var/tmp && \
    for bin in $(ls bin); do \
        rm -f bin/$bin && ln -s /docker-entrypoint.sh bin/$bin; \
    done; \
    chown -R hadoop:hadoop var && \
    rm -rf /tmp/* bin/*.cmd libexec/*.cmd etc/hadoop/*.cmd share/hadoop/mapreduce1 share/hadoop/mapreduce && \
    mv share/hadoop/mapreduce2 share/hadoop/mapreduce && \
    curl -L https://github.com/gofly/docker-build/releases/download/hadoop-${HADOOP_VERSION}-cdh${CDH_VERSION}/hadoop-native.tar.gz | tar zx -C lib && \
    find ./share -name sources | xargs rm -rf && \
    apk del --purge .install-deps
ENV JVM_OPTS="" \
    JAVA_OPTS="" \
    HADOOP_OPTS="" \
    HADOOP_IDENT_STRING="" \
    HDFS_OPTS="" \
    HADOOP_SECURE_DN="" \
    HADOOP_PRIVILEGED_NFS="" \
    MAPRED_OPTS="" \
    RCC_OPTS="" \
    YARN_OPTS="" \
    YARN_IDENT_STRING="" \
    YARN_USER_CLASSPATH_FIRST="" \
    YARN_USER_CLASSPATH=""
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
VOLUME ["/hadoop/var"]
EXPOSE 8019 8020 8030 8031 8032 8033 8040 8041 8042 8088 8480 8485 10020 19888 50010 50020 50070 50075 50470 50475
ENTRYPOINT ["/docker-entrypoint.sh"]
