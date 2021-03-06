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


# Update system
apt update
apt upgrade -y

# Install dependencies
declare -a packagesAptGet=("docker.io" "docker-compose" "python3" "net-tools" "python3-pip" "openvswitch-switch") # "neutron-openvswitch-agent" "openvswitch-common" "openvswitch-dbg" "openvswitch-doc" "openvswitch-pki" "openvswitch-switch-dpdk" "openvswitch-test" "openvswitch-test" "openvswitch-testcontroller" "openvswitch-vtep" "python3-openvswitch")
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