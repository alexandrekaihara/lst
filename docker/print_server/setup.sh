#!/bin/bash

# Set system time 
rm /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime

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


