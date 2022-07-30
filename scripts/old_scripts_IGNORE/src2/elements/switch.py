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


import logging
import subprocess
from elements.node import Node
from exceptions import NodeInstantiationFailed


class Switch(Node):
    # Brief: Instantiate an OpenvSwitch switch container
    # Params:
    # Return:
    #   None
    def instantiate(self, controllerIP='', controllerPort=-1) -> None:
        super().instantiate(dockerCommand=f"docker run -d --network=none --privileged --name={self.getNodeName()} openvswitch")
        try:
            # Create bridge and set it up
            subprocess.run(f"docker exec {self.getNodeName()} ovs-vsctl add-br {self.getNodeName()}", shell=True)
            subprocess.run(f"docker exec {self.getNodeName()} ip link set {self.getNodeName()} up", shell=True)
        except Exception as ex:
            logging.error(f"Error while creating the switch {self.getNodeName()}: {str(ex)}")
            raise NodeInstantiationFailed(f"Error while creating the switch {self.getNodeName()}: {str(ex)}")
        # Link it to a controller
        if controllerIP != '' and controllerPort != -1:
            self.setController(controllerIP, controllerPort)

    # Brief: Set the controller to which the switch will be connecting to
    # Params:
    #   String ip: Controller's IP address
    #   String port: Controller's port
    # Return:
    #   None
    def setController(self, ip:str, port: str):
        try:
            subprocess.run(f"ovs-vsctl set-controller {self.getNodeName()} tcp:{ip}:{port}", shell=True)
        except Exception as ex:
            logging.error(f"Error connecting switch {self.getNodeName()} to controller on IP {ip}/{port}: {str(ex)}")
            raise Exception(f"Error connecting switch {self.getNodeName()} to controller on IP {ip}/{port}: {str(ex)}")
