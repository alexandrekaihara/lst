#!/bin/bash

# Load all environment variables
. .env

# Remove all possible network configurations
chmod +x tear_down_experiment.sh
. tear_down_experiment.sh

# Configure all networks
chmod +x config_network.sh
. config_network.sh

# Instantiate seafile server
docker run -d --network=none --privileged --dns=8.8.8.8 ${REPOSITORY}:${SEAFILE}
configure_host ${SEAFILE} 50 1 ${INTERNAL} 
ip netns exec ${SEAFILE} mysql -uroot --password=Password123 -e "USE seafile-db; SELECT * FROM RepoOwner"
## Set seafolder variable for create_config_files.py
SEAFOLDER=01684009-63a2-4239-9326-acc6bb937cfa

# Substitute all env variables on experiment_script.json
chmod +x replace.sh
. replace.sh

# Generate all configure files
python3 create_config_files.py

# Start Ryu Controller
ryu-manager controller.py &

# Set up all machines
docker-compose up -d
