from subprocess import Popen
from configparser import ConfigParser
from datetime import datetime
import subprocess
import socket
import platform
import urllib3
import sys
	
# Configure backup server 
def configBackupServer(parser):
	
	# Read ips from backup servers 	
	backupIP = parser.get("backup", "ip")
			
	# Mount netstorage 
	try:
		cmd = "mount -t cifs -o username=mininet,password=mininet //" + backupIP + "/backup /home/debian/backup"
		subprocess.check_call(cmd, shell=True)
	except Exception as e:
		with open("/home/debian/log.txt", "a") as file:
			file.write(datetime.now().strftime("%y%m%d-%H%M%S") + " | Fehler beim Mount des Backup-Servers | " + str(e) + "\n")

# Init 
def main():
	# Init parser 
	parser = ConfigParser()
	
	# Open ServerConfig file with parser 
	parser.read("/home/debian/serverconfig.ini")
	
	# Configure Backup strategy 
	configBackupServer(parser)

if __name__ == "__main__":
	main()
