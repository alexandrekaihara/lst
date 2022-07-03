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
from exceptions import InvalidCommandLineInput
from systemresponse import SystemResponse


# Brief: This class is responsible for interpret the command line inputs
class CommandLineInterpreter():
    def __init__(self):
        self.systemresponse = SystemResponse()

        # Acceptable parameters
        self._REPORT = "--r"
        self._LOG = "--log"  
        self._HELP = "--help"

        # Possible --log values
        self._LOG_DEBUG = "DEBUG"
        self._LOG_INFO = "INFO"
        self._LOG_WARNING = "WARNING"
        self._LOG_ERROR = "ERROR"
        self._LOG_CRITICAL = "CRITICAL"

    # Brief: Verifies if there is an option to set the level of the logging
    # Params:
    #   List<String> argv: List of parameters received
    # Return:
    #   Returns true if self._LOG is found in one parameter
    def is_log(self, argv):
        for arg in argv:
            if self._LOG in arg:
                return True
        return False

    # Brief: Verifies if there is an option to set the level of the logging
    # Params:
    #   List<String> argv: List of parameters received
    # Return:
    #   Returns true if self._LOG is found in one parameter
    def is_log(self, argv):
        for arg in argv:
            if self._LOG in arg:
                return True
        return False

    # Brief: Verifies if was set an help option
    # Params:
    #   List<String> argv: List of parameters received
    # Return:
    #   Returns true if self._HELP is found in one parameter
    def is_help(self, argv):
        pass

    # Brief: Verifies if was set an help option
    # Params:
    #   List<String> argv: List of parameters received
    # Return:
    #   Returns true if self._HELP is found in one parameter
    def display_help():
        pass

    # Brief: Gets the value of the of the self._LOG received
    # Params:
    #   List<String> argv: List of parameters received
    # Return:
    #   Returns the string of the value received on self._LOG
    def get_log_value(self, argv):
        pass

    # Brief: Converts the input of self._LOG string value into logging level values
    # Params:
    #   String log_level: self._LOG 
    # Return:
    #   Returns the string of the value received on self._LOG
    def get_logging_level_value(self, log_level):
        if log_level == self._LOG_DEBUG:
            return logging.DEBUG
        elif log_level == self._LOG_INFO:
            return logging.INFO
        elif log_level == self._LOG_WARNING:
            return logging.WARNING
        elif log_level == self._LOG_ERROR:
            return logging.ERROR
        elif log_level == self._LOG_CRITICAL:
            return logging.CRITICAL

    # Brief: Gets the JSON filename inside the argv 
    # Params:
    #   List<String> argv: List of strings of the command line input
    # Return:
    #   Returns the JSON filename
    def get_json_path(self, argv):
        json_path = [arg for arg in argv if ".json" in arg]
        if len(json_path) != 1:
            raise InvalidCommandLineInput("No .json file provided")
        else:
            return json_path[0]
