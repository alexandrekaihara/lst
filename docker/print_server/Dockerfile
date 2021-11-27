# Usage:
## Build: docker build -t printerserver . 
## Run: docker run --cap-add=NET_ADMIN -it --network="printernet" -p 631:631 printerserver
## Install basic tools: apt install nano iptables net-tools iproute2 iputils-ping -y
## NAT Configurations:
### ip route add 192.168.56.0/24 via 192.168.1.125
### iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j MASQUERADE
### iptables -t nat -A PREROUTING -p tcp --dport 631 -j DNAT --to-destination 192.168.1.1:631
## Create network: docker network create --subnet "192.168.1.0/24" --ip-range "192.168.1.0/24" --gateway "192.168.1.125" --attachable -o "com.docker.network.bridge.default_bridge"="true" -o "com.docker.network.brigde.default_bridge"="true" -o "com.docker.network.bridge.enable_icc"="true" -o "com.docker.network.bridge.enable_ip_masquerade"="true" -o "com.docker.network.bridge.host_binding_ipv4"="0.0.0.0" -o "com.docker.network.driver.mtu"="1500" printernet
## To execute on SSH use "docker run -it [ID]"

# Imports
FROM ubuntu:20.04

# Install dependencies
COPY dependencies.sh .
RUN chmod +x dependencies.sh \
&& ./dependencies.sh \
&& sudo su

# Start setup
COPY setup.sh .
RUN chmod +x setup.sh\
&& ./setup.sh

# Start samba
COPY onboot.sh /home
RUN chmod +x /home/onboot.sh
CMD ["./home/onboot.sh"]

# For conecting via Open SSL
EXPOSE 22
EXPOSE 631


