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
    def instantiate(self):
        super().instantiate(dockerImage="openvswitch")

    def instantiate_local(self):
        try:
            subprocess.run(f"ovs-vsctl add-br {self.getNodeName()}", shell=True)
        except Exception as ex:
            logging.error(f"Error while creating the switch {self.getNodeName()}: {str(ex)}")
            raise NodeInstantiationFailed(f"Error while creating the switch {self.getNodeName()}: {str(ex)}")
        
    def delete(self):
        try:
            subprocess.run(f"ovs-vsctl del-br {self.getNodeName()}", shell=True)
        except Exception as ex:
            logging.error(f"Error while deleting the switch {self.getNodeName()}: {str(ex)}")
            raise NodeInstantiationFailed(f"Error while deleting the switch {self.getNodeName()}: {str(ex)}")
        