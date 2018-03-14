#!/bin/ash -x

if [[ "$(id -u)" = '0' ]]; then
    cmd=""
    case "$1" in
    hdfs)
        cmd="$1"
        mkdir -p var/hdfs/namenode var/hdfs/datanode
        ;;
    hadoop|mapred|rcc|yarn)
        cmd="$1"
        ;;
    esac
    if [[ ! -z "$cmd" ]]; then
        shift
        set -- su-exec hadoop bin/$cmd --config etc/hadoop "$@"
        chown -R hadoop:hadoop var
    fi
fi

exec "$@"
