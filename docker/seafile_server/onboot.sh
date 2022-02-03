#!/bin/bash

# Start programs
service ssh start
service mysql start
service nginx start

# Wait for the internet connection
until ping -c 1 google.com
do
echo "Waiting to stablish connection to setup machine"
sleep 1
done 

# Finish configuration
IP=$(ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p')
## Gambiarra para fazer com que o input da senha nao interrompa a configuração do docker
cd /opt/seafile-server-7.1.5/
sed -i 's/password = Utils.ask_question(question, key=key, password=True)/password = \"Password123\"/1' setup-seafile-mysql.py
## Config Seafile
echo -e '\nseafileserver\n'"$IP"'\n8082\n2\nlocalhost\n3306\nseafile\nccnet-db\nseafile-db\nseahub-db\n' | . setup-seafile-mysql.sh
chown -R seafile:seafile /opt/seafile-server-latest
chown -R seafile:seafile /opt/seafile-data
chown -R seafile:seafile /opt/ccnet
chown -R seafile:seafile /opt/seahub-data
chown -R seafile:seafile /opt/conf
mkdir /opt/logs
chown -R seafile:seafile /opt/logs
mkdir /opt/pids
chown -R seafile:seafile /opt/pids
## Config nginx
sed -i 's/replacehere/'"$IP"'/g' /etc/nginx/conf.d/seafile.conf
service nginx restart

# Seafile start
sudo su - seafile
cd /opt/seafile-server-latest
./seafile.sh start
echo -e 'alexandreamk1@gmail.com\nPassword123\nPassword123\n' | ./seahub.sh start

# Keep alive
tail -f /dev/null