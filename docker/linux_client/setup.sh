#!/bin/bash

#https://manual.seafile.com/deploy/using_mysql/ para instalar o seafile server

# Set system time 
rm /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Add to start
apt-get install --no-install-recommends -y cron=3.0pl1-136ubuntu1 wget
crontab -r

# Download the scripts from the webserver 
#wget 192.168.56.101/scripts/automation.zip
wget -m http://192.168.56.101/scripts/automation
mv 192.168.56.101/scripts/automation /home/debian/automation/
rm -r 192.168.56.101
chmod -R 755 /home/debian/automation
chown -R mininet:mininet /home/debian/automation

# From Ubuntu 18 and later, there is no support for libqt4-dev, so must run the following commands
sudo apt-get install software-properties-common -y
until dpkg -s aptitude | grep -q Status;
do
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
declare -a packagesAptGet=("aptitude=0.8.12-1ubuntu4" "python3=3.9.2-0ubuntu2" "python3-xlib=0.23-2build1" "python3-pip=20.0.2-5ubuntu1.6" "firefox=94.0+build3-0ubuntu0.20.04.1" "xvfb=2:1.20.11-1ubuntu1~20.04.2" "unzip=6.0-25ubuntu1" "cups=2.3.1-9ubuntu1.1" "cups-client=2.3.1-9ubuntu1.1" "cups-bsd=2.3.1-9ubuntu1.1" "cifs-utils=2:6.9-1ubuntu0.1" "cmake=3.16.3-1ubuntu1" "sqlite3=3.31.1-4ubuntu0.2" "python3-setuptools=45.2.0-1" "python3-simplejson=3.16.0-2ubuntu2" "autoconf=2.69-11.1" "automake=1:1.16.1-4ubuntu6" "libtool=2.4.6-14" "libevent-dev=2.1.11-stable-1" "libcurl4-openssl-dev=7.68.0-1ubuntu2.7" "libgtk2.0-dev=2.24.32-4ubuntu4" "uuid-dev=2.34-0.1ubuntu9.1" "intltool=0.51.0-5ubuntu1" "libsqlite3-dev=3.31.1-4ubuntu0.2" "valac=0.48.6-0ubuntu1" "libjansson-dev=2.12-1build1" "libqt4-dev=5:4.8.7+dfsg-7ubuntu4rock7" "libfuse-dev=2.9.9-3" "seafile-cli=7.0.6-1" "grub2=2.04-1ubuntu26.13" "nmap=7.80+dfsg1-2build1") 
for package in "${packagesAptGet[@]}"
do	
    apt-get --force-yes --no-install-recommends --yes install $package
done

# Definition of the Python-Libraries to install 
python3 -m pip install --upgrade pip

# No module selenium found https://shashanksrivastava.medium.com/how-to-fix-no-module-named-selenium-error-in-python-3-da3fd7b61485
until tar xf selenium-3.141.0.tar.gz/
do
    wget https://files.pythonhosted.org/packages/ed/9c/9030520bf6ff0b4c98988448a93c04fcbd5b13cd9520074d8ed53569ccfe/selenium-3.141.0.tar.gz
done
cd selenium-3.141.0
python3 setup.py install

declare -a packagesPip=("selenium" "pillow" "pyvirtualdisplay" "xvfbwrapper" "pexpect" "python-nmap" "pycups")

# Install Python-Libs using pip 
for package in "${packagesPip[@]}"
do
echo "Looking for package $package."
until pip3 show $package | grep -q Location;
do
echo "$package not found. Installing..."
pip3 install $package
done
echo "$package found."
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
