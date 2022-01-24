#!/bin/bash

# Create bridge for external acess
ovs-vsctl add-br br-int
ifconfig br-int up
## Enable nat
iptables -t nat -I POSTROUTING -o br-int -j MASQUERADE
## Create flows
ovs-ofctl add-flow br-int priority=500,dl_type=ip,nw_dst=192.168.100.0/27,actions=output:1
ovs-ofctl add-flow br-int priority=500,dl_type=ip,nw_dst=192.168.200.0/27,actions=output:2
ovs-ofctl add-flow br-int priority=500,dl_type=ip,nw_dst=192.168.210.0/27,actions=output:3
ovs-ofctl add-flow br-int priority=500,dl_type=ip,nw_dst=192.168.220.0/27,actions=output:4
ovs-ofctl add-flow br-int priority=500,arp,nw_proto=1,actions=flood

# Functions
## Create a subnet and expects the first parameter as tag of the subnet to be created
create_subnet(){
    ## Create interface for subnet
    ip link add eth$1 type bridge
    ifconfig eth$1 promisc
    ip link set dev eth$1 up
    ip addr add 192.168.$1.100/32 dev eth$1
    #ip route add 192.168.$1.0/24 dev eth$1

    ## Create docker network
    until docker network create -d macvlan --subnet=192.168.$1.0/24 --gateway=192.168.$1.100 --ip-range=192.168.$1.0/27 -o parent=eth$1.$1 -o macvlan_mode=bridge --aux-address="host=192.168.$1.30" cidds$1
    do 
    docker network rm cidds$1
    done

    ## Create macvlan interface do enable host communication
    ip link add veth-$1 link eth$1.$1 type macvlan mode bridge
    ip link set dev veth-$1 up
    ip addr add 192.168.$1.30/32 dev veth-$1
    #ip route add 192.168.$1.0/27 dev veth-$1
    ovs-vsctl add-port br-int veth-$1 -- set Interface veth-$1 ofport=$2
}

# Create all subnets
create_subnet 100 1
create_subnet 200 2 
create_subnet 210 3
create_subnet 220 4

# Connect br-int to eth0 and loopback
ovs-vsctl add-port br-int eth0
ovs-vsctl add-port br-int loopback
ifconfig eth0 0
dhclient br-int
