#!/bin/ash -x

if [[ "$(id -u)" = '0' ]]; then
    case "$1" in
    broker|coordinator|historical|middleManager|overlord)
        NODE_TYPE="$1"
        JVM_CONF="conf/$NODE_TYPE/jvm.config"
        JAVA_OPTS="-server $JAVA_OPTS -Duser.timezone=$USER_TIMEZONE -Dfile.encoding=$FILE_ENCODING \
            -Djava.library.path=hadoop-dependencies/native \
            -Ddruid.extensions.hadoopDependenciesDir=hadoop-dependencies \
            -Djava.io.tmpdir=var/tmp -Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager"
        if [[ -f "$JVM_CONF" ]]; then
            JAVA_OPTS=$(cat "$JVM_CONF" | xargs)
        fi
        set -- -cp "conf/_common:conf/$NODE_TYPE:lib/*" io.druid.cli.Main server "$@"
        mkdir -p var/tmp
        chown -R druid:druid var
        set -- su-exec druid java $JAVA_OPTS "$@"
        ;;
    tools)
        JAVA_OPTS="$JAVA_OPTS -Ddruid.extensions.directory=extensions \
            -Djava.library.path=hadoop-dependencies/native \
            -Ddruid.extensions.hadoopDependenciesDir=hadoop-dependencies"
        set -- java $JAVA_OPTS -cp "lib/*" io.druid.cli.Main "$@"
        ;;
    esac
fi

exec "$@"