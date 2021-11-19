from subprocess import Popen
from configparser import ConfigParser
from datetime import datetime
import subprocess
import socket
import platform
import urllib3
import sys


# Download recent ServerConfig
def getCurrentServerConfig():
	url = "192.168.56.101/scripts/automation/packages/system/serverconfig.ini"
	dst = "/home/debian/serverconfig.ini"
	http = urllib3.PoolManager()
	r = http.request('GET', url, preload_content=False)

	with open(dst, 'wb') as out:
		while True:
			data = r.read(1024)
			if not data:
				break
			out.write(data)

	r.release_conn()

# Configure backup server 
def configBackupServer(parser):
	
	# Read ips from backup servers 	
	backupIP = parser.get("backup", "ip")
			
	# Mount netstorage
	try:
		cmd = "mount -t cifs -o username=mininet,password=mininet //" + backupIP + "/backup_webserver /home/debian/backup"
		subprocess.check_call(cmd, shell=True)
	except Exception as e:
		with open("/home/debian/log.txt", "a") as file:
			file.write(datetime.now().strftime("%y%m%d-%H%M%S") + " | Fehler beim Mount des Backup-Servers | " + str(e) + "\n")

# Init 
def main():

	# Fetch recent server config file 
	getCurrentServerConfig()
	
	# Init parser 
	parser = ConfigParser()
	
	# Open ServerConfig file with parser 
	parser.read("/home/debian/serverconfig.ini")
	
	# Configure Backup strategy 
	configBackupServer(parser)

if __name__ == "__main__":
	main()
