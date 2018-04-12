#!/bin/ash

if [[ "$1" = 'server' ]]; then
    mkdir -p ${DRUID_HOME}/var/tmp
    chown -R druid:druid ${DRUID_HOME}/var
    set -- su-exec druid ${DRUID_HOME}/bin/druid "$@"
fi

exec "$@"