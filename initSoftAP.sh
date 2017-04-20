#!/bin/bash
#Initial wifi interface configuration
sudo ip link set  $1 up 
sudo ip addr add 10.0.0.1/24 dev $1
#10.0.0.1 netmask 255.255.255.0
sleep 5
###########Start DHCP, comment out / add relevant section##########
#Doesn't try to run dhcpd when already running
if [ "$(ps -e | grep dhcpd)" == "" ]; then
dhcpd $1 &
fi
###########
#Enable NAT
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
iptables --table nat --append POSTROUTING --out-interface $2 -j MASQUERADE
iptables --append FORWARD --in-interface $1 -j ACCEPT
 
#Uncomment the line below if facing problems while sharing PPPoE
#iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
 
sysctl -w net.ipv4.ip_forward=1
#start hostapd
hostapd /etc/hostapd/hostapd.conf 1>/dev/null
killall dhcpd
