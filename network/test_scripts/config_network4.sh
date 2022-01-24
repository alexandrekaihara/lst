#!/bin/bash

# Enable nat
#iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE

# Create bridge for external acess
ovs-vsctl add-br br-int
ifconfig br-int up
ovs-vsctl add-port br-int eth0
ifconfig eth0 0
dhclient br-int
ovs-vsctl set-controller br-int tcp:127.0.0.1:6653

iptables -t nat -I POSTROUTING -o br-int -j MASQUERADE

# Functions
## Create a subnet and expects the first parameter as tag of the subnet to be created
create_subnet(){
    ## Create interface for subnet
    ip link add eth$1 type bridge
    #ovs-vsctl add-br eth$1
    ip link set dev eth$1 up
    ip addr add 192.168.$1.100/32 dev eth$1

    ## Create macvlan interface do enable host communication
    ip link add veth-$1 link eth$1 type macvlan mode bridge
    ip link set dev veth-$1 up
    ip addr add 192.168.$1.30/32 dev veth-$1
    ovs-vsctl add-port eth$1 veth-$1

    ## Create docker network
    until docker network create -d macvlan --subnet=192.168.$1.0/24 --ip-range=192.168.$1.0/27 --gateway=192.168.$1.100 -o parent=eth$1 --aux-address="host=192.168.$1.30" cidds$1
    do 
    docker network rm cidds$1
    done
}

# Create all subnets
create_subnet 100
create_subnet 200
create_subnet 210
create_subnet 220
