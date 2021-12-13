#!/bin/bash

# Configure all networks
.config_network.sh

# Set up all machines
docker-compose --env-file .env -d up
