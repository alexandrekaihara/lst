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
IFNAME=`route | grep '^default' | grep -o '[^ ]*$'` > /dev/null 2>&1 || true
iptables -D FORWARD -i $INTERNAL -o $IFNAME -j ACCEPT > /dev/null 2>&1 || true
iptables -D FORWARD -i $IFNAME -o $INTERNAL -m state --state ESTABLISHED,RELATED -j ACCEPT > /dev/null 2>&1 || true
iptables -D FORWARD -i $EXTERNAL -o $IFNAME -j ACCEPT > /dev/null 2>&1 || true
iptables -D FORWARD -i $IFNAME -o $EXTERNAL -m state --state ESTABLISHED,RELATED -j ACCEPT > /dev/null 2>&1 || true


