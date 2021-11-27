#!/bin/bash

#https://manual.seafile.com/deploy/using_mysql/ para instalar o seafile server

# Set system time 
rm /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime

crontab -r


# Configure printers 
/etc/init.d/cups restart
# Use instead this command, needs to specify the host https://www.thegeekstuff.com/2015/01/lpadmin-examples/
## Returns the printer ip to be configured
cd /home/debian/automation/packages/system
until printerip=`cat printerip`
do
    python3 getprinterip.py
done
lpadmin -p PDF -v socket://$printerip -E
echo $printerip
sleep 30
/etc/init.d/cups restart

# Create directory for Netstorage 
mkdir -pv /home/debian/netstorage

# Create directory for local storage 
mkdir -pv /home/debian/localstorage

# Create directory for log files  
mkdir -pv /home/debian/log

# Configure Seafile (Cloud storage)
mkdir -pv /home/debian/sea /home/debian/seafile-client
until seaf-cli start -c /home/debian/.ccnet
do
seaf-cli init -d /home/debian/seafile-client -c /home/debian/.ccnet
done
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
