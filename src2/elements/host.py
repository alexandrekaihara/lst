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


from elements.node import Node


# Brief: This class is responsible for create, deleting and configuring a host
class Host(Node):
    # Brief: Set the peer1 parameter if exists
    # Params:
    #   String dockerImage: Is the name of the docker image to be instantiated
    #   String dockerCommand: Optional parameter to define the command to be used to instantiate the container instead of the deafult value
    # Return:
    #   None
    def __init__(self, containerName):
        self._containerName = containerName

    def getContainerName(self):
        return self._containerName

