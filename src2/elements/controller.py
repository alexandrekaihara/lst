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


from exceptions import MissingObjectParameter
import logging


# Brief: This class is responsible to configure the controllers of the experiment
class Controller():
    def __init__(self, object, name):
        # Controller type parameters' names
        self._IP = "controller_ip"
        self._IMAGE = "image"
        self._PORT = "controller_port"
        self._COPY_FILE = "copy_file"
        self._INSTANTIATE = "instantiate"
        self._RUN = "run"    

        self._ip = self._set_ip(object, name)
        self._image = self._set_image(object, name)
        self._port = self._set_port(object, name)
        self._copy_file = self._set_copy_file(object, name)
        self._instantiate = self._set_instantiate(object, name)
        self._run = self._set_run(object, name)

    
    # Brief: Set the ip parameter if exists
    # Params:
    #   Dict object: A link object
    # Return:
    #   Returns the value of the ip if exists, otherwise, returns none
    def _set_ip(self, object, name):
        try:
            self._ip = object[self._IP]
        except:
            logging.error(f'The object {name} is missing the {self._IP} parameter definition')
            raise MissingObjectParameter(f'The object {name} is missing the {self._IP} parameter definition')
    
    # Brief: Set the image parameter if exists
    # Params:
    #   Dict object: A link object
    # Return:
    #   Returns the value of the image if exists, otherwise, returns none
    def _set_image(self, object, name):
        try:
            self._image = object[self._IMAGE]
        except:
            pass
    
    # Brief: Set the port parameter if exists
    # Params:
    #   Dict object: A link object
    # Return:
    #   Returns the value of the port if exists, otherwise, returns none
    def _set_port(self, object, name):
        try:
            self._port = object[self._PORT]
        except:
            logging.error(f'The object {name} is missing the {self._PORT} parameter definition')
            raise MissingObjectParameter(f'The object {name} is missing the {self._PORT} parameter definition')
    
    # Brief: Set the copy_file parameter if exists
    # Params:
    #   Dict object: A link object
    # Return:
    #   Returns the value of the copy_file if exists, otherwise, returns none
    def _set_copy_file(self, object, name):
        try:
            self._copy_file = object[self._COPY_FILE]
        except:
            pass

    # Brief: Set the instantiate parameter if exists
    # Params:
    #   Dict object: A link object
    # Return:
    #   Returns the value of the instantiate if exists, otherwise, returns none
    def _set_instantiate(self, object, name):
        try:
            self._instantiate = object[self._INSTANTIATE]
        except:
            logging.error(f'The object {name} is missing the {self._INSTANTIATE} parameter definition')
            raise MissingObjectParameter(f'The object {name} is missing the {self._INSTANTIATE} parameter definition')
    
    # Brief: Set the run parameter if exists
    # Params:
    #   Dict object: A link object
    # Return:
    #   Returns the value of the run if exists, otherwise, returns none
    def _set_run(self, object, name):
        try:
            self._run = object[self._RUN]
        except:
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

    # Brief: Returns the value of port
    # Params:
    # Return:
    #   Returns the value of the port
    def get_port(self):
        return self._port

    # Brief: Returns the value of copy_file
    # Params:
    # Return:
    #   Returns the value of the copy_file
    def get_copy_file(self):
        return self._copy_file

    # Brief: Returns the value of instantiate
    # Params:
    # Return:
    #   Returns the value of the instantiate
    def get_instantiate(self):
        return self._instantiate

    # Brief: Returns the value of run
    # Params:
    # Return:
    #   Returns the value of the run
    def get_run(self):
        return self._run
