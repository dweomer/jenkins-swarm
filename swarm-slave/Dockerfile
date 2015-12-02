FROM java:8-jre

MAINTAINER Jacob Blain Christen <mailto:dweomer5@gmail.com, https://github.com/dweomer, https://twitter.com/dweomer>

ARG DOCKER_VERSION=1.9.1

ARG GOSU_GPG_KEYSERVER=ha.pool.sks-keyservers.net
ARG GOSU_GPG_RECV_KEYS=B42F6819007F00F88E364FD4036A9C25BF357DD4
ARG GOSU_VERSION=1.7

ARG TINI_VERSION=0.8.4

LABEL   "ARG:DOCKER_VERSION"="${DOCKER_VERSION}" \
        "ARG:GOSU_VERSION"="${GOSU_VERSION}" \
        "ARG:TINI_VERSION"="${TINI_VERSION}"

ENV JENKINS_GROUP=jenkins \
    JENKINS_HOME=/var/lib/jenkins \
    JENKINS_USER=jenkins

RUN set -x \
 && export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
### Install netstat to allow connection health check with `netstat -tan | grep ESTABLISHED`
 && apt-get install -y \
        curl \
        net-tools \
        wget \
### Install Docker
 && curl -fsSL --create-dirs --output /usr/local/bin/docker \
        "https://get.docker.com/builds/$(uname -s)/$(uname -m)/docker-${DOCKER_VERSION}" \
 && chmod +x /usr/local/bin/docker \
### Install Gosu
# && gpg --keyserver ${GOSU_GPG_KEYSERVER} --recv-keys ${GOSU_GPG_RECV_KEYS} \
 && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture)" \
# && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture).asc" \
# && gpg --verify /usr/local/bin/gosu.asc \
# && rm /usr/local/bin/gosu.asc \
 && chmod +x /usr/local/bin/gosu \
### Install Tini
 && curl --create-dirs -sSLo /usr/local/bin/tini \
        "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static" \
 && chmod -v +x /usr/local/bin/tini \
### Create Jenkins User
 && groupadd ${JENKINS_GROUP} \
 && useradd -c "Jenkins Swarm Agent" -d ${JENKINS_HOME} -g ${JENKINS_GROUP} -m ${JENKINS_USER} \
### Cleanup
 && apt-get clean \
 && rm -rf \
        /root/.gnupg \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*

COPY target/swarm-client.jar /usr/share/jenkins/
COPY src/main/resources /

RUN set -x \
  && chmod +x /jenkins-swarm-slave.sh

WORKDIR ${JENKINS_HOME}
VOLUME ${JENKINS_HOME}

ENTRYPOINT ["/jenkins-swarm-slave.sh"]
