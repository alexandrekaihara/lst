#!/bin/bash

# Destroy all containers
docker-compose down > /dev/null 2>&1
docker kill ${SEAFILE} > /dev/null 2>&1
docker rm ${SEAFILE} > /dev/null 2>&1

# Remove OpenvSwitch configurations
ovs-vsctl --if-exists del-br ${INTERNAL}
ovs-vsctl --if-exists del-br ${EXTERNAL}

# Delete all namespaces created
rm -r -f /var/run/netns > /dev/null 2>&1

# Del config files 
rm /home/seafolder > /dev/null 2>&1

# Stop controller
PID=`pgrep ryu`
if [ ! -z "$PID" ]; then kill $PID; fi

# Delete inserted firewall rules
iptables -D FORWARD -i $INTERNAL -o $IFNAME -j ACCEPT
iptables -D FORWARD -i $IFNAME -o $INTERNAL -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -D FORWARD -i $EXTERNAL -o $IFNAME -j ACCEPT
iptables -D FORWARD -i $IFNAME -o $EXTERNAL -m state --state ESTABLISHED,RELATED -j ACCEPT


