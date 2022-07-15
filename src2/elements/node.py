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
    def __init__(self):
        pass

    def instantiate(self, containerName, dockerImage="ubuntu:20.04", dockerCommand = ''):
        try:    
            if dockerCommand == '':
                subprocess.run("docker run -d --network=none --name={containerName} {dockerImage} tail -f /dev/null")
            else:
                subprocess.run(dockerCommand)
        except Exception as ex:
            logging.error(f"Error while criating the host {containerName}: {str(ex)}")
            raise DockerImageInstantiationFailed(f"Error while criating the host {containerName}: {str(ex)}")
