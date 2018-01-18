#!/usr/bin/env bash
set -x

# docker 仓库 env.DOCKER_REGISTRY_URL
export DOCKER_REGISTRY_URL="0.0.0.0:5000"

# spring boot 环境选择
mvn clean package

# 获取run.sh当前目录
dir=$(cd `dirname $0`; pwd)

# push image eureka
cd ${dir}/zsc-eureka
mvn docker:build -DpushImage
# eureka 容器ID
eurekaid=docker service ls | grep eureka | awk '{print $1}'
# rm container
# docker service rm cid
if [ -n "${eurekaid}" ]; then
    docker service rm ${eurekaid}
else
    echo "not eureka service"
fi

# push image config
cd ${dir}/zsc-config
mvn docker:build -DpushImage
configid=docker service ls | grep config-server | awk '{print $1}'
if [ -n "${configid}" ]; then
    docker service rm ${configid}
else
    echo "not eureka config-server"
fi

docker stack deploy --compose-file ${dir}/docker-compose-common.yml common

exit