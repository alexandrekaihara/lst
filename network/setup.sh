#!/bin/bash

# Load all environment variables
echo "[CIDDS] Setting up all environment variables"
. variables

# Remove all possible network configurations from previous experiments
echo "[CIDDS] Removing all residual network configurations of previous experiments"
chmod +x tear_down_experiment.sh
. tear_down_experiment.sh

# Configure bridges
echo "[CIDDS] Creating bridges ${INTERNAL} e ${EXTERNAL}"
chmod +x confbridges.sh
. confbridges.sh

# Add configure hosts function
chmod +x confhosts.sh
. confhosts.sh

# Start Ryu Controller
echo "[CIDDS] Setting up controller on ${CONTROLLERIP}:${CONTROLLERPORT}"
mkdir logs
ryu-manager controller.py > logs/controller.log 2>&1 & 

# Instantiate seafile server
## OBS: It is necessary because all linuxclients uses the seafolder ID, which is unique and can be stored only after creating container
echo "[CIDDS] Creating Seafile server"
docker run -d --network=none --privileged --dns=8.8.8.8 --name=${SEAFILE} ${REPOSITORY}:${SEAFILE} 
configure_host ${SEAFILE} 50 1 ${EXTERNAL} 
## Set seafolder variable for create_config_files.py
until docker cp $SEAFILE:/home/seafolder /home/seafolder > /dev/null 2>&1; do
echo "[CIDDS] Waiting for Seafile Server configurate and generates the seafolder file"
sleep 3
done
export SEAFOLDER=$(cat /home/seafolder)
echo "[CIDDS] Finished Seafile configuration. Seafolder ID is ${SEAFOLDER}"


# Generate all client configuration files
## Substitute all env variables on experiment_script.json
echo "[CIDDS] Creating all configuration files of ${LCLIENT} from experiment_script.json"
envsubst < experiment_script.json > experiment.json
## Execute script
python3 create_config_files.py experiment.json

# Set up all machines
echo "[CIDDS] Setting up all containers"
docker-compose up -d

# Copy all client configuration files into the respective containers
echo "[CIDDS] Starting network configuration of all containers"
chmod +x config_all_hosts.sh
. config_all_hosts.sh

# Finished setting up experiment
echo "[CIDDS] Experiment all set up"
