#!/bin/bash

# Set system time 
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Update the system
apt-get -y update
apt-get -y upgrade

# Create samba configuration 
## Create directory for samba 
mkdir /media/backup
chmod 777 /media/backup
# create mask und force create mode (necessary for overwriting files in the Inbox)
cat > /etc/samba/smb.conf <<EOF
[global]
workgroup = WORKGROUP
security = user
map to guest = bad user

[backup]
comment = Backup for all servers 
path = /media/backup
read only = no
guest ok = yes
create mask = 777
force create mode = 777
EOF

# Delete the folders regularly to save memory 
echo -e "" > /var/log/cron.log
echo -e "0 20 * * * rm -r /media/backup/* >> /var/log/cron.log 2>&1" >> mycron
## Create Cron-Daemon which deletes every night at 01:00 the backup folders 
echo -e "0 1 * * * apt-get update && apt-get upgrade >> /var/log/cron.log 2>&1" >> mycron
chmod 0644 mycron
crontab mycron
rm mycron


# Create auto login 
mkdir /etc/systemd/system/getty@tty1.service.d
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin debian --noclear %I 38400 linux
EOF

# Prepare for ssh user login (create user with appropriate password)
useradd -m -s /bin/bash mininet
echo "mininet:mininet" | chpasswd
usermod -a -G sudo mininet

# Prettify Prompt 
mkdir /home/debian
echo -e "PS1='\[\033[1;37m\]\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\[\033[41;37m\]\w\$\[\033[0m\] '" >> /home/debian/.bashrc

