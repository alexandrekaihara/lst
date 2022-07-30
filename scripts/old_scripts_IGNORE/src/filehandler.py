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
from json import load
from exceptions import InvalidCommandLineInput


# Brief: Class responsible to open and read files
class FileHandler():
    # Brief: Try open JSON with all experiment configurations
    # Params:
    #   String filename: Absolute or relative path to the JSON file
    # Return:
    #   Returns the JSON object
    def read_json(self, filename):
        try:
            logging.info(f"Reading and loading {filename}")
            with open(filename, "r") as f:
                return load(f)
        except Exception as ex:
            logging.error(f"Error on loading the {filename} JSON file with error: \"{str(ex)}\"")
            raise InvalidCommandLineInput(f"Error on loading the {filename} JSON file with error: \"{str(ex)}\"")
