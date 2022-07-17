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
    def instantiate(self) -> None:
        super().instantiate(dockerCommand=f"docker run -d --network=none --privileged --name={self.getNodeName()} openvswitch")
        try:
            subprocess.run(f"docker exec {self.getNodeName()} ovs-vsctl add-br {self.getNodeName()}", shell=True)
            subprocess.run(f"docker exec {self.getNodeName()} ip link set {self.getNodeName()} up", shell=True)
        except Exception as ex:
            logging.error(f"Error while creating the switch {self.getNodeName()}: {str(ex)}")
            raise NodeInstantiationFailed(f"Error while creating the switch {self.getNodeName()}: {str(ex)}")