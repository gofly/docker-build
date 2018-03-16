#!/bin/ash -x

if [[ "$(id -u)" = '0' ]]; then
    case "$1" in
    broker|coordinator|historical|middleManager|overlord|tools)
        NODE_TYPE="$1"

        JVM_OPTS="${JVM_OPTS:--Xms256m -Xmx256m -XX:MaxDirectMemorySize=1g}"
        if [[ -f "${JVM_CONF:=$DRUID_HOME/conf/$NODE_TYPE/jvm.config}" ]]; then
            JVM_OPTS=$(cat "$JVM_CONF" | xargs)
        fi

        JAVA_OPTS="${JAVA_OPTS:--Duser.timezone=UTC -Dfile.encoding=UTF-8}"
        if [[ "$NODE_TYPE" = 'tools' ]]; then
            JAVA_OPTS="$JAVA_OPTS \
                -Ddruid.extensions.directory=$DRUID_HOME/extensions \
                -Djava.library.path=$DRUID_HOME/hadoop-dependencies/native \
                -Ddruid.extensions.hadoopDependenciesDir=$DRUID_HOME/hadoop-dependencies"
            CLASSPATH="$DRUID_HOME/lib/*" \
            CLASS="io.druid.cli.Main"
            shift
        else
            JAVA_OPTS="$JAVA_OPTS \
                -Djava.library.path=$DRUID_HOME/hadoop-dependencies/native \
                -Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager \
                -Djava.io.tmpdir=$DRUID_HOME/var/tmp"
            CLASSPATH="$DRUID_HOME/conf/_common:$DRUID_HOME/conf/$NODE_TYPE:$DRUID_HOME/lib/*"
            CLASS="io.druid.cli.Main"
            ARGS="server"

            mkdir -p $DRUID_HOME/var/tmp
            chown -R druid:druid $DRUID_HOME/var
        fi

        set -- su-exec druid java -server $JVM_OPTS $JAVA_OPTS -cp "$CLASSPATH" $CLASS $ARGS "$@"
        ;;
    *)
        ;;
    esac
fi
exec "$@"