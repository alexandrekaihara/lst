#!/bin/bash

# Destroy all containers
docker-compose down > /dev/null 2>&1 || true
docker kill ${SEAFILE} > /dev/null 2>&1 || true
docker rm ${SEAFILE} > /dev/null 2>&1 || true

# Remove OpenvSwitch configurations
ovs-vsctl --if-exists del-br ${INTERNAL} || true
ovs-vsctl --if-exists del-br ${EXTERNAL} || true

# Delete all namespaces created
rm -r -f /var/run/netns > /dev/null 2>&1 || true

# Del config files 
rm /home/seafolder > /dev/null 2>&1 || true

# Stop controller
PID=`pgrep ryu` || true
if [ ! -z "$PID" ]; then kill $PID; fi || true

# Delete inserted firewall rules
iptables -D FORWARD -i $INTERNAL -o $IFNAME -j ACCEPT > /dev/null 2>&1 || true
iptables -D FORWARD -i $IFNAME -o $INTERNAL -m state --state ESTABLISHED,RELATED -j ACCEPT > /dev/null 2>&1 || true
iptables -D FORWARD -i $EXTERNAL -o $IFNAME -j ACCEPT > /dev/null 2>&1 || true
iptables -D FORWARD -i $IFNAME -o $EXTERNAL -m state --state ESTABLISHED,RELATED -j ACCEPT > /dev/null 2>&1 || true


