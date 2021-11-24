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
source config_inc_php.sh

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
cat > main.cf <<EOF
# See /usr/share/postfix/main.cf.dist for a commented, more complete version


# Debian specific:  Specifying a file name will cause the first
# line of that file to be used as the name.  The Debian default
# is /etc/mailname.
#myorigin = /etc/mailname

smtpd_banner = \$myhostname
biff = no

# appending .domain is the MUA's job.
append_dot_mydomain = no

# Uncomment the next line to generate "delayed mail" warnings
#delay_warning_time = 4h

readme_directory = no

# TLS parameters
smtpd_tls_cert_file=/etc/postfix/sslcert/mailserver.crt
smtpd_tls_key_file=/etc/postfix/sslcert/mailserver.key
smtpd_use_tls=yes
smtpd_tls_session_cache_database = btree:\${data_directory}/smtpd_scache

smtp_tls_cert_file = /etc/postfix/sslcert/mailserver.crt
Ösmtp_tls_key_file = /etc/postfix/sslcert/mailserver.key
smtp_tls_security_level=may
smtpd_tls_mandatory_protocols = !SSLv3
smtp_tls_session_cache_database = btree:\${data_directory}/smtp_scache
tls_high_cipherlist=EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH:+CAMELLIA256:+AES256:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!ECDSA:CAMELLIA256-SHA:AES256-SHA:CAMELLIA128-SHA:AES128-SHA

# See /usr/share/doc/postfix/TLS_README.gz in the postfix-doc package for
# information on enabling SSL in the smtp client.

smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
myhostname = mailserver.novalocal
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
myorigin = /etc/mailname
mydestination = mailserver.novalocal, localhost.novalocal, localhost
relayhost =
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = all

# a bit more spam protection
disable_vrfy_command = yes
# Authentification
smtpd_sasl_type=dovecot
smtpd_sasl_path=private/auth_dovecot
smtpd_sasl_auth_enable = yes
smtpd_sasl_authenticated_header = yes
broken_sasl_auth_clients = yes
proxy_read_maps = \$local_recipient_maps \$mydestination \$virtual_alias_maps \$virtual_alias_domains \$virtual_mailbox_maps \$virtual_mailbox_domains \$relay_recipient_maps \$relay_domains \$canonical_maps \$sender_canonical_maps \$recipient_canonical_maps \$relocated_maps \$transport_maps \$mynetworks \$smtpd_sender_login_maps
smtpd_sender_login_maps = proxy:mysql:/etc/postfix/mysql_sender_login_maps.cf
smtpd_sender_restrictions = reject_authenticated_sender_login_mismatch
                reject_unknown_sender_domain
                reject_unverified_sender
                permit_sasl_authenticated
smtpd_recipient_restrictions = permit_sasl_authenticated
                permit_mynetworks
                reject_rbl_client zen.spamhaus.org
                reject_unauth_destination
                reject_unknown_reverse_client_hostname
smtpd_data_restrictions = reject_unauth_pipelining
                permit
