#!/bin/bash

# Configure all networks
chmod +x config_network.sh
. config_network.sh

# Set up all machines
docker-compose --env-file=".env" up -d