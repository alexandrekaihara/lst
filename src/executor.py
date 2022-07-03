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
from filehandler import FileHandler
from systemresponse import SystemResponse
from elements.link import Link
from elements.host import Host
from elements.switch import Switch
from elements.controller import Controller
from commandlinehelper import CommandLineHelper


# Brief: Class responsible to execute the experiment from a given json file
class Executor():
    def __init__(self):
        self.filehandler = FileHandler()
        self.systemresponse = SystemResponse()
        self.commandlinehelper = CommandLineHelper(self.systemresponse)
        self.host = Host(self.commandlinehelper)
        self.link = Link(self.commandlinehelper)
        self.switch = Switch(self.commandlinehelper)
        self.controller = Controller(self.commandlinehelper)
        
    # Brief: Create all experiment 
    # Params:
    #   String path: Absolute or relative path to the JSON file
    # Return:
    #   None
    def run(self, path):
        logging.info("Starting experiment")
        json = self.filehandler.read_json(path)

        #switches = self.get_switches(json)
        #hosts = self.get_hosts(json)
        #links = self.get_links(json)
        logging.info("Finished experiment setup")
        
    # Brief: Instantiate all controllers
    # Params:
    #   Dict json: JSON object containing all elements of the experiment
    # Return:
    #   None
    def instantiate_controllers(self, json):
        controllers = self.get_controllers(json)
        if len(controllers) > 0:
            for name, obj in controllers.items():
                if self.controller.is_localhost(obj):
                    ip = self.controller.get_ip(name, obj)

                    self.controller.instantiate_localhost(name, obj)


    # Brief: Returns a list of controllers elements of the json file
    # Params:
    #   Dict json: JSON object
    # Return:
    #   Returns a list of controller elements inside the json object
    def get_controllers(self, json):
        return []

    # Brief: Returns a list of switches elements of the json file
    # Params:
    #   Dict json: JSON object
    # Return:
    #   Returns a list of switch elements inside the json object
    def get_switches(self, json):
        pass

    # Brief: Returns a list of hosts elements of the json file
    # Params:
    #   Dict json: JSON object
    # Return:
    #   Returns a list of host elements inside the json object
    def get_hosts(self, json):
        pass

    # Brief: Returns a list of links elements of the json file
    # Params:
    #   Dict json: JSON object
    # Return:
    #   Returns a list of link elements inside the json object
    def get_links(self, json):
        pass