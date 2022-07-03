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


from exceptions import Invalid


# Brief: This class is responsible to configure the controllers of the experiment
class Controller():
    def __init__(self, commandlinehelper):
        self.commandlinehelper = commandlinehelper

        # Acceptable parameters
        self.ip = 0
        self.image = 0
        self.port = 0
        self.copy_file = 0
        self.instantiate = 0
        self.run = 0

        # Controller type parameters' names
        self._IP = "IP"
        self._IMAGE = "image"
        self._PORT = "port"
        self._COPY_FILE = "copy_file"
        self._INSTANTIATE = "instantiate"
        self._RUN = "run"    

    # Brief: Instantiate controller on localhost
    # Params:
    #   String ip: IP of the controller on format "xxx.xxx.xxx.xxx"
    #   int port: Number of the port in which the controller will be listening to
    #   String command: A single command to be executed on terminal
    #   List<String> commands: List of commands to be executed on terminal
    # Return:
    #   Returns bool of the status of the operation (if success returns true, else returns false)
    def instantiate_localhost(self, ip, port, command = "", commands = []):
        pass

    # Brief: Instantiate controller on container
    # Params:
    #   String container_name: Name of the container to instantiate the controller
    #   String ip: IP of the controller on format "xxx.xxx.xxx.xxx"
    #   int port: Number of the port in which the controller will be listening to
    #   String command: A single command to be executed on terminal
    #   List<String> commands: List of commands to be executed on terminal
    # Return:
    #   Returns bool of the status of the operation (if success returns true, else returns false)
    def instantiate_container(self, container_name, ip, port, command = "", commands = []):
        pass

    # Brief: Copy a local file into the Docker container
    # Params:
    #   String host_name: Name of the host to copy the file
    #   String file_path: Path to the file
    #   String dest_path: Path to where the file will be copied
    # Return:
    #   Returns bool of the status of the operation (if success returns true, else returns false)
    def copy_file(self, host_name, file_path, dest_path):
        pass

    # Brief: Runs commands inside the container
    # Params:
    #   String container_name: Name of the container to instantiate the controller
    #   String command: A single command to be executed on terminal
    #   List<String> commands: List of commands to be executed on terminal
    # Return:
    #   Returns bool of the status of the operation (if success returns true, else returns false)
    def run(self, container_name, command = "", commands = []):
        pass

    # Brief: Verifies if the controller is to be instantiated on localhost
    # Params:
    #   Dict element: Controller element
    #   String command: A single command to be executed on terminal
    #   List<String> commands: List of commands to be executed on terminal
    # Return:
    #   Returns bool of the status of the operation (if success returns true, else returns false)
    def is_localhost(self, element):
        pass

    
    # Brief: Gets the ip from a controller object
    # Params:
    #   String name: Name of the object
    #   Dict controller: Controller object
    # Return:
    #   Returns the parameter IP reference
    def get_ip(self, name, controller):
        try:
            return controller[self._IP]
        except:
            raise MissingObjectParameter("Couldn't find IP parameter")

        
        # Controller type parameters' names
        self.IP = "IP"
        self.IMAGE = "image"
        self.PORT = "port"
        self.COPY_FILE = "copy_file"
        self.INSTANTIATE = "instantiate"
        self.RUN = "run"    



