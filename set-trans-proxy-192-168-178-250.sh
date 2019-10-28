#!/bin/bash

gid=`id -g proxy`
ip="192.168.178.84"
# iptables -t nat -A OUTPUT -p tcp --dport 80 -m owner --gid-owner 0  -j ACCEPT
# iptables -t nat -A OUTPUT -p tcp --dport 80 -m owner --gid-owner $gid -j ACCEPT
sudo iptables -t nat -A OUTPUT -p tcp --dport 80 -j DNAT --to-destination $ip:3128
# iptables-save > /etc/iptables/iptables.rules
# iptables -t nat -A OUTPUT -p tcp --dport 443 -m owner --gid-owner $gid -j ACCEPT
iptables -t nat -A OUTPUT -p tcp --dport 443 -j DNAT --to-destination $ip:3129
