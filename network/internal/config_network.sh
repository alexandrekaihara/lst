#!/bin/bash
# NOTE: If your internet access adapter is not called eth0, then 
# substitute all eth0 for the name of your adapter.


# Brief: Configure all network interfaces and connects them into the OVS bridges 
# Params:
#   - $1: name of the container
#   - $2: Tag of the subnet
#   - $3: Host ip part
# Return:
#   - None
# Example:
#   - configure_host [container name] [subnet] [host]
#   - configure_host mailserver 100 1
configure_host(){
    ## Add container to namespace. Available on: https://www.thegeekdiary.com/how-to-access-docker-containers-network-namespace-from-host/
    pid=$(docker inspect -f '{{.State.Pid}}' $1)
    mkdir -p /var/run/netns/
    ln -sfT /proc/$pid/ns/net /var/run/netns/$1

    ## Add interface on container and host
    ip link add veth$2.$3 type veth peer name vethsubnet$2
    ip link set veth$2.$3 up

    ## Connect interfaces into the container subspace to the bridge
    ip link set vethsubnet$2 netns $1
    ip -n $1 link set vethsubnet$2 up
    ovs-vsctl add-port br-int veth$2.$3

    ## Add ip addressses and routes
    ip -n $1 addr add 192.168.$2.$3/16 dev vethsubnet$2
    ip netns exec $1 route add default gw 192.168.$2.100
}


# Create bridges
## Create external bridge
ovs-vsctl add-br br-int
ifconfig br-int up
iptables -t nat -I POSTROUTING -o br-int -j MASQUERADE
ovs-vsctl add-port br-int eth0
ifconfig eth0 0
dhclient br-int
## Add routes from host to containers
ip addr add 192.168.100.100/24 dev br-int
ip addr add 192.168.200.100/24 dev br-int
ip addr add 192.168.210.100/24 dev br-int
ip addr add 192.168.220.100/24 dev br-int
## Connect to the controller
ovs-vsctl set-controller br-int tcp:127.0.0.1:6633


# Configure all hosts
configure_host mailserver 100 1
configure_host fileserver 100 2
configure_host webserver 100 3
configure_host backupserver 100 4
configure_host Mlinuxclient1 200 2
configure_host Olinuxclient1 210 2
configure_host Dlinuxclient1 220 2
