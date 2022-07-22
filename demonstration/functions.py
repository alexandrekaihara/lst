import signal
import sys
import subprocess
from host import Host
from switch import Switch
from controller import Controller
from node import Node


def create_linuxclient(name: str, image: str, bridge: Node, subnet: str, address: int, behaviour: str) -> Node:
    node = create_node(name, image, bridge, subnet, address)
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


def create_node(name: str, image: str, bridge: Node, subnet: str, address: int) -> Node:
    node = Host(name)
    node.instantiate(image)
    node.connect(bridge)
    node.setIp(subnet+str(address), 24, bridge)
    # Define default gateway of nodes
    if bridge == nodes['br_int']: node.setDefaultGateway(int_gateway, bridge)
    if bridge == nodes['br_ex']:  node.setDefaultGateway(ex_gateway , bridge)
    # Add routes to enable nodes within internal subnet communicate with server subnet
    if subnet != server_subnet: node.addRoute(server_subnet+'0', 24, bridge)
    subprocess.run(f"docker cp serverconfig.ini {name}:/home/debian/serverconfig.ini", shell=True)
    subprocess.run(f"docker cp backup.py {name}:/home/debian/backup.py", shell=True)
    return node


def unmakeChanges(nodes):
    [node.delete() for _,node in nodes.items()]


