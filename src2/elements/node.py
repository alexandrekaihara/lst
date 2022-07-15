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
from exceptions import DockerImageInstantiationFailed


# Brief: This is a super class that define methods common for network nodes
class Node:
    # Brief: Constructor of Node super class
    # Params:
    #   String containerName: Name of the container
    # Return:
    #   None
    def __init__(self, containerName: str) -> None:
        self.__containerName = containerName

    # Brief: Instantiate the container
    # Params:
    #   String dockerImage: Name of the container of a local image or in a Docker Hub repository
    #   String DockerCommand: String to be used to instantiate the container instead of the standard command
    # Return:
    #   None
    def instantiate(self, dockerImage="ubuntu:20.04", dockerCommand = '') -> None:
        try:    
            if dockerCommand == '':
                subprocess.run(f"docker run -d --network=none --name={self.__containerName} {dockerImage} tail -f /dev/null", shell=True)
            else:
                subprocess.run(dockerCommand, shell=True)
        except Exception as ex:
            logging.error(f"Error while criating the host {self.__containerName}: {str(ex)}")
            raise DockerImageInstantiationFailed(f"Error while criating the host {self.__containerName}: {str(ex)}")

    # Brief: Instantiate the container
    # Params:
    #   String dockerImage: Name of the container of a local image or in a Docker Hub repository
    #   String DockerCommand: String to be used to instantiate the container instead of the standard command
    # Return:
    #   None
    def delete(self):
        try:    
            subprocess.run(f"docker kill {self.getContainerName()} && docker rm {self.getContainerName()}", shell=True)
        except Exception as ex:
            logging.error(f"Error while deleting the host {self.__containerName}: {str(ex)}")
            raise DockerImageInstantiationFailed(f"Error while deleting the host {self.__containerName}: {str(ex)}")

    # Brief: Returns the value of the container name
    # Params:
    #   String containerName: Name of the container
    # Return:
    #   None
    def getContainerName(self):
        return self.__containerName