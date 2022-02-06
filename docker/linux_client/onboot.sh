#!/bin/bash

# Waiting for network configuration
IP=$(hostname -I)
until [ ! -z $IP ]; do
IP=$(hostname -I)
echo "Waiting for network configuration"
sleep 1
done 

# Open Brackets to send all outputs into a log file
{

# Update the automation directory
until unzip -o main.zip -d /home/debian
do
  wget https://github.com/mdewinged/cidds/archive/refs/heads/main.zip --no-check-certificate
done
rm main.zip 
mv /home/debian/cidds-main/scripts/automation /home/debian/
chmod -R 755 /home/debian/automation
rm -r /home/debian/cidds-main

# Move all configure files received
mv /home/debian/printerip        /home/debian/automation/packages/system/printerip   
mv /home/debian/config.ini       /home/debian/automation/packages/system/config.ini
mv /home/debian/serverconfig.ini /home/debian/automation/packages/system/serverconfig.ini
    
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
printerip=`cat printerip` 
if [ ! "$printerip" = "0.0.0.0" ]; then 
  lpadmin -p PDF -v socket://$printerip -E
  /etc/init.d/cups restart
fi

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

} > '/home/debian/log/'"$IP"'_onboot.log'

# add PATH to geckodriver for browsing.py to use Selenium
export PATH="$PATH:/opt/"

# Keep alive
cd /home/debian/automation
python3 readIni.py >> '/home/debian/log/'"$IP"'_onboot.log'
