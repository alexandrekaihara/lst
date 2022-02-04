#!/bin/bash

# Load all environment variables
. variables

# Remove all possible network configurations of previous experiments
chmod +x tear_down_experiment.sh
. tear_down_experiment.sh

# Configure bridges
chmod +x confbridges.sh
. confbridges.sh

# Add configure hosts function
chmod +x confhosts.sh
. confhosts.sh

# Instantiate seafile server
docker run -d --network=none --privileged --dns=8.8.8.8 ${REPOSITORY}:${SEAFILE}
configure_host ${SEAFILE} 50 1 ${INTERNAL} 
ip netns exec ${SEAFILE} mysql -uroot --password=Password123 -e "USE seafile-db; SELECT * FROM RepoOwner"
## Set seafolder variable for create_config_files.py
export SEAFOLDER=01684009-63a2-4239-9326-acc6bb937cfa

# Substitute all env variables on experiment_script.json
envsubst < experiment_script.json > experiment.json

# Generate all configure files
python3 create_config_files.py experiment.json

# Copy all configuration files into the respective containers
chmod +x config_all_hosts.sh
. config_all_hosts.sh

# Start Ryu Controller
ryu-manager controller.py &

# Set up all machines
docker-compose up -d
