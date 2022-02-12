#!/bin/bash

ip link add veth type bridge
# If you wish to change the IP on which seafile server will listen to you must change this line
ip addr add 192.168.50.1/24
ifconfig veth up
docker build --network=host mdewinged/cidds:seafileserver .
ip link del veth