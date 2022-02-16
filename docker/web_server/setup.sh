#!/bin/bash

# Set system time 
rm /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Mount the mount point to the backupserver
mkdir /home/debian
mkdir /home/debian/backup

# Delete the folders regularly to save memory 
echo -e "" > /var/log/cron.log
# Run the script to set up the backup server on a regular basis
echo -e "55 21 * * * python3 /home/debian/backup.py >> /var/log/cron.log 2>&1" >> mycron
# Run backup service periodically
echo -e "0 22 * * * tar -czf /home/debian/backup/backup_webserver.tar.gz /var/www/  >> /var/log/cron.log 2>&1" >> mycron
# Update frequently
echo -e "0 1 * * * apt-get update -y && apt-get upgrade -y >> /var/log/cron.log 2>&1" >> mycron
crontab mycron
rm mycron

# User for ssh logins
useradd -m -s /bin/bash mininet
echo "mininet:mininet" | chpasswd
usermod -a -G sudo mininet

# Prettify Prompt 
echo -e "PS1='\[\033[1;37m\]\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\[\033[41;37m\]\w\$\[\033[0m\] '" >> /home/debian/.bashrc