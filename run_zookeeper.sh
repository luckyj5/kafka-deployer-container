#!/bin/bash

# Key environment varaibles
# ZOOKEEPER_initLimit
# ZOOKEEPER_syncLimit
# ZOOKEEPER_servers
# ...

cd kafka

for envvar in `env | grep ^ZOOKEEPER_ | grep -v ZOOKEEPER_servers | grep -v ZOOKEEPER_myid`
do
    setting=`echo "${envvar}" | sed "s#^ZOOKEEPER_##g"`
    set -- `echo ${setting} | tr '=' ' '`
    key="$1"
    value="$2"

    res=`grep ${key} config/zookeeper.properties`
    if [ "${res}" != ""  ]; then
        sed -E -i"" "s@^#?${key}.*@${key}=${value}@g" config/zookeeper.properties
    else
        echo "" >> config/server.properties
        echo ${setting} >> config/zookeeper.properties
    fi
done

echo ${ZOOKEEPER_servers} | sed "s#,#\n#g" >> config/zookeeper.properties
mkdir -p ${ZOOKEEPER_dataDir}
echo "${ZOOKEEPER_myid}" > ${ZOOKEEPER_dataDir}/myid

sleep 10 # to wait the service name to broadcast

while :
do
    ./bin/zookeeper-server-start.sh config/zookeeper.properties
    sleep 1
done
