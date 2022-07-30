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


from commandlinehelper import CommandLineHelper


class LinkManager():
    def __init__(self, commandlinehelper):
        self.commandlinehelper = commandlinehelper

    # Brief: Creates a network link
    # Params:
    #   String interface1_name: Name of the first interface
    #   String interface2_name: Name of the second interface
    # Return:
    #   Returns bool of the status of the operation (if success returns true, else returns false)
    def create(self, interface1_name, interface2_name):
        pass

    # Brief: Set a interface into a network node
    # Params:
    #   String interface_name: Name of the interface to connect
    #   String interface_type: Name of the type of the network host to set the interface
    # Return:
    #   Returns bool of the status of the operation (if success returns true, else returns false)
    def set_interface(self, interface_name, interface_type):
        pass

    # Brief: Set ip to an interface of a network node
    # Params:
    #   String interface_name: Name of the interface to connect
    #   String ip: IP of the controller on format "xxx.xxx.xxx.xxx"
    #   int mask: Integer corresponding to the network mask (1-32)
    # Return:
    #   Returns bool of the status of the operation (if success returns true, else returns false)
    def set_ip_interface(self, interface_name, ip, mask):
        pass

    # Brief: Convert an integer (1-32) into string on format "xxx.xxx.xxx.xxx"
    # Params:
    #   String interface_name: Name of the interface to connect
    #   String ip: IP of the controller on format "xxx.xxx.xxx.xxx"
    #   int mask: Integer corresponding to the network mask (1-32) 
    # Return:
    #   Returns the network mask string of the correponding integer
    def _convert_net_mask(mask):
        pass

    