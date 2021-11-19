#!/bin/bash

# Update
apt-get update
apt-get upgrade

# Install sudo e apt-utils
apt-get install -y apt-utils=2.0.6 sudo 

# Solve problems on installing cups:
## 1.0 Dialog not found
apt-get install dialog=1.3-20190808-1 -y
## 1.1 Policy-rc.d not permit start process on reboot
printf '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d
## 1.2 Failed to create symbolic link em /etc/resolv.conf https://stackoverflow.com/questions/40877643/apt-get-install-in-ubuntu-16-04-docker-image-etc-resolv-conf-device-or-reso
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections
apt-get update
apt-get install -y --no-install-recommends resolvconf=1.82
