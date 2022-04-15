#!/bin/bash

#
# Copyright (C) 2022 Alexandre Mitsuru Kaihara
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#


printf "LST  Copyright (C) 2022  Alexandre Mitsuru Kaihara\n\n\tThis program comes with ABSOLUTELY NO WARRANTY;\n\tThis is free software, and you are welcome to redistribute it\n\tunder certain conditions;\n\n"

if [ -z $1 ]; then
echo "[ERROR] The first argument of this program must not be NULL."
echo "Provide the name of the input file like ./setup.sh experiment_script.json"
exit -1
fi

# Function to be used when exiting the setup script
function cleanup(){
    echo "[LST] EXITING NOW. Executing tear_down_experiment.sh (this may take few seconds)"
    . tear_down_experiment.sh
    trap - SIGINT
    exit 0
}

# Function to deal with errors
function error(){
    echo "\"${last_command}\" command filed with exit code $?."
    . tear_down_experiment.sh
    trap - SIGINT
    exit 0
}

## Keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
## Trap an error on commands
trap 'error' ERR
## Execute cleanup function when pressing CTRL+C
trap cleanup INT

# Creating directories
mkdir logs > /dev/null 2>&1 || true
mkdir attack > /dev/null 2>&1 || true

# Load all environment variables
echo "[LST] Setting up all environment variables"
. variables

# Remove all remaining network configuration from previous experiments
echo "[LST] Remove all remaining network configuration from previous experiments"
. tear_down_experiment.sh

# Configure bridges
echo "[LST] Creating bridges ${INTERNAL} and ${EXTERNAL}"
chmod +x confbridges.sh
. confbridges.sh

# Add configure hosts function
chmod +x confhosts.sh
. confhosts.sh

# Start Ryu Controller
echo "[LST] Setting up controller on ${CONTROLLERIP}:${CONTROLLERPORT}"
ryu-manager --ofp-listen-host=${CONTROLLERIP} --ofp-tcp-listen-port=${CONTROLLERPORT} controller.py > logs/controller.log 2>&1 & 

# Instantiate seafile server
## OBS: It is necessary because all linuxclients uses the seafolder ID, which is unique and can be stored only after creating container
echo "[LST] Creating Seafile server"
docker run -d --network=none --privileged --dns=8.8.8.8 --name=${SEAFILE} ${REPOSITORY}:${SEAFILE}
configure_host ${SEAFILE} 50 1 ${EXTERNAL} 
## Set seafolder variable for create_config_files.py
docker cp $SEAFILE:/home/seafolder /home/seafolder
export SEAFOLDER=$(cat /home/seafolder)
echo "[LST] Seafolder ID is ${SEAFOLDER}"

# Generate all client configuration files
echo "[LST] Creating all configuration files of ${LCLIENT} from $1"
## Substitute all env variables on experiment_script.json
envsubst < $1 > experiment.json
## Execute script
python3 create_config_files.py experiment.json

# Set up all machines
echo "[LST] Setting up all containers"
docker-compose up -d

# Copy all client configuration files into the respective containers
echo "[LST] Starting network configuration of all containers"
chmod +x config_all_hosts.sh
. config_all_hosts.sh 

# Finished setting up experiment
echo "[LST] EXPERIMENT ALL SET UP!"
echo "(To end this experiment, press Crtl + C)"
tail -f logs/controller.log || true


