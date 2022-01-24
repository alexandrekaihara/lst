#!/bin/bash

# Remove OpenvSwitch configurations
ovs-vsctl --if-exists del-br br-ex
ovs-vsctl --if-exists del-br br-int
dhclient eth0

ip link del veth100.1
ip link del veth200.1
ip link del veth210.1
ip link del veth220.1
