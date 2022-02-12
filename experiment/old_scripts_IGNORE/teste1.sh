# Create bridge interface that will connect all subnets
ip link add v-cidds-0 type bridge
ip link set dev v-cidds-0 up

# Create subnet namespaces
ip netns add server
ip netns add management
ip netns add developer
ip netns add office

# Create virtual link
ip link add veth-s1 type veth peer name veth-s11
ip link add veth-m2 type veth peer name veth-m12
ip link add veth-d3 type veth peer name veth-d13
ip link add veth-o4 type veth peer name veth-o14

# Connect one peer to the respective namespaces
ip link set veth-s1 netns server
ip link set veth-m1 netns management
ip link set veth-d1 netns developer
ip link set veth-o1 netns office

# Turn on Namespaces' Loopback interface
ip netns exec server ifconfig lo up
ip netns exec management ifconfig lo up
ip netns exec developer ifconfig lo up
ip netns exec office ifconfig lo up

# Set ip to Namespaces' interfaces
ip netns exec server ip addr add 192.168.101.1 dev veth-s1
ip netns exec management ip addr add 192.168.101.1 dev veth-m2
ip netns exec developer ip addr add 192.168.101.1 dev veth-d3
ip netns exec office ip addr add 192.168.101.1 dev veth-o4

# Turn on Namespaces' interfaces
ip netns exec server ip link set veth-s1 up
ip netns exec management ip link set veth-m2 up
ip netns exec developer ip link set veth-d3 up
ip netns exec office ip link set veth-o4 up

# Connect it to the bridge
ip link set veth-s11 master v-cidds-0
ip link set veth-m12 master v-cidds-0
ip link set veth-d13 master v-cidds-0
ip link set veth-o14 master v-cidds-0

# Set default gateway
ip addr add 192.168.101.100/24 dev v-cidds-0
ip netns exec server route add -net 192.168.100.0/24 dev veth-s11
ip netns exec server route add default gw 192.168.101.100 

# Make outside subnet reachable
ip netns exec server ip route add 192.168.100.0/24 via 192.168.101.100
ip netns exec management ifconfig veth-m12 192.168.200.1/24 up
ip netns exec developer ifconfig veth-d13 192.168.210.1/24 up
ip netns exec office ifconfig veth-o14 192.168.220.1/24 up

# Enable NAT
iptables -t nat -A POSTROUTING -s 192.168.101.0/24 -j MASQUERADE
sysctl -w net.ipv4.ip_forward=1
iptables -A FORWARD -o eth0 -i veth-s11 -j ACCEPT