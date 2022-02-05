#!/bin/bash

# Load all environment variables
. variables

# Remove all possible network configurations from previous experiments
chmod +x tear_down_experiment.sh
. tear_down_experiment.sh

# Configure bridges
chmod +x confbridges.sh
. confbridges.sh

# Add configure hosts function
chmod +x confhosts.sh
. confhosts.sh

# Instantiate seafile server
## OBS: It is necessary because all linuxclients uses the seafolder ID, which is unique and can be stored only after creating container
docker run -d --network=none --privileged --dns=8.8.8.8 --name=${SEAFILE} ${REPOSITORY}:${SEAFILE} 
configure_host ${SEAFILE} 50 1 ${INTERNAL} 
## Set seafolder variable for create_config_files.py
export SEAFOLDER=$(cat /home/seafolder)
until [ ! -z $SEAFOLDER ]; do
docker cp $SEAFILE:/home/seafolder /home/seafolder
echo "Waiting for Seafile Server configurate and generates the seafolder file"
done

# Generate all client configuration files
## Substitute all env variables on experiment_script.json
envsubst < experiment_script.json > experiment.json
## Execute script
python3 create_config_files.py experiment.json
## Copy all client configuration files into the respective containers
chmod +x config_all_hosts.sh
. config_all_hosts.sh

# Start Ryu Controller
ryu-manager controller.py &

# Set up all machines
docker-compose up -d
