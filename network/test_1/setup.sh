#!/bin/bash

# Substitute all env variables on experiment.json


# Remove all possible network configurations
chmod +x tear_down_experiment.sh
. tear_down_experiment.sh

# Start Ryu Controller
ryu-manager controller.py &

# Set up all machines
docker-compose --env-file=".env" up -d

# Configure all networks
chmod +x config_network.sh
. config_network.sh
