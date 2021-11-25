#!/bin/bash
# Start smbd
service mysql start
service postfix start
service apache2 start
service dovecot start

# Restore postfix database configuration and data
mysql -uroot --password=PWfMS2015 postfixdb < /tmp/mailsetup/postfixdb.sql

/bin/bash