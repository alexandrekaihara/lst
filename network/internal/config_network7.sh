# Create bridges
## Create external bridge
ovs-vsctl add-br br-int
ifconfig br-int up
iptables -t nat -I POSTROUTING -o br-int -j MASQUERADE
ovs-vsctl add-port br-int eth0
ifconfig eth0 0
dhclient br-int
## Connect to the controller
#ovs-vsctl set-controller br-int tcp:127.0.0.1:6633

# Create L2 Switches
ovs-vsctl add-br br-100
ovs-vsctl add-br br-200
ifconfig br-100 up
ifconfig br-200 up
iptables -t nat -I POSTROUTING -o br-100 -j MASQUERADE
iptables -t nat -I POSTROUTING -o br-200 -j MASQUERADE
## Connect into the Router
ip link add vethswitch100 type veth peer name vethrouter100
ovs-vsctl add-port br-100 vethswitch100 
ovs-vsctl add-port br-int vethrouter100
ip link add vethswitch200 type veth peer name vethrouter200
ovs-vsctl add-port br-200 vethswitch200 
ovs-vsctl add-port br-int vethrouter200
## Configure all flows 
ovs-ofctl add-flow br-int priority=3,arp,nw_dst=192.168.100.0/24,actions=output:"vethrouter100"
ovs-ofctl add-flow br-int priority=3,arp,nw_dst=192.168.200.0/24,actions=output:"vethrouter200"



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
    ovs-vsctl add-port br-$2 veth$2.$3

    ## Add ip addressses and routes
    ip -n $1 addr add 192.168.$2.$3/32 dev vethsubnet$2
    ip -n $1 route add 192.168.100.0/24 dev vethsubnet$2
    ip -n $1 route add 192.168.200.0/24 dev vethsubnet$2
    ip -n $1 route add 192.168.210.0/24 dev vethsubnet$2
    ip -n $1 route add 192.168.220.0/24 dev vethsubnet$2
}

configure_host vigilant_hopper 100 2
configure_host happy_perlman 100 1
configure_host goofy_bassi 200 1


ip netns exec happy_perlman route del default
ip netns exec happy_perlman ip route add 192.168.1.0/24 dev vethsubnet100
ip netns exec happy_perlman route add default gw 192.168.1.1 