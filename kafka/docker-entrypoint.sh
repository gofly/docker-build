#!/bin/ash -x

if [[ "$(id -u)" = '0' ]]; then
    COMMAND="$1"
    if [[ "${0##*/}" != "docker-entrypoint.sh" ]]; then
        COMMAND="${0##*/}"
    fi
    case "$COMMAND" in
    "connect-distributed")
        CLASS="org.apache.kafka.connect.cli.ConnectDistributed"
        ARGS="$KAFKA_HOME/config/connect-distributed.properties"
        ;;
    "connect-standalone")
        CLASS="org.apache.kafka.connect.cli.ConnectStandalone"
        ARGS="$KAFKA_HOME/config/connect-standalone.properties"
        ;;
    "kafka-acls")
        CLASS="kafka.admin.AclCommand"
        ;;
    "kafka-broker-api-versions")
        CLASS="kafka.admin.BrokerApiVersionsCommand"
        ;;
    "kafka-configs")
        CLASS="kafka.admin.ConfigCommand"
        ;;
    "kafka-console-consumer")
        CLASS="kafka.tools.ConsoleConsumer"
        ;;
    "kafka-console-producer")
        CLASS="kafka.tools.ConsoleProducer"
        ;;
    "kafka-consumer-groups")
        CLASS="kafka.admin.ConsumerGroupCommand"
        ;;
    "kafka-consumer-perf-test")
        CLASS="kafka.tools.ConsumerPerformance"
        ;;
    "kafka-delete-records")
        CLASS="kafka.admin.DeleteRecordsCommand"
        ;;
    "kafka-log-dirs")
        CLASS="kafka.admin.LogDirsCommand"
        ;;
    "kafka-mirror-maker")
        CLASS="kafka.tools.MirrorMaker"
        ;;
    "kafka-preferred-replica-election")
        CLASS="kafka.admin.PreferredReplicaLeaderElectionCommand"
        ;;
    "kafka-producer-perf-test")
        CLASS="org.apache.kafka.tools.ProducerPerformance"
        ;;
    "kafka-reassign-partitions")
        CLASS="kafka.admin.ReassignPartitionsCommand"
        ;;
    "kafka-replay-log-producer")
        CLASS="kafka.tools.ReplayLogProducer"
        ;;
    "kafka-replica-verification")
        CLASS="kafka.tools.ReplicaVerificationTool"
        ;;
    "kafka-server")
        CLASS="kafka.Kafka"
        ARGS="$KAFKA_HOME/config/server.properties"
        ;;
    "kafka-simple-consumer-shell")
        CLASS="kafka.tools.SimpleConsumerShell"
        ;;
    "kafka-streams-application-reset")
        CLASS="kafka.tools.StreamsResetter"
        ;;
    "kafka-topics")
        CLASS="kafka.admin.TopicCommand"
        ;;
    "kafka-verifiable-consumer")
        CLASS="org.apache.kafka.tools.VerifiableConsumer"
        ;;
    "kafka-verifiable-producer")
        CLASS="org.apache.kafka.tools.VerifiableProducer"
        ;;
    "trogdor")
        case "$2" in
        "agent")
            CLASS="org.apache.kafka.trogdor.agent.Agent"
            ;;
        "coordinator")
            CLASS="org.apache.kafka.trogdor.coordinator.Coordinator"
            ;;
        "client")
            CLASS="org.apache.kafka.trogdor.coordinator.CoordinatorClient"
            ;;
        "agent-client")
            CLASS="org.apache.kafka.trogdor.agent.AgentClient"
            ;;
        esac
        shift
        ;;
    "zookeeper-security-migration")
        CLASS="kafka.admin.ZkSecurityMigrator"
        ;;
    "zookeeper-server")
        CLASS="org.apache.zookeeper.server.quorum.QuorumPeerMain"
        ARGS="$KAFKA_HOME/config/zookeeper.properties"
        ;;
    "zookeeper-shell")
        CLASS="org.apache.zookeeper.ZooKeeperMain"
        ;;
    "commands")
        exec echo "connect-distributed" "connect-standalone" "kafka-acls" "kafka-broker-api-versions" \
            "kafka-configs" "kafka-console-consumer" "kafka-console-producer" "kafka-consumer-groups" \
            "kafka-consumer-perf-test" "kafka-delete-records" "kafka-log-dirs" "kafka-mirror-maker" \
            "kafka-preferred-replica-election" "kafka-producer-perf-test" "kafka-reassign-partitions" \
            "kafka-replay-log-producer" "kafka-replica-verification" "kafka-server" \
            "kafka-simple-consumer-shell" "kafka-streams-application-reset" "kafka-topics" \
            "kafka-verifiable-consumer" "kafka-verifiable-producer" "trogdor" \
            "zookeeper-security-migration" "zookeeper-server" "zookeeper-shell"
        exit
    esac
    if [[ ! -z "$CLASS" ]]; then
        shift
        mkdir -p $KAFKA_HOME/var/logs
        chown -R kafka:kafka $KAFKA_HOME/var
        JVM_OPTS="${JVM_OPTS:--Xmx1g} -XX:+UseG1GC -XX:MaxGCPauseMillis=20 \
            -XX:InitiatingHeapOccupancyPercent=35 -XX:+ExplicitGCInvokesConcurrent \
            -Djava.awt.headless=true -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps \
            -XX:+PrintGCTimeStamps"
        if [[ -f "${JVM_CONF:=$KAFKA_HOME/config/jvm.config}" ]]; then
            JVM_OPTS=$(cat "$JVM_CONF" | xargs)
        fi
        JAVA_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false \
            -Dcom.sun.management.jmxremote.ssl=false -Dkafka.logs.dir=$KAFKA_HOME/var/logs \
            -Dlog4j.configuration=file:$KAFKA_HOME/config/log4j.properties ${JAVA_OPTS}"
        set -- su-exec kafka java -server $JVM_OPTS $JAVA_OPTS -cp "$KAFKA_HOME/libs/*" $CLASS $ARGS "$@"
    fi
fi

exec "$@"
