#!/bin/bash

# Destroy all containers
docker-compose down 2>&1
docker kill ${SEAFILE} 2>&1
docker rm ${SEAFILE} 2>&1

# Remove OpenvSwitch configurations
ovs-vsctl --if-exists del-br ${INTERNAL}
ovs-vsctl --if-exists del-br ${EXTERNAL}

# Delete all namespaces created
rm -r -f /var/run/netns 2>&1

# Del config files 
rm /home/seafolder 2>&1

# Stop controller
PID=`pgrep ryu`
if [ ! -z "$PID" ]; then kill $PID; fi



