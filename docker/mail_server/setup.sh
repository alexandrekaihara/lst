#!/bin/bash

# Set system time 
rm /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Get a common files fron github
apt install -y --no-install-recommends unzip wget
wget https://github.com/mdewinged/cidds/archive/refs/heads/main.zip
unzip -o main.zip -d /home/  
rm main.zip
source /home/cidds-main/docker/utils.sh

# Configure database
cd /tmp/mailsetup
echo mysql-server mysql-server/root_password select PWfMS2015 | debconf-set-selections
echo mysql-server mysql-server/root_passworda_again select PWfMS2015 | debconf-set-selections
echo postfix postfix/mailname string mailserver.com | debconf-set-selections
echo postfix postfix/main_mailer_type string 'Internet Site' | debconf-set-selections

# Correction for installing the right version of php and adding repository to install the dependencies
declare -a versionsAptGet=("=0.99.9.8" "=0.8.12-1ubuntu4")
declare -a packagesAptGet=("software-properties-common" "aptitude")
SafeAptInstall $packagesAptGet $versionsAptGet
dpkg -l | grep php| awk '{print $2}' |tr "\n" " "
sudo aptitude purge `dpkg -l | grep php| awk '{print $2}' |tr "\n" " "`
# Guarantee that it is going to add repository
until dpkg -s php5.6 | grep -q Status;
do
  echo "\n" | sudo add-apt-repository ppa:ondrej/php
  RUNLEVEL=1 apt install -y --no-install-recommends php5.6=5.6.40-57+ubuntu20.04.1+deb.sury.org+1
done
sudo apt-get update

# Resolve MySQLd missing directory: https://stackoverflow.com/questions/34954455/mysql-daemon-lock-issue
mkdir /var/run/mysqld
chmod 777 /var/run/mysqld

# Define the packets to install with apt-get 
declare -a versionsAptGet=("5.6.40-57+ubuntu20.04.1+deb.sury.org+1" "5.6.40-57+ubuntu20.04.1+deb.sury.org+1" "5.6.40-57+ubuntu20.04.1+deb.sury.org+1" "=2.4.41-4ubuntu3.8" "=1:2.3.7.2-1ubuntu3.5" "=1:2.3.7.2-1ubuntu3.5" "=1:2.3.7.2-1ubuntu3.5" "=1:2.3.7.2-1ubuntu3.5" "=3.4.13-0ubuntu1.2" "=3.4.13-0ubuntu1.2" "=7.68.0-1ubuntu2.7" "=8.0.27-0ubuntu0.20.04.1")
declare -a packagesAptGet=("php5.6-mysql" "php5.6-imap" "php5.6-mbstring" "apache2" "dovecot-core" "dovecot-mysql" "dovecot-imapd" "dovecot-pop3d" "postfix" "postfix-mysql" "curl" "whois=5.5.6" "dos2unix" "mysql-server")
SafeAptInstall $packagesAptGet $versionsAptGet

# Continuation of MySQLd problem
chown mysql:mysql /var/run/mysqld

# Update again
apt-get -y update
apt-get -y upgrade

# Postfix configuration
mysql -uroot --password=PWfMS2015 -e "CREATE DATABASE postfixdb; CREATE USER 'postfix'@'localhost' IDENTIFIED BY 'MYSQLPW'; GRANT ALL PRIVILEGES ON postfixdb.* TO 'postfix'@'localhost'; FLUSH PRIVILEGES;SET GLOBAL default_storage_engine = 'InnoDB';"
cd /var/www
until tar xfvz postfixadmin-*.tar.gz
do
  wget --content-disposition https://sourceforge.net/projects/postfixadmin/files/postfixadmin/postfixadmin-3.0.2/postfixadmin-3.0.2.tar.gz/download
done
mv postfixadmin*/ postfixadmin
chown www-data:www-data -R postfixadmin
cd postfixadmin
source /tmp/mailsetup/config_inc_php.sh

#postfix user
groupadd -g 5000 vmail
useradd -g vmail -u 5000 vmail -d /var/vmail
mkdir /var/vmail
chown vmail:vmail /var/vmail
#cert
mkdir /etc/postfix/sslcert
cd /etc/postfix/sslcert
openssl req -new -newkey rsa:3072 -nodes -keyout mailserver.key -sha256 -days 730 -x509 -out mailserver.crt <<EOF
${DE}
${BY}
${Coburg}
${FHWi}
.
.
.
EOF
chmod go-rwx mailserver.key
#write /etc/postfix/main.cf
cd /etc/postfix/
source /tmp/postfix_config.sh

#change rights
cd /etc/postfix
chmod o-rwx,g+r mysql_*
chgrp postfix mysql_*
mv /etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf.sample
source

