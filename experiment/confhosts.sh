#!/bin/bash


# Brief: Configure all network interfaces and connects them into the OVS bridges 
# and 
# Params:
#   - $1: name of the container
#   - $2: Tag of the subnet
#   - $3: Host ip part
#   - $4: Name of the bridge to connect to the containers 
#   - $5: IF current conteiner is a linux client, then $5 represents name of the behaviour file (can be found on "client_behaviour" folder)
# Example:
#   - configure_host mailserver 100 1 br-int 
configure_host(){
    ## $1 and $2 and $3 and $4 must not be empty
    if [ -z $1 ] || [ -z $2 ] || [ -z $3 ] || [ -z $4 ]; then
    echo "[ERROR] The first, second, third or fourth argument of this function must not be NULL" 
    else

    ## Add container to namespace. Available on: https://www.thegeekdiary.com/how-to-access-docker-containers-network-namespace-from-host/
    pid=$(docker inspect -f '{{.State.Pid}}' $1)
    mkdir -p /var/run/netns/
    ln -sfT /proc/$pid/ns/net /var/run/netns/$1

    # If $5 is not NULL, then execute the commands below
    if [ ! -z $5 ]; then
        docker cp printersip/$2 $1:/home/debian/printerip
        docker cp client_behaviour/$5.ini $1:/home/debian/config.ini
        docker cp serverconfig.ini $1:/home/debian/serverconfig.ini
        docker cp sshiplist.ini $1:/home/debian/sshiplist.ini

        # If $5 is attacker type, then copy the attacker config files
        if [ $5 = 'attacker' ]; then
            # If the subnet is external
            if [ $2 = $ESUBNET ]; then
            docker cp attack/external_ipListPort80.txt $1:/home/debian/ipListPort80.txt
            docker cp attack/external_ipList.txt $1:/home/debian/ipList.txt
            docker cp attack/external_iprange.txt $1:/home/debian/iprange.txt
            # If the subnet is internal
            else
            docker cp attack/internal_ipListPort80.txt $1:/home/debian/ipListPort80.txt
            docker cp attack/internal_ipList.txt $1:/home/debian/ipList.txt
            docker cp attack/internal_iprange.txt $1:/home/debian/iprange.txt
            fi
        fi
    else
        # All other images receive the backup.py e serverconfig.ini (only backup and seafile server doesn't use)
        docker cp backup.py $1:/home/debian/backup.py > /dev/null 2>&1 
        docker cp serverconfig.ini $1:/home/debian/serverconfig.ini > /dev/null 2>&1
    fi
    
    ## Add interface on container and host
    ip link add veth$2.$3 type veth peer name vethsubnet$2
    ip link set veth$2.$3 up

    ## Connect interfaces into the container subspace to the bridge
    ip link set vethsubnet$2 netns $1
    ip -n $1 link set vethsubnet$2 up
    ovs-vsctl add-port $4 veth$2.$3

    ## Add ip addressses and routes
    ip -n $1 route add 192.168.$SSUBNET.0/24 dev vethsubnet$2
    ip -n $1 route add 192.168.$MSUBNET.0/24 dev vethsubnet$2
    ip -n $1 route add 192.168.$OSUBNET.0/24 dev vethsubnet$2
    ip -n $1 route add 192.168.$DSUBNET.0/24 dev vethsubnet$2
    ip -n $1 addr add 192.168.$2.$3/24 dev vethsubnet$2
    ip netns exec $1 route add default gw 192.168.$2.100
    fi
}