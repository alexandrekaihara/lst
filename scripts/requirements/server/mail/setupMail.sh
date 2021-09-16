#!/bin/bash
rm /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime

mkdir /tmp/mailsetup
cd /tmp/mailsetup
wget 192.168.56.101/scripts/requirements/server/mail/mailserver.sh
wget 192.168.56.101/scripts/requirements/server/mail/genDomain.sh -O /tmp/mailsetup/genDomain.sh
wget 192.168.56.101/scripts/requirements/server/mail/genUser.sh -O /tmp/mailsetup/genUser.sh
source mailserver.sh
