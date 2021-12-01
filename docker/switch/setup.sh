#!/bin/bash

apt update
apt install nano iptables net-tools iproute2 iputils-ping traceroute -y

docker network create -d ipvlan --subnet "192.168.0.0/24" --ip-range "192.168.0.0/24" --gateway "192.168.0.125" --attachable -o "com.docker.network.bridge.default_bridge"="true" -o "com.docker.network.brigde.default_bridge"="true" -o "com.docker.network.bridge.enable_icc"="true" -o "com.docker.network.bridge.enable_ip_masquerade"="true" -o "com.docker.network.bridge.host_binding_ipv4"="0.0.0.0" -o "com.docker.network.driver.mtu"="1500" -o parent=eth0 ciddsnet
docker network create -d ipvlan --subnet=192.168.100.0/24 --subnet=192.168.200.0/24 --subnet=192.168.210.0/24 --subnet=192.168.220.0/24 --gateway=192.168.100.225 --gateway=192.168.200.225 --gateway=192.168.210.225 --gateway=192.168.220.225 -o ipvlan_mode=l3 -o parent=eth0 cidds-ipvlan

docker run -it --network=ipvlan --ip=192.168.100.2 teste

# Create bridges for each subnet
## Developer Bridge
ip link add v-net-developer type bridge
ip link set v-net-developer up
## Management Bridge
ip link add v-net-management type bridge
ip link set v-net-management up
## server Bridge
ip link add v-net-server type bridge
ip link set v-net-server up
## office Bridge
ip link add v-net-office type bridge
ip link set v-net-office up

# Link namespaces
ip link add veth-developer type veth peer name veth-management
ip link set veth-developer netns developer
ip link set veth-management netns management

ip link add veth-manager type veth peer name veth-manager-br
