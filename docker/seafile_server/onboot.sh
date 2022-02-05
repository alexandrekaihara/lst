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

# DB Setup (mariadb)
service mysql start
echo -e 'rootpassword\nn\nY\nY\nY\nY\n' | mysql_secure_installation
mysql -u root --password=123 -e 'create database `ccnet-db` character set = 'utf8';'
mysql -u root --password=123 -e 'create database `seafile-db` character set = 'utf8';'
mysql -u root --password=123 -e 'create database `seahub-db` character set = 'utf8';'
mysql -u root --password=123 -e 'create user 'seafile'@'localhost';'
mysql -u root --password=123 -e 'set password for 'seafile'@'localhost' = password("Password123");'
mysql -u root --password=123 -e 'GRANT ALL PRIVILEGES ON `ccnet-db`.* to `seafile`@localhost;'
mysql -u root --password=123 -e 'GRANT ALL PRIVILEGES ON `seafile-db`.* to `seafile`@localhost;'
mysql -u root --password=123 -e 'GRANT ALL PRIVILEGES ON `seahub-db`.* to `seafile`@localhost;'
mysql -u root --password=123 -e 'FLUSH PRIVILEGES;'

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
python3 /home/login_seafile_page.py
mysql -uroot --password=Password123 -e "USE seafile-db; SELECT * FROM RepoOwner" | grep alexandreamk1@gmail.com > /home/seafolder
sed -i "s/2\t//1" /home/seafolder
sed -i "s/\talexandreamk1@gmail.com//1" /home/seafolder
SEAFOLDER=$(cat /home/seafolder)
if [ ! -z $SEAFOLDER ]; then echo "Seafolder successfully created with ID "$SEAFOLDER; fi

# Keep alive
tail -f /dev/null