# Virtual mailboxes
#local_transport = virtual
virtual_alias_maps = proxy:mysql:/etc/postfix/mysql_virtual_alias_maps.cf
virtual_mailbox_base = /var/vmail/
virtual_mailbox_domains = proxy:mysql:/etc/postfix/mysql_virtual_domains_maps.cf
virtual_mailbox_maps = proxy:mysql:/etc/postfix/mysql_virtual_mailbox_maps.cf
virtual_minimum_uid = 104
virtual_uid_maps = static:5000
virtual_gid_maps = static:5000
virtual_transport = dovecot
dovecot_destination_recipient_limit = 1
EOF
#Writing /etc/postfix/master.cf
cat > master.cf <<EOF
#
# Postfix master process configuration file.  For details on the format
# of the file, see the master(5) manual page (command: "man 5 master" or
# on-line: http://www.postfix.org/master.5.html).
#
# Do not forget to execute "postfix reload" after editing this file.
#
# ==========================================================================
# service type  private unpriv  chroot  wakeup  maxproc command + args
#               (yes)   (yes)   (yes)   (never) (100)
# ==========================================================================
smtp      inet  n       -       -       -       -       smtpd
#smtp      inet  n       -       -       -       1       postscreen
#smtpd     pass  -       -       -       -       -       smtpd
#dnsblog   unix  -       -       -       -       0       dnsblog
#tlsproxy  unix  -       -       -       -       0       tlsproxy
#submission inet n       -       -       -       -       smtpd
#  -o syslog_name=postfix/submission
#  -o smtpd_tls_security_level=encrypt
#  -o smtpd_sasl_auth_enable=yes
#  -o smtpd_reject_unlisted_recipient=no
#  -o smtpd_client_restrictions=\$mua_client_restrictions
#  -o smtpd_helo_restrictions=\$mua_helo_restrictions
#  -o smtpd_sender_restrictions=\$mua_sender_restrictions
#  -o smtpd_recipient_restrictions=
#  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
#  -o milter_macro_daemon_name=ORIGINATING
#smtps     inet  n       -       -       -       -       smtpd
#  -o syslog_name=postfix/smtps
#  -o smtpd_tls_wrappermode=yes
#  -o smtpd_sasl_auth_enable=yes
#  -o smtpd_reject_unlisted_recipient=no
#  -o smtpd_client_restrictions=\$mua_client_restrictions
#  -o smtpd_helo_restrictions=\$mua_helo_restrictions
#  -o smtpd_sender_restrictions=\$mua_sender_restrictions
#  -o smtpd_recipient_restrictions=
#  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
#  -o milter_macro_daemon_name=ORIGINATING
#628       inet  n       -       -       -       -       qmqpd
pickup    unix  n       -       -       60      1       pickup
cleanup   unix  n       -       -       -       0       cleanup
qmgr      unix  n       -       n       300     1       qmgr
#qmgr     unix  n       -       n       300     1       oqmgr
tlsmgr    unix  -       -       -       1000?   1       tlsmgr
rewrite   unix  -       -       -       -       -       trivial-rewrite
bounce    unix  -       -       -       -       0       bounce
defer     unix  -       -       -       -       0       bounce
trace     unix  -       -       -       -       0       bounce
verify    unix  -       -       -       -       1       verify
flush     unix  n       -       -       1000?   0       flush
proxymap  unix  -       -       n       -       -       proxymap
proxywrite unix -       -       n       -       1       proxymap
smtp      unix  -       -       -       -       -       smtp
relay     unix  -       -       -       -       -       smtp
#       -o smtp_helo_timeout=5 -o smtp_connect_timeout=5
showq     unix  n       -       -       -       -       showq
error     unix  -       -       -       -       -       error
retry     unix  -       -       -       -       -       error
discard   unix  -       -       -       -       -       discard
local     unix  -       n       n       -       -       local
virtual   unix  -       n       n       -       -       virtual
lmtp      unix  -       -       -       -       -       lmtp
anvil     unix  -       -       -       -       1       anvil
scache    unix  -       -       -       -       1       scache
#
# ====================================================================
# Interfaces to non-Postfix software. Be sure to examine the manual
# pages of the non-Postfix software to find out what options it wants.
#
# Many of the following services use the Postfix pipe(8) delivery
# agent.  See the pipe(8) man page for information about \${recipient}
# and other message envelope options.
# ====================================================================
#
# maildrop. See the Postfix MAILDROP_README file for details.
# Also specify in main.cf: maildrop_destination_recipient_limit=1
#
maildrop  unix  -       n       n       -       -       pipe
  flags=DRhu user=vmail argv=/usr/bin/maildrop -d \${recipient}
#
# ====================================================================
#
# Recent Cyrus versions can use the existing "lmtp" master.cf entry.
#
# Specify in cyrus.conf:
#   lmtp    cmd="lmtpd -a" listen="localhost:lmtp" proto=tcp4
#
# Specify in main.cf one or more of the following:
#  mailbox_transport = lmtp:inet:localhost
#  virtual_transport = lmtp:inet:localhost
#
# ====================================================================
#
# Cyrus 2.1.5 (Amos Gouaux)
# Also specify in main.cf: cyrus_destination_recipient_limit=1
#
#cyrus     unix  -       n       n       -       -       pipe
#  user=cyrus argv=/cyrus/bin/deliver -e -r \${sender} -m \${extension} \${user}
#
# ====================================================================
# Old example of delivery via Cyrus.
#
#old-cyrus unix  -       n       n       -       -       pipe
#  flags=R user=cyrus argv=/cyrus/bin/deliver -e -m \${extension} \${user}
#
# ====================================================================
#
# See the Postfix UUCP_README file for configuration details.
#
uucp      unix  -       n       n       -       -       pipe
  flags=Fqhu user=uucp argv=uux -r -n -z -a\$sender - \$nexthop!rmail (\$recipient)
