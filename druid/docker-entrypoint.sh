#!/bin/ash -x

if [[ "$(id -u)" = '0' ]]; then
    JAVA_OPTS="${JAVA_OPTS:--Duser.timezone=UTC -Dfile.encoding=UTF-8}"
    COMMAND="$1"
    case "$2" in
    -h|--help|help)
        CLASSPATH="$DRUID_HOME/lib/*"
        set -- help $COMMAND
        ;;
    *)
        case "$COMMAND" in
        index|internal|version|example)
            JVM_OPTS="${JVM_OPTS:--Xms256m -Xmx256m -XX:MaxDirectMemorySize=1g}"
            JAVA_OPTS="${JAVA_OPTS} \
                -Djava.library.path=$DRUID_HOME/hadoop-dependencies/native \
                -Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager \
                -Djava.io.tmpdir=$DRUID_HOME/var/tmp"
            CLASSPATH="$DRUID_HOME/conf/_common:$DRUID_HOME/lib/*"
            ;;
        'server')
            NODE_TYPE="$2"
            JVM_OPTS="${JVM_OPTS:--Xms256m -Xmx256m -XX:MaxDirectMemorySize=1g}"
            if [[ -f "${JVM_CONF:=$DRUID_HOME/conf/$NODE_TYPE/jvm.config}" ]]; then
                JVM_OPTS=$(cat "$JVM_CONF" | xargs)
            fi
            JAVA_OPTS="${JAVA_OPTS} \
                -Djava.library.path=$DRUID_HOME/hadoop-dependencies/native \
                -Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager \
                -Djava.io.tmpdir=$DRUID_HOME/var/tmp"
            CLASSPATH="$DRUID_HOME/conf/_common:$DRUID_HOME/conf/$NODE_TYPE:$DRUID_HOME/lib/*"
            mkdir -p $DRUID_HOME/var/tmp
            chown -R druid:druid $DRUID_HOME/var
            ;;
        'tools')
            JVM_OPTS="${JVM_TOOLS_OPTS:--Xms256m -Xmx256m -XX:MaxDirectMemorySize=1g}"
            JAVA_OPTS="${JAVA_OPTS} \
                -Ddruid.extensions.directory=$DRUID_HOME/extensions \
                -Djava.library.path=$DRUID_HOME/hadoop-dependencies/native \
                -Ddruid.extensions.hadoopDependenciesDir=$DRUID_HOME/hadoop-dependencies"
            CLASSPATH="$DRUID_HOME/lib/*"
            ;;
        -h|--help|help)
            CLASSPATH="$DRUID_HOME/lib/*"
            shift
            set -- help "$@"
            ;;
        *)
            if [[ "${0##*/}" = 'druid' ]]; then
                CLASSPATH="$DRUID_HOME/lib/*"
                shift
            fi
            ;;
        esac
        ;;
    esac
    if [[ ! -z "$CLASSPATH" ]]; then
        set -- su-exec druid java -server $JVM_OPTS $JAVA_OPTS -cp "$CLASSPATH" io.druid.cli.Main "$@"
    fi
fi

exec "$@"
