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

from sys import argv
from exceptions import InvalidCommandLineInput
from datetime import datetime
from executor import Executor
from systemresponse import SystemResponse
from commandlineinterpreter import CommandLineInterpreter


def main():
    # (IMPLEMENT) Add system configuration from file

    try:
        cli = CommandLineInterpreter()

        # If is help, show help instructions and end execution
        if cli.is_help(argv):
            cli.display_help()
            return 0

        # Set logging configuration 
        ## The default logging configuration is INFO
        level = logging.INFO
        if cli.is_log(argv):
            val = cli.get_log_value(argv)
            level = cli.get_logging_level_value(val)
        logname = "systemlogs/" +  datetime.now().strftime("%d-%m-%Y_%H-%M-%S") + ".log"
        format = "[%(asctime)s] %(levelname)s - %(message)s (%(filename)s %(funcName)s:%(lineno)d)"
        logging.basicConfig(filename=logname, filemode='w', level=level, format=format)
        
        # Execute project
        json_path = cli.get_json_path(argv)
        executor = Executor()
        executor.run(json_path)
    except InvalidCommandLineInput as ex:
        print(str(ex) + "\n")
        print("Use --help for more information")


if __name__ == "__main__":
    main()