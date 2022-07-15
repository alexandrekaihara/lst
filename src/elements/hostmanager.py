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


# Brief: This class 
class HostManager(Node):
    def __init__(self, commandlinehelper):
        self.commandlinehelper = commandlinehelper

    # Brief: Copy a local file into the Docker container
    # Params:
    #   String host_name: Name of the host to copy the file
    #   String file_path: Path to the file
    #   String dest_path: Path to where the file will be copied
    # Return:
    #   Returns bool of the status of the operation (if success returns true, else returns false)
    def copy_file(self, host_name, file_path, dest_path):
        pass

    # Brief: Executes a command to execute on command line inside a container
    # Params:
    #   String container_name: Name of the conteiner in which will be executed the command
    #   String command: String containing a command to execute inside a container
    #   String command: List of commands to execute inside a container
    # Return:
    #   None
    def run(self, container_name,  command = "", commands = []):
        pass

    # Brief: Executes a bash script
    # Params:
    #   String filename: Path to the bash script
    # Return:
    #   None
    def run(self, container_name, filename):
        pass

    # create firewall methods