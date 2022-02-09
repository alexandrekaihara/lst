#!/bin/bash

# Start services
service mysql start
service postfix start
service apache2 start
service dovecot start
service ssh start
service cron start

# Restore postfix database configuration and data
#mysql -uroot --password=PWfMS2015 -e "create database postfixdb;"
mysql -uroot --password=PWfMS2015 postfixdb < /tmp/mailsetup/postfixdb.sql

# Keep alive
tail -f /dev/null
#/bin/bash