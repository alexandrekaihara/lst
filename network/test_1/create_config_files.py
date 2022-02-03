from sys import argv
from json import load
from sys import exit
from os import environ

# Brief: Class responsible for configuring all experiment setup, create docker-compose file to setup containers,
class CreateConfigurationFiles():
    def __init__(self, configfile) -> None:
        self.endl = "\n"
        self.ident = "\t"
        self.serverconfig = ""
        self.network_config = "#\\bin\\bash\n\n"
        self.composefile = "version: \"3.7\"\n\nservices:\n"
        try:
            with open(configfile, "r") as f:
                self.experiment_script = load(f)
        except:
            exit("[create_config_files.py] ERROR: Error on opening ", configfile, "\n Check if file exists or for any error on .json formatting\n\n")

    def create_container_script(self, name, param):
        script = 2*self.ident + name + ":" + self.endl
        script += 3*self.ident + "image: " + param['image'] + self.endl
        script += 3*self.ident + "container_name: " + name + self.endl
        script += 3*self.ident + "restart: always" + self.endl
        script += 3*self.ident + "privileged: true" + self.endl
        script += 3*self.ident + "network_mode: none" + self.endl
        script += 3*self.ident + "dns:" + self.endl
        script += 4*self.ident + "- " + param['dns'] + self.endl
        script += 3*self.ident + "depends_on:" + self.endl
        dep = param['depends_on']
        if len(dep) > 0:
            for i in range(len(dep)):
                script += 4*self.ident + "- " + dep[i] + self.endl
        self.composefile += script
    
    def create_network_config_script(self, name, params):
        ip = params['IP'].split('.')
        subnet = ip[2]
        hostip = ip[3]
        bridge = params['bridge']
        self.network_config += "configure_host " + name + " " + subnet + " " + hostip + " " + bridge + self.endl        

    def create_serverconfig_script(self, serverconfig_filename):
        d = {}
        subnets = set()
        d[environ['PRINTER']] = {}
        d[environ['WEB']] = {}
        for _, params in self.experiment_script:
            # If is a Linuxclient image
            if params['image'] != environ['LCLIENT']:
                subnets.add(params['IP'].split('.')[2])
            # If is not a Linuxclient image
            else:
                subnet = params['IP'].split('.')[2]
                d[subnet][params['image']] = params['IP']
        
        self.serverconfig = "[backup]\nip = " + d['backup'] + 2*self.endl
        for subnet in subnets:
            self.serverconfig += '[' + subnet + ']' + self.endl
            self.serverconfig += 'print = '   + d[subnet][environ['REPOSITORY']+':'+environ["PRINTER"]] + self.endl
            self.serverconfig += 'mail = '    + d["100" ][environ['REPOSITORY']+':'+environ["MAIL"]] + self.endl
            self.serverconfig += 'file = '    + d["100" ][environ['REPOSITORY']+':'+environ["FILE"]] + self.endl
            self.serverconfig += 'web = '     + d["100" ][environ['REPOSITORY']+':'+environ["WEB"]] + self.endl
            self.serverconfig += 'seafile = ' + d["100" ][environ['REPOSITORY']+':'+environ["SEAFILE"]] + self.endl
            self.serverconfig += 'seafolder = '  + environ['SEAFOLDER'] + 2*self.endl
        with(open(serverconfig_filename, "w")) as f:
            f.write(self.serverconfig)  

    def run_compose(self, compose_filename):
        [self.create_container_script(name, params) for name, params in self.experiment_script.items()]
        with(open(compose_filename, "w")) as f:
            f.write(self.composefile)  

    def run_network_config(self, network_config_filename):
        [self.create_network_config_script(name, params) for name, params in self.experiment_script.items()]
        with(open(network_config_filename, "w")) as f:
            f.write(self.network_config)  


def main():
    try:
        argv[1]
    except:
        exit("[create_config_files.py] ERROR: Expected command line argument. Must provide the file path to the .json for experiment")
    
    c = CreateConfigurationFiles(argv[1])
    c.run_compose("docker-compose.yml")
    c.run_network_config("configure_hosts.sh")
    c.create_serverconfig_script("serverconfig.ini")


if __name__ == "__main__":
    main()