#!/bin/bash

# Set system time 
rm /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Define the packets to install with apt-get 
declare -a packagesAptGet=("apache2=2.4.41-4ubuntu3.8" "unzip=6.0-25ubuntu1" "rsync=3.1.3-8")

# Install all predefined packages 
for package in "${packagesAptGet[@]}"
do
	echo "Looking for package $package."
	until dpkg -s $package | grep -q Status;
	do
	    echo "$package not found. Installing..."
	    RUNLEVEL=1 apt-get --no-install-recommends --force-yes --yes install $package
	done
	echo "$package found."
done

# System update
apt-get -y update
apt-get -y upgrade

# Configure auto login 
mkdir /etc/systemd/system/getty@tty1.service.d
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin debian --noclear %I 38400 linux
EOF

# Mount the mount point for backup
mkdir /home/debian
mkdir /home/debian/backup

# Download the script to set up the backup server
wget -O /home/debian/backup.py 192.168.56.101/scripts/requirements/server/web/backup.py

# Run the script to set up the backup server on a regular basis
echo -e "55 21 * * * sudo bash -c 'python /home/debian/backup.py'" >> mycron

# Run backup service periodically
echo -e "0 22 * * * sudo bash -c 'tar -czf /home/debian/backup/backup.tar.gz /var/www/'\n" >> mycron

crontab mycron
rm mycron

# User for ssh logins 
useradd -m -s /bin/bash stack
echo "stack:mininet" | chpasswd
usermod -a -G sudo stack

# Prettify Prompt 
echo -e "PS1='\[\033[1;37m\]\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\[\033[41;37m\]\w\$\[\033[0m\] '" >> /home/debian/.bashrc

# Restart 
reboot
