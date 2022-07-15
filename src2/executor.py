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
from exceptions import MissingObjectParameter
from elements.host import Host
from elements.link import Link
from elements.switch import Switch
from elements.controller import Controller
from elements.linkmanager import LinkManager
from elements.hostmanager import HostManager
from elements.switchmanager import SwitchManager
from elements.controllermanager import ControllerManager
from commandlinehelper import CommandLineHelper



# Brief: Class responsible to execute the experiment from a given json file
class Executor():
    def __init__(self):
        self.filehandler = FileHandler()
        self.systemresponse = SystemResponse()
        self.commandlinehelper = CommandLineHelper(self.systemresponse)
        self.hostmanager = HostManager(self.commandlinehelper)
        self.linkmanager = LinkManager(self.commandlinehelper)
        self.switchmanager = SwitchManager(self.commandlinehelper)
        self.controllermanager = ControllerManager(self.commandlinehelper)
        
        # Holds the element objects by each
        self.controllers = {}
        self.switches = {}
        self.hosts = {}
        self.links = {}

        self._TYPE = "type"
        self._HOST = "host"
        self._CONTROLLER = "controller"
        self._SWITCH = "switch"
        self._LINK = "link"

    # Brief: Create all experiment 
    # Params:
    #   String path: Absolute or relative path to the JSON file
    # Return:
    #   None
    def run(self, path):
        logging.info("Starting experiment")
        json = self.filehandler.read_json(path)

        # Load the json object into element objects
        logging.info("Loading the json objects into classes")
        self.load_controllers_objects(json)
        self.load_hosts_objects(json)
        self.load_switches_objects(json)
        self.load_links_objects(json)

        # Instantiate the controllers
        logging.info("Intantiating the controllers")
        #self.instantiate_controllers()

        print(self.controllers)

        logging.info("Finished experiment setup")

    # Brief: Instantiate all controllers
    # Params:
    #   Dict json: JSON object containing all elements of the experiment
    # Return:
    #   None
    def instantiate_controllers(self, json):
        objcontrollers = self.get_controllers(json)
        
    # Brief: Create instances of the class Controller
    # Params:
    #   Dict json: JSON object containing all elements of the experiment
    # Return:
    #   None
    def load_controllers_objects(self, json):
        objcontrollers = self.get_controllers(json)
        def create(name, controller):
            self.controllers[name] = Controller(controller, name)
        [create(name, controller) for name, controller in objcontrollers.items()]
            
        
    # Brief: Create instances of the class Host
    # Params:
    #   Dict json: JSON object containing all elements of the experiment
    # Return:
    #   None
    def load_hosts_objects(self, json):
        objhosts = self.get_hosts(json)
        def create(name, host):
            self.hosts[name] = Host(host, name)
        [create(name, host) for name, host in objhosts.items()]
                    
    # Brief: Create instances of the class Switch
    # Params:
    #   Dict json: JSON object containing all elements of the experiment
    # Return:
    #   None
    def load_switches_objects(self, json):
        objswitches = self.get_switches(json)
        def create(name, switch):
            self.switches[name] = Switch(switch, name)
        [create(name, switch) for name, switch in objswitches.items()]
                    
    # Brief: Create instances of the class Link
    # Params:
    #   Dict json: JSON object containing all elements of the experiment
    # Return:
    #   None
    def load_links_objects(self, json):
        objlinks = self.get_links(json)
        def create(name, link):
            self.links[name] = Link(link, name)
        [create(name, link) for name, link in objlinks.items()]

    # Brief: Returns a list of controllers elements of the json file
    # Params:
    #   Dict json: JSON object
    # Return:
    #   Returns a list of controller elements inside the json object
    def get_controllers(self, json):
        ret = {}
        def set_dict(name, value):
            ret[name] = value
        [set_dict(name, value) for name, value in json.items() if self.get_element_type(value, name) == self._CONTROLLER]
        return ret

    # Brief: Returns a list of switches elements of the json file
    # Params:
    #   Dict json: JSON object
    # Return:
    #   Returns a list of switch elements inside the json object
    def get_switches(self, json):
        ret = {}
        def set_dict(name, value):
            ret[name] = value
        [set_dict(name, value) for name, value in json.items() if self.get_element_type(value, name) == self._SWITCH]
        return ret

    # Brief: Returns a list of hosts elements of the json file
    # Params:
    #   Dict json: JSON object
    # Return:
    #   Returns a list of host elements inside the json object
    def get_hosts(self, json):
        ret = {}
        def set_dict(name, value):
            ret[name] = value
        [set_dict(name, value) for name, value in json.items() if self.get_element_type(value, name) == self._HOST]
        return ret

    # Brief: Returns a list of links elements of the json file
    # Params:
    #   Dict json: JSON object
    # Return:
    #   Returns a list of link elements inside the json object
    def get_links(self, json):
        ret = {}
        def set_dict(name, value):
            ret[name] = value
        [set_dict(name, value) for name, value in json.items() if self.get_element_type(value, name) == self._LINK]
        return ret

    def get_element_type(self, element, name):
        try: 
            return element[self._TYPE]
        except:
            logging.error(f"Couldn't find parameter {self._TYPE} on {name}")
            raise MissingObjectParameter(f"Couldn't find parameter {self._TYPE} on {name}")
