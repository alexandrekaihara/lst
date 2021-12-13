#!/bin/bash7

# https://serverfault.com/questions/453254/routing-between-two-networks-on-linux
# Enable forwading rules
sysctl -w net.ipv4.ip_forward=1
iptables -A FORWARD -i eth0 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth2 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth3 -j ACCEPT

# Always accept loopback traffic
iptables -A INPUT -i lo -j ACCEPT

# We allow traffic from the LAN side
iptables -A INPUT -i eth0 -j ACCEPT

# Enable masquerading
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
