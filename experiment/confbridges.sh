#!/bin/bash

# Create bridges
## Create Internal bridge
ovs-vsctl add-br $INTERNAL
ifconfig $INTERNAL up
### Enable NAT on the interface that has connection to the internet
IFNAME=`route | grep '^default' | grep -o '[^ ]*$'`
iptables -t nat -I POSTROUTING -o $IFNAME -j MASQUERADE
iptables -t nat -I POSTROUTING -o $INTERNAL -j MASQUERADE
## Configure firewall to permit Forwarding between intercafes
iptables -A FORWARD -i $INTERNAL -o $IFNAME -j ACCEPT
iptables -A FORWARD -i $IFNAME -o $INTERNAL -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $EXTERNAL -o $IFNAME -j ACCEPT
iptables -A FORWARD -i $IFNAME -o $EXTERNAL -m state --state ESTABLISHED,RELATED -j ACCEPT
### Add multiples IP to the bridge as a gateway for all containers and set routes from host to containers
ifconfig $INTERNAL promisc
ip addr add 192.168.$SSUBNET.100/24 dev $INTERNAL
ip addr add 192.168.$MSUBNET.100/24 dev $INTERNAL
ip addr add 192.168.$OSUBNET.100/24 dev $INTERNAL
ip addr add 192.168.$DSUBNET.100/24 dev $INTERNAL
### Connect bridge to the controller
ovs-vsctl set-controller $INTERNAL tcp:$CONTROLLERIP:$CONTROLLERPORT

## Create External bridge
ovs-vsctl add-br $EXTERNAL
ifconfig $EXTERNAL up
iptables -t nat -I POSTROUTING -o $EXTERNAL -j MASQUERADE
### Add IP to the bridge and route to the 
ip addr add 192.168.$ESUBNET.100/24 dev $EXTERNAL
### Connect bridge to the controller
ovs-vsctl set-controller $EXTERNAL tcp:$CONTROLLERIP:$CONTROLLERPORT