#
# Other external delivery methods.
#
ifmail    unix  -       n       n       -       -       pipe
  flags=F user=ftn argv=/usr/lib/ifmail/ifmail -r \$nexthop (\$recipient)
bsmtp     unix  -       n       n       -       -       pipe
  flags=Fq. user=bsmtp argv=/usr/lib/bsmtp/bsmtp -t\$nexthop -f\$sender \$recipient
scalemail-backend unix  -       n       n       -       2       pipe
  flags=R user=scalemail argv=/usr/lib/scalemail/bin/scalemail-store \${nexthop} \${user} \${extension}
mailman   unix  -       n       n       -       -       pipe
  flags=FR user=list argv=/usr/lib/mailman/bin/postfix-to-mailman.py
  \${nexthop} \${user}
dovecot   unix  -       n       n       -       -       pipe
  flags=DRhu user=vmail:vmail argv=/usr/lib/dovecot/deliver -d \${recipient}
submission inet n       -       -       -       -       smtpd
  -o smtpd_enforce_tls=yes
  -o smtpd_tls_security_level=encrypt
  -o smtpd_client_restrictions=permit_sasl_authenticated,reject
EOF
#Writing /etc/postfix/mysql_virtual_alias_maps.cf
cat > mysql_virtual_alias_maps.cf <<EOF
hosts = localhost
user = postfix
password = MYSQLPW
dbname = postfixdb
query = SELECT goto FROM alias WHERE address='%s' AND active = '1'
EOF
#Writing /etc/postfix/mysql_virtual_mailbox_maps.cf
cat > mysql_virtual_mailbox_maps.cf <<EOF
hosts = localhost
user = postfix
password = MYSQLPW
dbname = postfixdb
query = SELECT maildir FROM mailbox WHERE username='%s' AND active = '1'
EOF
#Writing /etc/postfix/mysql_sender_login_maps.cf
cat > mysql_sender_login_maps.cf <<EOF
hosts = localhost
user = postfix
password = MYSQLPW
dbname = postfixdb
query = SELECT username AS allowedUser FROM mailbox WHERE username="%s" AND active = 1 UNION SELECT goto FROM alias WHERE address="%s" AND active = 1
EOF
#Writing /etc/postfix/mysql_virtual_domains_maps.cf
cat > mysql_virtual_domains_maps.cf <<EOF
hosts = localhost
user = postfix
password = MYSQLPW
dbname = postfixdb
query = SELECT domain FROM domain WHERE domain='%s' AND active = '1'
EOF
#change rights
cd /etc/postfix
chmod o-rwx,g+r mysql_*
chgrp postfix mysql_*
mv /etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf.sample
cat > /etc/dovecot/dovecot.conf <<EOF
auth_mechanisms = plain login
log_timestamp = "%Y-%m-%d %H:%M:%S "
passdb {
  args = /etc/dovecot/dovecot-mysql.conf
  driver = sql
}
namespace inbox {
  inbox = yes
  location =
  separator = .
  prefix =
  mailbox Drafts {
    auto = subscribe
    special_use = \Drafts
  }
  mailbox Sent {
    auto = subscribe
    special_use = \Sent
  }
  mailbox Trash {
    auto = subscribe
    special_use = \Trash
  }
  mailbox Junk {
    auto = subscribe
    special_use = \Junk
  }
}
protocols = imap pop3
service auth {
  unix_listener /var/spool/postfix/private/auth_dovecot {
    group = postfix
    mode = 0660
    user = postfix
  }
  unix_listener auth-master {
    mode = 0600
    user = vmail
  }
  user = root
}
listen = *
ssl_cert = </etc/postfix/sslcert/mailserver.crt
ssl_key = </etc/postfix/sslcert/mailserver.key
ssl_min_protocol = !SSLv3
ssl_cipher_list = EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH:+CAMELLIA256:+AES256:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!ECDSA:CAMELLIA256-SHA:AES256-SHA:CAMELLIA128-SHA:AES128-SHA
userdb {
  args = /etc/dovecot/dovecot-mysql.conf
  driver = sql
}
protocol pop3 {
  pop3_uidl_format = %08Xu%08Xv
}
protocol lda {
  auth_socket_path = /var/run/dovecot/auth-master
  postmaster_address = postmaster@mailserver.com
}
EOF
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
