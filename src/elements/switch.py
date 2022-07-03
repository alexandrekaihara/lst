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


class Switch(Node):
    def __init__(self, commandlinehelper):
        self.commandlinehelper = commandlinehelper

    # Brief: Creates a new Open vSwitch
    # Params:
    #   String name: Name of the new switch
    # Return:
    #   Returns bool of the status of the operation (if success returns true, else returns false)
    def create(self, name):
        pass

    # Brief: Configure Open vSwitch switch to connect to a controller on a given IP and port
    # Params:
    #   String switch_name: Name of the switch to configure the gateway
    #   String controller_ip: IP of the controller on format "xxx.xxx.xxx.xxx"
    #   int controller_port: Number of the port the controller is listening to
    # Return:
    #   Returns bool of the status of the operation (if success returns true, else returns false)
    def configure_controller(self, switch_name, controller_ip, controller_port):
        pass

    # create firewall