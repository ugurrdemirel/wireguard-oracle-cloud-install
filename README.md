# WireGuard for Oracle Cloud

Wireguard VPN Setup for Oracle Cloud Instances  
Oracle Cloud instances need some additional configuration to get WireGuard up and running as expected. Here is how we do that:

## Please Note: 
- The wireguard kernel mod ships with the latest Ubuntu image on Oracle Cloud.
- The image used for testing is Ubuntu 22.04 Minimal aarch64
- All scripts must be run as root.

## Installation
Install dependencies:
```bash
sudo apt-get update && sudo apt-get install -y wireguard qrencode resolvconf git
```

Continue as root:
```bash
sudo su
```
Download and install our scripts ( Huge thanks to [@vaughngx4](https://github.com/vaughngx4)):
```bash
cd /etc/wireguard
git clone https://github.com/ugurrdemirel/wireguard-oracle-cloud-install.git
mv wireguard-oracle-cloud-install/* ./
rm -rf wireguard-oracle-cloud-install
```

Generate the config(follow the prompts, this will not start the server):
```bash
./wireguard-autoconfig.sh
```

A reboot is needed at this point. Answer 'y' to the reboot prompt to reboot.

Once you've reconnected to the instance, add a peer and start the server:
```bash
sudo su
cd /etc/wireguard
./add-peer.sh
```

You can use the qr code that is ouput to the terminal or copy the configuration from `/etc/wireguard/peerX`('X' being the peer number). The `add-peer.sh` script will automatically restart the server to apply changes. To add another peer, simply run the script again. Peer configs can found in folders inside `/etc/wireguard/` starting with folder name `peer2`(the peer number corresponds with the peer's IP address).

That's it, you can now connect to the vpn using the auto generated configs :)
