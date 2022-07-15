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


class Switch():
    def __init__(self):
        self.ip = self.set_ip()
        self.geteway = self.set_gateway()
        self.controller_port = self.set_controller_port()
        self.controller_ip = self.set_controller_ip()

    # Brief: Set the ip parameter if exists
    # Params:
    #   Dict object: A link object
    # Return:
    #   Returns the value of the ip if exists, otherwise, returns none
    def set_ip(self, object):
        pass

    # Brief: Returns the value of gateway
    # Params:
    # Return:
    #   Returns the value of the gateway
    def set_gateway(self):
        return self._gateway

    # Brief: Returns the controller_port
    # Params:
    # Return:
    #   Return the value of the controller_port
    def set_controller_port(self):
        pass

    # Brief: Set the controller_ip parameter if exists
    # Params:
    #   Dict object: A link object
    # Return:
    #   Returns the value of the controller_ip if exists, otherwise, returns none
    def set_controller_ip(self, object):
        pass

    # Brief: Returns the value of ip
    # Params:
    # Return:
    #   Returns the value of the ip
    def get_ip(self):
        return self._ip
    
    # Brief: Returns the value of gateway
    # Params:
    # Return:
    #   Returns the value of the gateway
    def get_gateway(self):
        return self._gateway
    
    # Brief: Returns the value of controller_port
    # Params:
    # Return:
    #   Returns the value of the controller_port
    def get_controller_port(self):
        return self._controller_port
    
    # Brief: Returns the value of controller_ip
    # Params:
    # Return:
    #   Returns the value of the controller_ip
    def get_controller_ip(self):
        return self._controller_ip
    
    