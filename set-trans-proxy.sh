#!/bin/bash

gid=`id -g proxy`
# iptables -t nat -A OUTPUT -p tcp --dport 80 -m owner --gid-owner 0  -j ACCEPT
iptables -t nat -A OUTPUT -p tcp --dport 80 -m owner --gid-owner $gid -j ACCEPT
iptables -t nat -A OUTPUT -p tcp --dport 80 -j DNAT --to-destination 192.168.178.38:3127
# iptables-save > /etc/iptables/iptables.rules
iptables -t nat -A OUTPUT -p tcp --dport 443 -m owner --gid-owner $gid -j ACCEPT
iptables -t nat -A OUTPUT -p tcp --dport 443 -j DNAT --to-destination 192.168.178.38:3129
