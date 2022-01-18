# ryu-manager ryu.app.simple_switch_13 --verbose --ofp-listen-host 127.10.0.0 --ofp-tcp-listen-port 6633 --observe-links
# sudo -E mn --custom minimaltopo.py --topo topo --controller remote,ip=192.168.56.102,port=6633 --mac
from mininet.cli import CLI
from mininet.log import setLogLevel
from mininet.net import Mininet
from mininet.node import RemoteController, OVSKernelSwitch
 
def runMinimalTopo():
    # Create a network based on the topology using OVS and controlled by
    # a remote controller.
    net = Mininet(topo=None, build=False)

    s1 = net.addSwitch('s1', cls=OVSKernelSwitch)
        
    c0 = net.addController('c0', controller=RemoteController, ip='192.168.100.4', port = 6633, protocol='tcp')

    net.build()

    s1.start([c0])
 
    # Drop the user in to a CLI so user can run commands.
    CLI(net)
 
    # After the user exits the CLI, shutdown the network.
    net.stop()
 
if __name__ == '__main__':
    # This runs if this file is executed directly
    setLogLevel( 'info' )
    runMinimalTopo()

TOPOS = {'topo': runMinimalTopo}
