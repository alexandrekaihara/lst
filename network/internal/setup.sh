#!/bin/bash

# Remove all possible network configurations
## Del bridge
ovs-vsctl --if-exists del-br br-int
## Delete all namespaces created
rm -r /var/run/netns

# Start Ryu Controller
ryu-manager controller.py &

# Set up all machines
docker-compose --env-file=".env" up -d

# Configure all networks
chmod +x config_network.sh
. config_network.sh
