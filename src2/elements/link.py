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
import subprocess
from elements.node import Node


# This class holds the values of the network node link and some
class Link():
    # Brief: Creates Linux virtual interfaces and connects peers to the nodes
    # Params:
    #   String peer1: Reference to the first node object class
    #   String peer2: Reference to the second node object class
    #   String peer1Name: Name of the interface to be connected to the first object
    #   String peer2Name: Name of the interface to be connected to the second object
    # Return:
    #   None
    def __init__(self, node1: Node, node2: Node) -> None:
        self.__node1 = node1
        self.__node2 = node2
        self.__peer1Name = "veth"+self.__node1.getNodeName()+self.__node2.getNodeName()
        self.__peer2Name = "veth"+self.__node2.getNodeName()+self.__node1.getNodeName()
        self.__connect()

    # Brief: Creates Linux virtual interfaces and connects peers to the nodes, in case of one of the nodes is a switch, it also creates a port in bridge
    # Params:
    #   String peer1Ip: Ip of the first peer in format "192.168.56.100"
    #   String peer1Mask: integer corresponding to the subnet mask of peer1 (e.g. 24 = 255.255.0.0)
    #   String peer2Ip: Ip of the second peer in format "192.168.56.100"
    #   String peer2Mask: integer corresponding to the subnet mask of peer2 (e.g. 24 = 255.255.0.0)
    # Return:
    #   None
    def __connect(self) -> None:
        self.__create(self.__peer1Name, self.__peer2Name)
        self.__setInterface(self.__node1.getNodeName(), self.__peer1Name)
        self.__setInterface(self.__node2.getNodeName(), self.__peer2Name)

        if self.__node1.__class__.__name__ == "Switch": self.__createSwitchPort(self.__node1.getNodeName(), self.__peer1Name)
        if self.__node2.__class__.__name__ == "Switch": self.__createSwitchPort(self.__node2.getNodeName(), self.__peer2Name)

    # Brief: Creates the virtual interfaces and set them up (names cant be the same as some existing one in host's namespace)
    # Params:
    #   String peer1Name: Name of the interface to connect to the first peer 
    #   String peer2Name: Name of the interface to connect to the second peer 
    # Return:
    #   None
    def __create(self, peer1Name: str, peer2Name: str) -> None:
        try:
            subprocess.run(f"ip link add {peer1Name} type veth peer name {peer2Name}", shell=True)
        except Exception as ex:
            logging.error(f"Error while creating virtual interfaces {peer1Name} and {peer2Name}: {str(ex)}")
            raise Exception(f"Error while creating virtual interfaces {peer1Name} and {peer2Name}: {str(ex)}")
    
    # Brief: Set the interface to node
    # Params:
    #   String nodeName: Name of the node network namespace
    #   String peerName: Name of the interface to set to node
    # Return:
    #   None
    def __setInterface(self, nodeName: str, peerName: str) -> None:
        try:
            subprocess.run(f"ip link set {peerName} netns {nodeName}", shell=True)
            subprocess.run(f"ip -n {nodeName} link set {peerName} up", shell=True)
        except Exception as ex:
            logging.error(f"Error while setting virtual interfaces {peerName} to {nodeName}: {str(ex)}")
            raise Exception(f"Error while setting virtual interfaces {peerName} to {nodeName}: {str(ex)}")

    # Brief: Creates a port in OpenvSwitch bridge
    # Params:
    #   String nodeName: The name of the bridge is for default the same name of the switch container
    #   String peerName: Name of the interface to connect to the switch
    # Return:
    #   None
    def __createSwitchPort(self, nodeName, peerName) -> None:
        try:
            subprocess.run(f"docker exec {nodeName} ovs-vsctl add-port {nodeName} {peerName}", shell=True)
        except Exception as ex:
            logging.error(f"Error while creating port {peerName} in switch {nodeName}: {str(ex)}")
            raise Exception(f"Error while creating port {peerName} in switch {nodeName}: {str(ex)}")

    # Brief: Set Ip to an interface (the ip must be set only after connecting it to a container, because)
    # Params:
    #   String node: Node object to set the interface
    #   String ip: IP address to be set to peerName interface
    #   String mask: Network mask for the IP address
    #   bool setGateway: Enables setting the default gateway if not already configured
    # Return:
    #   None
    def setIp(self, node: Node, ip: str, mask: int, setGateway=True) -> None:
        # Raise error if received node does not belong to the link
        if not(self.__isNode1(node) or self.__isNode2(node)):
            logging.error(f"Incorrect node reference for this Link class, expected reference for {self.__node1.getNodeName()} or {self.__node2.getNodeName()} object")
            raise Exception(f"Incorrect node reference for this Link class, expected reference for {self.__node1.getNodeName()} or {self.__node2.getNodeName()} object")

        # Check which node is to be configured and not accept if the received node it do not belongs to the link
        if self.__isNode1(node): 
            peerName = self.__peer1Name
            otherPeerName = self.__peer2Name
            otherNode = self.__node2
        else:
            peerName = self.__peer2Name
            otherPeerName = self.__peer1Name
            otherNode = self.__node1
            
        # If it is a switch, needs to set the ip in bridge instead of the created interface
        if node.__class__.__name__ == "Switch": 
            self.__setIpSwitch(node, ip, mask, peerName)
            # If no gateway is defined, then define the gateway 
            if self.__isDefaultGateway(node.getNodeName()) and setGateway:
                self.setDefaultGateway(otherNode.getNodeName(), otherPeerName, ip)
        else:
            self.__setIpNonSwitch(node, ip, mask, peerName)

        # If other peer node is a switch,then configure the route to the bridge instead to the interface 
        if otherNode.__class__.__name__ == "Switch":
            self.addRoute(otherNode.getNodeName(), otherNode.getNodeName(), ip, mask)
        else: 
            # Insert a new route on the other peer automatically
            self.addRoute(otherNode.getNodeName(), otherPeerName, ip, mask)
            # Define the interface as the default gateway if it doensn't exist
            self.setDefaultGateway(otherNode.getNodeName(), otherPeerName, ip)

    def __isNode1(self, node: Node) -> bool:
        if node == self.__node1: return True
        return False

    def __isNode2(self, node: Node) -> bool:
        if node == self.__node2: return True
        return False

    def __setIpNonSwitch(self, node: Node, ip: str, mask: int, peerName: str) -> None:
        try:
            subprocess.run(f"ip -n {node.getNodeName()} addr add {ip}/{mask} dev {peerName}", shell=True)
        except Exception as ex:
            logging.error(f"Error while setting IP {ip}/{mask} to virtual interface {peerName}: {str(ex)}")
            raise Exception(f"Error while setting IP {ip}/{mask} to virtual interface {peerName}: {str(ex)}")

    def __setIpSwitch(self, node: Node, ip: str, mask: int, peerName: str) -> None:
        try:
            subprocess.run(f"ip -n {node.getNodeName()} addr add {ip}/{mask} dev {node.getNodeName()}", shell=True)
        except Exception as ex:
            logging.error(f"Error while setting IP {ip}/{mask} to virtual interface {peerName}: {str(ex)}")
            raise Exception(f"Error while setting IP {ip}/{mask} to virtual interface {peerName}: {str(ex)}")


    # Brief: Add a route in routing table of container
    # Params:
    #   String node: Node object to set the new route
    #   String peerName: name of the gateway interface
    #   String ip: IP address of the route
    #   String mask: Network mask for the IP address route
    # Return:
    #   None
    def addRoute(self, nodeName: str, peerName: str, ip: str, mask: int):
        ip = ip.split('.')
        ip[3] = '0'
        ip = '.'.join(ip)
        try:
            subprocess.run(f"docker exec {nodeName} ip route add {ip}/{mask} dev {peerName}", shell=True)
        except Exception as ex:
            logging.error(f"Error adding route {ip}/{mask} via {peerName} in {nodeName}: {str(ex)}")
            raise Exception(f"Error adding route {ip}/{mask} via {peerName} in {nodeName}: {str(ex)}")

    # Brief: Set Ip to an interface (the ip must be set only after connecting it to a container, because)
    # Params:
    #   String nodeName: Name of the container to set the IP
    #   String destinationIp: The destination IP address of the gateway in format "XXX.XXX.XXX.XXX"
    #   String outputInterface: The name of the interface to forward as gateway
    # Return:
    #   None
    def setDefaultGateway(self, nodeName: str, outputInterface: str, destinationIp: str) -> None:
        try:
            subprocess.run(f"docker exec {nodeName} route add default gw {destinationIp} dev {outputInterface}", shell=True)
        except Exception as ex:
            logging.error(f"Error while setting gateway {destinationIp} on device {outputInterface} in {nodeName}: {str(ex)}")
            raise Exception(f"Error while setting gateway {destinationIp} on device {outputInterface} in {nodeName}: {str(ex)}")

    # Brief: Check if exists a default gw
    # Params:
    #   String nodeName: Name of the container to check if already exists default gateway
    # Return:
    #   Returns true if there is a gateway configured already and False otherwise
    def __isDefaultGateway(self, nodeName: str) -> bool:
        return True #implement
