#!/bin/bash
echo '== STARTING WIREGUARD SERVER CONFIGURATION =='
hasModule=$(modinfo wireguard)

while [[ $(echo $hasModule | grep -o 'ERROR') == 'ERROR' ]];do
    echo '== ATTEMPING TO INSTALL WIREGUARD =='
    sudo dnf install -y wireguard-tools qrencode
cat << EOF >> /etc/sysctl.conf
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF
    break;
done

hasConf=$(ls /etc/wireguard)
while [[ $(echo $hasConf | grep -o 'wg0.conf') == 'wg0.conf' ]];do
    echo 'wg0.conf already exists, exiting.'
    exit 0
    break;
done

cd /etc/wireguard

echo '== GENERATING KEYPAIR =='
umask 077
wg genkey | tee privatekey | wg pubkey > publickey
cat << EOF > wg0.conf
[Interface]
PrivateKey = REF_SERVER_KEY
Address = REF_SERVER_ADDRESS
ListenPort = REF_SERVER_PORT
SaveConfig = true
PostUp = /etc/wireguard/helper/add-nat-routing.sh
PostDown = /etc/wireguard/helper/remove-nat-routing.sh
EOF
mkdir settings
echo "2" > settings/peer.next
echo '== ENTER WIREGUARD SERVER DETAILS =='
read -p "External WireGuard Port(e.g 51820):" server_port
echo $server_port > settings/port
read -p "Internal Server IPv4 Address(e.g 172.16.16.1):" ipv4_server_addr
ipv4_server_addr="$ipv4_server_addr/24"
echo $ipv4_server_addr > settings/ipv4
sed -i 's;1/24;;g' settings/ipv4

echo '== DETERMINING IPV6 ADDRESS FROM DATE AND MACHINE ID =='
ipv6_server_addr="fd$(printf $(date +%s%N)$(cat /var/lib/dbus/machine-id) | sha1sum | tr -d ' -' | cut -c 31-)"
ipv6_server_addr="$(echo $ipv6_server_addr | sed -r 's/.{4}/&:/g')"
echo $ipv6_server_addr > settings/ipv6
ipv6_server_addr="$ipv6_server_addr:1/64"

echo '== SETTING CONFIGURATION =='
sed -i "s;REF_SERVER_KEY;$(cat privatekey);g" wg0.conf
sed -i "s;REF_SERVER_ADDRESS;$ipv4_server_addr, $ipv6_server_addr;g" wg0.conf
sed -i "s;REF_SERVER_PORT;$server_port;g" wg0.conf
