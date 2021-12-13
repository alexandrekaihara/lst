ip link add veth-200 link eth0 type macvlan mode bridge
ip link set dev veth-200 up
ip addr add 192.168.200.200/32 dev veth-200
ip route add 192.168.200.192/27 dev veth-200
#docker network create -d macvlan --subnet=192.168.100.0/24 --subnet=10.0.2.0/24 --gateway=10.0.2.2 -o parent=veth-200 --attachable -o "com.docker.network.bridge.default_bridge"="true" -o "com.docker.network.brigde.default_bridge"="true" -o "com.docker.network.bridge.enable_icc"="true" -o "com.docker.network.bridge.enable_ip_masquerade"="true" -o "com.docker.network.bridge.host_binding_ipv4"="0.0.0.0" -o "com.docker.network.driver.mtu"="1500" cidds100
docker network rm cidds100
docker network create -d macvlan --subnet=192.168.200.0/24 --ip-range=192.168.200.192/27 --gateway=192.168.200.1 -o parent=eth0 --aux-address 'host=192.168.200.200' cidds100
docker run -it --network=cidds100 --privileged teset

# Subnet 100
ip link add eth100 type bridge
ip link set dev eth100 up
ip addr add 192.168.100.4/32 dev eth100
ip route add 192.168.100.0/24 dev eth100

iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
#sysctl -w net.ipv4.ip_forward=1

ip link add veth-100 link eth100 type macvlan mode bridge
ip link set dev veth-100 up
ip addr add 192.168.100.200/32 dev veth-100
ip route add 192.168.100.192/27 dev veth-100

docker network rm cidds100
docker network create -d macvlan --subnet=192.168.100.1/24 --ip-range=192.168.100.192/27 --gateway=192.168.100.4 -o parent=eth100 --aux-address 'host=192.168.100.200' cidds100
docker run -it --network=cidds100 --privileged teset

## Solução 2
ip addr add 192.168.201.4/24 dev eth0

ip link add veth-201 link eth0 type macvlan mode bridge
ip link set dev veth-201 up
ip addr add 192.168.201.200/32 dev veth-201
ip route add 192.168.201.192/27 dev veth-201

docker network rm cidds201
docker network create -d macvlan --subnet=192.168.201.1/24 --ip-range=192.168.201.192/27 --gateway=192.168.201.4 -o parent=eth0 --aux-address 'host=192.168.201.200' cidds201
docker run -it --network=cidds201 --privileged teset