#writing /etc/dovecot/dovecot-mysql.conf
cat > /etc/dovecot/dovecot-mysql.conf <<EOF
driver = mysql
connect = "host=localhost dbname=postfixdb user=postfix password=MYSQLPW"
default_pass_scheme = MD5-CRYPT
password_query = SELECT password FROM mailbox WHERE username = '%u'
user_query = SELECT CONCAT('maildir:/var/vmail/',maildir) AS mail, 5000 AS uid, 5000 AS gid FROM mailbox INNER JOIN domain WHERE username = '%u' AND mailbox.active = '1' AND domain.active = '1'
EOF
chmod o-rwx,g+r /etc/dovecot/dovecot-mysql.conf
chgrp vmail /etc/dovecot/dovecot-mysql.conf
/etc/init.d/postfix restart
# Solving the problem that !SSLv3 was not recognized by dovecot https://b4d.sablun.org/blog/2019-02-25-dovecot_2.3_upgrade_on_debian/
sudo sed -i "s/\!SSLv3/TLSv1.2/g" /etc/dovecot/dovecot.conf
/etc/init.d/dovecot restart
/etc/init.d/apache2 restart

#postfix configuration
# Correction to connect to database on setup.php
cat > /etc/mysql/my.cnf << EOF
#
# The MySQL database server configuration file.
#
# You can copy this to one of:
# - "/etc/mysql/my.cnf" to set global options,
# - "~/.my.cnf" to set user-specific options.
#
# One can use all long options that the program supports.
# Run program with --help to get a list of available options and with
# --print-defaults to see which it would actually understand and use.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html

#
# * IMPORTANT: Additional settings that can override those from this file!
#   The files must end with '.cnf', otherwise they'll be ignored.
#

!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mysql.conf.d/

[client] 
default-character-set=utf8

[mysql]
default-character-set=utf8

[mysqld]
collation-server = utf8_unicode_ci
character-set-server = utf8
default-authentication-plugin=mysql_native_password
EOF

# Correct the problem with key cannot be more than 1000 bytes long. See more on https://confluence.atlassian.com/fishkb/mysql-database-migration-fails-with-specified-key-was-too-long-max-key-length-is-1000-bytes-298978735.html
sed -i "s/[Mm][Yy][Ii][Ss][Aa][Mm]/InnoDb/g" /var/www/postfixadmin/upgrade.php
mysql -uroot --password=PWfMS2015 -e "alter user 'postfix'@'localhost' identified with mysql_native_password by 'MYSQLPW';"
service mysql restart

mv /var/www/postfixadmin /var/www/html/
php /var/www/html/postfixadmin/setup.php #curl http://127.0.0.1/postfixadmin/setup.php?debug=1
# If has a problem with acess to postfixdb access https://askubuntu.com/questions/1268295/phpmyadmin-is-not-working-in-ubuntu-20-04-with-php5-6
curl -d "form=createadmin&setup_password=PWfMS2015&username=postmaster@mailserver.com&password=PWfMS2015&password2=PWfMS2015&submit=Add+Admin"  http://127.0.0.1/postfixadmin/setup.php

#setup mailing domain and users
#every possible user gets an own user
## Corretion of Docker COPY files not in UNIX format https://askubuntu.com/questions/966488/how-do-i-fix-r-command-not-found-errors-running-bash-scripts-in-wsl
dos2unix /tmp/mailsetup/genDomain.sh
dos2unix /tmp/mailsetup/genUser.sh
source /tmp/mailsetup/genDomain.sh mailserver.example
subnet=0
host=0
while [ $subnet -le 255 ]
do
while [ $host -le 255 ]
do
user=`printf "user.%03d.%03d" $subnet $host`
sh /tmp/mailsetup/genUser.sh $user mailserver.example
host=$((host+1))
#echo $host
#

echo $subnet
done
subnet=$((subnet+1))
host=0
done

# Configure auto login 
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin debian --noclear %I 38400 linux
EOF

# Necessary for finding the NetBIOS name 
#samba
echo "Looking for package samba."
if dpkg -s samba | grep -q Status; then
    echo "samba found."
else
    echo "samba not found. Setting up samba..."
    apt-get --force-yes --yes install samba
fi

# Cron daemon set up to make every night at 01:00 clock updates
echo -e "0 1 * * * sudo bash -c 'apt-get update && apt-get upgrade' >> /var/log/apt/myupdates.log" >> mycron

# Mount the mount point for backup
mkdir /home/debian/backup/

# Run the script to set up the backup server on a regular basis
echo -e "55 21 * * * sudo bash -c 'python /home/debian/backup.py'" >> mycron

# Run backup service periodically
echo -e "0 22 * * * sudo bash -c 'tar -cf /home/debian/backup/backup.tar /var/vmail/'\n" >> mycron

crontab mycron
rm mycron

# User for ssh script 
useradd -m -s /bin/bash stack
echo "stack:mininet" | chpasswd
usermod -a -G sudo stack

# Prettify Prompt 
echo -e "PS1='\[\033[1;37m\]\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\[\033[41;37m\]\w\$\[\033[0m\] '" >> /home/debian/.bashrc

mysql -uroot --password=PWfMS2015 -e "USE posfixdb; showtables;"
sleep 100000
