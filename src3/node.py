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
from exceptions import NodeInstantiationFailed


# Brief: This is a super class that define methods common for network nodes
class Node:
    # Brief: Constructor of Node super class
    # Params:
    #   String containerName: Name of the container
    # Return:
    #   None
    def __init__(self, nodeName: str) -> None:
        self.__nodeName = nodeName
        self.__connections = {}
        self.__dns = "8.8.8.8"
        self.__ipv4 = []

    # Brief: Instantiate the container
    # Params:
    #   String dockerImage: Name of the container of a local image or in a Docker Hub repository
    #   String DockerCommand: String to be used to instantiate the container instead of the standard command
    # Return:
    #   None
    def instantiate(self, dockerImage="host:latest", dockerCommand = '') -> None:
        try:    
            if dockerCommand == '':
                subprocess.run(f"docker run -d --network=none --privileged --name={self.getNodeName()} {dockerImage} tail -f /dev/null", shell=True)
            else:
                subprocess.run(dockerCommand, shell=True)
            self.__enableNamespace(self.getNodeName())
        except Exception as ex:
            logging.error(f"Error while criating the container {self.getNodeName()}: {str(ex)}")
            raise NodeInstantiationFailed(f"Error while criating the container {self.getNodeName()}: {str(ex)}")

    # Brief: Instantiate the container
    # Params:
    #   String dockerImage: Name of the container of a local image or in a Docker Hub repository
    #   String DockerCommand: String to be used to instantiate the container instead of the standard command
    # Return:
    #   None
    def delete(self) -> None:
        try:    
            subprocess.run(f"docker kill {self.getNodeName()} && docker rm {self.getNodeName()}", shell=True)
        except Exception as ex:
            logging.error(f"Error while deleting the host {self.getNodeName()}: {str(ex)}")
            raise NodeInstantiationFailed(f"Error while deleting the host {self.getNodeName()}: {str(ex)}")

    # Brief: Set Ip to an interface (the ip must be set only after connecting it to a container)
    # Params:
    #   String ip: IP address to be set to peerName interface
    #   int mask: Integer that represents the network mask
    #   String node: Reference to the node it is connected to this container to discover the intereface to set the ip to
    # Return:
    #   None
    def setIp(self, ip: str, mask: int, node: Node) -> None:
        self.__isConnected(node)
        # Set the ip on an interface
        interfaceName = self.__getThisInterfaceName(node)
        self.__setIp(ip, mask, interfaceName)

    # Brief: Creates Linux virtual interfaces and connects peers to the nodes, in case of one of the nodes is a switch, it also creates a port in bridge
    # Params:
    #   Node node: Reference of another node to connect to
    # Return:
    #   None
    def connect(self, node: Node, configureGateway=True) -> None:
        peer1Name = self.__getThisInterfaceName(node)
        peer2Name = self.__getOtherInterfaceName(node)
        
        self.__create(peer1Name, peer2Name)
        self.__setInterface(self.getNodeName(), peer1Name)
        self.__setInterface(node.getNodeName(), peer2Name)

        # Save the information about the nodes this container is connected to
        self.__addConnection(node)
        
        if configureGateway:
            self.__setDefaultGateway()
        
    # Brief: Check if this container is connected to another node reference
    # Params:
    #   Node node: Reference to the node to check if this container is connected to
    # Return:
    #   None
    def __isConnected(self, node: Node) -> None:
        # Check if the received node is already connected to this container
        try:
            self.__connections[node.getNodeName()]
        except:
            logging.error(f"Incorrect node reference for {self.getNodeName()}, connect {node.getNodeName()} first")
            raise Exception(f"Incorrect node reference for {self.getNodeName()}, connect {node.getNodeName()} first")

    def __addConnection(self, node: Node) -> None:
        self.__connections[node.getNodeName()] = node

    # Brief: Set Ip to an interface
    # Params:
    #   String ip: IP address to be set to peerName interface
    #   int mask: Integer that represents the network mask
    #   String interfaceName: Name of the interface to set the ip
    # Return:
    #   None
    def __setIp(self, ip: str, mask: int, interfaceName: str) -> None:
        try:
            subprocess.run(f"ip -n {self.getNodeName()} addr add {ip}/{mask} dev {interfaceName}", shell=True)
        except Exception as ex:
            logging.error(f"Error while setting IP {ip}/{mask} to virtual interface {interfaceName}: {str(ex)}")
            raise Exception(f"Error while setting IP {ip}/{mask} to virtual interface {interfaceName}: {str(ex)}")
        # Save the ip, mask an interface name that was set to this container
        self.__setNodeIp(ip, mask, interfaceName)    

    # Brief: Save the ip and mask information
    # Params:
    #   String ip: IP address to be set to peerName interface
    #   int mask: Integer that represents the network mask
    #   String interfaceName: The name of the interface the IP was set
    # Return:
    #   None
    def __setNodeIp(self, ip: str, mask: int, interfaceName: str) -> None:
        self.__ipv4.append({ip, mask, interfaceName})

    # Brief: Returns the value of the container name
    # Params:
    #   String containerName: Name of the container
    # Return:
    #   None
    def getNodeName(self) -> str:
        return self.__nodeName

    # Brief: Returns the name of the interface to be created on this node
    # Params:
    #   Node node: Reference of another node to connect to
    # Return:
    #   Name of the interface with pattern veth + this node name + other node name
    def __getThisInterfaceName(self, node: Node) -> str:
        return "veth"+self.getNodeName()+node.getNodeName()

    # Brief: Returns the name of the interface to be created on other node
    # Params:
    #   Node node: Reference of another node to connect to
    # Return:
    #   Name of the interface with pattern veth + other node name + this node name
    def __getOtherInterfaceName(self, node: Node) -> str:
        return "veth"+node.getNodeName()+self.getNodeName()

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

    # Brief: Enable accessing the Docker node namespace directly
    # Params:
    # Return:
    #   None
    def __enableNamespace(self, nodeName) -> None:
        try:    
            subprocess.run(f"pid=$(docker inspect -f '{{{{.State.Pid}}}}' {nodeName}); mkdir -p /var/run/netns/; ln -sfT /proc/$pid/ns/net /var/run/netns/{nodeName}", shell=True)
        except Exception as ex:
            logging.error(f"Error while deleting the host {self.getNodeName()}: {str(ex)}")
            raise Exception(f"Error while deleting the host {self.getNodeName()}: {str(ex)}")

    # Brief: Add a route in routing table of container
    # Params:
    #   String ip: IP address of the route
    #   String mask: Network mask for the IP address route
    #   String node: Reference to the node to be the gateway
    # Return:
    #   None
    def __addRoute(self,ip: str, mask: int,  node: Node):
        self.__isConnected(node)
        
        ip = ip.split('.')
        ip[3] = '0'
        ip = '.'.join(ip)
        peerName = self.__getThisInterfaceName(node)
        try:
            subprocess.run(f"docker exec {self.getNodeName()} ip route add {ip}/{mask} dev {peerName}", shell=True)
        except Exception as ex:
            logging.error(f"Error adding route {ip}/{mask} via {peerName} in {self.getNodeName()}: {str(ex)}")
            raise Exception(f"Error adding route {ip}/{mask} via {peerName} in {self.getNodeName()}: {str(ex)}")

    # Brief: Set Ip to an interface (the ip must be set only after connecting it to a container, because)
    # Params:
    #   String destinationIp: The destination IP address of the gateway in format "XXX.XXX.XXX.XXX"
    #   String node: Reference to the node that will serve as gateway
    # Return:
    #   None
    def setDefaultGateway(self, destinationIp: str, node: Node) -> None:
        self.__isConnected(node)
        outputInterface = self.__getThisInterfaceName(node)
        try:
            subprocess.run(f"docker exec {self.getNodeName()} route add default gw {destinationIp} dev {outputInterface}", shell=True)
        except Exception as ex:
            logging.error(f"Error while setting gateway {destinationIp} on device {outputInterface} in {self.getNodeName()}: {str(ex)}")
            raise Exception(f"Error while setting gateway {destinationIp} on device {outputInterface} in {self.getNodeName()}: {str(ex)}")
