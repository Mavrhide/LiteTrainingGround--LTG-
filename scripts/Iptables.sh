#!/bin/bash

sudo iptables -L > /dev/null

sudo iptables -F FORWARD
sudo iptables -A FORWARD -s 10.0.10.30 -d 10.0.20.30 -p tcp --dport 443 -j ACCEPT
sudo iptables -A FORWARD -p tcp -d 10.0.10.30 --dport 80 -j ACCEPT
sudo iptables -A FORWARD -p tcp -d 10.0.20.30 --dport 80 -j ACCEPT
sudo iptables -A FORWARD -p icmp --icmp-type echo-request -m limit --limit 5/sec --limit-burst 10 -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport 22 -j DROP
sudo iptables -P FORWARD DROP
