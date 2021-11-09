#!/bin/bash

#https://manual.seafile.com/deploy/using_mysql/ para instalar o seafile server

# Set system time 
rm /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime


# Add to start
crontab -r


# Download the scripts from the webserver 
wget 192.168.56.101/scripts/automation.zip


# From Ubuntu 18 and later, there is no support for libqt4-dev, so must run the following commands
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:rock-core/qt4
sudo apt-get install -y aptitude
#

# Add sources  
sudo aptitude update
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 8756C4F765C9AC3CB6B85D62379CE192D401AB61
echo deb http://dl.bintray.com/seafile-org/deb strech main | sudo tee /etc/apt/sources.list.d/seafile.list

### Prepare the clients for the automation 

# Update the system 
apt-get -y update
apt-get -y upgrade


# Define the packets to install with apt-get 
declare -a packagesAptGet=("aptitude" "python3" "python3-xlib" "libcups2-dev" "python3-pip" "xvfb" "unzip" "cups" "cups-client" "cups-bsd" "cifs-utils" "cmake" "sqlite3" "python2.7" "python3-setuptools" "python3-simplejson" "autoconf" "automake" "libtool" "libevent-dev" "libcurl4-openssl-dev" "libgtk2.0-dev" "uuid-dev" "intltool" "libsqlite3-dev" "valac" "libjansson-dev" "libqt4-dev" "libfuse-dev" "seafile-cli" "grub2" "nmap") # "iceweasel" "python-imaging"

# Install all predefined packages 
for package in "${packagesAptGet[@]}"
do
	echo "Looking for package $package."
	until dpkg -s $package | grep -q Status;
	do
	    echo "$package not found. Installing..."
	    apt-get --allow-downgrades --allow-remove-essential --allow-change-held-packages --yes install $package
	done
	echo "$package found."
done

# Definition of the Python-Libraries to install 
python3 -m pip install --upgrade pip
declare -a packagesPip=("selenium" "pillow" "pyvirtualdisplay" "xvfbwrapper" "pexpect" "python-nmap" "pycups")

# Install Python-Libs using pip 
for package in "${packagesPip[@]}"
do
echo "Looking for package $package."
until pip show $package | grep -q Location;
do
echo "$package not found. Installing..."
python3 -mpip install $package
done
echo "$package found."
done

# Update the system 
aptitude -y update
aptitude -y upgrade

# Install the geckodriver for selenium (needed for browsing)
sudo apt-get install firefox
wget "https://github.com/mozilla/geckodriver/releases/download/v0.29.1/geckodriver-v0.29.1-linux64.tar.gz"
tar -xzf "geckodriver-v0.29.1-linux64.tar.gz"
mv geckodriver /opt/

# Configure printers 
/etc/init.d/cups restart
#lpoptions -d pdf
# Use instead this command, needs to specify the host https://www.thegeekstuff.com/2015/01/lpadmin-examples/
lpadmin -p PDF -v socket://192.168.56.117 -E
/etc/init.d/cups restart

# Create directory for Netstorage 
mkdir -pv /home/debian/netstorage

# Create directory for local storage 
mkdir -pv /home/debian/localstorage

# Create directory for log files  
mkdir -pv /home/debian/log

# Configure Seafile (Cloud storage)
mkdir -pv /home/debian/sea /home/debian/seafile-client
seaf-cli init -d /home/debian/seafile-client -c /home/debian/.ccnet
seaf-cli start -c /home/debian/.ccnet
seaf-cli config -k disable_verify_certificate -v true -c /home/debian/.ccnet
seaf-cli config -k enable_http_sync -v true -c /home/debian/.ccnet
seaf-cli stop -c /home/debian/.ccnet
seaf-cli start -c /home/debian/.ccnet
chown -R mininet:mininet /home/debian/sea/ /home/debian/seafile-client/ /home/debian/.ccnet
echo -e "@reboot sleep 60 && seaf-cli start -c /home/debian/.ccnet 2>&1 > /dev/null\n" | crontab -

# Generate dummy files for seafile
mkdir -pv /home/debian/tmpseafiles
i=0
while [ $i -le 100 ]
do
  i=`expr $i + 1`;
  zufall=$RANDOM;
  zufall=$(($zufall % 9999))
  dd if=/dev/zero of=/home/debian/tmpseafiles/test-`expr $zufall`.dat bs=1K count=`expr $zufall`
done

chown -R mininet:mininet /home/debian/tmpseafiles/
chmod -R 755 /home/debian/tmpseafiles/ 
chmod -R 755 /home/debian/sea

# Unzip the downloaded scripts from Server 
unzip automation.zip -d /home/debian/
chmod -R 755 /home/debian/automation
chown -R mininet:mininet /home/debian/automation

# Configure auto login after booting the OS 
mkdir -pv /etc/systemd/system/getty@tty1.service.d/
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin debian --noclear %I 38400 linux
EOF

# Set up services for scripts 
cat > /etc/systemd/system/automation.service <<EOF
[Unit]
Description=Start automation scripts

[Service]
WorkingDirectory=/home/debian/automation/
ExecStart=/usr/bin/python readIni.py
Type=simple

[Install]
WantedBy=multi-user.target
EOF

# Reload Systemd manager  
systemctl daemon-reload

# Activate services
systemctl enable automation.service

# Prettify Prompt 
echo -e "PS1='\[\033[1;37m\]\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\[\033[41;37m\]\w\$\[\033[0m\] '" >> /home/debian/.bashrc

# Restart 
reboot
