#!/bin/bash

# Set system time 
rm /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Every mahcine needs to have this folder
mkdir home/debian

# Configure Cups
service cups restart

# Make printer available in Network
sed -i "s/Listen localhost:631/Listen *:631/" /etc/cups/cupsd.conf
sed -i "/<Location \/>/a \\ \\ Allow All" /etc/cups/cupsd.conf
until sed -i "s/Shared No/Shared Yes/" /etc/cups/printers.conf
do
    echo "/etc/cups/printers not found, trying again"
    sleep 1
done

# Cron daemon set up to make every night at 01:00 clock updates
echo -e "" > /var/log/cron.log
echo -e "0 1 * * * apt-get update -y && apt-get upgrade -y >> /var/log/cron.log 2>&1" >> mycron
crontab mycron
rm mycron

# Add user for ssh script 
useradd -m -s /bin/bash mininet
echo "mininet:mininet" | chpasswd
usermod -a -G sudo mininet

# Prettify Prompt 
mkdir /home/debian
echo -e "PS1='\[\033[1;37m\]\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\[\033[41;37m\]\w\$\[\033[0m\] '" >> /home/debian/.bashrc


