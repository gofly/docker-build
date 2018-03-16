#!/bin/ash -x

if [[ "$(id -u)" = '0' ]]; then
    cmd=""
    case "$1" in
    hdfs)
        cmd="$1"
        if [[ ! -d "var/tmp/dfs/name/current"]]; then
            mkdir -p var/tmp/dfs/name
            chown -R hadoop:hadoop var/tmp/dfs/name
            su-exec hadoop bin/hdfs namenode -format
        fi
        ;;
    hadoop|mapred|rcc|yarn)
        cmd="$1"
        ;;
    esac
    if [[ ! -z "$cmd" ]]; then
        shift
        chown -R hadoop:hadoop var
        set -- su-exec hadoop bin/$cmd "$@"
    fi
fi

exec "$@"
