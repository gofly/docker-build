#!/bin/ash -x

if [[ "$(id -u)" = '0' ]]; then
    mkdir -p $KAFKA_HOME/var/logs
    chown -R kafka:kafka $KAFKA_HOME/var
    set -- su-exec kafka $KAFKA_HOME/bin/kafka "$@"
fi

exec "$@"
