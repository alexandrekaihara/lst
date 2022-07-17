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


class Controller(Node):
    def __init__(self, nodeName: str) -> None:
        super(Controller, self).__init__(nodeName)
        self.__process = 0

    # Brief: Instantiate a controller container
    # Params:
    # Return:
    #   None
    def instantiate(self, dockerImage='ryucontroller', dockerCommand='') -> None:
        super().instantiate(dockerImage=dockerImage, dockerCommand=dockerCommand)

    def initController(self, ip:str, mask: int):
        #try:
        #    subprocess.run(f"ip link set {peerName} netns {nodeName}", shell=True)
        #    subprocess.run(f"ip -n {nodeName} link set {peerName} up", shell=True)
        #except Exception as ex:
        #    logging.error(f"Error while setting virtual interfaces {peerName} to {nodeName}: {str(ex)}")
        #    raise Exception(f"Error while setting virtual interfaces {peerName} to {nodeName}: {str(ex)}")
        pass

    def instantiate_local(self, controllerIp, controllerPort):
        process = self.__getProcess()
        if process == 0:
            try:
                self.__process = subprocess.Popen(f"ryu-manager --ofp-listen-host={controllerIp} --ofp-tcp-listen-port={controllerPort} controller.py > controller.log", shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            except Exception as ex:
                logging.error(f"Error while creating the switch {self.getNodeName()}: {str(ex)}")
                raise NodeInstantiationFailed(f"Error while creating the switch {self.getNodeName()}: {str(ex)}")
        else:
            logging.error(f"Controller {self.getNodeName()} already instantiated")
            raise Exception(f"Controller {self.getNodeName()} already instantiated")
        
    def delete(self):
        process = self.__getProcess()
        if process != 0:
            try:
                self.__process.kill()
                _, stderr = self.__process.communicate()
            except Exception as ex:
                logging.error(f"Error while deleting the switch {self.getNodeName()}: {str(ex)}\nThreads error: {stderr}")
                raise NodeInstantiationFailed(f"Error while deleting the switch {self.getNodeName()}: {str(ex)}\nThreads error: {stderr}")
        else:
            logging.error(f"Can't delete {self.getNodeName()}. {self.getNodeName()} was not instantiated.")
            raise Exception(f"Can't delete {self.getNodeName()}. {self.getNodeName()} was not instantiated.")
        
    def __getProcess(self):
        return self.__process