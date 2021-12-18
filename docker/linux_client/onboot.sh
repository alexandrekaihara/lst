#!/bin/bash
# Generate dummy files for seafile
mkdir -pv /home/debian/tmpseafiles
i=0
while [ $i -le 100 ]
do
  i=`expr $i + 1`;
  zufall=$RANDOM;
  zufall=$(($zufall % 9999))
  dd if=/dev/zero of=/home/debian/tmpseafiles/test-`expr $zufall`.dat bs=1K count=`expr $zufall`
done

# Configure printer 
/etc/init.d/cups start
# Use instead this command, needs to specify the host https://www.thegeekstuff.com/2015/01/lpadmin-examples/
## Returns the printer ip to be configured from serverconfig.ini file
cd /home/debian/automation/packages/system
until printerip=`cat printerip`
do
    python3 getprinterip.py
done
lpadmin -p PDF -v socket://$printerip -E
/etc/init.d/cups restart

# Configure Seafile
mkdir -pv /home/debian/sea /home/debian/seafile-client
until test -e /home/debian/.ccnet
do
seaf-cli init -d /home/debian/seafile-client -c /home/debian/.ccnet
done
until seaf-cli config -k disable_verify_certificate -v true -c /home/debian/.ccnet
do
seaf-cli start -c /home/debian/.ccnet
done
seaf-cli config -k enable_http_sync -v true -c /home/debian/.ccnet
seaf-cli stop -c /home/debian/.ccnet
seaf-cli start -c /home/debian/.ccnet
chown -R mininet:mininet /home/debian/sea/ /home/debian/seafile-client/ /home/debian/.ccnet

# Keep alive
cd /home/debian/automation
python3 readIni.py
#/bin/bash