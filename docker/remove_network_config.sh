#!/bin/bash

delete_subnet(){
    ip link del eth$1
    #ovs-vsctl --if-exists del-br eth$1
    docker network rm cidds$1
}

# Delete all subnets
delete_subnet 100
delete_subnet 200
delete_subnet 210
delete_subnet 220

# Remove OpenvSwitch configurations
ovs-vsctl --if-exists del-br br-int
dhclient eth0