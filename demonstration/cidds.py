#!/usr/bin/env python
import signal
import sys
import subprocess
from wsgiref.simple_server import ServerHandler, server_version
from host import Host
from switch import Switch
from controller import Controller
from configparser import ConfigParser
from node import Node
from globalvariables import *

class Seafile(Host):
    def updateServerConfig(self) -> None:
        self.copyContainerToLocal("/home/seafolder", "seafolder")
        out = subprocess.run("cat seafolder", shell=True, capture_output=True).stdout.decode('utf8')
        parser = ConfigParser()
        parser.read('serverconfig.ini')
        parser.set("50", "seafolder",  out)
        parser.set("200", "seafolder", out)
        parser.set("210", "seafolder", out)
        parser.set("220", "seafolder", out)
        with open('serverconfig.ini', 'w') as configfile:
            parser.write(configfile)


class LinuxClient(Host):
    def setAutomationScripts(self, path) -> None:
        self.copyLocalToContainer(path, "/home/debian/automation")
    def setPrinterIp(self, path) -> None:
        self.copyLocalToContainer(path, "/home/debian/automation/packages/system/printerip")
    def setSshIpList(self, path) -> None:
        self.copyLocalToContainer(path, "/home/debian/automation/packages/system/sshiplist.ini")
    def setClientBehaviour(self, path) -> None:
        self.copyLocalToContainer(path, "/home/debian/automation/packages/system/config.ini")
    def setServerConfig(self, path) -> None:
        self.copyLocalToContainer(path, "/home/debian/automation/packages/system/serverconfig.ini")
    def setIpListPort80(self, path) -> None:
        self.copyLocalToContainer(path, "/home/debian/automation/packages/attacking/ipListPort80.txt")
    def setIpList(self, path) -> None:
        self.copyLocalToContainer(path, "/home/debian/automation/packages/attacking/ipList.txt")
    def setIpRange(self, path) -> None:
        self.copyLocalToContainer(path, "/home/debian/automation/packages/attacking/iprange.txt")


def setLinuxClientFileConfig(node: LinuxClient, subnet: str, behaviour: str):
    if subnet != external_subnet: aux = "internal"
    else: aux = "external"
    node.setAutomationScripts("automation")
    node.setPrinterIp(f"printersip/{subnet.split('.')[2]}")
    node.setSshIpList("sshiplist.ini")
    node.setClientBehaviour(f"client_behaviour/{behaviour}.ini")
    node.setServerConfig("serverconfig.ini")
    node.setIpListPort80(f"{aux}_ipListPort80.txt")        
    node.setIpList(f"{aux}_ipList.txt")
    node.setIpRange(f"{aux}_iprange.txt")


def setNetworkConfig(node: Node, bridge: Node, subnet: str, address: int, setFiles=True) -> Node:
    node.connect(bridge)
    node.setIp(subnet+str(address), 24, bridge)
    node.setDns(['8.8.8.8', '8.8.4.4'])
    # Define default gateway of nodes
    if bridge == nodes['brint']: node.setDefaultGateway(int_gateway, bridge)
    if bridge == nodes['brex']:  node.setDefaultGateway(ex_gateway , bridge)
    # Add routes to enable nodes within internal subnet communicate with server subnet
    if subnet != server_subnet: node.addRoute(server_subnet+'0', 24, bridge)
    if subnet != management_subnet: node.addRoute(management_subnet+'0', 24, bridge)
    if subnet != office_subnet: node.addRoute(office_subnet+'0', 24, bridge)
    if subnet != developer_subnet: node.addRoute(developer_subnet+'0', 24, bridge)
    if subnet != external_subnet: node.addRoute(external_subnet+'0', 24, bridge)
    if setFiles:
        subprocess.run(f"docker cp serverconfig.ini {node.getNodeName()}:/home/debian/serverconfig.ini", shell=True)
        subprocess.run(f"docker cp backup.py {node.getNodeName()}:/home/debian/backup.py", shell=True)


def createBridge(name: str, ip: str, gatewayIp: str) -> None: 
    nodes[name] = Switch(name)
    nodes[name].instantiate()
    nodes[name].setIp(ip, 24)
    nodes[name].connectToInternet(gatewayIp, 24)


def createController(name: str, bridgeName: str, controllerIp: str, controllerPort: int) -> None:
    nodes[name] = Controller(name)
    nodes[name].instantiate()
    nodes[name].connect(nodes[bridgeName])
    nodes[name].setIp(controllerIp, 24, nodes[bridgeName])
    nodes[name].initController(controllerIp, controllerPort)
    nodes[bridgeName].setController(controllerIp, controllerPort)
    

