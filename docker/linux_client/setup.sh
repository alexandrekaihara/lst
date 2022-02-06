#!/bin/bash

#https://manual.seafile.com/deploy/using_mysql/ para instalar o seafile server

# Create directory for mount to host
mkdir /home/debian
mkdir /home/debian/log

# Set system time 
rm /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime

crontab -r

# Create user on machine
useradd -m -s /bin/bash mininet
echo "mininet:mininet" | chpasswd
usermod -a -G sudo mininet

# Create directory for Netstorage 
mkdir -pv /home/debian/netstorage

# Create directory for local storage 
mkdir -pv /home/debian/localstorage

# Create directory for log files  
mkdir -pv /home/debian/log

# Configure Seafile (Cloud storage)
echo -e "@reboot sleep 60 && seaf-cli start -c /home/debian/.ccnet 2>&1 > /dev/null\n" | crontab 
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
