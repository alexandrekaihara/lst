ip netns add server
## Create and add virtual ethernet to namespace
ip link add veth-s type veth peer name veth-s1
ip link set veth-s1 netns server
ip addr add 192.168.101.1/24 dev veth-s
ip netns exec server ip addr add 192.168.101.2/24 dev veth-s1
## Set up internet access through namespace
ip link set veth-s up
ip netns exec server ip link set veth-s1 up
## Setup ip forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -A FORWARD -o eth0 -i veth-s -j ACCEPT
iptables -A FORWARD -i eth0 -o veth-s -j ACCEPT
iptables -t nat -A POSTROUTING -s 192.168.101.2/24 -o eth0 -j MASQUERADE
ip netns exec server ip route add default via 192.168.101.1

docker network create -d bridge --subnet=192.168.101.0/24 --gateway=192.168.101.125  --attachable -o "com.docker.network.bridge.default_bridge"="true" -o "com.docker.network.brigde.default_bridge"="true" -o "com.docker.network.bridge.enable_icc"="true" -o "com.docker.network.bridge.enable_ip_masquerade"="true" -o "com.docker.network.bridge.host_binding_ipv4"="0.0.0.0" -o "com.docker.network.driver.mtu"="1500" cidds



ip netns add linuxhint
ip netns exec linuxhint ip link set dev lo up
ip link add v-enp2s0 type veth peer name v-eth0
ip link set v-eth0 netns linuxhint
ip -n linuxhint addr add 10.0.1.0/24 dev v-eth0
ip -n linuxhint link set v-eth0 up
ip link set dev enp2s0 netns linuxhint