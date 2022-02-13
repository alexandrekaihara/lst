#!/bin/bash

if [ -z $1 ]; then
echo "[ERROR] The first argument of this program must not be NULL."
echo "Provide the name of the input file like ./setup.sh experiment_script.json"
exit -1
fi

# Function to be used when exiting the setup script
function cleanup(){
    echo "[CIDDS] EXITING NOW. Executing tear_down_experiment.sh (this may take few seconds)"
    . tear_down_experiment.sh
    trap - SIGINT
    exit 0
}
trap cleanup INT

# Creating directories
mkdir logs > /dev/null 2>&1
mkdir attack > /dev/null 2>&1

# Load all environment variables
echo "[CIDDS] Setting up all environment variables"
. variables

# Remove all remaining network configuration from previous experiments
echo "[CIDDS] Remove all remaining network configuration from previous experiments"
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
ryu-manager controller.py > logs/controller.log 2>&1 & 

# Instantiate seafile server
## OBS: It is necessary because all linuxclients uses the seafolder ID, which is unique and can be stored only after creating container
echo "[CIDDS] Creating Seafile server"
docker run -d --network=none --privileged --dns=8.8.8.8 --name=${SEAFILE} ${REPOSITORY}:${SEAFILE} > /dev/null 2>&1
configure_host ${SEAFILE} 50 1 ${EXTERNAL} 
## Set seafolder variable for create_config_files.py
docker cp $SEAFILE:/home/seafolder /home/seafolder
export SEAFOLDER=$(cat /home/seafolder)
echo "[CIDDS] Seafolder ID is ${SEAFOLDER}"

# Generate all client configuration files
echo "[CIDDS] Creating all configuration files of ${LCLIENT} from $1"
## Substitute all env variables on experiment_script.json
envsubst < $1 > experiment.json
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
echo "[CIDDS] EXPERIMENT ALL SET UP!"
echo "(To end this experiment, press Crtl + C)"
tail -f logs/controller.log


