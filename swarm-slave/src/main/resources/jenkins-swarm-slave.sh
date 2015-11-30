#!/bin/bash

# if `docker run` first argument start with `-` the user is passing jenkins swarm launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "-"* ]]; then
    # jenkins swarm slave
    SWARM_JAR=/usr/share/jenkins/swarm-client.jar

    # if -master is not provided and using --link jenkins:jenkins
    if [[ "$@" != *"-master "* ]] && [ ! -z "${JENKINS_PORT_8080_TCP_ADDR}" ]; then
        SWARM_PARAMS="-master http://${JENKINS_PORT_8080_TCP_ADDR}:${JENKINS_PORT_8080_TCP_PORT}"
    fi

    for f in $(find /jenkins-swarm-slave.init.d -type f | sort); do
        case "$f" in
            *.sh)   echo "$0: sourcing $f"; . "$f";;
            *)      echo "$0: ignoring $f" ;;
        esac
    done

    echo Running java ${JAVA_OPTS} -jar ${SWARM_JAR} -fsroot ${JENKINS_HOME} ${SWARM_PARAMS} "$@"
    exec gosu ${JENKINS_USER} tini -s -- java ${JAVA_OPTS} -jar ${SWARM_JAR} -fsroot ${JENKINS_HOME} ${SWARM_PARAMS} "$@"
else
    # As argument is not jenkins, assume user want to run his own process, for sample a `bash` shell to explore this image
    exec "$@"
fi

