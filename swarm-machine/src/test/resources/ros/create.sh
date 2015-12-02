#!/bin/bash -xe

export MACHINE_STORAGE_PATH=$(echo $(readlink -f ${BASH_SOURCE[0]} 2>/dev/null || realpath -e ${BASH_SOURCE[0]}) | sed -e 's|swarm-machine.*|swarm-machine/target/docker-machine|g')

mkdir -vp ${MACHINE_STORAGE_PATH}

if [ ! -e ${MACHINE_STORAGE_PATH}/cache/rancheros.iso ]; then
    curl \
        --create-dirs \
        --fail \
        --location \
        --show-error \
        --silent \
        --output ${MACHINE_STORAGE_PATH}/cache/rancheros.iso \
        "https://github.com/rancher/os/releases/download/v${RANCHEROS_VERSION:-0.4.1}/rancheros.iso"
fi

export JENKINS_SWARM_RANCHEROS_ISO="file://${MACHINE_STORAGE_PATH}/cache/rancheros.iso"

docker-machine --debug create \
    --driver virtualbox \
    --virtualbox-memory 2048 \
    --virtualbox-boot2docker-url "${JENKINS_SWARM_RANCHEROS_ISO}" \
    --engine-label 'rancher=master' \
    ros0

eval "$(docker-machine env ros0)"

docker-compose -f $(dirname ${BASH_SOURCE[0]})/compose-ros0.d/consul/docker-compose.yml up -d
docker-compose -f $(dirname ${BASH_SOURCE[0]})/compose-ros0.d/registry/docker-compose.yml up -d

export JENKINS_SWARM_CONTROLLER_IP=$(docker-machine ip ros0)
export JENKINS_SWARM_KVSTORE_URL="consul://${JENKINS_SWARM_CONTROLLER_IP}:8500"

docker-machine --debug create \
    --driver virtualbox \
    --virtualbox-memory 2048 \
    --virtualbox-boot2docker-url "${JENKINS_SWARM_RANCHEROS_ISO}" \
    --swarm \
    --swarm-master \
    --swarm-discovery="${JENKINS_SWARM_KVSTORE_URL}" \
    --engine-insecure-registry="http://${JENKINS_SWARM_CONTROLLER_IP}:4999" \
    --engine-insecure-registry="http://${JENKINS_SWARM_CONTROLLER_IP}:5000" \
    --engine-opt="cluster-store=${JENKINS_SWARM_KVSTORE_URL}" \
    --engine-opt="cluster-advertise=eth1:2376" \
    --engine-registry-mirror="http://${JENKINS_SWARM_CONTROLLER_IP}:4999" \
    --engine-registry-mirror="http://${JENKINS_SWARM_CONTROLLER_IP}:5000" \
    --engine-label 'rancher=master' \
    --engine-label 'jenkins=master' \
    ros1

docker-machine --debug create \
    --driver virtualbox \
    --virtualbox-memory 2048 \
    --virtualbox-boot2docker-url "${JENKINS_SWARM_RANCHEROS_ISO}" \
    --swarm \
    --swarm-discovery="${JENKINS_SWARM_KVSTORE_URL}" \
    --engine-insecure-registry="http://${JENKINS_SWARM_CONTROLLER_IP}:4999" \
    --engine-insecure-registry="http://${JENKINS_SWARM_CONTROLLER_IP}:5000" \
    --engine-opt="cluster-store=${JENKINS_SWARM_KVSTORE_URL}" \
    --engine-opt="cluster-advertise=eth1:2376" \
    --engine-registry-mirror="http://${JENKINS_SWARM_CONTROLLER_IP}:4999" \
    --engine-registry-mirror="http://${JENKINS_SWARM_CONTROLLER_IP}:5000" \
    --engine-label 'rancher=slave' \
    --engine-label 'jenkins=slave' \
    ros2


docker-machine --debug create \
    --driver virtualbox \
    --virtualbox-memory 2048 \
    --virtualbox-boot2docker-url "${JENKINS_SWARM_RANCHEROS_ISO}" \
    --swarm \
    --swarm-discovery="${JENKINS_SWARM_KVSTORE_URL}" \
    --engine-insecure-registry="http://${JENKINS_SWARM_CONTROLLER_IP}:4999" \
    --engine-insecure-registry="http://${JENKINS_SWARM_CONTROLLER_IP}:5000" \
    --engine-opt="cluster-store=${JENKINS_SWARM_KVSTORE_URL}" \
    --engine-opt="cluster-advertise=eth1:2376" \
    --engine-registry-mirror="http://${JENKINS_SWARM_CONTROLLER_IP}:4999" \
    --engine-registry-mirror="http://${JENKINS_SWARM_CONTROLLER_IP}:5000" \
    --engine-label 'rancher=slave' \
    --engine-label 'jenkins=slave' \
    ros3

