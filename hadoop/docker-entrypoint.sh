#!/bin/ash -x

if [[ "$(id -u)" = '0' ]]; then
    ENTRY="${0##*/}"
    COMMAND=""
    case "$ENTRY" in
        hadoop|hdfs|mapred|rcc|yarn)
            COMMAND="$1"
            shift
            ;;
        *)
            ENTRY="$1"
            COMMAND="$2"
            shift 2
            ;;
    esac

    EXE="java"
    JVM_MODE="-server"
    CLASSPATH="${HADOOP_HOME}/etc/hadoop:${HADOOP_HOME}/share/hadoop/common/lib/*:${HADOOP_HOME}/share/hadoop/common/*:${HADOOP_HOME}/share/hadoop/hdfs:${HADOOP_HOME}/share/hadoop/hdfs/lib/*:${HADOOP_HOME}/share/hadoop/hdfs/*:${HADOOP_HOME}/share/hadoop/yarn/lib/*:${HADOOP_HOME}/share/hadoop/yarn/*:${HADOOP_HOME}/share/hadoop/mapreduce/lib/*:${HADOOP_HOME}/share/hadoop/mapreduce/*:${HADOOP_HOME}/contrib/capacity-scheduler/*.jar"
    JAVA_OPTS="-Djava.net.preferIPv4Stack=true \
        -Djava.library.path=${HADOOP_HOME}/lib/native \
        ${JAVA_OPTS}"
    COMMON_OPTS="-Dproc_${COMMAND} \
        -Dhadoop.home.dir=${HADOOP_HOME} \
        -Dhadoop.policy.file=hadoop-policy.xml \
        -Dhadoop.log.dir=${HADOOP_HOME}/var/logs \
        -Dhadoop.log.file=hadoop.log \
        -Dhadoop.root.logger=INFO,console \
        -Dhadoop.security.logger=INFO,NullAppender"

    case "$ENTRY" in
    'hadoop')
        JVM_OPTS="${JVM_OPTS:--Xmx512m}"
        JAVA_OPTS="${JAVA_OPTS} ${COMMON_OPTS} \
            -Dhadoop.log.file=hadoop.log \
            -Dhadoop.id.str=${HADOOP_IDENT_STRING} \
            ${HADOOP_OPTS}"
        case "$COMMAND" in
        'fs')
            CLASS='org.apache.hadoop.fs.FsShell'
            ;;
        'version')
            CLASS='org.apache.hadoop.util.VersionInfo'
            ;;
        'jar')
            CLASS='org.apache.hadoop.util.RunJar'
            ;;
        'checknative')
            CLASS='org.apache.hadoop.util.NativeLibraryChecker'
            ;;
        'distcp')
            CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/share/hadoop/tools/lib/*"
            CLASS='org.apache.hadoop.tools.DistCp'
            ;;
        'archive')
            CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/share/hadoop/tools/lib/*"
            CLASS='org.apache.hadoop.tools.HadoopArchives'
            ;;
        'classpath')
            echo $CLASSPATH
            exit 0
            ;;
        'credential')
            CLASS='org.apache.hadoop.security.alias.CredentialShell'
            ;;
        'daemonlog')
            CLASS='org.apache.hadoop.log.LogLevel'
            ;;
        's3guard')
            CLASS='org.apache.hadoop.fs.s3a.s3guard.S3GuardTool'
            ;;
        'trace')
            CLASS='org.apache.hadoop.tracing.TraceAdmin'
            ;;
        -h|--help)
            echo "Usage: hadoop [--config confdir] COMMAND"
            echo "       where COMMAND is one of:"
            echo "  fs                   run a generic filesystem user client"
            echo "  version              print the version"
            echo "  jar <jar>            run a jar file"
            echo "  checknative [-a|-h]  check native hadoop and compression libraries availability"
            echo "  distcp <srcurl> <desturl> copy file or directories recursively"
            echo "  archive -archiveName NAME -p <parent path> <src>* <dest> create a hadoop archive"
            echo "  classpath            prints the class path needed to get the"
            echo "  credential           interact with credential providers"
            echo "                       Hadoop jar and the required libraries"
            echo "  daemonlog            get/set the log level for each daemon"
            echo "  s3guard              manage data on S3"
            echo "  trace                view and modify Hadoop tracing settings"
            echo " or"
            echo "  CLASSNAME            run the class named CLASSNAME"
            echo ""
            echo "Most commands print help when invoked w/o parameters."
            exit
            ;;
        *)
            CLASS="$COMMAND"
            ;;
        esac
        ;;
    'hdfs')
        JVM_OPTS="${JVM_OPTS:--Xmx1000m}"
        JAVA_OPTS="${JAVA_OPTS} ${COMMON_OPTS} \
            -Dhadoop.log.file=hdfs.log \
            -Dhadoop.id.str=${HADOOP_IDENT_STRING} \
            -Dhdfs.audit.logger=INFO,NullAppender \
            ${HDFS_OPTS}"
        case "$COMMAND" in
        'namenode')
            CLASS='org.apache.hadoop.hdfs.server.namenode.NameNode'
            if [[ ! -f "${HADOOP_HOME}/var/tmp/dfs/name/current/VERSION" && "$1" != "-format" ]]; then
                mkdir -p ${HADOOP_HOME}/var/tmp/dfs/name
                chown -R hadoop:hadoop ${HADOOP_HOME}/var/tmp/dfs/name
                hdfs namenode -format -clusterid "$HDFS_CLUSTER_ID" -nonInteractive
            fi
            ;;
        'secondarynamenode')
            CLASS='org.apache.hadoop.hdfs.server.namenode.SecondaryNameNode'
            ;;
        'journalnode')
            CLASS='org.apache.hadoop.hdfs.qjournal.server.JournalNode'
            ;;
        'zkfc')
            CLASS='org.apache.hadoop.hdfs.tools.DFSZKFailoverController'
            ;;
        'datanode')
            if [[ -n "$HADOOP_SECURE_DN" ]]; then
                JVM_MODE='-jvm server'
                JAVA_OPTS="-outfile ${HADOOP_HOME}/var/logs/jsvc.out -errfile ${HADOOP_HOME}/var/logs/jsvc.err -nodetach -jvm server ${JAVA_OPTS}"
                EXEC="${HADOOP_HOME}/jsvc/jsvc"
                CLASS='org.apache.hadoop.hdfs.server.datanode.SecureDataNodeStarter'
            else
                CLASS='org.apache.hadoop.hdfs.server.datanode.DataNode'
            fi
            ;;
        'zkfc')
            CLASS='org.apache.hadoop.hdfs.tools.DFSZKFailoverController'
            ;;
        'dfsadmin')
            CLASS='org.apache.hadoop.hdfs.tools.DFSAdmin'
            ;;
        'diskbalancer')
            CLASS='org.apache.hadoop.hdfs.tools.DiskBalancerCLI'
            ;;
        'haadmin')
            CLASS='org.apache.hadoop.hdfs.tools.DFSHAAdmin'
            ;;
        'fsck')
            CLASS='org.apache.hadoop.hdfs.tools.DFSck'
            ;;
        'balancer')
            CLASS='org.apache.hadoop.hdfs.server.balancer.Balancer'
            ;;
        'jmxget')
            CLASS='org.apache.hadoop.hdfs.tools.JMXGet'
            ;;
        'mover')
            CLASS='org.apache.hadoop.hdfs.server.mover.Mover'
            ;;
        'oiv')
            CLASS='org.apache.hadoop.hdfs.tools.offlineImageViewer.OfflineImageViewerPB'
            ;;
        'oiv_legacy')
            CLASS='org.apache.hadoop.hdfs.tools.offlineImageViewer.OfflineImageViewer'
            ;;
        'oev')
            CLASS='org.apache.hadoop.hdfs.tools.offlineEditsViewer.OfflineEditsViewer'
            ;;
        'fetchdt')
            CLASS='org.apache.hadoop.hdfs.tools.DelegationTokenFetcher'
            ;;
        'getconf')
            CLASS='org.apache.hadoop.hdfs.tools.GetConf'
            ;;
        'groups')
            CLASS='org.apache.hadoop.hdfs.tools.GetGroups'
            ;;
        'snapshotDiff')
            CLASS='org.apache.hadoop.hdfs.tools.snapshot.SnapshotDiff'
            ;;
        'lsSnapshottableDir')
            CLASS='org.apache.hadoop.hdfs.tools.snapshot.LsSnapshottableDir'
            ;;
        'portmap')
            CLASS='org.apache.hadoop.portmap.Portmap'
            ;;
        'nfs3')
            if [[ -n "$HADOOP_PRIVILEGED_NFS" ]]; then
                JVM_MODE=""
                JAVA_OPTS="-outfile ${HADOOP_HOME}/var/logs/jsvc.out -errfile ${HADOOP_HOME}/var/logs/jsvc.err -nodetach ${JAVA_OPTS}"
                EXEC="${HADOOP_HOME}/jsvc/jsvc"
                CLASS='org.apache.hadoop.hdfs.nfs.nfs3.PrivilegedNfsGatewayStarter'
            else
                CLASS='org.apache.hadoop.hdfs.nfs.nfs3.Nfs3'
            fi
            ;;
        'cacheadmin')
            CLASS='org.apache.hadoop.hdfs.tools.CacheAdmin'
            ;;
        'crypto')
            CLASS='org.apache.hadoop.hdfs.tools.CryptoAdmin'
            ;;
        'storagepolicies')
            CLASS='org.apache.hadoop.hdfs.tools.StoragePolicyAdmin'
            ;;
        'version')
            CLASS='org.apache.hadoop.util.VersionInfo'
            ;;
        *)
            echo "Usage: hdfs [--config confdir] COMMAND"
            echo "       where COMMAND is one of:"
            echo "  dfs                  run a filesystem command on the file systems supported in Hadoop."
            echo "  namenode -format     format the DFS filesystem"
            echo "  secondarynamenode    run the DFS secondary namenode"
            echo "  namenode             run the DFS namenode"
            echo "  journalnode          run the DFS journalnode"
            echo "  zkfc                 run the ZK Failover Controller daemon"
            echo "  datanode             run a DFS datanode"
            echo "  dfsadmin             run a DFS admin client"
            echo "  diskbalancer         Distributes data evenly among disks on a given node"
            echo "  haadmin              run a DFS HA admin client"
            echo "  fsck                 run a DFS filesystem checking utility"
            echo "  balancer             run a cluster balancing utility"
            echo "  jmxget               get JMX exported values from NameNode or DataNode."
            echo "  mover                run a utility to move block replicas across"
            echo "                       storage types"
            echo "  oiv                  apply the offline fsimage viewer to an fsimage"
            echo "  oiv_legacy           apply the offline fsimage viewer to an legacy fsimage"
            echo "  oev                  apply the offline edits viewer to an edits file"
            echo "  fetchdt              fetch a delegation token from the NameNode"
            echo "  getconf              get config values from configuration"
            echo "  groups               get the groups which users belong to"
            echo "  snapshotDiff         diff two snapshots of a directory or diff the"
            echo "                       current directory contents with a snapshot"
            echo "  lsSnapshottableDir   list all snapshottable dirs owned by the current user"
            echo "                        Use -help to see options"
            echo "  portmap              run a portmap service"
            echo "  nfs3                 run an NFS version 3 gateway"
            echo "  cacheadmin           configure the HDFS cache"
            echo "  crypto               configure HDFS encryption zones"
            echo "  storagepolicies      list/get/set block storage policies"
            echo "  version              print the version"
            echo ""
            echo "Most commands print help when invoked w/o parameters."
            exit
            ;;
        esac
        ;;
    'mapred')
        JVM_OPTS="${JVM_OPTS:--Xmx1000m}"
        JAVA_OPTS="${JAVA_OPTS} ${COMMON_OPTS} ${MAPRED_OPTS} \
            -Dhadoop.id.str=${HADOOP_IDENT_STRING}"
        CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/modules/*.jar"
        case "$COMMAND" in
        'pipes')
            CLASS='org.apache.hadoop.mapred.pipes.Submitter'
            ;;
        'job')
            CLASS='org.apache.hadoop.mapred.JobClient'
            ;;
        'queue')
            CLASS='org.apache.hadoop.mapred.JobQueueClient'
            ;;
        'classpath')
            echo $CLASSPATH
            exit
            ;;
        'historyserver')
            CLASS='org.apache.hadoop.mapreduce.v2.hs.JobHistoryServer'
            ;;
        'distcp')
            CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/share/hadoop/tools/lib/*"
            CLASS='org.apache.hadoop.tools.DistCp'
            ;;
        'archive')
            CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/share/hadoop/tools/lib/*"
            CLASS='org.apache.hadoop.tools.HadoopArchives'
            ;;
        'archive-logs')
            CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/share/hadoop/tools/lib/*"
            CLASS='org.apache.hadoop.tools.HadoopArchiveLogs'
            ;;
        'hsadmin')
            CLASS='org.apache.hadoop.mapreduce.v2.hs.client.HSAdmin'
            ;;
        *)
            echo "Usage: mapred [--config confdir] COMMAND"
            echo "       where COMMAND is one of:"
            echo "  pipes                run a Pipes job"
            echo "  job                  manipulate MapReduce jobs"
            echo "  queue                get information regarding JobQueues"
            echo "  classpath            prints the class path needed for running"
            echo "                       mapreduce subcommands"
            echo "  historyserver        run job history servers as a standalone daemon"
            echo "  distcp <srcurl> <desturl> copy file or directories recursively"
            echo "  archive -archiveName NAME -p <parent path> <src>* <dest> create a hadoop archive"
            echo "  archive-logs         combine aggregated logs into hadoop archives"
            echo "  hsadmin              job history server admin interface"
            echo ""
            echo "Most commands print help when invoked w/o parameters."
            exit
            ;;
        esac
        ;;
    'rcc')
        JVM_OPTS="${RCC_JVM_OPTS}"
        JAVA_OPTS="${JAVA_OPTS} ${COMMON_OPTS} ${RCC_OPTS} \
            -Dhadoop.id.str=${HADOOP_IDENT_STRING}"
        CLASS='org.apache.hadoop.record.compiler.generated.Rcc'
        ;;
    'yarn')
        CLASSPATH="${CLASSPATH}:${HADOOP_HOME}/etc/hadoop/rm-config/log4j.properties"
        JVM_OPTS="${JVM_OPTS:--Xmx1000m}"
        JAVA_OPTS="${JAVA_OPTS} ${COMMON_OPTS} \
            -Dyarn.home.dir=${HADOOP_HOME} \
            -Dyarn.log.dir=${HADOOP_HOME}/var/logs \
            -Dyarn.log.file=yarn.log \
            -Dyarn.root.logger=INFO,console \
            -Dyarn.policy.file=hadoop-policy.xml \
            -Dyarn.id.str=${YARN_IDENT_STRING} \
            ${YARN_OPTS}"
        if [[ -n "$YARN_USER_CLASSPATH_FIRST"]]; then
            CLASSPATH="${YARN_USER_CLASSPATH}:${CLASSPATH}"
        else
            CLASSPATH="${CLASSPATH}:${YARN_USER_CLASSPATH}"
        fi
        case "$COMMAND" in
        'resourcemanager')
            JVM_OPTS="${YARN_RM_JVM_OPTS:-$JVM_OPTS}"
            CLASS='org.apache.hadoop.yarn.server.resourcemanager.ResourceManager'
            ;;
        'nodemanager')
            JVM_OPTS="${YARN_NM_JVM_OPTS:-$JVM_OPTS}"
            CLASS='org.apache.hadoop.yarn.server.nodemanager.NodeManager'
            ;;
        'timelineserver')
            JVM_OPTS="${YARN_TS_JVM_OPTS:-$JVM_OPTS}"
            CLASS='org.apache.hadoop.yarn.server.applicationhistoryservice.ApplicationHistoryServer'
            ;;
        'rmadmin')
            JVM_OPTS="${YARN_RMADMIN_JVM_OPTS:-$JVM_OPTS}"
            CLASS='org.apache.hadoop.yarn.client.cli.RMAdminCLI'
            JAVA_OPTS="${JAVA_OPTS}:${YARN_CLIENT_OPTS}"
            ;;
        'version')
            CLASS='org.apache.hadoop.util.VersionInfo'
            JAVA_OPTS="${JAVA_OPTS}:${YARN_CLIENT_OPTS}"
            ;;
        'jar')
            JVM_OPTS="${YARN_JAR_JVM_OPTS:-$JVM_OPTS}"
            CLASS='org.apache.hadoop.util.RunJar'
            JAVA_OPTS="${JAVA_OPTS}:${YARN_CLIENT_OPTS}"
            ;;
        application|applicationattempt|container)
            JVM_OPTS="${YARN_CONTAINER_JVM_OPTS:-$JVM_OPTS}"
            CLASS='org.apache.hadoop.yarn.client.cli.ApplicationCLI'
            JAVA_OPTS="${JAVA_OPTS}:${YARN_CLIENT_OPTS}"
            set -- $COMMAND "$@"
            ;;
        'node')
            JVM_OPTS="${YARN_NODE_JVM_OPTS:-$JVM_OPTS}"
            CLASS='org.apache.hadoop.yarn.client.cli.NodeCLI'
            JAVA_OPTS="${JAVA_OPTS}:${YARN_CLIENT_OPTS}"
            ;;
        'queue')
            JVM_OPTS="${YARN_QUEUE_JVM_OPTS:-$JVM_OPTS}"
            CLASS='org.apache.hadoop.yarn.client.cli.QueueCLI'
            JAVA_OPTS="${JAVA_OPTS}:${YARN_CLIENT_OPTS}"
            ;;
        'logs')
            JVM_OPTS="${YARN_LOGS_JVM_OPTS:-$JVM_OPTS}"
            CLASS='org.apache.hadoop.yarn.client.cli.LogsCLI'
            JAVA_OPTS="${JAVA_OPTS}:${YARN_CLIENT_OPTS}"
            ;;
        'classpath')
            echo $CLASSPATH
            exit
            ;;
        'daemonlog')
            CLASS='org.apache.hadoop.log.LogLevel'
            JAVA_OPTS="${JAVA_OPTS}:${YARN_CLIENT_OPTS}"
            ;;
        'top')
            CLASS='org.apache.hadoop.yarn.client.cli.TopCLI'
            JAVA_OPTS="${JAVA_OPTS}:${YARN_CLIENT_OPTS}"
            ;;
        -h|--help)
            echo "Usage: yarn [--config confdir] COMMAND"
            echo "where COMMAND is one of:"
            echo "  resourcemanager -format-state-store   deletes the RMStateStore"
            echo "  resourcemanager                       run the ResourceManager"
            echo "                                        Use -format-state-store for deleting the RMStateStore."
            echo "                                        Use -remove-application-from-state-store <appId> for "
            echo "                                            removing application from RMStateStore."
            echo "  nodemanager                           run a nodemanager on each slave"
            echo "  timelineserver                        run the timeline server"
            echo "  rmadmin                               admin tools"
            echo "  version                               print the version"
            echo "  jar <jar>                             run a jar file"
            echo "  application                           prints application(s)"
            echo "                                        report/kill application"
            echo "  applicationattempt                    prints applicationattempt(s)"
            echo "                                        report"
            echo "  container                             prints container(s) report"
            echo "  node                                  prints node report(s)"
            echo "  queue                                 prints queue information"
            echo "  logs                                  dump container logs"
            echo "  classpath                             prints the class path needed to"
            echo "                                        get the Hadoop jar and the"
            echo "                                        required libraries"
            echo "  daemonlog                             get/set the log level for each"
            echo "                                        daemon"
            echo "  top                                   run cluster usage tool"
            echo " or"
            echo "  CLASSNAME                             run the class named CLASSNAME"
            echo ""
            echo "Most commands print help when invoked w/o parameters."
            exit
            ;;
        *)
            CLASS="$COMMAND"
            ;;
        esac
        ;;
    esac
    if [[ -n "$CLASS" ]]; then
        set -- su-exec hadoop $EXE $JVM_MODE $JVM_OPTS $JAVA_OPTS -cp "$CLASSPATH" $CLASS "$@"
    fi
    chown -R hadoop:hadoop var
fi

exec "$@"
