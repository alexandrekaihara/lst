#!/bin/bash


# Start Ryu Controller
ryu-manager controller.py &


# Set up all machines
docker-compose --env-file=".env" up -d


# Configure all networks
chmod +x config_network.sh
. config_network.sh
