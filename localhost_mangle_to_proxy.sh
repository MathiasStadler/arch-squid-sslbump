#/bin/bash


SQUIDURL="192.168.178.250"

iptables -t mangle -A PREROUTING -j ACCEPT -p tcp --dport 80 -s $SQUIDURL
iptables -t mangle -A PREROUTING -j ACCEPT -p tcp --dport 443 -s $SQUIDURL
iptables -t mangle -A OUTPUT -j MARK --set-mark 3 -p tcp --dport 80
iptables -t mangle -A OUTPUT -j MARK --set-mark 3 -p tcp --dport 443
ip rule add fwmark 3 table 2
ip route add default via $SQUIDURL dev enp0s25  table 2
ip route show table 2
ip route flush cache

sysctl -w net.ipv4.ip_forward=1
sysctl net.ipv4.ip_forward
