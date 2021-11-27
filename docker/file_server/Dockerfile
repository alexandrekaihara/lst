# Usage: 
## Build: docker build -t fileserver --network=host .
## Run ssh: docker run --cap-add=NET_ADMIN -it --network="pnet" -p 446:445 fileserver
## Create network: docker network create --subnet "192.168.1.0/24" --ip-range "192.168.1.0/24" --gateway "192.168.1.125" --attachable -o "com.docker.network.bridge.default_bridge"="true" -o "com.docker.network.brigde.default_bridge"="true" -o "com.docker.network.bridge.enable_icc"="true" -o "com.docker.network.bridge.enable_ip_masquerade"="true" -o "com.docker.network.bridge.host_binding_ipv4"="0.0.0.0" -o "com.docker.network.driver.mtu"="1500" pnet
## Install basic tools: apt install nano iptables net-tools iproute2 iputils-ping -y

# Imports
FROM ubuntu:20.04

# Updates
COPY dependencies.sh .
RUN chmod +x dependencies.sh \
&& ./dependencies.sh \
&& sudo su

# Copy the backup file
RUN mkdir /home/debian
COPY backup.py /home/debian/

# Start setup
COPY setup.sh .
RUN chmod +x setup.sh\
&& ./setup.sh

# Start samba and dummy files on start
COPY onboot.sh /home
RUN chmod +x /home/onboot.sh
CMD ["./home/onboot.sh"]

# For conecting via Open SSL
EXPOSE 22
EXPOSE 139
EXPOSE 445


