#!/bin/ash

if [[ "$1" = 'server' ]]; then
	shift
    mkdir -p /data/tmp
    chown -R druid:druid /data
    set -- su-exec druid druid-server "$@"
fi

exec "$@"