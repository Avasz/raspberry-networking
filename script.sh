#!/bin/bash
#Description: This script will help you to forward your internet connection made by mobile tethering to ethernet in raspberry pi.
#May work in other ubuntu/debian systems too.
#Copyleft (ɔ) Avasz <avashmulmi@gmail.com>
#Anyone is free to use and reuse and modify and distribute the script.
apt-get update
apt-get -y install isc-dhcp-server

ip_lan="172.18.0.1"
netmask="255.255.255.0"
subnet="172.18.0.0"
ip_range_start="172.18.0.2"
ip_range_end="172.18.0.200"
lan_iface="eth0"
teth_iface="usb0"

echo"
	auto lo $lan_iface
		iface lo inet loopback
	iface $lan_iface inet static
		address $ip_lan
		netmask $netmask
	
	auto $teth_iface
	iface $teth_iface inet dhcp
	
	up iptables-restore < /etc/iptables.ipv4.nat
" > /etc/network/interfaces

echo "
	option domain-name \"raspberry\";
	option domain-name-servers 8.8.8.8, 8.8.4.4;
	subnet $subnet netmask $neetmask {
		range $ip_range_start $ip_range_end;
		option routers $ip_lan;
	}
" > /etc/dhcp/dhcpd.conf

echo "INTERFACES=\"$lan_iface\"" > /etc/default/isc-dhcp-server
service isc-dhcp-server restart
update-rc.d isc-dhcp-server enable

 echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
 echo "1" > /proc/sys/net/ipv4/ip_forward
 iptables -t nat -A POSTROUTING -o $wifid -j MASQUERADE
 iptables -A FORWARD -i $wifid -o $land -m state --state RELATED,ESTABLISHED -j ACCEPT
 iptables -A FORWARD -i $land -o $wifid -j ACCEPT
 iptables-save > /etc/iptables.ipv4.nat

sed -i '13iifup $lan_iface' /etc/rc.local
sed -i '14iifup $teth_iface' /etc/rc.local
sed -i '15i/etc/init.d/isc-dhcp-server start' /etc/rc.local

clear

echo "Complete!!!"
