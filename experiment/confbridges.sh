#!/bin/bash

#
# Copyright (C) 2022 Alexandre Mitsuru Kaihara
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#



# Create bridges
## Create Internal bridge
ovs-vsctl add-br $INTERNAL
ifconfig $INTERNAL up
### Enable NAT on the interface that has connection to the internet
IFNAME=`route | grep '^default' | grep -o '[^ ]*$'`
iptables -t nat -I POSTROUTING -o $IFNAME -j MASQUERADE
iptables -t nat -I POSTROUTING -o $INTERNAL -j MASQUERADE
## Configure firewall to permit Forwarding between interfaces
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

