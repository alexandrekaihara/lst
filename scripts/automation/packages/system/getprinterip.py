from configparser import ConfigParser
from re import sub
import socket


def getAndSetSubnetHostAndHostname(parser):
	# Determine IP 
	try:
		s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
		s.connect(("www.google.com", 80))
		ip = (s.getsockname()[0])
		s.close()
	except Exception as e:
		print("getandSetSubnetHostAndHostname job error: " + str(e))
		print("Trying again to connect to google.com")
		return -1, -1, -1
	# Determine subnet using the IP Address 
	subnet = ip.split('.')[2]
	# Determine the host part of the IP 
	host = ip.split('.')[3]
	hostname = socket.gethostname()
	parser.set("network", "hostname", hostname)
	parser.set("network", "subnet", subnet)
	parser.set("network", "host", host)
	# "flush" 
	with open("config.ini", "w") as config:
		parser.write(config)
	return subnet, host, hostname


# Get current subnet
parser = ConfigParser()
parser.read("config.ini")
subnet = host = hostname =-1
while (subnet == -1 and host == -1 and hostname == -1):
    subnet, host, hostname = getAndSetSubnetHostAndHostname(parser)
	
# Get printer ip
parser = ConfigParser()
parser.read("serverconfig.ini")
printIP = parser.get(subnet, "print")
with open("printerip", 'w') as f:
    f.write(printIP)
print("Success on getting printer ip addres for subnet", subnet)
