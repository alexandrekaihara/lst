#!/bin/bash


# Enable nat
iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE


# Subnet 100
## Create interface for subnet
ip link add eth100 type bridge
ip link set dev eth100 up
ip addr add 192.168.100.4/32 dev eth100
ip route add 192.168.100.0/24 dev eth100

## Create macvlan interface do enable host communication
ip link add veth-100 link eth100 type macvlan mode bridge
ip link set dev veth-100 up
ip addr add 192.168.100.200/32 dev veth-100
ip route add 192.168.100.192/27 dev veth-100

# Create docker network
docker network rm cidds100
docker network create -d macvlan --subnet=192.168.100.1/24 --ip-range=192.168.100.192/27 --gateway=192.168.100.4 -o parent=eth100 --aux-address 'host=192.168.100.200' cidds100
docker run -it --network=cidds100 --privileged teset


# Subnet 200
## Create interface for subnet
ip link add eth200 type bridge
ip link set dev eth200 up
ip addr add 192.168.200.4/32 dev eth200
ip route add 192.168.200.0/24 dev eth200

## Create macvlan interface do enable host communication
ip link add veth-200 link eth200 type macvlan mode bridge
ip link set dev veth-200 up
ip addr add 192.168.200.200/32 dev veth-200
ip route add 192.168.200.192/27 dev veth-200

# Create docker network
docker network rm cidds200
docker network create -d macvlan --subnet=192.168.200.1/24 --ip-range=192.168.200.192/27 --gateway=192.168.200.4 -o parent=eth200 --aux-address 'host=192.168.200.200' cidds200
docker run -it --network=cidds200 --privileged teset


# Subnet 210
## Create interface for subnet
ip link add eth210 type bridge
ip link set dev eth210 up
ip addr add 192.168.210.4/32 dev eth210
ip route add 192.168.210.0/24 dev eth210

## Create macvlan interface do enable host communication
ip link add veth-210 link eth210 type macvlan mode bridge
ip link set dev veth-210 up
ip addr add 192.168.210.200/32 dev veth-210
ip route add 192.168.210.192/27 dev veth-210

# Create docker network
docker network rm cidds210
docker network create -d macvlan --subnet=192.168.210.1/24 --ip-range=192.168.210.192/27 --gateway=192.168.210.4 -o parent=eth210 --aux-address 'host=192.168.210.200' cidds210
docker run -it --network=cidds210 --privileged teset


# Subnet 220
## Create interface for subnet
ip link add eth220 type bridge
ip link set dev eth220 up
ip addr add 192.168.220.4/32 dev eth220
ip route add 192.168.220.0/24 dev eth220

## Create macvlan interface do enable host communication
ip link add veth-220 link eth220 type macvlan mode bridge
ip link set dev veth-220 up
ip addr add 192.168.220.200/32 dev veth-220
ip route add 192.168.220.192/27 dev veth-220

# Create docker network
docker network rm cidds220
docker network create -d macvlan --subnet=192.168.220.1/24 --ip-range=192.168.220.192/27 --gateway=192.168.220.4 -o parent=eth220 --aux-address 'host=192.168.220.200' cidds220
docker run -it --network=cidds220 --privileged teset
