#!/bin/bash

# Create bridges
## Create Internal bridge
ovs-vsctl add-br $INTERNAL
ifconfig $INTERNAL up
### Enable NAT on the interface that has connection to the internet
IFNAME=`route | grep '^default' | grep -o '[^ ]*$'`
iptables -t nat -I POSTROUTING -o $IFNAME -j MASQUERADE
iptables -t nat -I POSTROUTING -o $INTERNAL -j MASQUERADE
### Add multiples IP to the bridge as a gateway for all containers and set routes from host to containers
ip addr add 192.168.100.100/24 dev $INTERNAL
ip addr add 192.168.200.100/24 dev $INTERNAL
ip addr add 192.168.210.100/24 dev $INTERNAL
ip addr add 192.168.220.100/24 dev $INTERNAL
### Connect bridge to the controller
ovs-vsctl set-controller $INTERNAL tcp:127.0.0.1:6633

## Create External bridge
ovs-vsctl add-br $EXTERNAL
ifconfig $EXTERNAL up
iptables -t nat -I POSTROUTING -o $EXTERNAL -j MASQUERADE
### Add IP to the bridge and route to the 
ip addr add 192.168.50.100/24 dev $EXTERNAL
### Connect bridge to the controller
ovs-vsctl set-controller $EXTERNAL tcp:127.0.0.1:6633

