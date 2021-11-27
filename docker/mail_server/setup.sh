#!/bin/bash

# Global variables
## Direcotry of all configuration files
mailsetup="/tmp/mailsetup"

# Set system time 
rm /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Configure database
cd $mailsetup
echo mysql-server mysql-server/root_password select PWfMS2015 | debconf-set-selections
echo mysql-server mysql-server/root_password_again select PWfMS2015 | debconf-set-selections

echo postfix postfix/mailname string mailserver.com | debconf-set-selections
echo postfix postfix/main_mailer_type string 'Internet Site' | debconf-set-selections

## Corretion of Docker COPY files not in UNIX format https://askubuntu.com/questions/966488/how-do-i-fix-r-command-not-found-errors-running-bash-scripts-in-wsl
dos2unix $mailsetup/genDomain.sh
dos2unix $mailsetup/genUser.sh
dos2unix $mailsetup/mysql_conf.sh
dos2unix $mailsetup/config_inc_php.sh
dos2unix $mailsetup/postfix_config.sh
dos2unix $mailsetup/dovecot_config.sh

# Update again
apt-get -y update
apt-get -y upgrade

# Postfix configuration
## Fix ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (1) on https://www.digitalocean.com/community/questions/error-2002-hy000-can-t-connect-to-local-mysql-server-through-socket-var-run-mysqld-mysqld-sock-2
service mysql stop
usermod -d /var/lib/mysql/ mysql
service mysql start
## Fix error end
mysql -uroot --password=PWfMS2015 -e "CREATE DATABASE postfixdb; CREATE USER 'postfix'@'localhost' IDENTIFIED BY 'MYSQLPW'; GRANT ALL PRIVILEGES ON postfixdb.* TO 'postfix'@'localhost'; FLUSH PRIVILEGES;SET GLOBAL default_storage_engine = 'InnoDB';"
cd /var/www
until mv postfixadmin*/ postfixadmin
do
  wget --content-disposition https://sourceforge.net/projects/postfixadmin/files/postfixadmin/postfixadmin-3.0.2/postfixadmin-3.0.2.tar.gz/download
  tar xfvz postfixadmin-*.tar.gz
  rm postfixadmin-*.tar.gz
done
chown www-data:www-data -R postfixadmin
cd postfixadmin
. $mailsetup/config_inc_php.sh

## Postfix user
groupadd -g 5000 vmail
useradd -g vmail -u 5000 vmail -d /var/vmail
mkdir /var/vmail
chown vmail:vmail /var/vmail
## cert
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
## Write /etc/postfix/main.cf
cd /etc/postfix/
. /tmp/postfix_config.sh
## Change rights
cd /etc/postfix
chmod o-rwx,g+r mysql_*
chgrp postfix mysql_*
## Configure Dovecot
mv /etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf.sample
. $mailsetup/dovecot_config.sh
chmod o-rwx,g+r /etc/dovecot/dovecot-mysql.conf
chgrp vmail /etc/dovecot/dovecot-mysql.conf
/etc/init.d/postfix restart
# Solving the problem that !SSLv3 was not recognized by dovecot https://b4d.sablun.org/blog/2019-02-25-dovecot_2.3_upgrade_on_debian/
sudo sed -i "s/\!SSLv3/TLSv1.2/g" /etc/dovecot/dovecot.conf
/etc/init.d/dovecot restart
/etc/init.d/apache2 restart

# Correction to connect to database on setup.php
. $mailsetup/mysql_conf.sh

# Correct the problem with key cannot be more than 1000 bytes long. See more on https://confluence.atlassian.com/fishkb/mysql-database-migration-fails-with-specified-key-was-too-long-max-key-length-is-1000-bytes-298978735.html
sed -i "s/[Mm][Yy][Ii][Ss][Aa][Mm]/InnoDb/g" /var/www/postfixadmin/upgrade.php
mysql -uroot --password=PWfMS2015 -e "alter user 'postfix'@'localhost' identified with mysql_native_password by 'MYSQLPW';"
service mysql restart

# Create database
mv /var/www/postfixadmin /var/www/html/
cd /var/www/html/postfixadmin
php setup.php #curl http://127.0.0.1/postfixadmin/setup.php?debug=1

# Setup mailing domain and users
## Every possible user gets an own user
. $mailsetup/genDomain.sh mailserver.example
subnet=0
host=0
while [ $subnet -le 255 ]
do
  while [ $host -le 255 ]
  do
    user=`printf "user.%03d.%03d" $subnet $host`
    sh $mailsetup/genUser.sh $user mailserver.example
    host=$((host+1))
    echo $host
    echo $subnet
  done
  subnet=$((subnet+1))
  host=0
done
## Save database configuration, because the docker reset all mysql after build
mysqldump -uroot --password=PWfMS2015 postfixdb > $mailsetup/postfixdb.sql 

# Configure auto login 
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin debian --noclear %I 38400 linux
EOF

# Necessary for finding the NetBIOS name 
declare -a versionsAptGet=("=2:4.13.14+dfsg-0ubuntu0.20.04.1")
declare -a packagesAptGet=("samba")
count=${#packagesAptGet[@]}
for i in `seq 1 $count` 
do
  SafeAptInstall ${packagesAptGet[$i-1]} ${versionsAptGet[$i-1]}
done


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
