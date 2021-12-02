# wireguard-oracle-cloud-install
Wireguard VPN setup for Oracle Cloud Instances  
Oracle Cloud instances need some additional configuration to be able to complete handshake. You must follow this steps to install wireguard vpn to oracle cloud instance. 

```bash
curl -O https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
chmod +x wireguard-install.sh
./wireguard-install.sh

sudo cd /etc/wireguard/
sudo mkdir helper
sudo nano /etc/wireguard/helper/add-nat-routing.sh

```

## add-nat-routing.sh
Set primary network interface to IN_FACE  
Set wireguard port to WG_PORT
```bash
#!/bin/bash
IPT="/sbin/iptables"
IPT6="/sbin/ip6tables"

IN_FACE="PUT PRIMARY NETWORK INTERFACE (example: enp0s3)"                   # NIC connected to the internet
WG_FACE="wg0"                    # WG NIC
SUB_NET="10.66.66.0/24"          # WG IPv4 sub/net aka CIDR
WG_PORT="SET YOUR WIREGUARD PORT"                  # WG udp port
SUB_NET_6="fd42:42:42::/64"      # WG IPv6 sub/net

## IPv4 ##
$IPT -t nat -I POSTROUTING 1 -s $SUB_NET -o $IN_FACE -j MASQUERADE
$IPT -I INPUT 1 -i $WG_FACE -j ACCEPT
$IPT -I FORWARD 1 -i $IN_FACE -o $WG_FACE -j ACCEPT
$IPT -I FORWARD 1 -i $WG_FACE -o $IN_FACE -j ACCEPT
$IPT -I INPUT 1 -i $IN_FACE -p udp --dport $WG_PORT -j ACCEPT

## IPv6 (Uncomment) ##
$IPT6 -t nat -I POSTROUTING 1 -s $SUB_NET_6 -o $IN_FACE -j MASQUERADE
$IPT6 -I INPUT 1 -i $WG_FACE -j ACCEPT
$IPT6 -I FORWARD 1 -i $IN_FACE -o $WG_FACE -j ACCEPT
$IPT6 -I FORWARD 1 -i $WG_FACE -o $IN_FACE -j ACCEPT
```
CTRL+X to save and exit

## remove-nat-routing.sh
```bash
sudo nano /etc/wireguard/helper/remove-nat-routing.sh
```
Set primary network interface to IN_FACE  
Set wireguard port to WG_PORT
```bash
#!/bin/bash
IPT="/sbin/iptables"
IPT6="/sbin/ip6tables"

IN_FACE="PUT PRIMARY NETWORK INTERFACE (example: enp0s3)"                   # NIC connected to the internet
WG_FACE="wg0"                    # WG NIC
SUB_NET="10.66.66.0/24"          # WG IPv4 sub/net aka CIDR
WG_PORT="SET YOUR WIREGUARD PORT"                  # WG udp port
SUB_NET_6="fd42:42:42::/64"      # WG IPv6 sub/net

# IPv4 rules #
$IPT -t nat -D POSTROUTING -s $SUB_NET -o $IN_FACE -j MASQUERADE
$IPT -D INPUT -i $WG_FACE -j ACCEPT
$IPT -D FORWARD -i $IN_FACE -o $WG_FACE -j ACCEPT
$IPT -D FORWARD -i $WG_FACE -o $IN_FACE -j ACCEPT
$IPT -D INPUT -i $IN_FACE -p udp --dport $WG_PORT -j ACCEPT

# IPv6 rules (uncomment) #
$IPT6 -t nat -D POSTROUTING -s $SUB_NET_6 -o $IN_FACE -j MASQUERADE
$IPT6 -D INPUT -i $WG_FACE -j ACCEPT
$IPT6 -D FORWARD -i $IN_FACE -o $WG_FACE -j ACCEPT
$IPT6 -D FORWARD -i $WG_FACE -o $IN_FACE -j ACCEPT
```
CTRL+X to save and exit

## Edit wireguard configuration
```bash
sudo nano /etc/wireguard/wg0.conf
```
Change these lines
```bash
PostUp = /etc/wireguard/helper/add-nat-routing.sh
PostDown = /etc/wireguard/helper/remove-nat-routing.sh
```

## Start wireguard vpn
```bash
sudo wg-quick down wg0
sudo wg-quick up wg0
```

You are ready to connect with configuration file
