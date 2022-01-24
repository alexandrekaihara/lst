# Usage: 
## Build: docker build -t fileserver --network=host .
## Run ssh: docker run --cap-add=NET_ADMIN -it --network="pnet" -p 446:445 fileserver
## Create network: docker network create --subnet "192.168.1.0/24" --ip-range "192.168.1.0/24" --gateway "192.168.1.125" --attachable -o "com.docker.network.bridge.default_bridge"="true" -o "com.docker.network.brigde.default_bridge"="true" -o "com.docker.network.bridge.enable_icc"="true" -o "com.docker.network.bridge.enable_ip_masquerade"="true" -o "com.docker.network.bridge.host_binding_ipv4"="0.0.0.0" -o "com.docker.network.driver.mtu"="1500" pnet
## Install basic tools: apt install nano iptables net-tools iproute2 iputils-ping -y

# Imports
FROM ubuntu:20.04

# Install dependencies
COPY dependencies_seafile.sh .
RUN chmod +x dependencies_seafile.sh \
&& ./dependencies_seafile.sh \
&& sudo su

# Start setup
COPY setup_seafile.sh .
RUN chmod +x setup_seafile.sh\
&& ./setup.sh

# Install dependencies
COPY dependencies_web.sh .
RUN chmod +x dependencies_web.sh \
&& ./dependencies_web.sh \
&& sudo su

# Start setup
COPY setup_web.sh .
RUN chmod +x setup_web.sh\
&& ./setup.sh

# Script to start needed programs
COPY onboot.sh /home
RUN chmod +x /home/onboot.sh
CMD ["./home/onboot.sh"]

# For conecting via Open SSL
EXPOSE 80
EXPOSE 8082
EXPOSE 8000
EXPOSE 22


