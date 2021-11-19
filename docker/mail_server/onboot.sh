#!/bin/bash
# Start smbd
service mysql start
service postfix start
service apache2 start
service dovecot start
/bin/bash