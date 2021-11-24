#!/bin/bash

#https://manual.seafile.com/deploy/using_mysql/ para instalar o seafile server

# Set system time 
rm /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Add to start
RUNLEVEL=1 apt-get install --no-install-recommends -y cron=3.0pl1-136ubuntu1 wget
crontab -r

# Download the scripts from the webserver 
#wget 192.168.56.101/scripts/automation.zip
until mv 192.168.56.101/scripts/automation /home/debian/automation/
do
    wget -m http://192.168.56.101/scripts/automation
done
rm -r 192.168.56.101
chmod -R 755 /home/debian/automation

# From Ubuntu 18 and later, there is no support for libqt4-dev, so must run the following commands
until dpkg -s aptitude | grep -q Status;
do
    apt-get install -y --no-install-recommends software-properties-common
    echo "\n" | sudo add-apt-repository ppa:rock-core/qt4
    sudo apt-get install -y aptitude
done

# Add sources  
sudo aptitude update
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 8756C4F765C9AC3CB6B85D62379CE192D401AB61
echo deb http://dl.bintray.com/seafile-org/deb strech main | sudo tee /etc/apt/sources.list.d/seafile.list

# Update the system 
apt-get -y update
apt-get -y upgrade

# Install all predefined packages
declare -a versionsAptGet=("=0.8.12-1ubuntu4" "=3.8.2-0ubuntu2" "=0.23-2build1" "=20.0.2-5ubuntu1.6" "=94.0+build3-0ubuntu0.20.04.1" "=2:1.20.11-1ubuntu1~20.04.2" "6.0-25ubuntu1" "=2.3.1-9ubuntu1.1" "=2.3.1-9ubuntu1.1" "=2.3.1-9ubuntu1.1" "=2:6.9-1ubuntu0.1" "=3.16.3-1ubuntu1" "=3.31.1-4ubuntu0.2" "45.2.0-1"           "=3.16.3-1ubuntu1"   "=2.69-11.1" "=1:1.16.1-4ubuntu6" "=2.4.6-14" "=2.1.11-stable-1" "=7.68.0-1ubuntu2.7"   "=2.24.32-4ubuntu4" "=2.34-0.1ubuntu9.1" "=0.51.0-5ubuntu1" "=3.31.1-4ubuntu0.2" "=0.48.6-0ubuntu1" "=2.12-1build1"  "=5:4.8.7+dfsg-7ubuntu4rock7" "=2.9.9-3",   "=7.0.6-1"    "=2.04-1ubuntu26.13" "=7.80+dfsg1-2build1" "=3.8.10-0ubuntu1~20.04.1" "=2.3.1-9ubuntu1.1" "=4:9.3.0-1ubuntu2")  
declare -a packagesAptGet=("aptitude"          "python3"        "python3-xlib"  "python3-pip"        "firefox"                       "xvfb"                        "unzip"         "cups"              "cups-client"       "cups-bsd"          "cifs-utils"        "cmake"            "sqlite3"            "python3-setuptools" "python3-simplejson" "autoconf"   "automake"          "libtool"    "libevent-dev"     "libcurl4-openssl-dev" "libgtk2.0-dev"     "uuid-dev"           "intltool"         "libsqlite3-dev"     "valac"            "libjansson-dev" "libqt4-dev"                  "libfuse-dev" "seafile-cli" "grub2"              "nmap"                "python3.8-dev"            "libcups2-dev"      "gcc"              ) 
count=${#packagesAptGet[@]}
for i in `seq 1 $count`
do
echo "Looking for package ${packagesAptGet[$i-1]}."
until dpkg -s ${packagesAptGet[$i-1]} | grep -q Status;
do
echo "${packagesAptGet[$i-1]} not found. Installing..."
apt-get install -y --no-install-recommends --force-yes ${packagesAptGet[$i-1]}${versionsAptGet[$i-1]}
done
echo "${packagesAptGet[$i-1]} found."
done

# Definition of the Python-Libraries to install 
python3 -m pip install --upgrade pip

# No module selenium found https://shashanksrivastava.medium.com/how-to-fix-no-module-named-selenium-error-in-python-3-da3fd7b61485
#until tar xf selenium-3.141.0.tar.gz
#do
#    wget https://files.pythonhosted.org/packages/ed/9c/9030520bf6ff0b4c98988448a93c04fcbd5b13cd9520074d8ed53569ccfe/selenium-3.141.0.tar.gz
#done
#cd selenium-3.141.0
#python3 setup.py install

# Install Python-Libs using pip 
declare -a versionsPip=("==3.141.0", "==8.4.0", "==2.2", "==0.2.9", "==4.8.0", "==0.7.1", "==2.0.1")
declare -a packagesPip=("selenium" "pillow" "pyvirtualdisplay" "xvfbwrapper" "pexpect" "python-nmap" "pycups")
count=${#packagesPip[@]}
for i in `seq 1 $count`
do
echo "Looking for package ${packagesPip[$i-1]}."
until pip3 show ${packagesPip[$i-1]} | grep -q Location;
do
echo "${packagesPip[$i-1]} not found. Installing..."
pip3 install ${packagesPip[$i-1]}${versionsPip[$i-1]}
done
echo "${packagesPip[$i-1]} found."
done

# Update the system 
aptitude -y update
aptitude -y upgrade

# Install the geckodriver for selenium (needed for browsing)
sudo apt-get install -y --no-install-recommends firefox firefox-geckodriver
#wget "https://github.com/mozilla/geckodriver/releases/download/v0.29.1/geckodriver-v0.29.1-linux64.tar.gz"
#tar -xzf "geckodriver-v0.29.1-linux64.tar.gz"
#rm geckodriver-v0.29.1-linux64.tar.gz
#mv geckodriver /opt/
#export PATH="$PATH:/opt/geckodriver"

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
#chown -R mininet:mininet /home/debian/sea/ /home/debian/seafile-client/ /home/debian/.ccnet
echo -e "@reboot sleep 60 && seaf-cli start -c /home/debian/.ccnet 2>&1 > /dev/null\n" | crontab -

chown -R mininet:mininet /home/debian/tmpseafiles/
chmod -R 755 /home/debian/tmpseafiles/ 
chmod -R 755 /home/debian/sea

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
