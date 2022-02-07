#!/bin/bash

# Start programs
service ssh start
service mysql start
service nginx start

# Waiting for network configuration
IP=$(hostname -I)
until [ ! -z $IP ]; do
IP=$(hostname -I)
echo "Waiting for network configuration"
sleep 1
done 

# Finish seafile configuration
cd /opt/seafile-server-7.1.5/
## Correction on python script to avoid stopping container execution when asking for password
sed -i 's/password = Utils.ask_question(question, key=key, password=True)/password = \"Password123\"/1' setup-seafile-mysql.py
## Config Seafile
echo 'Found host IP '"$IP"
chmod +x setup-seafile-mysql.sh
echo -e '\nseafileserver\n'"$IP"'\n8082\n2\nlocalhost\n3306\nseafile\nccnet-db\nseafile-db\nseahub-db\n' | ./setup-seafile-mysql.sh
#chown -R seafile:seafile /opt/seafile-server-latest
#chown -R seafile:seafile /opt/seafile-data
#chown -R seafile:seafile /opt/ccnet
#chown -R seafile:seafile /opt/seahub-data
#chown -R seafile:seafile /opt/conf
mkdir /opt/logs
#chown -R seafile:seafile /opt/logs
mkdir /opt/pids
#chown -R seafile:seafile /opt/pids
## Config nginx
sed -i 's/replacehere/'"$IP"'/g' /etc/nginx/conf.d/seafile.conf
service nginx restart

# Seafile start
#sudo su - seafile
cd /opt/seafile-server-latest
./seafile.sh start
## Correction on python script to avoid stopping container execution when asking for password
sed -i "s/key = 'admin password'/return 'Password123'/1" check_init_admin.py
echo -e 'alexandreamk1@gmail.com' | ./seahub.sh start

# Must login on seafile server in order to create a user folder to enable synchronizing with clients
cd /root
mkdir -pv /root/sea /root/seafile-client
until test -e /root/.ccnet
do
seaf-cli init -d /root/seafile-client -c /root/.ccnet
done
until seaf-cli config -k disable_verify_certificate -v true -c /root/.ccnet
do
seaf-cli start -c /root/.ccnet
done
seaf-cli config -k enable_http_sync -v true -c /root/.ccnet 
seaf-cli stop -c /root/.ccnet
seaf-cli start -c /root/.ccnet
chown -R mininet:mininet /root/sea/ /root/seafile-client/ /root/.ccnet
seaf-cli create -n cidds -s http://192.168.50.1 -u alexandreamk1@gmail.com -p Password123 > /home/seafolder
SEAFOLDER=$(cat /home/seafolder)
if [ ! -z $SEAFOLDER ]; then 
echo "Seafolder successfully created with ID "$SEAFOLDER;
fi

# Keep alive
tail -f /dev/null