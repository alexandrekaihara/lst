# Create bridges
## Create external bridge
ovs-vsctl add-br br-ex
ifconfig br-ex up
iptables -t nat -I POSTROUTING -o br-ex -j MASQUERADE
ovs-vsctl add-port br-ex eth0
ifconfig eth0 0
dhclient br-ex
## Create internal bridge
ovs-vsctl add-br br-int
ifconfig br-int up
## Set controler on bridges
ovs-vsctl set-controller br-ex tcp:10.10.53.50:6633
ovs-vsctl set-controller br-int tcp:127.0.0.1:6633


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
    ip -n $1 addr add 192.168.$2.$3/32 dev vethsubnet$2
    ip -n $1 route add 192.168.100.0/24 dev vethsubnet$2
    ip -n $1 route add 192.168.200.0/24 dev vethsubnet$2
    ip -n $1 route add 192.168.210.0/24 dev vethsubnet$2
    ip -n $1 route add 192.168.220.0/24 dev vethsubnet$2
    
    ## Configure flows into the switch
    ovs-ofctl add-flow br-int priority=3,arp,nw_dst=192.168.$2.$3/32,actions=output:"veth$2.$3"
    ovs-ofctl add-flow br-int priority=3,ip,nw_dst=192.168.$2.$3/32,actions=output:"veth$2.$3"
}

configure_host cool_taussig 100 1
configure_host inspiring_panini 200 1
configure_host gifted_brahmagupta 210 1
