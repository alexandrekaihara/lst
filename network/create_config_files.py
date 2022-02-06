from sys import argv
from json import load
from sys import exit
from os import environ, mkdir


# Brief: Class responsible for configuring all experiment setup, create docker-compose file to setup containers,
class CreateConfigurationFiles():
    def __init__(self, configfile) -> None:
        self.endl = "\n"
        self.ident = "  "
        self.composefile = "version: \"3.7\"\n\nservices:\n"
        self.network_config = "#\\bin\\bash\n\n"
        self.serverconfig = ""
        self.config_hosts_script = "#\\bin\\bash\n\n"
        self.nonclientsIP = {}
        self.subnets = set()
        self.experiment_script = self.read_json(configfile) 

    # Try open .json with all experiment configurations
    def read_json(self, filename):
        try:
            with open(filename, "r") as f:
                return load(f)
        except:
            exit("[create_config_files.py] ERROR: Error on opening ", filename, "\n Check if file exists or for any error on .json formatting\n\n")

    # Create docker-compose.yml file from .json
    def create_container_script(self, name, param):
        script = 1*self.ident + name + ":" + self.endl
        script += 2*self.ident + "image: " + param['image'] + self.endl
        script += 2*self.ident + "container_name: " + name + self.endl
        script += 2*self.ident + "restart: always" + self.endl
        script += 2*self.ident + "privileged: true" + self.endl
        script += 2*self.ident + "network_mode: none" + self.endl
        script += 2*self.ident + "dns:" + self.endl
        script += 3*self.ident + "- " + param['dns'] + self.endl
        dep = param['depends_on']
        # If it has a dependency, add all of them
        if len(dep) > 0:
            script += 2*self.ident + "depends_on:" + self.endl
            for i in range(len(dep)):
                script += 3*self.ident + "- " + dep[i] + self.endl
        self.composefile += script

    # Iterates over dictionaries on .json file to create a docker-compose
    def run_compose(self, filename):
        [self.create_container_script(name, params) for name, params in self.experiment_script.items() if name != environ["SEAFILE"]]
        with(open(filename, "w")) as f:
            f.write(self.composefile)  

    # Create the config file containing all the server IPs
    def create_serverconfig_script(self, filename):
        # Selecting IP by its subnet and its docker image
        for _, params in self.experiment_script.items():
            # If is a Linuxclient image
            if params['image'] == environ['REPOSITORY']+':'+environ['LCLIENT']:
                self.subnets.add(params['IP'].split('.')[2])
            # If is not a Linuxclient image
            else:
                subnet = params['IP'].split('.')[2]
                if subnet not in self.nonclientsIP.keys():
                    self.nonclientsIP[subnet] = {}
                self.nonclientsIP[subnet][params['image']] = params['IP']

        # Generating all script
        self.serverconfig = "[backup]\nip = " + self.nonclientsIP[environ['SSUBNET']][environ['REPOSITORY']+':'+environ["BACKUP"]] + 2*self.endl
        for subnet in self.subnets:
            self.serverconfig += '[' + subnet + ']' + self.endl
            if subnet != "50":
                self.serverconfig += 'print = '   + self.nonclientsIP[subnet][environ['REPOSITORY']+':'+environ["PRINTER"]] + self.endl
                self.serverconfig += 'mail = '    + self.nonclientsIP[environ['SSUBNET']][environ['REPOSITORY']+':'+environ["MAILSERVER"]] + self.endl
                self.serverconfig += 'file = '    + self.nonclientsIP[environ['SSUBNET']][environ['REPOSITORY']+':'+environ["FILE"]] + self.endl
                self.serverconfig += 'web = '     + self.nonclientsIP[environ['SSUBNET']][environ['REPOSITORY']+':'+environ["WEB"]] + self.endl
            else:
                self.serverconfig += 'web = '     + self.nonclientsIP[environ['ESUBNET']][environ['REPOSITORY']+':'+environ["WEB"]] + self.endl
            self.serverconfig += 'seafile = ' + self.nonclientsIP[environ['ESUBNET'] ][environ['REPOSITORY']+':'+environ["SEAFILE"]] + self.endl
            self.serverconfig += 'seafolder = '  + environ['SEAFOLDER'] + 2*self.endl
        
        # Saving script
        with(open(filename, "w")) as f:
            f.write(self.serverconfig)  
    
    # Generate the file that calls configure_host (on confghosts.sh) with its all configurations
    def config_hosts(self, filename):
        # Create files with the printer's IP of the subnet
        try:
            mkdir('printersip')
        except:
            pass
        for subnet in self.subnets:
            try:
                printerip = self.nonclientsIP[subnet][environ['REPOSITORY']+':'+environ['PRINTER']]
            except:
                printerip = "0.0.0.0"
            with open("printersip/"+str(subnet), 'w') as f:
                f.write(printerip)

        # For each container described on the .json file
        for name, params in self.experiment_script.items():
            if params['image'] != environ['REPOSITORY']+':'+environ['SEAFILE']:
                # If is a Linuxclient image
                subnet = params['IP'].split('.')[2]
                hostip = params['IP'].split('.')[3]
                bridge = params['bridge']   
                # If the container is a Linuxclient, then add the filename behaviour parameter
                if params['image'] == environ['REPOSITORY']+':'+environ['LCLIENT']:
                    behaviour = params['client_behaviour']
                    self.config_hosts_script += "configure_host " + name + " " + subnet + " " + hostip + " " + bridge + " " + behaviour + self.endl
                # Do not insert the behaviour parameter
                else:
                    self.config_hosts_script += "configure_host " + name + " " + subnet + " " + hostip + " " + bridge + self.endl
                self.config_hosts_script += "echo \"Configuring " + name + "\"" + self.endl 

        # Saving script
        with(open(filename, "w")) as f:
            f.write(self.config_hosts_script)  


def main():
    try:
        argv[1]
    except:
        exit("[create_config_files.py] ERROR: Expected command line argument. Must provide the file path to the .json for experiment")
    
    c = CreateConfigurationFiles(argv[1])
    c.run_compose("docker-compose.yml")
    c.create_serverconfig_script("serverconfig.ini")
    c.config_hosts("config_all_hosts.sh")


if __name__ == "__main__":
    main()