def createServer(name: str, serverImage: str, subnet: str,  address: int) -> None:
    nodes[name] = Host[name]
    nodes[name].instantiate(serverImage)
    setNetworkConfig(nodes[name], nodes['brint'], subnet, address)


def createLinuxClient(name, bridge: Node, subnet: str, address: int) -> None:
    nodes[name] = LinuxClient(name)
    nodes[name].instantiate(linuxclient)
    setNetworkConfig(nodes[name], bridge, subnet, address)


def createPrinter(name, subnet: str) -> None:
    nodes[name] = Host()
    nodes[name].instantiate(printerserver)
    setNetworkConfig(nodes[name], nodes['brint'], subnet, 1)


def unmakeChanges():
    [node.delete() for _,node in nodes.items()]


def signal_handler(sig, frame):
    print('You pressed Ctrl+C!')
    unmakeChanges(nodes)
    sys.exit(0)



# Create Bridges and connect them
nodes['brint'] = createBridge('brint', brint_ip, int_gateway)
nodes['brex'] = createBridge('brex', brex_ip, ex_gateway)
nodes['brex'].connect(nodes['brint'])

subprocess.run(f"ip route add 192.168.200.0/24 dev veth-host-brint", shell=True)
subprocess.run(f"ip route add 192.168.210.0/24 dev veth-host-brint", shell=True)
subprocess.run(f"ip route add 192.168.220.0/24 dev veth-host-brint", shell=True)

# Create seafile server
nodes['seafile'] = Seafile('seafile')
nodes['seafile'].instantiate()
setNetworkConfig(nodes['seafile'], seafileserver, nodes['brint'], external_subnet, 1, setFiles=False)
nodes['seafile'].updateServerConfig()

# Create controllers
nodes['c1'] = createController('c1', 'brint', c1_ip, c1port)
nodes['c2'] = createController('c2', 'ex', c1_ip, c1port)

# Create server subnet
createServer('mail',   mailserver,   server_subnet, 1)
createServer('file',   fileserver,   server_subnet, 2)
createServer('web',    webserver,    server_subnet, 3)
createServer('backup', backupserver, server_subnet, 4)

# Set Management Subnet
createPrinter('mprinter', management_subnet)
createLinuxClient('m1', nodes['brint'], management_subnet, 2)
createLinuxClient('m2', nodes['brint'], management_subnet, 3)
createLinuxClient('m3', nodes['brint'], management_subnet, 4)
createLinuxClient('m4', nodes['brint'], management_subnet, 5)
    
# Set Office Subnet
createPrinter('oprinter', office_subnet)
createLinuxClient('o1', nodes['brint'], office_subnet, 2)
createLinuxClient('o2', nodes['brint'], office_subnet, 3)

# Set Developer Subnet
createPrinter('dprinter', developer_subnet)
createLinuxClient('d1', nodes['brint'], office_subnet, 2)
createLinuxClient('d2', nodes['brint'], office_subnet, 3)
createLinuxClient('d3', nodes['brint'], office_subnet, 4)
createLinuxClient('d4', nodes['brint'], office_subnet, 5)
createLinuxClient('d5', nodes['brint'], office_subnet, 6)
createLinuxClient('d6', nodes['brint'], office_subnet, 7)
createLinuxClient('d7', nodes['brint'], office_subnet, 8)
createLinuxClient('d8', nodes['brint'], office_subnet, 9)
createLinuxClient('d9', nodes['brint'], office_subnet, 10)
createLinuxClient('d10', nodes['brint'], office_subnet, 11)
createLinuxClient('d11', nodes['brint'], office_subnet, 12)
createLinuxClient('d12', nodes['brint'], office_subnet, 13)
createLinuxClient('d13', nodes['brint'], office_subnet, 14)

# Set External Subnet
createServer('eweb', webserver, external_subnet, 2)
createLinuxClient('e1', nodes['brex'], external_subnet, 3)
createLinuxClient('e2', nodes['brex'], external_subnet, 4)

# Set Configuration Files
[setLinuxClientFileConfig(nodes[f'm{i}'], management_subnet, 'management') for i in range(4)]
[setLinuxClientFileConfig(nodes[f'o{i}'], office_subnet, 'office') for i in range(2)]
[setLinuxClientFileConfig(nodes[f'd{i}'], developer_subnet, 'administrator') for i in range(2)]
[setLinuxClientFileConfig(nodes[f'd{i}'], developer_subnet, 'developer') for i in range(3,13)]
[setLinuxClientFileConfig(nodes[f'd{i}'], developer_subnet, 'attacker') for i in range(13,15)]
[setLinuxClientFileConfig(nodes[f'e{i}'], developer_subnet, 'external_attacker') for i in range(2)]

unmakeChanges(nodes)

