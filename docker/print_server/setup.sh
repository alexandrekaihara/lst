#!/bin/bash

# Set system time 
rm /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Solve problems on installing cups:
## 1.0 Dialog not found
apt-get install -y apt-utils=2.0.6
apt-get install -y dialog=1.3-20190808-1 -y
## 1.1 Policy-rc.d not permit start process on reboot
printf '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d
## 1.2 Failed to create symbolic link em /etc/resolv.conf https://stackoverflow.com/questions/40877643/apt-get-install-in-ubuntu-16-04-docker-image-etc-resolv-conf-device-or-reso
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections
apt-get update
apt-get install -y resolvconf=1.82

# Install dependencies
RUNLEVEL=1 apt-get install samba=2:4.13.14+dfsg-0ubuntu0.20.04.1 -y
RUNLEVEL=1 apt-get install printer-driver-cups-pdf=3.0.1-6 -y
apt-get install openssl=1.1.1f-1ubuntu2.8 -y
apt-get install cron=3.0pl1-136ubuntu1 -y

# Configure Cups
service cups restart

# Make printer available in Network
sed -i "s/Listen localhost:631/Listen *:631/" /etc/cups/cupsd.conf
sed -i "/<Location \/>/a \\ \\ Allow All" /etc/cups/cupsd.conf
sed -i "s/Shared No/Shared Yes/" /etc/cups/printers.conf

# Cron daemon set up to make every night at 01:00 clock updates
echo -e "0 1 * * * sudo bash -c 'apt-get update && apt-get upgrade' >> /var/log/apt/myupdates.log\n" | crontab -

# Configure auto login 
mkdir /etc/systemd/system/getty@tty1.service.d/
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin debian --noclear %I 38400 linux
EOF

# Add user for ssh script 
useradd -m -s /bin/bash stack
echo "stack:mininet" | chpasswd
usermod -a -G sudo stack

# Prettify Prompt 
mkdir /home/debian
echo -e "PS1='\[\033[1;37m\]\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\[\033[41;37m\]\w\$\[\033[0m\] '" >> /home/debian/.bashrc


