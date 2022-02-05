#!/bin/bash

# Destroy all containers
docker-compose down
docker kill ${SEAFILE}
docker rm ${SEAFILE}

# Remove OpenvSwitch configurations
ovs-vsctl --if-exists del-br ${INTERNAL}
ovs-vsctl --if-exists del-br ${EXTERNAL}

# Delete all namespaces created
rm -r -f /var/run/netns

# Del config files 
rm /home/seafolder

# Stop controller
PID=`pgrep ryu`
if [ ! -z "$PID" ]; then kill $PID; fi



