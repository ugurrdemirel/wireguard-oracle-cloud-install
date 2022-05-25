#!/bin/bash
IPT="/sbin/iptables"
IPT6="/sbin/ip6tables"

IN_FACE="ens3"                                          # NIC connected to the internet
WG_FACE="wg0"                                           # WG NIC
SUB_NET="$(cat /etc/wireguard/settings/ipv4)0/24"       # WG IPv4 sub/net aka CIDR
WG_PORT="$(cat /etc/wireguard/settings/port)"           # WG udp port
SUB_NET_6="$(cat /etc/wireguard/settings/ipv6):/64"     # WG IPv6 sub/net

# IPv4 rules #
$IPT -t nat -D POSTROUTING -s $SUB_NET -o $IN_FACE -j MASQUERADE
$IPT -D INPUT -i $WG_FACE -j ACCEPT
$IPT -D FORWARD -i $IN_FACE -o $WG_FACE -j ACCEPT
$IPT -D FORWARD -i $WG_FACE -o $IN_FACE -j ACCEPT
$IPT -D INPUT -i $IN_FACE -p udp --dport $WG_PORT -j ACCEPT

# IPv6 rules #
$IPT6 -t nat -D POSTROUTING -s $SUB_NET_6 -o $IN_FACE -j MASQUERADE
$IPT6 -D INPUT -i $WG_FACE -j ACCEPT
$IPT6 -D FORWARD -i $IN_FACE -o $WG_FACE -j ACCEPT
$IPT6 -D FORWARD -i $WG_FACE -o $IN_FACE -j ACCEPT
