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


# Brief: This is a super class that define methods common for network nodes
class Node:
    def __init__(self):
        pass

    # Brief: Configure the gateway of the node
    # Params:
    #   String name: Name of the node to configure the gateway
    #   String ip: IP address of the gateway on format "xxx.xxx.xxx.xxx"
    #   String interface_name: Name of the interface to reach the gateway
    # Return:
    #   Returns bool of the status of the operation (if success returns true, else returns false)
    def configure_gateway(self, name, ip, interface_name):
        pass

    # Brief: Enables forwarding packets inside a network node 
    # Params:
    #   String name: Name of the node to configure the gateway
    #   String interface_name: Name of the interface to reach the gateway
    # Return:
    #   Returns bool of the status of the operation (if success returns true, else returns false)
    def enable_packet_forwarding(self, name, interface_name):
        pass

        