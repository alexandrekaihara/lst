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


# Brief: This class 
class Host():
    def __init__(self, commandlinehelper):
        self._IP = self.set_ip()
        self._IMAGE = self.set_image()
        self._GATEWAY = self.set_gateway()
        self._DNS = self.set_dns()
        self.depends_on = self.set_depends_on()
        self.copy_file = self.set_copy_file()
        self.run = self.set_run()

        self.ip = self.set_ip()
        self.image = self.set_image()
        self.gateway = self.set_gateway()
        self.dns = self.set_dns()
        self.depends_on = self.set_depends_on()
        self.copy_file = self.set_copy_file()
        self.run = self.set_run()

    # Brief: Set the ip parameter if exists
    # Params:
    #   Dict object: A link object
    # Return:
    #   Returns the value of the ip if exists, otherwise, returns none
    def set_ip(self, object):
        pass

    # Brief: Set the image parameter if exists
    # Params:
    #   Dict object: A link object
    # Return:
    #   Returns the value of the image if exists, otherwise, returns none
    def set_image(self, object):
        pass

    # Brief: Set the gateway parameter if exists
    # Params:
    #   Dict object: A link object
    # Return:
    #   Returns the value of the gateway if exists, otherwise, returns none
    def set_gateway(self, object):
        pass

    # Brief: Set the dns parameter if exists
    # Params:
    #   Dict object: A link object
    # Return:
    #   Returns the value of the dns if exists, otherwise, returns none
    def set_dns(self, object):
        pass

    # Brief: Set the depends_on parameter if exists
    # Params:
    #   Dict object: A link object
    # Return:
    #   Returns the value of the depends_on if exists, otherwise, returns none
    def set_depends_on(self, object):
        pass

    # Brief: Set the copy_file parameter if exists
    # Params:
    #   Dict object: A link object
    # Return:
    #   Returns the value of the copy_file if exists, otherwise, returns none
    def set_copy_file(self, object):
        pass

    # Brief: Set the run parameter if exists
    # Params:
    #   Dict object: A link object
    # Return:
    #   Returns the value of the run if exists, otherwise, returns none
    def set_run(self, object):
        pass

    # Brief: Returns the value of ip
    # Params:
    # Return:
    #   Returns the value of the ip
    def get_ip(self):
        return self._ip

    # Brief: Returns the value of image
    # Params:
    # Return:
    #   Returns the value of the image
    def get_image(self):
        return self._image
        
    # Brief: Returns the value of gateway
    # Params:
    # Return:
    #   Returns the value of the gateway
    def get_gateway(self):
        return self._gateway
        
    # Brief: Returns the value of dns
    # Params:
    # Return:
    #   Returns the value of the dns
    def get_dns(self):
        return self._dns
        
    # Brief: Returns the value of depends_on
    # Params:
    # Return:
    #   Returns the value of the depends_on
    def get_depends_on(self):
        return self._depends_on
        
    # Brief: Returns the value of copy_file
    # Params:
    # Return:
    #   Returns the value of the copy_file
    def get_copy_file(self):
        return self._copy_file
        
    # Brief: Returns the value of run
    # Params:
    # Return:
    #   Returns the value of the run
    def get_run(self):
        return self._run