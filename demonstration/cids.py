#!/usr/bin/env python
import signal
import sys
import subprocess
from host import Host
from switch import Switch
from controller import Controller
from node import Node


class Cids:
    def __init__(self) -> None:
        self.repository = 'mdewinged/cids'
        self.br_int_ip = '192.168.100.100'
        self.int_gateway = '192.168.100.101'
        self.server_subnet = '192.168.100.'
        self.management_subnet = '192.168.200.'
        self.office_subnet = '192.168.210.'
        self.developer_subnet = '192.168.220.'
        self.external_subnet = '192.168.50.'
        self.br_ex_ip = self.external_subnet+'100'
        self.ex_gateway= '192.168.50.101'
        self.c1port = 9001
        self.c2port = 9001
        self.nodes = {}

    def set_bridges(self) -> None:
        self.nodes['br_int'] = Switch("br_int")
        self.nodes['br_int'].instantiate()
        self.nodes['br_int'].setIp(self.br_int_ip, 24)
        self.nodes['br_int'].connectToInternet(self.int_gateway, 24)

        self.nodes['br_ex'] = Switch("br_ex")
        self.nodes['br_ex'].instantiate()
        self.nodes['br_ex'].setIp(self.br_ex_ip, 24)
        self.nodes['br_ex'].connectToInternet(self.ex_gateway, 24)

    def set_controllers(self) -> None:
        self.nodes['c1'] = Controller("c1")
        self.nodes['c1'].instantiate()
        self.nodes['c1'].connect(self.nodes['br_int'])
        self.nodes['c1'].setIp(self.br_int_ip, 24, self.br_int)
        self.nodes['c1'].initController(self.br_int_ip, self.c1port)
        self.nodes['br_int'].setController(self.br_int_ip, self.c1port)
        
        self.nodes['c2'] = Controller("c2")
        self.nodes['c2'].instantiate()
        self.nodes['c2'].connect(self.nodes['br_int'])
        self.nodes['c2'].setIp(self.br_ex_ip, 24, self.nodes['br_int'])
        self.nodes['c2'].initController(self.br_ex_ip, self.c2port)
        self.nodes['br_int'].setController(self.br_ex_ip, self.c2port)
        
    def set_server_subnet(self) -> None:
        self.nodes['mail']   = self.__create_node('mailserver',   self.repository+':mailserver',   self.nodes['br_int'], self.server_subnet, 1)
        self.nodes['file']   = self.__create_node('fileserver',   self.repository+':fileserver',   self.nodes['br_int'], self.server_subnet, 2)
        self.nodes['web']    = self.__create_node('webserver',    self.repository+':webserver',    self.nodes['br_int'], self.server_subnet, 3)
        self.nodes['backup'] = self.__create_node('backupserver', self.repository+':backupserver', self.nodes['br_int'], self.server_subnet, 4)

    def set_management_subnet(self) -> None:
        self.nodes['mprinter'] = self.__create_node('mprinter', self.repository+'printerserver', self.nodes['br_int'], self.management_subnet, 1)
        self.nodes['m1'] = self.__create_linuxclient('m1', self.repository+'linuxclient', self.nodes['br_int'], self.management_subnet, 2, 'management')
        self.nodes['m2'] = self.__create_linuxclient('m2', self.repository+'linuxclient', self.nodes['br_int'], self.management_subnet, 3, 'management')
        self.nodes['m3'] = self.__create_linuxclient('m3', self.repository+'linuxclient', self.nodes['br_int'], self.management_subnet, 4, 'management')
        self.nodes['m4'] = self.__create_linuxclient('m4', self.repository+'linuxclient', self.nodes['br_int'], self.management_subnet, 5, 'management')
    
    def set_office_subnet(self) -> None:
        self.nodes['oprinter'] = self.__create_node('oprinter', self.repository+'printerserver', self.nodes['br_int'], self.office_subnet, 1)
        self.nodes['o1'] = self.__create_linuxclient('o1', self.repository+'linuxclient', self.nodes['br_int'], self.office_subnet, 2, 'office')
        self.nodes['o2'] = self.__create_linuxclient('o2', self.repository+'linuxclient', self.nodes['br_int'], self.office_subnet, 3, 'office')
        
    def set_developer_subnet(self) -> None:
        self.nodes['dprinter'] = self.__create_node('dprinter', self.repository+'printerserver', self.nodes['br_int'], self.developer_subnet, 1)
        self.nodes['d1'] = self.__create_linuxclient('d1',   self.repository+'linuxclient', self.nodes['br_int'], self.developer_subnet, 2,  'administrator')
        self.nodes['d2'] = self.__create_linuxclient('d2',   self.repository+'linuxclient', self.nodes['br_int'], self.developer_subnet, 3,  'administrator')
        self.nodes['d3'] = self.__create_linuxclient('d3',   self.repository+'linuxclient', self.nodes['br_int'], self.developer_subnet, 4,  'developer')
        self.nodes['d4'] = self.__create_linuxclient('d4',   self.repository+'linuxclient', self.nodes['br_int'], self.developer_subnet, 5,  'developer')
        self.nodes['d5'] = self.__create_linuxclient('d5',   self.repository+'linuxclient', self.nodes['br_int'], self.developer_subnet, 6,  'developer')
        self.nodes['d6'] = self.__create_linuxclient('d6',   self.repository+'linuxclient', self.nodes['br_int'], self.developer_subnet, 7,  'developer')
        self.nodes['d7'] = self.__create_linuxclient('d7',   self.repository+'linuxclient', self.nodes['br_int'], self.developer_subnet, 8,  'developer')
        self.nodes['d8'] = self.__create_linuxclient('d8',   self.repository+'linuxclient', self.nodes['br_int'], self.developer_subnet, 9,  'developer')
        self.nodes['d9'] = self.__create_linuxclient('d9',   self.repository+'linuxclient', self.nodes['br_int'], self.developer_subnet, 10, 'developer')
        self.nodes['d10'] = self.__create_linuxclient('d10', self.repository+'linuxclient', self.nodes['br_int'], self.developer_subnet, 11, 'developer')
        self.nodes['d11'] = self.__create_linuxclient('d11', self.repository+'linuxclient', self.nodes['br_int'], self.developer_subnet, 12, 'developer')
        self.nodes['d12'] = self.__create_linuxclient('d12', self.repository+'linuxclient', self.nodes['br_int'], self.developer_subnet, 13, 'attacker')
        self.nodes['d13'] = self.__create_linuxclient('d13', self.repository+'linuxclient', self.nodes['br_int'], self.developer_subnet, 14, 'attacker')
        
    def set_external_subnet(self) -> None:
        self.nodes['eweb'] =  self.__create_node('ewebserver', self.repository+':webserver',  self.nodes['br_ex'], self.external_subnet, 2)
        self.nodes['e1'] = self.__create_linuxclient('e1', self.repository+'linuxclient', self.nodes['br_ex'], self.external_subnet, 3, 'external_attacker')
        self.nodes['e2'] = self.__create_linuxclient('e2', self.repository+'linuxclient', self.nodes['br_ex'], self.external_subnet, 4, 'external_attacker')
        
    def __create_linuxclient(self, name: str, image: str, bridge: Node, subnet: str, address: int, behaviour: str) -> Node:
        node = self.__create_node(name, image, bridge, subnet, address)
        subprocess.run(f"docker cp printersip/{subnet.split('.')[2]} {name}:/home/debian/printerip", shell=True)
        subprocess.run(f"docker cp sshiplist.ini {name}:/home/debian/sshiplist.ini", shell=True)
        subprocess.run(f"docker cp client_behaviour/{behaviour}.ini {name}:/home/debian/config.ini", shell=True)
        if behaviour == 'external_attacker':
            subprocess.run(f"docker cp attack/external_ipListPort80.txt {name}:/home/debian/ipListPort80.txt", shell=True)
            subprocess.run(f"docker cp attack/external_ipList.txt {name}:/home/debian/ipList.txt", shell=True)
            subprocess.run(f"docker cp attack/external_iprange.txt {name}:/home/debian/iprange.txt", shell=True)
        elif behaviour == 'attacker':
            subprocess.run(f"docker cp attack/internal_ipListPort80.txt {name}:/home/debian/ipListPort80.txt", shell=True)
            subprocess.run(f"docker cp attack/internal_ipList.txt {name}:/home/debian/ipList.txt", shell=True)
            subprocess.run(f"docker cp attack/internal_iprange.txt {name}:/home/debian/iprange.txt", shell=True)
        return node

    def __create_node(self, name: str, image: str, bridge: Node, subnet: str, address: int) -> Node:
        node = Host(name)
        node.instantiate(image)
        node.connect(bridge)
        node.setIp(subnet+str(address), 24, bridge)
        # Define default gateway of nodes
        if bridge == self.nodes['br_int']: node.setDefaultGateway(self.int_gateway, bridge)
        if bridge == self.nodes['br_ex']:  node.setDefaultGateway(self.ex_gateway , bridge)
        # Add routes to enable nodes within internal subnet communicate with server subnet
        if subnet != self.server_subnet: node.addRoute(self.server_subnet+'0', 24, bridge)
        subprocess.run(f"docker cp serverconfig.ini {name}:/home/debian/serverconfig.ini", shell=True)
        subprocess.run(f"docker cp backup.py {name}:/home/debian/backup.py", shell=True)
        return node

    def run(self) -> None:
        self.nodes['seafileserver'] = self.__create_node('seafileserver', self.repository+':seafile', self.nodes['br_ex'], self.external_subnet, 1)
        subprocess.run(f'docker cp seafileserver:/home/seafolder seafolder', shell=True)
        subprocess.run("cat seafolder", shell=True)
        # Change the serverconfig.ini file with the seafilefolder id
        self.set_bridges()
        self.set_controllers()
        self.set_server_subnet()
        self.set_management_subnet()
        self.set_office_subnet()
        self.set_developer_subnet()

    def unmakeChanges(self):
        [node.delete() for _,node in self.nodes.items()]


def signal_handler(sig, frame):
    print('You pressed Ctrl+C!')
    c.unmakeChanges()
    sys.exit(0)


try:
    c = Cids()
    c.run()
    signal.signal(signal.SIGINT, signal_handler)
    print('Press Ctrl+C to destroy experiment')
    signal.pause()
except Exception as e:
    print(str(e))
    c.unmakeChanges()


