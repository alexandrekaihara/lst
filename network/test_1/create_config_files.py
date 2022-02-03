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
        self.move_config_files = "#\\bin\\bash\n\n"
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
        if len(dep) > 0:
            script += 2*self.ident + "depends_on:" + self.endl
            for i in range(len(dep)):
                script += 3*self.ident + "- " + dep[i] + self.endl
        self.composefile += script

    def run_compose(self, filename):
        [self.create_container_script(name, params) for name, params in self.experiment_script.items() if name != environ["SEAFILE"]]
        with(open(filename, "w")) as f:
            f.write(self.composefile)  
    
    def create_network_config_script(self, name, params):
        ip = params['IP'].split('.')
        subnet = ip[2]
        hostip = ip[3]
        bridge = params['bridge']
        self.network_config += "configure_host " + name + " " + subnet + " " + hostip + " " + bridge + self.endl        

    def run_network_config(self, network_config_filename):
        [self.create_network_config_script(name, params) for name, params in self.experiment_script.items()]
        with(open(network_config_filename, "w")) as f:
            f.write(self.network_config)  

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
        self.serverconfig = "[backup]\nip = " + self.nonclientsIP["100"][environ['REPOSITORY']+':'+environ["BACKUP"]] + 2*self.endl
        for subnet in self.subnets:
            self.serverconfig += '[' + subnet + ']' + self.endl
            if subnet != "50":
                self.serverconfig += 'print = '   + self.nonclientsIP[subnet][environ['REPOSITORY']+':'+environ["PRINTER"]] + self.endl
                self.serverconfig += 'mail = '    + self.nonclientsIP["100" ][environ['REPOSITORY']+':'+environ["MAILSERVER"]] + self.endl
                self.serverconfig += 'file = '    + self.nonclientsIP["100" ][environ['REPOSITORY']+':'+environ["FILE"]] + self.endl
                self.serverconfig += 'web = '     + self.nonclientsIP["100" ][environ['REPOSITORY']+':'+environ["WEB"]] + self.endl
            else:
                self.serverconfig += 'web = '     + self.nonclientsIP["50" ][environ['REPOSITORY']+':'+environ["WEB"]] + self.endl
            self.serverconfig += 'seafile = ' + self.nonclientsIP["50"  ][environ['REPOSITORY']+':'+environ["SEAFILE"]] + self.endl
            self.serverconfig += 'seafolder = '  + environ['SEAFOLDER'] + 2*self.endl
        
        # Saving script
        with(open(filename, "w")) as f:
            f.write(self.serverconfig)  
    
    def move_configurations_files_to_containers(self, filename):
        # Create files with the printer's IP of the subnet
        mkdir('printersip')
        for subnet in self.subnets:
            try:
                printerip = self.nonclientsIP[subnet][environ['REPOSITORY']:environ['PRINTER']]
            except:
                printerip = "0.0.0.0"
            with open(str(subnet), 'w') as f:
                f.write("printersip/" + printerip)

        for name, params in self.experiment_script.items():
            # If is a Linuxclient image
            if params['image'] == environ['REPOSITORY']+':'+environ['LCLIENT']:
                subnet = params['IP'].split('.')[2]
                behaviour = params['client_behaviour']
                self.move_config_files += "move_configs " + name + " " + subnet + " " + behaviour + self.endl

        # Saving script
        with(open(filename, "w")) as f:
            f.write(self.serverconfig)  


def main():
    try:
        argv[1]
    except:
        exit("[create_config_files.py] ERROR: Expected command line argument. Must provide the file path to the .json for experiment")
    
    c = CreateConfigurationFiles(argv[1])
    c.run_compose("docker-compose.yml")
    c.run_network_config("configure_hosts.sh")
    c.create_serverconfig_script("serverconfig.ini")
    c.move_configurations_files_to_containers("move_all_config_files.sh")


if __name__ == "__main__":
    main()