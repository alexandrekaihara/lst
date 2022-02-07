#!/bin/bash

# Create user on machine for seafile-cli
useradd -m -s /bin/bash mininet
echo "mininet:mininet" | chpasswd
usermod -a -G sudo mininet

# Create seafile user 
echo -e 'rootpassword\nrootpassword' | passwd root
useradd -m -s /bin/bash seafile
echo -e '123\n123' | passwd seafile
# ERROR Username is not in the sudoers file https://unix.stackexchange.com/questions/179954/username-is-not-in-the-sudoers-file-this-incident-will-be-reported 
adduser seafile sudo
chmod  0440  /etc/sudoers
#reboot

# Se der problema de protocol not supported https://techglimpse.com/nginx-error-address-family-solution/
sed -i "s/listen \[\:\:\]\:80 default_server;/#listen \[\:\:\]\:80 default_server;/g" /etc/nginx/sites-enabled/default
service nginx start

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

# Seafile Setup 
wget O /var/eafile-server_7.1.5_x86-64.tar.gz https://s3.eu-central-1.amazonaws.com/download.seadrive.org/seafile-server_7.1.5_x86-64.tar.gz
tar xzvf seafile-server_7.1.5_x86-64.tar.gz -C /opt
rm -rf /opt/seafile-server_7.1.5_x86-64.tar.gz
chown -R seafile:seafile /opt/seafile-server-7.1.5

# Change server name to the right ip address
cat > /etc/nginx/conf.d/seafile.conf << \EOF
server {
    #listen [::]:80;
    listen 80;
    server_name  replacehere;
    autoindex off;
    client_max_body_size 100M;
    access_log /var/log/nginx/seafile.com.access.log;
    error_log /var/log/nginx/seafile.com.error.log;

     location / {
            proxy_pass         http://127.0.0.1:8000;
            proxy_set_header   Host $host;
            proxy_set_header   X-Real-IP $remote_addr;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header   X-Forwarded-Host $server_name;
            proxy_read_timeout  1200s;
        }

     location /seafhttp {
            rewrite ^/seafhttp(.*)$ $1 break;
            proxy_pass http://127.0.0.1:8082;
            proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_connect_timeout  36000s;
            proxy_read_timeout  36000s;
            proxy_send_timeout  36000s;
            send_timeout  36000s;
        }

    location /media {
            root /opt/seafile-server-latest/seahub;
        }
}
EOF