#!/bin/bash
sudo iptables -F FORWARD

sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

sudo iptables -A FORWARD -s 10.0.10.30 -d 10.0.20.30 -p tcp --dport 443 -j ACCEPT
sudo iptables -A FORWARD -p tcp -d 10.0.10.30 --dport 80 -j ACCEPT
sudo iptables -A FORWARD -p tcp -d 10.0.20.30 --dport 80 -j ACCEPT

sudo iptables -A FORWARD -s 10.0.10.0/24 -d 10.0.40.10 -p tcp -m multiport --dports 1514,1515 -j ACCEPT
sudo iptables -A FORWARD -s 10.0.20.0/24 -d 10.0.40.10 -p tcp -m multiport --dports 1514,1515 -j ACCEPT
sudo iptables -A FORWARD -s 10.0.30.0/24 -d 10.0.40.10 -p tcp -m multiport --dports 1514,1515 -j ACCEPT

sudo iptables -A FORWARD -p icmp --icmp-type echo-request -m limit --limit 5/sec --limit-burst 10 -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport 22 -j DROP
sudo iptables -P FORWARD DROP
