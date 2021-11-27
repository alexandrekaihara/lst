#!/bin/bash

# Update
apt-get update
apt-get upgrade

declare -a versionsAptGet=("=1:8.2p1-4ubuntu0.3" "=2.0.6"    ""     "=1.3-20190808-1" "=3.0pl1-136ubuntu1" "=0.99.9.8"                  "=0.8.12-1ubuntu4" ""     ""      "=2.2.19-3ubuntu2.1")
declare -a packagesAptGet=("openssh-client"     "apt-utils" "sudo" "dialog"          "cron"               "software-properties-common" "aptitude"         "wget" "unzip" "dirmngr")
count=${#packagesAptGet[@]}
for i in `seq 1 $count` 
do
  until dpkg -s ${packagesAptGet[$i-1]} | grep -q Status;
  do
    RUNLEVEL=1 apt install -y --no-install-recommends ${packagesAptGet[$i-1]}${versionsAptGet[$i-1]}
  done
  echo "${packagesAptGet[$i-1]} found."
done

# Solve problems on installing cups:
## 1.1 Policy-rc.d not permit start process on reboot
printf '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d
## 1.2 Failed to create symbolic link em /etc/resolv.conf https://stackoverflow.com/questions/40877643/apt-get-install-in-ubuntu-16-04-docker-image-etc-resolv-conf-device-or-reso
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections
until dpkg -s resolvconf | grep -q Status;
do
  RUNLEVEL=1 apt install -y --no-install-recommends resolvconf=1.82
done
apt-get update

# Get automation script from github
mkdir /home/debian
until unzip -o main.zip -d /home/debian
do
  wget https://github.com/mdewinged/cidds/archive/refs/heads/main.zip --no-check-certificate
done
rm main.zip 
mv /home/debian/cidds-main/scripts/automation /home/debian/
chmod -R 755 /home/debian/automation
rm -r /home/debian/cidds-main

# From Ubuntu 18 and later, there is no support for libqt4-dev, so must run the following commands
until dpkg -s libqt4-dev | grep -q Status;
do
    echo "\n" | sudo add-apt-repository ppa:rock-core/qt4
    apt-get install -y --no-install-recommends libqt4-dev=5:4.8.7+dfsg-7ubuntu4rock7
done

# Add sources  
sudo aptitude update
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 8756C4F765C9AC3CB6B85D62379CE192D401AB61
echo deb http://dl.bintray.com/seafile-org/deb strech main | sudo tee /etc/apt/sources.list.d/seafile.list

# Update the system 
apt-get -y update
apt-get -y upgrade

# Install Geckodriver
until mv geckodriver /opt/
do
  wget "https://github.com/mozilla/geckodriver/releases/download/v0.29.1/geckodriver-v0.29.1-linux64.tar.gz"
  tar -xzf "geckodriver-v0.29.1-linux64.tar.gz"
done
rm geckodriver-v0.29.1-linux64.tar.gz
export PATH="$PATH:/opt/geckodriver"

# Install all predefined packages
declare -a versionsAptGet=("=0.8.12-1ubuntu4" "=3.8.2-0ubuntu2" "=0.23-2build1" "=20.0.2-5ubuntu1.6" "=94.0+build3-0ubuntu0.20.04.1" "=2:1.20.11-1ubuntu1~20.04.2" "6.0-25ubuntu1" "=2.3.1-9ubuntu1.1" "=2.3.1-9ubuntu1.1" "=2.3.1-9ubuntu1.1" "=2:6.9-1ubuntu0.1" "=3.16.3-1ubuntu1" "=3.31.1-4ubuntu0.2" "45.2.0-1"           "=3.16.0-2ubuntu2"   "=2.69-11.1" "=1:1.16.1-4ubuntu6" "=2.4.6-14" "=2.1.11-stable-1" "=7.68.0-1ubuntu2.7"   "=2.24.32-4ubuntu4" "=2.34-0.1ubuntu9.1" "=0.51.0-5ubuntu1" "=3.31.1-4ubuntu0.2" "=0.48.6-0ubuntu1" "=2.12-1build1"  "=2.9.9-3" "=7.0.6-1"    "=2.04-1ubuntu26.13" "=7.80+dfsg1-2build1" "=3.8.10-0ubuntu1~20.04.1" "=2.3.1-9ubuntu1.1" "=4:9.3.0-1ubuntu2" "=94.0+build3-0ubuntu0.20.04.1")  
declare -a packagesAptGet=("aptitude"         "python3"         "python3-xlib"  "python3-pip"        "firefox"                       "xvfb"                        "unzip"         "cups"              "cups-client"       "cups-bsd"          "cifs-utils"        "cmake"            "sqlite3"            "python3-setuptools" "python3-simplejson" "autoconf"   "automake"          "libtool"    "libevent-dev"     "libcurl4-openssl-dev" "libgtk2.0-dev"     "uuid-dev"           "intltool"         "libsqlite3-dev"     "valac"            "libjansson-dev" "libfuse2" "seafile-cli" "grub2"              "nmap"                "python3.8-dev"            "libcups2-dev"      "gcc"               "firefox-geckodriver"           ) 
count=${#packagesAptGet[@]}
for i in `seq 1 $count`
do
until dpkg -s ${packagesAptGet[$i-1]} | grep -q Status;
do
apt-get install -y --no-install-recommends --force-yes ${packagesAptGet[$i-1]}${versionsAptGet[$i-1]}
done
echo "${packagesAptGet[$i-1]} found."
done

# Definition of the Python-Libraries to install 
python3 -m pip install --upgrade pip
declare -a versionsPip=("==3.141.0" "==8.4.0" "==2.2" "==0.2.9" "==4.8.0" "==0.7.1" "==2.0.1")
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
