#!/bin/bash

# Update system
apt update
apt upgrade -y

# Install dependencies
declare -a packagesAptGet=("docker" "docker-compose" "net-tools" "python3-pip" "openvswitch-switch")
count=${#packagesAptGet[@]}
for i in `seq 1 $count` 
do
  until dpkg -s ${packagesAptGet[$i-1]} | grep -q Status;
  do
    RUNLEVEL=1 apt install -y --no-install-recommends ${packagesAptGet[$i-1]}
  done
  echo "${packagesAptGet[$i-1]} found."
done

# Install Python dependencies
python3 -m pip install --upgrade pip
pip3 install ryu eventlet==0.30.2 pandas