#!/bin/bash
echo '== STARTING WIREGUARD PEER CONFIGURATION =='
hasModule=$(modinfo wireguard)

while [[ $(echo $hasModule | grep -o 'ERROR') == 'ERROR' ]];do
    echo 'WireGuard not installed. Run wireguard-autoconfig.sh first.'
    exit 1
    break;
done

hasSettings=$(ls /etc/wireguard/settings/peer.next)

while [[ $hasSettings != '/etc/wireguard/settings/peer.next' ]];do
    echo 'Script config not found. Run wireguard-autoconfig.sh first.'
    exit 1
    break;
done

cd /etc/wireguard

peerNum=$(cat settings/peer.next)
echo $(($peerNum + 1)) > settings/peer.next

mkdir peer${peerNum}
cd peer${peerNum}

echo '== GENERATING KEYPAIR =='
umask 077
wg genkey | tee privatekey | wg pubkey > publickey
cat << EOF > peer.conf
[Interface]
PrivateKey = REF_PEER_KEY
Address = REF_PEER_ADDRESS
DNS = REF_PEER_DNS

[Peer]
PublicKey = REF_SERVER_PUBLIC_KEY
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = REF_SERVER_ENDPOINT
EOF
external_ip=$(curl ipinfo.io/ip)
server_endpoint="$external_ip:$(cat ../settings/port)"
ipv4_peer_addr="$(cat ../settings/ipv4)${peerNum}/24"
ipv6_peer_addr="$(cat ../settings/ipv6):${peerNum}/64"
dns="$(cat ../settings/ipv4)1, $(cat ../settings/ipv6):1"

echo '== SETTING PEER CONFIGURATION =='
sed -i "s;REF_PEER_KEY;$(cat privatekey);g" peer.conf
sed -i "s;REF_PEER_ADDRESS;$ipv4_peer_addr, $ipv6_peer_addr;g" peer.conf
sed -i "s;REF_PEER_DNS;$dns;g" peer.conf
sed -i "s;REF_SERVER_PUBLIC_KEY;$(cat ../publickey);g" peer.conf
sed -i "s;REF_SERVER_ENDPOINT;$server_endpoint;g" peer.conf

wg-quick down wg0

echo '== UPDATING SERVER CONFIGURATION =='
cat << EOF >> ../wg0.conf

[Peer]
PublicKey = REF_PEER_PUBLIC_KEY
AllowedIPs = REF_PEER_IPS
EOF
allowed_ips="$(cat ../settings/ipv4)${peerNum}/32, $(cat ../settings/ipv6):${peerNum}/128"
sed -i "s;REF_PEER_PUBLIC_KEY;$(cat publickey);g" ../wg0.conf
sed -i "s;REF_PEER_IPS;$allowed_ips;g" ../wg0.conf

wg-quick up wg0

cat peer.conf | qrencode --type utf8
