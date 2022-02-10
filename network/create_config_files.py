from logging.config import listen
from sys import argv
from json import load
from sys import exit
from os import environ, mkdir, getcwdb
from threading import local
from venv import create


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
        self.ssh_config = "[ssh]\n"

    # Try open .json with all experiment configurations
    def read_json(self, filename):
        try:
            with open(filename, "r") as f:
                return load(f)
        except:
            exit("[create_config_files.py] ERROR: Error on opening ", filename, "\n Check if file exists or for any error on .json formatting\n\n")

    # Create docker-compose.yml file from .json
    def create_container_script(self, name, param):
        def add_line(ident_level, string):
            return ident_level*self.ident + string + self.endl
        script = add_line(1, name + ":")
        script += add_line(2, "image: " + param['image'])
        script += add_line(2, "container_name: " + name)
        script += add_line(2, "restart: always")
        script += add_line(2, "privileged: true")
        script += add_line(2, "network_mode: none")
        script += add_line(2, "dns:")
        script += add_line(3, "- " + param['dns'])
        dep = param['depends_on']
        # If it has a dependency, add all of them
        if len(dep) > 0:
            script += add_line(2, "depends_on:")
            for i in range(len(dep)):
                script += add_line(3, "- " + dep[i])
        script += add_line(2, "volumes:")
        script += add_line(3, "- " + getcwdb().decode('utf-8') + "/logs:/home/debian/log")
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

    def create_attack_configs(self):
        path = 'attack/'
        external = []
        internal = []
        listen_port_80_internal = []
        listen_port_80_external = []
        subnet_internal = set()
        subnet_external = set()
        # Separate IPs by external and internal and find all servers that listens to port 80
        for _, params in self.experiment_script.items():
            IP = params['IP']
            sub = IP.split('.')[2]
            webserver = environ['REPOSITORY']+':'+environ['WEB']
            seafileserver = environ['REPOSITORY']+':'+environ['SEAFILE']
            if sub == environ['ESUBNET']: 
                external.append(IP)
                subnet_external.add(sub)
                if params['image'] in (webserver, seafileserver):
                    listen_port_80_external.append(IP)
            else: 
                internal.append(IP)            
                subnet_internal.add(sub)
                if params['image'] in (webserver, seafileserver):
                    listen_port_80_internal.append(IP)

        # Change the subnet string to a complete ip range format
        subnet_internal = ["192.168." + subnet + ".0/24" for subnet in subnet_internal]
        subnet_external = ["192.168." + subnet + ".0/24" for subnet in subnet_external]
            
        def create_ip_list(filename, iplist):
            script = ''
            [script:= script + ip + self.endl for ip in iplist]
            with open(path+filename, 'w') as f:
                f.write(script)    

        create_ip_list("internal_ipList.txt", internal)
        create_ip_list("external_ipList.txt", external)
        create_ip_list("internal_ipListPort80.txt", listen_port_80_internal)
        create_ip_list("external_ipListPort80.txt", listen_port_80_external)
        create_ip_list('internal_iprange.txt', list(subnet_internal))
        create_ip_list('external_iprange.txt', list(subnet_external))
        
    def create_ssh_configs(self, filename):
        self.ssh_config += "web = " + self.experiment_script[environ['WEB']]['IP'] + self.endl
        self.ssh_config += "mail = " + self.experiment_script[environ['MAILSERVER']]['IP'] + self.endl
        self.ssh_config += "file = " + self.experiment_script[environ['FILE']]['IP'] + self.endl
        self.ssh_config += "backup = " + self.experiment_script[environ['BACKUP']]['IP'] + self.endl
        with open(filename, 'w') as f:
            f.write(self.ssh_config)    

def main():
    try:
        argv[1]
    except:
        exit("[create_config_files.py] ERROR: Expected command line argument. Must provide the file path to the .json for experiment")
    
    c = CreateConfigurationFiles(argv[1])
    c.run_compose("docker-compose.yml")
    c.create_serverconfig_script("serverconfig.ini")
    c.config_hosts("config_all_hosts.sh")
    c.create_attack_configs()
    c.create_ssh_configs("sshiplist.ini")

if __name__ == "__main__":
    main()