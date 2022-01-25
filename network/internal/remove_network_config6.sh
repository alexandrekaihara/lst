#!/bin/bash

# Remove OpenvSwitch configurations
ovs-vsctl --if-exists del-br br-ex
ovs-vsctl --if-exists del-br br-int
dhclient eth0

# Delete all namespaces created
rm -r /var/run/netns

