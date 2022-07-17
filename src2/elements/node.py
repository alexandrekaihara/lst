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
from exceptions import NodeInstantiationFailed


# Brief: This is a super class that define methods common for network nodes
class Node:
    # Brief: Constructor of Node super class
    # Params:
    #   String containerName: Name of the container
    # Return:
    #   None
    def __init__(self, nodeName: str) -> None:
        self.__nodeName = nodeName
        self.__dns = "8.8.8.8"

    # Brief: Instantiate the container
    # Params:
    #   String dockerImage: Name of the container of a local image or in a Docker Hub repository
    #   String DockerCommand: String to be used to instantiate the container instead of the standard command
    # Return:
    #   None
    def instantiate(self, dockerImage="ubuntu:20.04", dockerCommand = '') -> None:
        try:    
            if dockerCommand == '':
                subprocess.run(f"docker run -d --network=none --name={self.getNodeName()} {dockerImage} tail -f /dev/null", shell=True)
                self.__enableNamespace(self.getNodeName())
            else:
                subprocess.run(dockerCommand, shell=True)
        except Exception as ex:
            logging.error(f"Error while criating the container {self.getNodeName()}: {str(ex)}")
            raise NodeInstantiationFailed(f"Error while criating the container {self.getNodeName()}: {str(ex)}")

    # Brief: Instantiate the container
    # Params:
    #   String dockerImage: Name of the container of a local image or in a Docker Hub repository
    #   String DockerCommand: String to be used to instantiate the container instead of the standard command
    # Return:
    #   None
    def delete(self) -> None:
        try:    
            subprocess.run(f"docker kill {self.getnodeName()} && docker rm {self.getnodeName()}", shell=True)
        except Exception as ex:
            logging.error(f"Error while deleting the host {self.getNodeName()}: {str(ex)}")
            raise NodeInstantiationFailed(f"Error while deleting the host {self.getNodeName()}: {str(ex)}")

    # Brief: Enable accessing the Docker node namespace directly
    # Params:
    # Return:
    #   None
    def __enableNamespace(self, nodeName) -> None:
        try:    
            subprocess.run(f"pid=$(docker inspect -f '{{{{.State.Pid}}}}' {nodeName}); mkdir -p /var/run/netns/; ln -sfT /proc/$pid/ns/net /var/run/netns/{nodeName}", shell=True)
        except Exception as ex:
            logging.error(f"Error while deleting the host {self.getNodeName()}: {str(ex)}")
            raise Exception(f"Error while deleting the host {self.getNodeName()}: {str(ex)}")


    # Brief: Returns the value of the container name
    # Params:
    #   String containerName: Name of the container
    # Return:
    #   None
    def getNodeName(self) -> str:
        return self.__nodeName
